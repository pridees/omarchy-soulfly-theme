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
  color(g,'fg','#ecc18e')
end
for _, g in ipairs({'Type','@type.builtin','@lsp.type.interface','@lsp.type.class'}) do color(g,'fg','#c792ff') end
color('Function','fg','#72bfff')
for _, g in ipairs({'zigProperty','@property','@variable.member','@lsp.type.property','@lsp.type.field'}) do color(g,'fg','#abc5d0') end
color('Comment','fg','#8a8e85')
color('LspInlayHint','fg','#7d817a')
color('Normal','bg','#090908')
color('NormalFloat','bg','#191917')
color('NeoTreeNormal','bg','#0f0f0e')
color('SnacksIndent','fg','#191917')
color('SnacksIndentScope','fg','#25231f')
assert(vim.g.terminal_color_7 == '#c0bfba')
-- Guard semantic text against accidental reuse of nearly invisible guide colors.
local function luminance(c)
  local value = 0
  for i, weight in ipairs({0.2126, 0.7152, 0.0722}) do
    local v = math.floor(c / 256 ^ (3-i)) % 256 / 255
    value = value + weight * (v <= 0.04045 and v / 12.92 or ((v + 0.055) / 1.055) ^ 2.4)
  end
  return value
end
local function contrast(a,b)
  a,b=luminance(a),luminance(b)
  return (math.max(a,b)+0.05)/(math.min(a,b)+0.05)
end
for _, group in ipairs({'NonText','SnacksPickerDir','SnacksPickerTotals','SnacksPickerPathHidden','SnacksPickerDimmed','SnacksPickerKeymapRhs','BlinkCmpGhostText','BlinkCmpLabelDetail'}) do
  local fg=vim.api.nvim_get_hl(0,{name=group,link=false}).fg
  for _, bg in ipairs({0x0f0f0e,0x191917,0x3a302b}) do
    assert(contrast(fg,bg)>=4.5, group .. ': insufficient contrast')
  end
end
local thumb=vim.api.nvim_get_hl(0,{name='PmenuThumb'}).bg
local track=vim.api.nvim_get_hl(0,{name='PmenuSbar'}).bg
assert(contrast(thumb,track)>=2.8)
assert(contrast(vim.api.nvim_get_hl(0,{name='FloatBorder'}).fg,0x191917)>=2.4)
assert(contrast(vim.api.nvim_get_hl(0,{name='SnacksPickerListCursorLine'}).bg,0x0f0f0e)>=1.45)
color('SnacksIndent','fg','#191917')
color('SnacksIndentScope','fg','#25231f')
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
  'const path = cmd.command.full_path;',
  'const field = self.name;',
  'const result = items[0].value;',
  'const deref = ptr.*.value;',
  'const text = "obj.field"; // self.name',
  'var missing: ?u8 = null;',
  'var raw: u8 = undefined;',
  'const escaped = "hello\\n";',
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
token(1,'const','#ecc18e')
token(1,'Command','#c792ff')
token(1,'@import','#ecc18e')
token(2,'fn','#ecc18e')
token(2,'echo','#72bfff')
token(4,'try','#ecc18e')
token(4,'print','#72bfff')
token(5,'return','#ecc18e')
token(7,'command','#abc5d0')
token(7,'full_path','#abc5d0')
token(8,'name','#abc5d0')
token(9,'value','#abc5d0')
token(10,'value','#abc5d0')
token(11,'field','#b5d86d')
token(11,'name','#8a8e85')
token(3,'1','#d9976e')
token(12,'null','#d9976e')
token(13,'undefined','#d9976e')
token(14,'\\n','#d9976e')
vim.cmd.colorscheme('habamax')
assert(vim.g.colors_name=='habamax')
vim.cmd.colorscheme('soulfly')
color('SnacksIndentScope','fg','#25231f')
print('PASS: standalone colorscheme, Zig tokens, LSP roles, surfaces, indent guides and theme switching')
