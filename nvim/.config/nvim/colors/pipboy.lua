-- Maintainer: Gallen (seirios0107@gmail.com)
-- Repo: https://github.com/nellaG
--
-- Converted from Vimscript to Neovim Lua colorscheme.

local M = {}

local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

function M.colorscheme()
  vim.opt.background = "dark"

  -- Equivalent of: hi clear | syntax reset | let g:colors_name=...
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end
  vim.g.colors_name = "pipboy3000-green"

  -- Base
  hi("Normal",       { fg = nil, bg = "#000000" }) -- ctermfg=82 ctermbg=233 (approx in gui)
  hi("CursorColumn", { fg = nil, bg = "#666666" }) -- Grey40
  hi("CursorLine",   { fg = nil, bg = "#666666" }) -- Grey40

  -- Syntax-ish groups (approx colors; original was mostly cterm)
  hi("Boolean",     { fg = "#00d787" }) -- cterm 42-ish
  hi("Comment",     { fg = "#00ff5f" }) -- cterm 47-ish
  hi("Conditional", { fg = "#5f8700" }) -- cterm 64-ish
  hi("Constant",    { fg = "#005f5f" }) -- cterm 23-ish
  hi("Define",      { fg = "#005f5f" })
  hi("Error",       { fg = "#ff0000" })
  hi("Exception",   { fg = "#5f8700" })
  hi("Function",    { fg = "#d7ff00" }) -- cterm 190
  hi("Identifier",  { fg = "#afff87" }) -- cterm 156
  hi("Ignore",      { fg = nil })
  hi("Include",     { fg = "#5f8700" })
  hi("Keyword",     { fg = "#5f8700" })
  hi("Label",       { fg = "#5f8700" })
  hi("Macro",       { fg = "#ff00d7" }) -- cterm 200-ish
  hi("Number",      { fg = "#005f5f" })
  hi("Operator",    { fg = "#5f8700" })
  hi("PreCondit",   { fg = "#808080" }) -- cterm 244
  hi("PreProc",     { fg = "#5f8700" })
  hi("Repeat",      { fg = "#5f8700" })
  hi("Statement",   { fg = "#005f5f" })
  hi("String",      { fg = "#005f00" }) -- cterm 22-ish
  hi("Structure",   { fg = "#af0000" }) -- cterm 124-ish
  hi("Special",     { fg = "#5fff5f" }) -- cterm 83-ish
  hi("Todo",        { fg = "#00d700" }) -- cterm 40-ish
  hi("Type",        { fg = "#afff00" }) -- cterm 154-ish
  hi("Underlined",  { underline = true })

  -- UI groups
  hi("ColorColumn",  { bg = "#5f5f00" }) -- ctermbg=70 approx
  hi("Cursor",       { fg = "#000000", bg = "#eeeeee" }) -- ctermbg=255 approx
  -- Diff groups: original had DiffText twice; later definition wins
  hi("DiffText",     { bold = true, bg = "#ff0000" }) -- later: bold + Red bg
  hi("DiffAdd",      { fg = "#ff00d7", bg = "#d7ffff" }) -- LightCyan approx
  hi("DiffChange",   { fg = "#ffffff", bg = "#d7ffff" })
  hi("DiffDelete",   { fg = "#ff00d7", bg = "#d7ffff" })

  hi("ErrorMsg",     { fg = "#ff5f5f" })
  hi("Folded",       { fg = "#ff00d7" })
  hi("FoldColumn",   { fg = "#000087", bg = "#bcbcbc" }) -- DarkBlue/Grey approx
  hi("IncSearch",    { fg = "#000000", bg = "#87ff87" }) -- LightGreen approx
  hi("lCursor",      { fg = "#000000", bg = "#eeeeee" })
  hi("LineNr",       { fg = "#00ff00" }) -- cterm 46-ish
  hi("MatchParen",   { bg = "#008787" }) -- DarkCyan approx
  hi("ModeMsg",      { fg = "#5fd700" }) -- cterm 82-ish
  hi("MoreMsg",      { fg = "#5fd700" })
  hi("NonText",      { fg = "#00d700", bg = "#000000" })

  hi("Pmenu",        { fg = "#5fd700", bg = "#121212" }) -- ctermbg=233 approx
  hi("PmenuSel",     { fg = nil, bg = "#005f00" }) -- DarkGrey-ish -> use greenish bg from original ctermbg=22
  hi("PmenuSbar",    { bg = "#bcbcbc" })
  hi("PmenuThumb",   { reverse = true })

  hi("Question",     { fg = "#ff00d7" })
  hi("Search",       { fg = "#5fd700", bg = "#005f00" }) -- ctermfg=82 ctermbg=22-ish

  -- SignColumn duplicated in original; later one wins there too
  hi("SignColumn",   { fg = "#00ffff", bg = "#bcbcbc" })

  hi("SpecialKey",   { fg = "#00ffff" })

  hi("StatusLine",   { fg = nil, bg = "#272d2f" })
  hi("StatusLineNC", { fg = nil, bg = "#272d2f" })

  hi("SpellBad",     { undercurl = true, sp = "#ff0000" })
  hi("SpellCap",     { undercurl = true, sp = "#0000ff" })
  hi("SpellRare",    { undercurl = true, sp = "#ff00ff" })
  hi("SpellLocal",   { undercurl = true, sp = "#00ffff" })

  hi("TabLineFill",  { fg = nil, bg = "#272d2f" })
  hi("TabLine",      { fg = nil, bg = "#272d2f" })
  hi("TabLineSel",   { fg = nil, bg = "#272d2f" })

  hi("Title",        { fg = "#87ff00" }) -- cterm 118-ish
  hi("VertSplit",    { fg = "#5f8787", bg = "#000000" }) -- ctermfg=66 approx
  hi("Visual",       { reverse = true })
  hi("VisualNOS",    { underline = true })
  hi("WarningMsg",   { fg = "#d75faf", bg = "#000000" }) -- cterm 167-ish
  hi("WildMenu",     { fg = "#000000", bg = "#5f5f00" }) -- ctermbg=60-ish
end

M.colorscheme()
return M
