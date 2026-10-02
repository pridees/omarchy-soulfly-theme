import importlib.util
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('zen_theme', Path(__file__).with_name('zen-theme.py'))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class ZenThemeTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.profile = Path(self.directory.name) / 'profile'
        self.profile.mkdir()
        (self.profile / 'prefs.js').write_text('// Existing browser preferences\n')

    def test_preserves_existing_customizations_and_is_idempotent(self):
        original = 'user_pref("layout.css.devPixelsPerPx", "1.8");\n'
        (self.profile / 'user.js').write_text(original)
        chrome = self.profile / 'chrome'
        chrome.mkdir()
        original_css = '@charset "UTF-8";\n#navigator-toolbox { color: pink; }\n'
        (chrome / 'userChrome.css').write_text(original_css)
        module.sync_profile(self.profile, ':root { color: tan; }')
        first = {p.relative_to(self.profile): p.read_bytes() for p in self.profile.rglob('*') if p.is_file()}
        module.sync_profile(self.profile, ':root { color: tan; }')
        self.assertEqual(first, {p.relative_to(self.profile): p.read_bytes() for p in self.profile.rglob('*') if p.is_file()})
        self.assertEqual((self.profile / 'user.js.before-soulfly').read_text(), original)
        self.assertEqual((chrome / 'userChrome.css.before-soulfly').read_text(), original_css)
        self.assertTrue((chrome / 'userChrome.css').read_text().startswith('@charset "UTF-8";'))
        self.assertIn(original, (self.profile / 'user.js').read_text())

    def test_dry_run_writes_nothing(self):
        module.sync_profile(self.profile, ':root {}', True)
        self.assertEqual([p.name for p in self.profile.iterdir()], ['prefs.js'])

    def test_uninitialized_profile_is_not_created(self):
        missing = self.profile / 'missing'
        self.assertIn('uninitialized', module.sync_profile(missing, ':root {}'))
        self.assertFalse(missing.exists())

    def test_no_browser_has_no_side_effects(self):
        with patch.object(module, 'installed', return_value=False), patch.object(module.Path, 'home', return_value=self.profile):
            self.assertEqual(module.main(), 0)
        self.assertEqual([p.name for p in self.profile.iterdir()], ['prefs.js'])

    def test_symlink_is_not_replaced_or_followed(self):
        outside = Path(self.directory.name) / 'outside.js'
        outside.write_text('unchanged')
        (self.profile / 'user.js').symlink_to(outside)
        self.assertIn('symlink', module.sync_profile(self.profile, ':root {}'))
        self.assertEqual(outside.read_text(), 'unchanged')
        self.assertFalse((self.profile / 'chrome').exists())

    def test_other_theme_disables_only_managed_css(self):
        module.sync_profile(self.profile, ':root { color: tan; }')
        user_js = (self.profile / 'user.js').read_text()
        module.sync_profile(self.profile, None)
        css = (self.profile / 'chrome/omarchy-soulfly.css').read_text()
        self.assertNotIn(':root', css)
        self.assertEqual((self.profile / 'user.js').read_text(), user_js)

    def test_existing_unmanaged_file_is_not_overwritten(self):
        chrome = self.profile / 'chrome'
        chrome.mkdir()
        (chrome / 'omarchy-soulfly.css').write_text('user owned')
        self.assertIn('unmanaged', module.sync_profile(self.profile, ':root {}'))
        self.assertEqual((chrome / 'omarchy-soulfly.css').read_text(), 'user owned')
        self.assertFalse((self.profile / 'user.js').exists())


if __name__ == '__main__':
    unittest.main()
