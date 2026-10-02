" Fill gaps in Neovim's stock Zig syntax when Tree-sitter is unavailable.
" These groups use standard links under other colorschemes as well.
syntax match zigProperty /\%(\.\)\@<=[A-Za-z_][A-Za-z0-9_]*/
syntax match zigTypeName /\<[A-Z][A-Za-z0-9_]*\>/
syntax match zigConstant /\<[A-Z][A-Z0-9_]*\>/
syntax match zigFunction /\<[A-Za-z_][A-Za-z0-9_]*\ze\s*(/
syntax match zigBuiltinFn /@[A-Za-z_][A-Za-z0-9_]*/
syntax keyword zigImport @import @cImport
highlight default link zigTypeName Type
highlight default link zigFunction Function
highlight default link zigImport Include
highlight default link zigProperty Identifier
