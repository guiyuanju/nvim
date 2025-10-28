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
vim.opt.conceallevel = 2 -- don't hide markup
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
vim.opt.autochdir = true -- auto change directory or not
-- vim.opt.iskeyword:append("-") -- treat dash as part of word
vim.opt.path:append("**") -- include subdirectories in search
vim.opt.selection = "inclusive" -- selection behavior
vim.opt.mouse = "a" -- enable mouse support
vim.opt.clipboard:append("unnamedplus") -- use system clipboard
vim.opt.modifiable = true -- allow buffer modifications
vim.opt.encoding = "UTF-8" -- set encoding

-- Split behavior
vim.opt.splitbelow = true -- Horizontal splits go below
vim.opt.splitright = true -- Vertical splits go right

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
		local dir = vim.fn.expand("<afile>:p:h")
		if vim.fn.isdirectory(dir) == 0 then
			vim.fn.mkdir(dir, "p")
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
	local size = vim.fn.getfsize(vim.fn.expand("%"))
	if size < 0 then
		return "nil"
	end
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
		["\22"] = "V-BLOCK", -- Ctrl-V
		c = "COMMAND",
		s = "SELECT",
		S = "S-LINE",
		["\19"] = "S-BLOCK", -- Ctrl-S
		R = "REPLACE",
		r = "REPLACE",
		["!"] = "SHELL",
		t = "TERMINAL",
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
	vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
		callback = function()
			vim.opt_local.statusline = table.concat({
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
				"%=", -- Right-align everything after this
				"%l:%c  %P ", -- Line:Column and Percentage
			})
		end,
	})
	vim.api.nvim_set_hl(0, "StatusLineBold", { bold = true })

	vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
		callback = function()
			vim.opt_local.statusline = "  %f%h%m%r │ %=  %l:%c   %P "
		end,
	})
end

setup_dynamic_statusline()

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
		{ "nvim-mini/mini.pairs", version = "*", opts = {} }, -- auto pairs
		{ "nvim-mini/mini.bufremove", version = "*", opts = {} }, -- better buffer kill behavior
		{ "nvim-mini/mini.diff", version = "*", opts = { view = { style = "sign" } } }, -- git diff
		{ "nvim-mini/mini.pick", version = "*", opts = {} }, -- picker
		{ "nvim-mini/mini.files", version = "*", opts = {} }, -- file picker
		{ "nvim-mini/mini.visits", version = "*", opts = {} }, -- for recent files
		{ "nvim-mini/mini.extra", version = "*", opts = {} }, -- for extra pickers
		{
			"stevearc/oil.nvim",
			opts = {
				default_file_explorer = true,
				columns = { "permissions", "size", "mtime" },
				delete_to_trash = true,
			},
			lazy = false,
		},
		{
			"NeogitOrg/neogit",
			dependencies = {
				"nvim-lua/plenary.nvim", -- required
				"sindrets/diffview.nvim", -- optional - Diff integration
				"nvim-mini/mini.pick", -- optional
			},
		},
		-- LSP
		{ "neovim/nvim-lspconfig" }, -- no opts, no setup
		{ "mason-org/mason.nvim", opts = {} },
		-- Completion
		{
			"saghen/blink.cmp",
			dependencies = {},
			version = "1.*",
			opts = {
				keymap = {
					preset = "enter",
					["K"] = { "show_documentation" },
				},
				appearance = {
					nerd_font_variant = "mono",
				},
				completion = { documentation = { auto_show = false } },
				sources = {
					default = { "lsp", "path", "snippets", "buffer" },
				},
				fuzzy = { implementation = "prefer_rust_with_warning" },
			},
			opts_extend = { "sources.default" },
		},
		-- {
		--   "folke/trouble.nvim",
		--   opts = {}, -- for default options, refer to the configuration section for custom setup.
		--   cmd = "Trouble",
		-- },
		{
			"folke/snacks.nvim",
			---@type snacks.Config
			opts = {
				image = {
					resolve = function(path, src)
						if require("obsidian.api").path_is_note(path) then
							return require("obsidian.api").resolve_image_path(src)
						end
					end,
				},
			},
		},
		{
			"obsidian-nvim/obsidian.nvim",
			version = "*", -- recommended, use latest release instead of latest commit
			ft = "markdown",
			lazy = false,
			opts = {
				legacy_commands = false,
				workspaces = {
					{
						name = "personal",
						path = "/Users/june/Library/Mobile Documents/iCloud~md~obsidian/Documents/notes",
					},
				},
				-- see below for full list of options 👇
				attachments = {
					img_folder = "./attachments",
				},
				daily_notes = {
					folder = "4_archived/daily",
					date_format = nil,
					alias_format = nil,
					default_tags = { "daily-notes" },
					workdays_only = true,
				},
			},
		},
		{
			"stevearc/conform.nvim",
			opts = {
				formatters_by_ft = {
					lua = { "stylua" },
					-- Conform will run multiple formatters sequentially
					python = { "isort", "black" },
					-- You can customize some of the format options for the filetype (:help conform.format)
					rust = { "rustfmt", lsp_format = "fallback" },
					-- Conform will run the first available formatter
					javascript = { "prettierd", "prettier", stop_after_first = true },
					go = { "gofumpt", "goimports" },
				},
				format_on_save = {
					-- These options will be passed to conform.format()
					timeout_ms = 500,
					lsp_format = "fallback",
				},
			},
		},
		{
			"gruvw/strudel.nvim",
			build = "npm install",
			config = function()
				require("strudel").setup()
			end,
			lazy = false,
		},
		--Color Schemes
		{ "olimorris/onedarkpro.nvim" },
		{ "catppuccin/nvim" },
		{ "nyoom-engineering/oxocarbon.nvim" },
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
	-- "oxocarbon"
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
	pattern = { "python" },
	callback = function()
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "go" },
	callback = function()
		vim.opt_local.makeprg = "go run ."
	end,
})

