-- kurodake-green.nvim
-- Author: Taro Morita (kurodake-green)
-- Concept: black x green only, high-contrast, eyes-friendly night theme
-- Single-file Neovim colorscheme (Lua)

local M = {}

-- ===== Palette (green & black only) =====
local palette = {
	black = "#060a06", -- almost black
	black2 = "#0a120a", -- popups / secondary bg
	base = "#101610", -- for inversed fg

	fg = "#55c455", -- main text green
	muted = "#3a7a3a", -- comments / subtle
	dim = "#284c28", -- more subtle
	edge = "#1f4e1f", -- borders / separators

	accent = "#63e063", -- vivid green
	accent2 = "#7af77a", -- brighter green
	accent3 = "#a0ffa0", -- yellowish green

	cursor = "#7af77a", -- cursor fill
	glow = "#b7ffb7", -- soft match glow
	sel_bg = "#1a301a", -- selection bg
	sel_fg = "#e8ffe8", -- selection fg

	emerald = "#31d18f", -- greenish error tone
}

---Apply a highlight
---@param name string
---@param spec table|string
local function hl(name, spec)
	if type(spec) == "string" then
		vim.api.nvim_set_hl(0, name, { fg = palette[spec] })
	else
		local s = {}
		if spec.fg then
			s.fg = palette[spec.fg] or spec.fg
		end
		if spec.bg then
			s.bg = palette[spec.bg] or spec.bg
		end
		if spec.sp then
			s.sp = palette[spec.sp] or spec.sp
		end
		if spec.bold then
			s.bold = true
		end
		if spec.italic then
			s.italic = true
		end
		if spec.underline then
			s.underline = true
		end
		if spec.undercurl then
			s.undercurl = true
		end
		if spec.reverse then
			s.reverse = true
		end
		if spec.strikethrough then
			s.strikethrough = true
		end
		vim.api.nvim_set_hl(0, name, s)
	end
end

