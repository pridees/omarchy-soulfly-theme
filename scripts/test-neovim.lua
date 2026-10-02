-- Run from repository root: nvim --headless -u NONE -i NONE -l scripts/test-neovim.lua
local root = vim.fn.getcwd()
vim.opt.rtp:prepend(root .. '/nvim')
vim.opt.rtp:append(root .. '/nvim/after')
-- A native colorscheme must not read external palette files.
local readfile = vim.fn.readfile
vim.fn.readfile = function() error('Unexpected external palette read') end
vim.cmd.colorscheme('soulfly')
assert(vim.g.colors_name == 'soulfly')
vim.fn.readfile = readfile
local function color(group, field, expected)
  local actual = vim.api.nvim_get_hl(0, {name=group,link=false})[field]
  assert(actual == tonumber(expected:sub(2),16), group .. ': ' .. tostring(actual))
end
for _, g in ipairs({'Keyword','Include','zigVarDecl','zigExecution','@keyword','@keyword.import','@keyword.operator','@keyword.type'}) do
  color(g,'fg','#f49b62')
end
for _, g in ipairs({'Type','@type.builtin','@lsp.type.interface','@lsp.type.class'}) do color(g,'fg','#c792ff') end
color('Function','fg','#72bfff')
color('Comment','fg','#8a8e85')
color('LspInlayHint','fg','#7d817a')
color('Normal','bg','#090908')
color('NormalFloat','bg','#191917')
color('NeoTreeNormal','bg','#0f0f0e')
color('SnacksIndent','fg','#191917')
color('SnacksIndentScope','fg','#25231f')
assert(vim.g.terminal_color_7 == '#c0bfba')
-- Exercise the real stock Zig syntax, not just hand-picked highlight groups.
vim.cmd('filetype plugin on')
vim.cmd('syntax enable')
vim.api.nvim_buf_set_lines(0,0,-1,false,{
  'const Command = @import("command.zig").Command;',
  'pub fn echo(out: *std.Io.Writer) void {',
  '    const value = 1;',
  '    try out.print("hello");',
  '    return;',
  '}',
})
vim.bo.filetype='zig'
vim.cmd('syntax sync fromstart')
local function token(row,text,expected)
  local line=vim.api.nvim_buf_get_lines(0,row-1,row,false)[1]
  local col=assert(line:find(text,1,true))
  local id=vim.fn.synIDtrans(vim.fn.synID(row,col,1))
  local value=vim.fn.synIDattr(id,'fg#')
  assert(value==expected, text .. ': ' .. value .. ' (' .. vim.fn.synIDattr(id,'name') .. ')')
end
token(1,'const','#f49b62')
token(1,'Command','#c792ff')
token(1,'@import','#f49b62')
token(2,'fn','#f49b62')
token(2,'echo','#72bfff')
token(4,'try','#f49b62')
token(4,'print','#72bfff')
token(5,'return','#f49b62')
vim.cmd.colorscheme('habamax')
assert(vim.g.colors_name=='habamax')
vim.cmd.colorscheme('soulfly')
color('SnacksIndentScope','fg','#25231f')
print('PASS: standalone colorscheme, Zig tokens, LSP roles, surfaces, indent guides and theme switching')