-- Function to find project root
local function find_root(patterns)
	local path = vim.fn.expand("%:p:h")
	local root = vim.fs.find(patterns, { path = path, upward = true })[1]
	return root and vim.fn.fnamemodify(root, ":h") or path
end

-- Go LSP setup
vim.lsp.enable("gopls")

-- rust LSP setup
vim.lsp.enable("rust_analyzer")

-- LSP keymaps
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(event)
		local opts = { buffer = event.buf }

		-- Information
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)

		-- Code actions
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts)

		-- Diagnostics
		vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
		vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)
	end,
})

-- Better LSP UI
vim.diagnostic.config({
	virtual_text = { prefix = "●" },
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
		},
	},
})

vim.api.nvim_create_user_command("LspInfo", function()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients == 0 then
		print("No LSP clients attached to current buffer")
	else
		for _, client in ipairs(clients) do
			print("LSP: " .. client.name .. " (ID: " .. client.id .. ")")
		end
	end
end, { desc = "Show LSP client info" })

-- ===================================================================
-- ## Key mappings
-- ===================================================================

vim.g.mapleader = " " -- Set leader key to space
vim.g.maplocalleader = " " -- Set local leader key (NEW)

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
vim.keymap.set("n", "<leader>bD", ":bdelete!<CR>", { desc = "Delete buffer" })
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
vim.keymap.set("n", "<leader>fe", ":Oil<CR>", { desc = "Open file explorer" })
vim.keymap.set("n", "<leader>ff", ":Pick files<CR>", { desc = "Find file" })
vim.keymap.set("n", "<leader>fc", ":e ~/.config/nvim/init.lua<CR>", { desc = "Edit config" })
vim.keymap.set("n", "<leader>fs", ":w<CR>")

-- Adjust LHS and description to your liking
vim.keymap.set("n", "<leader>fr", ":Pick visit_paths cwd='' recency_weight=0.5<CR>")
-- vim.keymap.set('n', '<leader>fr', ":Pick visit_paths cwd='' recency_weight=1 filter='core'")

-- Terminal
local terminal = nil
local terminal_height = 15
local function toggle_terminal()
	if terminal and not vim.api.nvim_buf_is_valid(terminal) then
		terminal = nil
	end

	-- no terminal, create new
	if terminal == nil then
		vim.cmd("split")
		vim.cmd("terminal")
		vim.api.nvim_win_set_height(0, terminal_height)
		terminal = vim.api.nvim_get_current_buf()
		return
	end

	if vim.api.nvim_buf_is_valid(terminal) then
		local winid = vim.fn.bufwinid(terminal)
		if winid ~= -1 then
			-- visible, hide it
			vim.api.nvim_win_close(winid, true)
		else
			-- hidden, show it
			vim.cmd("sbuffer " .. terminal)
			vim.api.nvim_win_set_height(0, terminal_height)
		end
		return
	end
end

vim.keymap.set("n", "<leader>t", toggle_terminal)
vim.keymap.set({ "n", "t", "i", "v" }, "<C-/>", toggle_terminal)
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Esc to normal mode in terminal" })
vim.keymap.set("t", "<C-d>", "<C-\\><C-n> | :bd!<CR>", { desc = "Close terminal" })

-- Copy full file-path
vim.keymap.set("n", "<leader>fp", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("file:", path)
end)

