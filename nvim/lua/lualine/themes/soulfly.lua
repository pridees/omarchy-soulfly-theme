local p = require('soulfly.palette')
local function mode(accent)
  return {
    a = { fg = p.editor_background, bg = accent, gui = 'bold' },
    b = { fg = p.text, bg = p.tab_active_background },
    c = { fg = p.text_muted, bg = p.status_bar_background },
  }
end
return {
  normal = mode(p.accent),
  insert = mode(p.accent),
  visual = mode(p.accent),
  replace = mode(p.accent),
  command = mode(p.accent),
  inactive = { a = {fg=p.text_muted,bg=p.status_bar_background}, b = {fg=p.text_muted,bg=p.status_bar_background}, c = {fg=p.text_muted,bg=p.status_bar_background} },
}
