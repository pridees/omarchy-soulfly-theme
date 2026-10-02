-- Run from the repository root: nvim --headless -u NONE -l scripts/test-neovim.lua
local root = vim.fn.getcwd()
local source = vim.fn.readfile
local theme_name = 'soulfly'
vim.fn.readfile = function(path, ...)
  if path:match('/current/theme.name$') then return { theme_name } end
  if path:match('/current/theme/zed.json$') then return source(root .. '/zed.json') end
  return source(path, ...)
end
local s = vim.json.decode(table.concat(source(root .. '/zed.json'), '\n')).themes[1].style
local function flush() vim.wait(30, function() return false end) end
local function color(group, key, expected)
  local actual = vim.api.nvim_get_hl(0, { name = group, link = false })[key]
  assert(actual == tonumber(expected:sub(2), 16), group .. ' ' .. key)
end
dofile(root .. '/nvim/soulfly.lua')[1].config()
flush()
for group, token in pairs({
  Type='type', ['@lsp.type.interface']='type', ['@lsp.type.class']='type',
  ['@constructor.tsx']='type', ['@type.builtin']='type',
  ['@keyword.operator']='keyword', ['@keyword.import']='keyword', Include='keyword',
  ['@keyword.return']='keyword', ['@function.builtin']='function', Function='function',
  ['@variable.member']='property', String='string', Constant='constant',
  Comment='comment', LspInlayHint='hint',
}) do color(group, 'fg', s.syntax[token].color) end
color('Normal', 'bg', s['editor.background'])
color('NormalFloat', 'bg', s['elevated_surface.background'])
color('NeoTreeNormal', 'bg', s['panel.background'])
assert(vim.g.terminal_color_7 == s['terminal.ansi.white'])
assert(not vim.api.nvim_get_hl(0, { name='LspInlayHint' }).bold)
-- Restore surfaces after Omarchy's transparency pass.
vim.api.nvim_exec_autocmds('ColorScheme', {})
vim.api.nvim_set_hl(0, 'Normal', { fg='#ffffff' })
flush()
color('Normal', 'bg', s['editor.background'])
-- Do not repaint another active theme.
theme_name = 'other'
vim.api.nvim_set_hl(0, 'Normal', { fg='#123456', bg='#654321' })
vim.api.nvim_exec_autocmds('ColorScheme', {})
flush()
color('Normal', 'fg', '#123456')
color('Normal', 'bg', '#654321')
print('PASS: Zed parity, colorscheme reload, transparency ordering and other-theme isolation')
