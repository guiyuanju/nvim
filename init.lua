-- ===================================================================
-- ## OPTIONS
-- ===================================================================

-- Theme & transparency
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true -- highlight current line
vim.opt.wrap = false
vim.opt.scrolloff = 10 -- keep 10 lines above/below cursor
vim.opt.sidescrolloff = 9 -- keep 8 columns left/right of cursor

-- Indentation
vim.opt.tabstop = 2 -- tab width
vim.opt.shiftwidth = 2 -- intent width
vim.opt.softtabstop = 2 -- soft tab stop
vim.opt.expandtab = true -- use spaces instead of tabs
vim.opt.smartindent = true -- smart auto-indenting
vim.opt.autoindent = true -- copy indent from current line

-- Search settings
vim.opt.ignorecase = true -- case insensitive search
vim.opt.smartcase = true -- case sensitive if uppercase in search
vim.opt.hlsearch = true -- highlight search results or not
vim.opt.incsearch = true -- show matches as you type

-- Visual settings
vim.opt.termguicolors = true -- enable 24-bit colors
vim.opt.signcolumn = "yes" -- always show sign column
vim.opt.colorcolumn = "100" -- show column at 100 characters
vim.opt.showmatch = true -- highlight matching bracket
vim.opt.matchtime = 2 -- how long to show matching bracket
vim.opt.cmdheight = 1 -- command line height
vim.opt.completeopt = "menuone,noinsert,noselect" -- completion options
vim.opt.showmode = false -- don't show mode in command line
vim.opt.pumheight = 10 -- popup menu height
vim.opt.pumblend = 10 -- popup menu transparency
vim.opt.winblend = 10 -- floating window transparency
vim.opt.winborder = "rounded"
vim.opt.conceallevel = 0 -- don't hide markup
vim.opt.concealcursor = "" -- don't hide cursor line markup
vim.opt.lazyredraw = true -- don't redraw during macros
vim.opt.synmaxcol = 300 -- syntax highlighting limit

-- File handling
vim.opt.backup = false -- don't create backup files
vim.opt.writebackup = false -- don't create backup before writing
vim.opt.swapfile = false -- don't create swap files
vim.opt.undofile = true -- persistent undo
vim.opt.undodir = vim.fn.expand("~/.vim/undodir") -- undo directory
-- Create undo directory if it doesn't exist
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end
-- vim.opt.updatetime = 300 -- faster completion
vim.opt.timeout = false -- key chord never timeout
vim.opt.autoread = true -- auto reload files changed outside of vim
vim.opt.autowrite = false -- don't auto save

-- Behavior settings
vim.opt.hidden = true -- allow hidden buffers
vim.opt.errorbells = false -- no error bells
vim.opt.backspace = "indent,eol,start" -- better backspace behavior
vim.opt.autochdir = false -- auto change directory or not
vim.opt.iskeyword:append("-") -- treat dash as part of word
vim.opt.path:append("**") -- include subdirectories in search
vim.opt.selection = "inclusive" -- selection behavior
vim.opt.mouse = "a" -- enable mouse support
vim.opt.clipboard:append("unnamedplus") -- use system clipboard
vim.opt.modifiable = true -- allow buffer modifications
vim.opt.encoding = "UTF-8" -- set encoding

-- Split behavior
vim.opt.splitbelow = true                          -- Horizontal splits go below
vim.opt.splitright = true                          -- Vertical splits go right

-- Command-line completion
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.wildignore:append({ "*.o", "*.obj", "*.pyc", "*.class", "*.jar" })

-- Better diff options
vim.opt.diffopt:append("linematch:60")

-- Performance improvements
vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000

-- ============================================================================
-- ## USEFUL FUNCTIONS
-- ============================================================================

-- Basic autocommands
local augroup = vim.api.nvim_create_augroup("UserConfig", {})

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto-resize splits when window is resized
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup,
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Create directories when saving files
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  callback = function()
    local dir = vim.fn.expand('<afile>:p:h')
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, 'p')
    end
  end,
})

-- ============================================================================
-- ## TERMINAL
-- ============================================================================

-- Auto-close terminal when process exits
vim.api.nvim_create_autocmd("TermClose", {
  group = augroup,
  callback = function()
    if vim.v.event.status == 0 then
      vim.api.nvim_buf_delete(0, {})
    end
  end,
})

-- Disable line numbers in terminal
vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end,
})

-- ============================================================================
-- ## STATUS LINE
-- ============================================================================

-- Git branch function
local function git_branch()
  local branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
  if branch ~= "" then
    return branch
  end
  return ""
end

-- LSP status
local function lsp_status()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients > 0 then
    return "LSP"
  end
  return ""
end

-- Word count for text files
local function word_count()
  local ft = vim.bo.filetype
  if ft == "markdown" or ft == "text" or ft == "tex" then
    local words = vim.fn.wordcount().words
    return words .. " words"
  end
  return ""