--- Setup and load the colorscheme.
--- @param opts { transparent?: boolean } | nil
function M.setup(opts)
	opts = opts or {}

	-- basic init
	vim.cmd("highlight clear")
	if vim.fn.exists("syntax_on") == 1 then
		vim.cmd("syntax reset")
	end
	vim.g.colors_name = "kurodake-green"

	local bg = opts.transparent and "NONE" or palette.black
	local bg2 = opts.transparent and "NONE" or palette.black2

	-- UI Core
	hl("Normal", { fg = "fg", bg = bg })
	hl("NormalNC", { fg = "fg", bg = bg })
	hl("NormalFloat", { fg = "fg", bg = bg2 })
	hl("FloatBorder", { fg = "edge", bg = bg2 })
	hl("WinSeparator", { fg = "edge" })
	hl("LineNr", { fg = "muted", bg = bg })
	hl("CursorLineNr", { fg = "accent2", bold = true })
	hl("SignColumn", { bg = bg })
	hl("EndOfBuffer", { fg = "black" })

	-- Cursor / Cursorline / Selection
	hl("Cursor", { fg = "base", bg = "cursor" })
	hl("lCursor", { fg = "base", bg = "cursor" })
	hl("CursorIM", { fg = "base", bg = "cursor" })
	hl("CursorLine", { bg = "black2" })
	hl("CursorColumn", { bg = "black2" })
	hl("CursorLineFold", { fg = "accent3", underline = true })
	hl("CursorLineSign", { fg = "accent3", underline = true })
	hl("MatchParen", { bg = "glow" })
	hl("Visual", { fg = "sel_fg", bg = "sel_bg" })
	hl("Search", { fg = "base", bg = "accent" })
	hl("IncSearch", { fg = "base", bg = "accent2" })

	-- Menus / Popups
	hl("Pmenu", { fg = "fg", bg = "black2" })

	hl("PmenuSel", { fg = "accent3", underline = true, bg = "edge" })
	hl("PmenuSbar", { bg = "black" })
	hl("PmenuThumb", { bg = "accent2" })
	hl("NormalSB", { fg = "fg", bg = "black2" })
	hl("Question", { fg = "accent2" })

	-- Statusline
	hl("StatusLine", { fg = "base", bg = "accent" })
	hl("StatusLineNC", { fg = "muted", bg = bg2 })
	-- Mode-like flavors (linked)
	hl("KurodakeStatusNormal", { fg = "base", bg = "accent" })
	hl("KurodakeStatusInsert", { fg = "base", bg = "accent2" })
	hl("KurodakeStatusSelect", { fg = "base", bg = "accent3" })

	-- Gutter
	hl("FoldColumn", { fg = "muted", bg = bg })
	hl("ColorColumn", { bg = "black2" })

	-- Diagnostics (LSP)
	hl("DiagnosticInfo", { fg = "accent2", undercurl = true, sp = "accent2" })
	hl("DiagnosticHint", { fg = "muted", undercurl = true, sp = "muted" })
	hl("DiagnosticWarn", { fg = "accent3", undercurl = true, sp = "accent3" })
	hl("DiagnosticError", { fg = "emerald", undercurl = true, sp = "emerald" })
	hl("DiagnosticUnderlineInfo", { undercurl = true, sp = "accent2" })
	hl("DiagnosticUnderlineHint", { undercurl = true, sp = "muted" })
	hl("DiagnosticUnderlineWarn", { undercurl = true, sp = "accent3" })
	hl("DiagnosticUnderlineError", { undercurl = true, sp = "emerald" })

	-- Diff
	hl("DiffAdd", { fg = "accent2" })
	hl("DiffChange", { fg = "accent" })
	hl("DiffDelete", { fg = "dim" })
	hl("DiffText", { fg = "accent3", bold = true })

	-- Syntax (basic)
	hl("Comment", { fg = "dim", italic = true })
	hl("Constant", { fg = "accent2" })
	hl("String", { fg = "accent3" })
	hl("Character", { fg = "accent2" })
	hl("Number", { fg = "accent2" })
	hl("Boolean", { fg = "accent2" })
	hl("Float", { fg = "accent2" })
	hl("Identifier", { fg = "fg" })
	hl("Function", { fg = "accent2" })
	hl("Statement", { fg = "accent", bold = true })
	hl("Conditional", { fg = "accent3" })
	hl("Repeat", { fg = "accent3" })
	hl("Label", { fg = "accent" })
	hl("Operator", { fg = "fg" })
	hl("Keyword", { fg = "accent", bold = true })
	hl("Exception", { fg = "accent" })
	hl("PreProc", { fg = "accent" })
	hl("Include", { fg = "accent" })
	hl("Define", { fg = "accent" })
	hl("Macro", { fg = "accent" })
	hl("PreCondit", { fg = "accent" })
	hl("Type", { fg = "fg" })
	hl("StorageClass", { fg = "fg" })
	hl("Structure", { fg = "fg" })
	hl("Typedef", { fg = "fg" })
	hl("Special", { fg = "accent" })
	hl("SpecialChar", { fg = "accent2" })
	hl("Tag", { fg = "accent" })
	hl("Delimiter", { fg = "fg" })
	hl("SpecialComment", { fg = "dim", italic = true })
	hl("Debug", { fg = "emerald" })
	hl("Underlined", { fg = "accent", underline = true })
	hl("Bold", { fg = "accent2", bold = true })
	hl("Italic", { fg = "accent", italic = true })

	-- Treesitter (a subset mapped to the design)
	hl("@variable", { fg = "fg" })
	hl("@variable.builtin", { fg = "accent", italic = true })
	hl("@variable.parameter", { fg = "fg" })
	hl("@variable.member", { fg = "fg" })

	hl("@constant", { fg = "accent2" })
	hl("@constant.builtin", { fg = "accent2" })
	hl("@constant.macro", { fg = "accent" })

	hl("@number", { fg = "accent2" })
	hl("@boolean", { fg = "accent2" })
	hl("@float", { fg = "accent2" })
	hl("@string", { fg = "accent3" })
	hl("@string.regex", { fg = "accent" })
	hl("@string.escape", { fg = "accent2" })
	hl("@string.special", { fg = "accent2" })
	hl("@string.special.url", { fg = "accent", underline = true })
	hl("@character", { fg = "accent2" })
	hl("@character.special", { fg = "accent2" })

	hl("@function", { fg = "accent2" })
	hl("@function.builtin", { fg = "accent2" })
	hl("@function.macro", { fg = "accent2" })
	hl("@function.method", { fg = "accent2" })
	hl("@constructor", { fg = "accent2" })

	hl("@keyword", { fg = "accent", bold = true })
	hl("@keyword.function", { fg = "accent", bold = true })
	hl("@keyword.operator", { fg = "accent" })
	hl("@keyword.return", { fg = "accent3" })
	hl("@keyword.conditional", { fg = "accent3" })
	hl("@keyword.repeat", { fg = "accent3" })
	hl("@keyword.import", { fg = "accent" })
	hl("@keyword.exception", { fg = "accent" })
	hl("@operator", { fg = "fg" })
	-- hl("@keyword.control", { fg = "accent3" })

	hl("@type", { fg = "fg" })
	hl("@type.builtin", { fg = "fg" })
	hl("@type.definition", { fg = "fg" })
	hl("@type.qualifier", { fg = "accent" })

	hl("@comment", { fg = "dim", italic = true })
	hl("@comment.documentation", { fg = "muted", italic = true })
	hl("@comment.error", { fg = "emerald", italic = true })
	hl("@comment.warning", { fg = "accent3", italic = true })
	hl("@comment.todo", { fg = "accent2", italic = true })
	hl("@comment.note", { fg = "accent2", italic = true })

	hl("@tag", { fg = "accent" })
	hl("@tag.attribute", { fg = "fg" })
	hl("@tag.delimiter", { fg = "dim" })
	hl("@attribute", { fg = "accent2" })

	hl("@namespace", { fg = "accent" })
	hl("@label", { fg = "accent" })

	hl("@markup.heading", { fg = "accent2", bold = true, underline = true })
	hl("@markup.heading.1", { link = "markdownH1" })
	hl("@markup.heading.2", { link = "markdownH2" })
	hl("@markup.heading.3", { link = "markdownH3" })
	hl("@markup.list", { fg = "accent3" })
	hl("@markup.list.checked", { fg = "accent2" })
	hl("@markup.list.unchecked", { fg = "dim" })
	hl("@markup.italic", { fg = "accent", italic = true })
	hl("@markup.bold", { fg = "accent2", bold = true })
	hl("@markup.strikethrough", { strikethrough = true, fg = "dim" })
	hl("@markup.link", { fg = "accent", underline = true })
	hl("@markup.link.label", { fg = "accent3" })
	hl("@markup.raw", { fg = "accent3" })
	hl("@markup.quote", { fg = "muted" })

	hl("@lsp.type.class", { link = "@type" })
	hl("@lsp.type.decorator", { link = "@function" })
	hl("@lsp.type.enum", { link = "@type" })
	hl("@lsp.type.enumNumber", { link = "@constant" })
	hl("@lsp.type.function", { link = "@function" })
	hl("@lsp.type.interface", { link = "@type" })
	hl("@lsp.type.macro", { link = "@function.macro" })
	hl("@lsp.type.method", { link = "@function.method" })
	hl("@lsp.type.namespace", { link = "@namespace" })
	hl("@lsp.type.parameter", { link = "@variable.parameter" })
	hl("@lsp.type.property", { link = "@variable.member" })
	hl("@lsp.type.struct", { link = "@type" })
	hl("@lsp.type.type", { link = "@type" })
	hl("@lsp.type.variable", { link = "@variable" })

	-- Markdown
	hl("markdownH1", { fg = "accent2", bold = true, underline = true })
	hl("markdownH2", { fg = "accent2", bold = true, underline = true })
	hl("markdownH3", { fg = "accent2", bold = true, underline = true })
	hl("markdownLinkText", { fg = "accent3" })
	hl("markdownUrl", { fg = "accent", underline = true })

	-- Telescope
	hl("TelescopeNormal", { fg = "fg", bg = bg2 })
	hl("TelescopeBorder", { fg = "edge", bg = bg2 })
	hl("TelescopeSelection", { fg = "accent3", bg = "black2" })
	hl("TelescopeMatching", { fg = "accent", bold = true })

	-- Git / VCS
	hl("GitSignsAdd", { fg = "accent2" })
	hl("GitSignsChange", { fg = "accent" })
	hl("GitSignsDelete", { fg = "dim" })

	-- Messages
	hl("ErrorMsg", { fg = "emerald" })
	hl("WarningMsg", { fg = "accent3" })
	hl("MoreMsg", { fg = "accent2" })
	hl("ModeMsg", { fg = "accent2" })
	hl("Title", { fg = "accent2", bold = true })

	-- Whitespace / Guides
	hl("Whitespace", { fg = "dim" })
	hl("IndentBlanklineChar", { fg = "edge" })

	-- Virtual Text Tone (dimmed by design)
	hl("NonText", { fg = "dim" })
	hl("SpecialKey", { fg = "dim" })

	-- Terminal ANSI (greenish scale)
	vim.g.terminal_color_0 = palette.black
	vim.g.terminal_color_8 = palette.dim

	vim.g.terminal_color_1 = palette.emerald
	vim.g.terminal_color_9 = palette.accent

	vim.g.terminal_color_2 = palette.accent2
	vim.g.terminal_color_10 = palette.accent3

	vim.g.terminal_color_3 = palette.accent
	vim.g.terminal_color_11 = palette.accent3

	vim.g.terminal_color_4 = palette.fg
	vim.g.terminal_color_12 = palette.accent2

	vim.g.terminal_color_5 = palette.accent
	vim.g.terminal_color_13 = palette.accent2

	vim.g.terminal_color_6 = palette.accent2
	vim.g.terminal_color_14 = palette.accent3

	vim.g.terminal_color_7 = palette.sel_fg
	vim.g.terminal_color_15 = palette.glow
end

-- If user simply :colorscheme kurodake-green after sourcing this file,
-- run with defaults.
if ... == nil then
	M.setup()
end

return M
