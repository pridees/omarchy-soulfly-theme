local p = require('soulfly.palette')
local function mode(accent)
  return {
    a = { fg = p.editor_background, bg = accent, gui = 'bold' },
    b = { fg = p.text, bg = p.tab_active_background },
    c = { fg = p.text_muted, bg = p.status_bar_background },
  }
end
return {
  normal = mode(p.syntax['function']),
  insert = mode(p.syntax.string),
  visual = mode(p.syntax.type),
  replace = mode(p.error),
  command = mode(p.syntax.keyword),
  inactive = { a = {fg=p.text_muted,bg=p.status_bar_background}, b = {fg=p.text_muted,bg=p.status_bar_background}, c = {fg=p.text_muted,bg=p.status_bar_background} },
}
