local M = {}
local p = require("soulfly.palette")

function M.load()
  vim.o.termguicolors = true
  vim.o.background = "dark"
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
  vim.g.colors_name = "soulfly"
  local function hl(names, fg, bg, extra)
    for name in names:gmatch("%S+") do
      local value = vim.tbl_extend("force", { fg = fg, bg = bg }, extra or {})
      vim.api.nvim_set_hl(0, name, value)
    end
  end
  local function syntax(names, token)
    hl(names, p.syntax[token])
  end
  -- Legacy syntax, Tree-sitter captures and LSP semantic tokens share roles.
  syntax("Identifier @variable @module @module.builtin @lsp.type.variable @lsp.type.namespace", "variable")
  syntax("@variable.parameter @variable.parameter.builtin @lsp.type.parameter", "variable.parameter")
  syntax("@variable.builtin", "variable.special")
  syntax("Function @function @function.call @function.builtin @function.method @function.method.call @function.macro @lsp.type.function @lsp.type.method @lsp.type.decorator", "function")
  syntax("Type Structure Typedef @type @type.builtin @type.definition @constructor @constructor.tsx @lsp.type.type @lsp.type.class @lsp.type.interface @lsp.type.struct @lsp.type.enum @lsp.type.typeParameter", "type")
  syntax("Constant Number Float Boolean @constant @constant.builtin @constant.macro @number @number.float @boolean @lsp.type.enumMember @lsp.type.number", "constant")
  syntax("Statement Conditional Repeat Keyword Exception Include Define Macro PreProc PreCondit StorageClass Debug @keyword @keyword.conditional @keyword.conditional.ternary @keyword.coroutine @keyword.debug @keyword.directive @keyword.directive.define @keyword.exception @keyword.function @keyword.import @keyword.operator @keyword.repeat @keyword.return @keyword.storage @keyword.modifier @keyword.type @type.qualifier @lsp.type.keyword @lsp.type.modifier", "keyword")
  syntax("String Character @string @string.documentation @character @lsp.type.string", "string")
  syntax("SpecialChar @string.escape @character.special", "string.escape")
  syntax("@string.regexp @lsp.type.regexp", "string.regex")
  syntax("zigProperty @property @field @variable.member @attribute @tag.attribute @lsp.type.property @lsp.type.field @lsp.type.member", "property")
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
  -- Opaque surfaces preserve the editor, panel and popup hierarchy.
  hl("Normal NormalNC EndOfBuffer", p.editor_foreground, p.editor_background)
  hl("Terminal", p.terminal_foreground, p.terminal_background)
  hl("NormalFloat Pmenu TelescopeNormal TelescopePromptNormal WhichKeyFloat", p.text, p.elevated_surface_background)
  hl("FloatBorder TelescopeBorder TelescopePromptBorder", p.popup_border, p.elevated_surface_background)
  hl("PmenuSel Visual", p.text, p.selection)
  hl("CursorLine CursorColumn", nil, p.editor_active_line_background)
  hl("SignColumn FoldColumn LineNr", p.editor_line_number, p.editor_gutter_background)
  hl("CursorLineNr", p.editor_active_line_number, p.editor_gutter_background)
  hl("Folded", p.text_muted, p.surface_background)
  hl("WinSeparator VertSplit", p.border, p.panel_background)
  hl("SoulflyAccent", p.accent)
  hl("NeoTreeRootName NvimTreeRootFolder", p.text)
  hl("SoulflyExplorerName", p.text)
  hl("SoulflyExplorerMuted", p.text_muted)
  hl("SoulflyExplorerIgnored", "#989b96")
  hl("SoulflyExplorerAdded", p.created)
  hl("SoulflyExplorerModified", p.modified)
  hl("SoulflyExplorerDeleted", p.deleted)
  hl("SoulflyExplorerRenamed", p.info)
  hl("NeoTreeTitleBar NeoTreeFloatTitle", p.accent, p.panel_background)
  hl("StatusLine", p.text, p.status_bar_background)
  hl("StatusLineNC", p.text_muted, p.status_bar_background)
  hl("TabLine TabLineFill", p.text_muted, p.tab_inactive_background)
  hl("TabLineSel", p.text_accent, p.tab_active_background)
  hl("NeoTreeNormal NeoTreeNormalNC NeoTreeEndOfBuffer NvimTreeNormal NvimTreeNormalNC NvimTreeEndOfBuffer SnacksPickerList SnacksPickerInput", p.text, p.panel_background)
  hl("NeoTreeWinSeparator NeoTreeVertSplit NvimTreeVertSplit", p.border, p.panel_background)
  hl("IblIndent IndentBlanklineChar", p.indent)
  hl("IblScope", p.indent_scope)
  for suffix, key in pairs({ Error = "error", Warn = "warning", Info = "info", Hint = "hint" }) do
    hl("Diagnostic" .. suffix .. " DiagnosticVirtualText" .. suffix .. " DiagnosticSign" .. suffix, p[key])
    hl("DiagnosticUnderline" .. suffix, nil, nil, { undercurl = true, sp = p[key] })
  end
  for group, key in pairs({ GitSignsAdd = "created", GitSignsChange = "modified", GitSignsDelete = "deleted" }) do
    hl(group, p[key])
  end
  local ansi = { "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white" }
  for i, color in ipairs(ansi) do
    vim.g["terminal_color_" .. (i - 1)] = p.ansi[color]
    vim.g["terminal_color_" .. (i + 7)] = p.ansi["bright_" .. color]
  end
  -- Zig's stock Vim syntax links declarations to Function and return to Special.
  -- Override language groups explicitly, including when Tree-sitter is absent.
  syntax("zigVarDecl zigKeyword zigExecution zigStructure zigException zigMacro zigPreProc zigConditional zigRepeat zigComparatorWord", "keyword")
  syntax("zigBuiltinFn zigFunction", "function")
  syntax("zigType zigTypeName", "type")
  syntax("zigEscape zigEscapeUnicode", "string.escape")
  hl("NonText SpecialKey Conceal", p.dimmed)
  hl("Whitespace", p.indent)
  hl("SnacksIndent SnacksIndentBlank IblIndent IndentBlanklineChar", p.indent)
  hl("SnacksIndentScope SnacksIndentChunk IblScope MiniIndentscopeSymbol", p.indent_scope)
  for i = 1, 8 do hl("SnacksIndent" .. i, p.indent) end
  hl("Search CurSearch IncSearch", p.editor_background, p.syntax.constant)
  hl("MatchParen", p.text, p.element_selected)
  hl("PmenuSbar", nil, p.element_selected)
  hl("PmenuThumb", nil, p.scrollbar)
  hl("ErrorMsg", p.error)
  hl("WarningMsg", p.warning)
  hl("MoreMsg Question", p.syntax.string)
  hl("Todo", p.syntax.keyword, p.surface_background)
  hl("Directory", p.syntax["function"])
  hl("DiffAdd", nil, "#20281a")
  hl("DiffChange", nil, "#282319")
  hl("DiffDelete", p.deleted, "#2d1c1b")
  hl("DiffText", p.text, "#3a3020")
  hl("BufferLineFill BufferLineBackground BufferLineTab", p.text_muted, p.tab_inactive_background)
  hl("BufferLineBufferSelected BufferLineTabSelected", p.text, p.tab_active_background)
  hl("BufferLineIndicatorSelected", p.accent, p.tab_active_background)
  -- Text metadata must remain readable independently of decorative guides.
  hl("PmenuExtra PmenuKind BlinkCmpLabelDetail BlinkCmpLabelDescription BlinkCmpSource", p.secondary, p.elevated_surface_background)
  hl("BlinkCmpGhostText", p.dimmed)
  hl("BlinkCmpLabelDeprecated", p.dimmed, nil, { strikethrough = true })
  hl("BlinkCmpLabelMatch", p.syntax.constant, nil, { bold = true })
  hl("BlinkCmpMenuBorder BlinkCmpDocBorder BlinkCmpDocSeparator BlinkCmpSignatureHelpBorder", p.popup_border, p.elevated_surface_background)
  hl("SnacksPickerDir SnacksPickerTotals SnacksPickerBufFlags SnacksPickerKeymapRhs SnacksDashboardDir", p.secondary)
  hl("SnacksPickerPathHidden SnacksPickerPathIgnored SnacksPickerDimmed SnacksPickerUnselected", p.dimmed)
  hl("SnacksPickerGitStatusUntracked", p.created)
  hl("SnacksPickerGitStatusIgnored", p.dimmed)
  hl("SnacksPickerFile SnacksPickerDirectory", p.text)
  hl("SnacksPickerPreview", p.editor_foreground, p.editor_background)
  hl("SnacksPickerMatch TelescopeMatching", p.syntax.constant, nil, { bold = true })
  hl("SnacksPickerPrompt", p.accent)
  hl("SnacksPickerListCursorLine SnacksPickerPreviewCursorLine TelescopeSelection", nil, p.selection)
  hl("SnacksPickerBorder SnacksPickerListBorder SnacksPickerInputBorder SnacksPickerPreviewBorder", p.popup_border, p.panel_background)
  hl("FloatTitle SnacksPickerTitle SnacksPickerListTitle SnacksPickerInputTitle SnacksPickerPreviewTitle", p.accent)

end

return M
