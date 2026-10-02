#!/usr/bin/env python3
"""Synchronize a color-only Zen stylesheet without creating browser profiles."""
import configparser
import os
from pathlib import Path
import shutil
import sys
import tempfile

IMPORT = '/* Soulfly managed import */\n@import url("omarchy-soulfly.css");\n'
PREF = ('// Soulfly managed stylesheet preference\n'
        'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);\n')
MARKER = '/* Managed by Soulfly Zen hook. */\n'


def read(path):
    return path.read_text() if path.exists() else ''


def safe(path):
    return not any(p.is_symlink() for p in (path, *path.parents))


def write(path, content):
    if read(path) == content:
        return
    backup = path.with_name(path.name + '.before-soulfly')
    if path.exists() and not backup.exists():
        # Exclusive backup: never overwrite an existing file or follow its symlink.
        with backup.open('x') as stream:
            stream.write(path.read_text())
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(prefix='.soulfly-', dir=path.parent)
    try:
        with os.fdopen(fd, 'w') as stream:
            stream.write(content)
        os.chmod(tmp, path.stat().st_mode & 0o777 if path.exists() else 0o600)
        os.replace(tmp, path)
    finally:
        if os.path.exists(tmp):
            os.unlink(tmp)


def sync_profile(profile, css, dry_run=False):
    chrome = profile / 'chrome'
    style = chrome / 'omarchy-soulfly.css'
    user_css = chrome / 'userChrome.css'
    user_js = profile / 'user.js'
    if not (profile / 'prefs.js').is_file():
        return 'skip: uninitialized profile'
    if not all(safe(p) for p in [profile, style, user_css, user_js]):
        return 'skip: symlinked profile or customization'
    if style.exists() and not read(style).startswith(MARKER):
        return 'skip: unmanaged stylesheet with the same name'
    if css is None:
        if style.exists() and not dry_run:
            write(style, MARKER + '/* No Zen theme in the active Omarchy theme. */\n')
        return 'disabled' if style.exists() else 'skip: no Zen theme'
    existing_css, existing_js = read(user_css), read(user_js)
    # Imports must precede rules; @charset must remain first.
    if IMPORT not in existing_css:
        if existing_css.lstrip('\ufeff').startswith('@charset'):
            index = existing_css.find(';') + 1
            if not index:
                return 'skip: malformed CSS charset'
            existing_css = existing_css[:index] + '\n' + IMPORT + existing_css[index:]
        else:
            existing_css = IMPORT + existing_css.lstrip('\ufeff')
    if PREF not in existing_js:
        existing_js += ('\n' if existing_js and not existing_js.endswith('\n') else '') + PREF
    if not dry_run:
        write(style, MARKER + css)
        write(user_css, existing_css)
        write(user_js, existing_js)
    return 'would update' if dry_run else 'synced (restart Zen to load CSS)'


def installed(home):
    return any(shutil.which(name) for name in ['zen-browser', 'zen', 'zen-browser-bin']) or any(
        p.exists() for p in [home / '.local/share/flatpak/app/app.zen_browser.zen/current',
                            Path('/var/lib/flatpak/app/app.zen_browser.zen/current')])


def main():
    home = Path.home()
    if not installed(home):
        return 0
    source = home / '.local/state/omarchy/current/theme/zen.css'
    css = read(source) if source.is_file() else None
    config = Path(os.environ.get('XDG_CONFIG_HOME', str(home / '.config')))
    roots = [config / 'zen', home / '.zen', home / '.var/app/app.zen_browser.zen/.zen',
             home / '.var/app/app.zen_browser.zen/config/zen']
    seen = set()
    for root in roots:
        ini = root / 'profiles.ini'
        if not ini.is_file() or not safe(ini):
            continue
        try:
            parser = configparser.ConfigParser(interpolation=None)
            parser.read(ini)
            for section in parser.sections():
                if not section.startswith('Profile') or not parser.has_option(section, 'Path'):
                    continue
                profile = Path(parser.get(section, 'Path'))
                if parser.get(section, 'IsRelative', fallback='1') == '1':
                    if profile.is_absolute() or '..' in profile.parts:
                        continue
                    profile = root / profile
                elif not profile.is_absolute():
                    continue
                if str(profile) in seen:
                    continue
                seen.add(str(profile))
                try:
                    result = sync_profile(profile, css, '--dry-run' in sys.argv)
                    print('Soulfly Zen: ' + result)
                except (OSError, UnicodeError) as error:
                    print('Soulfly Zen: profile skipped: ' + str(error), file=sys.stderr)
        except (OSError, UnicodeError, configparser.Error) as error:
            print('Soulfly Zen: profiles skipped: ' + str(error), file=sys.stderr)
    return 0


if __name__ == '__main__':
    sys.exit(main())