end

-- File size
local function file_size()
  local size = vim.fn.getfsize(vim.fn.expand('%'))
  if size < 0 then return "nil" end
  if size < 1024 then
    return size .. "B"
  elseif size < 1024 * 1024 then
    return string.format("%.1fK", size / 1024)
  else
    return string.format("%.1fM", size / 1024 / 1024)
  end
end

-- Mode indicators with icons
local function mode_icon()
  local mode = vim.fn.mode()
  local modes = {
    n = "NORMAL",
    i = "INSERT",
    v = "VISUAL",
    V = "V-LINE",
    ["\22"] = "V-BLOCK",  -- Ctrl-V
    c = "COMMAND",
    s = "SELECT",
    S = "S-LINE",
    ["\19"] = "S-BLOCK",  -- Ctrl-S
    R = "REPLACE",
    r = "REPLACE",
    ["!"] = "SHELL",
    t = "TERMINAL"
  }
  return modes[mode] or "  " .. mode:upper()
end

_G.mode_icon = mode_icon
_G.git_branch = git_branch
_G.file_type = file_type
_G.file_size = file_size
_G.lsp_status = lsp_status

vim.cmd([[
  highlight StatusLineBold gui=bold cterm=bold
]])

-- Function to change statusline based on window focus
local function setup_dynamic_statusline()
  vim.api.nvim_create_autocmd({"WinEnter", "BufEnter"}, {
    callback = function()
    vim.opt_local.statusline = table.concat {
      "  ",
      "%#StatusLineBold#",
      "%{v:lua.mode_icon()}",
      "%#StatusLine#",
      " │ ",
      "%f%h%m%r",
      " │ ",
      -- "%{v:lua.git_branch()}",
      -- " │ ",
      "%{v:lua.file_size()}",
      " │ ",
      "%{v:lua.lsp_status()}",
      "%=",                     -- Right-align everything after this
      "%l:%c  %P ",             -- Line:Column and Percentage
    }
    end
  })
  vim.api.nvim_set_hl(0, "StatusLineBold", { bold = true })

  vim.api.nvim_create_autocmd({"WinLeave", "BufLeave"}, {
    callback = function()
      vim.opt_local.statusline = "  %f%h%m%r │ %=  %l:%c   %P "
    end
  })
end

setup_dynamic_statusline()

-- ===================================================================
-- ## Key mappings
-- ===================================================================

vim.g.mapleader = " "                              -- Set leader key to space
vim.g.maplocalleader = " "                         -- Set local leader key (NEW)

-- Search
vim.keymap.set("n", "<leader>ss", ":Pick buf_lines<CR>", { desc = "Seach buffer lines" })
vim.keymap.set("n", "<leader>sg", ":Pick grep<CR>", { desc = "Grep" })
vim.keymap.set("n", "<leader>sc", ":nohlsearch<CR>", { desc = "Clear search highlights" })

-- Y to EOL
vim.keymap.set("n", "Y", "y$", { desc = "Yank to the end of line" })

-- Delete without yanking
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })

