-- Optional LazyVim integration. Read palette data, never execute theme code.
local function apply()
  local root = vim.fn.expand("~/.local/state/omarchy/current/")
  local ok, name = pcall(vim.fn.readfile, root .. "theme.name")
  if not ok or name[1] ~= "soulfly" then return end
  local success, theme = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(root .. "theme/zed.json"), "\n"))
  end)
  if not success or not theme.themes or not theme.themes[1] then return end
  local s = theme.themes[1].style
  local function hl(names, fg, bg, extra)
    for name in names:gmatch("%S+") do
      local value = vim.tbl_extend("force", { fg = fg, bg = bg }, extra or {})
      vim.api.nvim_set_hl(0, name, value)
    end
  end
  local function syntax(names, token)
    hl(names, s.syntax[token].color)
  end
  -- Legacy syntax, Tree-sitter captures and LSP semantic tokens share roles.
  syntax("Identifier @variable @module @module.builtin @lsp.type.variable @lsp.type.namespace", "variable")
  syntax("@variable.parameter @variable.parameter.builtin @lsp.type.parameter", "variable.parameter")
  syntax("@variable.builtin", "variable.special")
  syntax("Function @function @function.call @function.builtin @function.method @function.method.call @function.macro @lsp.type.function @lsp.type.method @lsp.type.decorator", "function")
  syntax("Type Structure Typedef @type @type.builtin @type.definition @constructor @constructor.tsx @lsp.type.type @lsp.type.class @lsp.type.interface @lsp.type.struct @lsp.type.enum @lsp.type.typeParameter", "type")
  syntax("Constant Number Float Boolean @constant @constant.builtin @constant.macro @number @number.float @boolean @lsp.type.enumMember @lsp.type.number", "constant")
  syntax("Statement Conditional Repeat Keyword Exception Include Define Macro PreProc PreCondit StorageClass Debug @keyword @keyword.conditional @keyword.conditional.ternary @keyword.coroutine @keyword.debug @keyword.directive @keyword.directive.define @keyword.exception @keyword.function @keyword.import @keyword.operator @keyword.repeat @keyword.return @keyword.storage @keyword.modifier @type.qualifier @lsp.type.keyword @lsp.type.modifier", "keyword")
  syntax("String Character @string @string.documentation @character @lsp.type.string", "string")
  syntax("SpecialChar @string.escape @character.special", "string.escape")
  syntax("@string.regexp @lsp.type.regexp", "string.regex")
  syntax("@property @variable.member @attribute @tag.attribute @lsp.type.property", "property")
  syntax("Label @label", "label")
  syntax("Tag @tag @tag.tsx @tag.javascript", "tag")
  syntax("Operator @operator @lsp.type.operator", "operator")
  syntax("Delimiter @punctuation.bracket @punctuation.delimiter @tag.delimiter @tag.delimiter.tsx", "punctuation")
  syntax("Special @punctuation.special", "punctuation.special")
  syntax("Comment @comment @comment.documentation @lsp.type.comment", "comment")
  syntax("LspInlayHint LspCodeLens LspCodeLensSeparator", "hint")
  syntax("Title @markup.heading", "title")
  syntax("@markup.raw @markup.raw.markdown_inline", "string")
  syntax("Underlined @markup.link @markup.link.url", "link_text")
  -- Transparent-background overrides must not flatten the Zed surface hierarchy.
  hl("Normal NormalNC EndOfBuffer", s["editor.foreground"], s["editor.background"])
  hl("Terminal", s["terminal.foreground"], s["terminal.background"])
  hl("NormalFloat Pmenu TelescopeNormal TelescopePromptNormal WhichKeyFloat", s.text, s["elevated_surface.background"])
  hl("FloatBorder TelescopeBorder TelescopePromptBorder", s.border, s["elevated_surface.background"])
  hl("PmenuSel Visual", s.text, s["element.selected"])
  hl("CursorLine CursorColumn", nil, s["editor.active_line.background"])
  hl("SignColumn FoldColumn LineNr", s["editor.line_number"], s["editor.gutter.background"])
  hl("CursorLineNr", s["editor.active_line_number"], s["editor.gutter.background"])
  hl("Folded", s["text.muted"], s["surface.background"])
  hl("WinSeparator VertSplit", s.border, s["panel.background"])
  hl("StatusLine", s.text, s["status_bar.background"])
  hl("StatusLineNC", s["text.muted"], s["status_bar.background"])
  hl("TabLine TabLineFill", s["text.muted"], s["tab.inactive_background"])
  hl("TabLineSel", s["text.accent"], s["tab.active_background"])
  hl("NeoTreeNormal NeoTreeNormalNC NeoTreeEndOfBuffer NvimTreeNormal NvimTreeNormalNC NvimTreeEndOfBuffer SnacksPickerList SnacksPickerInput", s.text, s["panel.background"])
  hl("NeoTreeWinSeparator NeoTreeVertSplit NvimTreeVertSplit", s.border, s["panel.background"])
  hl("IblIndent IndentBlanklineChar", s["editor.indent_guide"])
  hl("IblScope", s["editor.indent_guide_active"])
  for suffix, key in pairs({ Error = "error", Warn = "warning", Info = "info", Hint = "hint" }) do
    hl("Diagnostic" .. suffix .. " DiagnosticVirtualText" .. suffix .. " DiagnosticSign" .. suffix, s[key])
    hl("DiagnosticUnderline" .. suffix, nil, nil, { undercurl = true, sp = s[key] })
  end
  for group, key in pairs({ GitSignsAdd = "created", GitSignsChange = "modified", GitSignsDelete = "deleted" }) do
    hl(group, s[key])
  end
  local ansi = { "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white" }
  for i, color in ipairs(ansi) do
    vim.g["terminal_color_" .. (i - 1)] = s["terminal.ansi." .. color]
    vim.g["terminal_color_" .. (i + 7)] = s["terminal.ansi.bright_" .. color]
  end
end

return {
  {
    name = "soulfly-zed-palette",
    dir = vim.fn.stdpath("config"),
    lazy = false,
    priority = 900,
    config = function()
      local group = vim.api.nvim_create_augroup("SoulflyZedPalette", { clear = true })
      vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
        group = group,
        callback = function() vim.schedule(apply) end,
      })
      vim.schedule(apply)
    end,
  },
}