-- Git
vim.keymap.set("n", "<leader>g", ":Neogit<CR>")

-- Trouble
-- vim.keymap.set("n", "<leader>lD", ":Trouble diagnostics toggle<CR>")
-- vim.keymap.set("n", "<leader>ld", ":Trouble diagnostics toggle filter.buf=0<CR>")
-- vim.keymap.set("n", "<leader>ls", ":Trouble symbols toggle focus=false<CR>")
-- vim.keymap.set("n", "<leader>lL", ":Trouble lsp toggle focus=false win.position=right<CR>")
-- vim.keymap.set("n", "<leader>lL", ":Trouble loclist toggle<CR>")
-- vim.keymap.set("n", "<leader>lq", ":Trouble qflist toggle<CR>")

-- Search
-- List (Search)
vim.keymap.set("n", "<leader>sb", function()
	MiniExtra.pickers.buf_lines({ scope = "current", preserve_order = false })
end)
vim.keymap.set("n", "<leader>sg", ":Pick grep<CR>", { desc = "Grep" })
-- vim.keymap.set("n", "<leader>ss", function() MiniExtra.pickers.lsp({ scope = 'document_symbol' }) end, { desc = "Grep" })
vim.keymap.set("n", "<leader>ss", ":Pick lsp scope='document_symbol'<CR>")
-- delete default keybindings
if not vim.fn.empty(vim.fn.maparg("n", "grr")) then -- prevent :source error
	vim.keymap.del("n", "grr")
	vim.keymap.del("n", "gri")
	vim.keymap.del("n", "grt")
	vim.keymap.del("n", "grn")
	vim.keymap.del("n", "gra")
end
vim.keymap.set("n", "gr", ":Pick lsp scope='references'<CR>")
vim.keymap.set("n", "<leader>sd", ":Pick diagnostic<CR>", opts)
vim.keymap.set("n", "<leader>sm", ":Pick keymaps<CR>", opts)
vim.keymap.set("n", "<leader>p", ":Pick resume<CR>", opts)

-- Jump
vim.keymap.set("n", "<leader>jc", ":e ~/.config/nvim/init.lua<CR>")
vim.keymap.set("n", "<leader>jo", ":Obsidian quick_switch<CR>")
-- vim.keymap.set("n", "<leader>js", ":e ~/Code/Resources/strudel/main.str")
vim.keymap.set("n", "<leader>js", function()
	MiniPick.builtin.files(nil, { source = { cwd = "~/Code/Resources/strudel/" } })
end)

-- Obsidian
vim.keymap.set("n", "<leader>oo", ":Obsidian quick_switch<CR>")
vim.keymap.set("n", "<leader>op", ":Obsidian paste_img<CR>")
vim.keymap.set("n", "<leader>ob", ":Obsidian backlinks<CR>")
vim.keymap.set("n", "<leader>og", ":Obsidian follow_link<CR>")
vim.keymap.set("n", "<leader>on", ":Obsidian new<CR>")
vim.keymap.set("n", "<leader>od", ":Obsidian dailies<CR>")

-- Strudel
local strudel = require("strudel")
vim.keymap.set("n", "<leader>ml", strudel.launch, { desc = "Launch Strudel" })
vim.keymap.set("n", "<leader>mq", strudel.quit, { desc = "Quit Strudel" })
vim.keymap.set("n", "<leader>mt", strudel.toggle, { desc = "Strudel Toggle Play/Stop" })
vim.keymap.set("n", "<leader>mu", strudel.update, { desc = "Strudel Update" })
vim.keymap.set("n", "<leader>ms", strudel.stop, { desc = "Strudel Stop Playback" })
vim.keymap.set("n", "<leader>mb", strudel.set_buffer, { desc = "Strudel set current buffer" })
vim.keymap.set("n", "<leader>mx", strudel.execute, { desc = "Strudel set current buffer and update" })

-- Visit labels
local map_vis = function(keys, call, desc)
	local rhs = "<Cmd>lua MiniVisits." .. call .. "<CR>"
	vim.keymap.set("n", "<Leader>" .. keys, rhs, { desc = desc })
end

map_vis("va", "add_label('core')", "Add label")
map_vis("vd", "remove_label('core')", "Remove label")
vim.keymap.set("n", "<leader>vv", ":Pick visit_paths cwd='' filter='core'<CR>") -- all core
vim.keymap.set("n", "<leader>vV", ":Pick visit_paths cwd=nil filter='core'<CR>") -- cwd core

-- UI
vim.keymap.set("n", "<leader>uw", ":set wrap!<CR>")