-- Center screen when jumping
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Buffer navigation
vim.keymap.set("n", "<leader>bb", ":Pick buffers<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>`", ":b#<CR>", { desc = "Previous active buffer" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Window splitting
vim.keymap.set("n", "<leader>wv", ":vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>wh", ":split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>wd", ":close<CR>", { desc = "Split window horizontally" })

-- Window resizing
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Move lines up/down
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Better indenting in visual mode
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Better J behavior
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

-- Quick file navigation
vim.keymap.set("n", "<leader>fe", ":lua MiniFiles.open()<CR>", { desc = "Open file explorer" })
vim.keymap.set("n", "<leader>ff", ":Pick files<CR>", { desc = "Find file" })
vim.keymap.set("n", "<leader>fc", ":e ~/.config/nvim/init.lua<CR>", { desc = "Edit config" })
-- Function to open the recent files picker
local function open_recent_files_picker()
  MiniPick.start({ source = { items = MiniVisits.list_paths() } })
end
vim.keymap.set('n', '<leader>fr', open_recent_files_picker, { desc = 'Open recent files picker' })

-- Terminal
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Esc to normal mode in terminal" })
vim.keymap.set("t", "<C-d>", "<C-\\><C-n> | :bd!<CR>", { desc = "Close terminal" })

-- Copy full file-path
vim.keymap.set("n", "<leader>fp", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  print("file:", path)
end)

-- Picker
vim.keymap.set("n", "<leader>pp", ":Pick resume<CR>")
vim.keymap.set("n", "<leader>pc", ":Pick commands<CR>")
vim.keymap.set("n", "<leader>pd", ":Pick diagnostic<CR>")
vim.keymap.set("n", "<leader>pg", ":Pick git_commits<CR>")
vim.keymap.set("n", "<leader>ph", ":Pick history<CR>")

-- ===================================================================
-- ## Package Manager Lazy
-- ===================================================================

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- QOL
    { 'nvim-mini/mini.pairs', version = '*', opts = {} }, -- auto pairs
    { 'nvim-mini/mini.bufremove', version = '*', opts = {} }, -- better buffer kill behavior
    { 'nvim-mini/mini.diff', version = '*', opts = { view = { style = 'sign' } } }, -- git diff
    { 'nvim-mini/mini.pick', version = '*', opts = {} }, -- picker
    { 'nvim-mini/mini.files', version = '*', opts = {} }, -- picker
    { 'nvim-mini/mini.visits', version = '*', opts = {} }, -- for recent files
    { 'nvim-mini/mini.extra', version = '*', opts = {} }, -- for extra pickers
    -- LSP
    { 'neovim/nvim-lspconfig' }, -- no opts, no setup
    { 'mason-org/mason.nvim', opts = {} },
    -- Completion
    {
      'saghen/blink.cmp',
      -- optional: provides snippets for the snippet source
      dependencies = {},
      -- use a release tag to download pre-built binaries
      version = '1.*',
      ---@module 'blink.cmp'
      ---@type blink.cmp.Config
      opts = {
        -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
        -- 'super-tab' for mappings similar to vscode (tab to accept)
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        -- All presets have the following mappings:
        -- C-space: Open menu or open docs if already open
        -- C-n/C-p or Up/Down: Select next/previous item
        -- C-e: Hide menu
        -- C-k: Toggle signature help (if signature.enabled = true)
        -- See :h blink-cmp-config-keymap for defining your own keymap
        keymap = {
          preset = 'super-tab',
          ['<C-k>'] = { 'show_documentation' },
        },
        appearance = {
          nerd_font_variant = 'mono'
        },
        -- (Default) Only show the documentation popup when manually triggered
        completion = { documentation = { auto_show = false } },
        -- Default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer' },
        },
        fuzzy = { implementation = "prefer_rust_with_warning" }
      },
      opts_extend = { "sources.default" }
    },
    -- Color Schemes
    { 'olimorris/onedarkpro.nvim' },
    { 'catppuccin/nvim' },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

-- Color scheme
vim.cmd.colorscheme(
  "catppuccin"
  -- "onedark"
  -- "default"
  -- "delek"
  -- "desert"
  -- "elflord"
  -- "evening"
  -- "habamax"
  -- "industry"
  -- "koehler"
  -- "lunaperche"
  -- "morning"
  -- "murphy"
  -- "pablo"
  -- "peachpuff"
  -- "quiet"
  -- "ron"
  -- "shine"
  -- "slate"
  -- "torte"
  -- "zellner"
)

-- ============================================================================
-- ## LSP & Languages
-- ============================================================================

-- Set filetype-specific settings
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = {"python" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

-- Function to find project root
local function find_root(patterns)
  local path = vim.fn.expand('%:p:h')
  local root = vim.fs.find(patterns, { path = path, upward = true })[1]
  return root and vim.fn.fnamemodify(root, ':h') or path
end

-- Go LSP setup
vim.lsp.enable('gopls')
vim.lsp.config('gopls', {
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      gofumpt = true,
    },
  },
})

-- go auto fmt on save
-- vim.api.nvim_create_autocmd("BufWritePost", {
--   pattern = "*.go",
--   callback = function()
--     -- Format the entire buffer with goimports, handling imports and formatting
--     vim.cmd("silent !goimports -w %")
--   end,
-- })
--
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    local params = vim.lsp.util.make_range_params()
    params.context = {only = {"source.organizeImports"}}
    -- buf_request_sync defaults to a 1000ms timeout. Depending on your
    -- machine and codebase, you may want longer. Add an additional
    -- argument after params if you find that you have to write the file
    -- twice for changes to be saved.
    -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end
    vim.lsp.buf.format({async = false})
  end
})

-- LSP keymaps 
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local opts = {buffer = event.buf}

    -- Navigation
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gs', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)

    -- Information
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)

    -- Code actions
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>br', vim.lsp.buf.rename, opts)

    -- Diagnostics
    vim.keymap.set('n', '<leader>nd', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<leader>pd', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
  end,
})

-- Better LSP UI
vim.diagnostic.config({
  virtual_text = { prefix = '●' },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "✗",
      [vim.diagnostic.severity.WARN] = "⚠",
      [vim.diagnostic.severity.INFO] = "ℹ",
      [vim.diagnostic.severity.HINT] = "💡",
    }
  }
})

vim.api.nvim_create_user_command('LspInfo', function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    print("No LSP clients attached to current buffer")
  else
    for _, client in ipairs(clients) do
      print("LSP: " .. client.name .. " (ID: " .. client.id .. ")")
    end
  end
end, { desc = 'Show LSP client info' })

