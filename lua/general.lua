local opt = vim.opt
local keymap = vim.keymap.set

-- Global options
opt.encoding = "utf-8"
opt.shada = "!,%,:100,'300,/50,<300,s100,f1,h"
opt.makeef = "error.err"
opt.spellfile = vim.fn.expand("$HOME/Dropbox/vim/spell/en.utf-8.add")
-- The next option is problematic with cmp-cmdline https://github.com/hrsh7th/cmp-cmdline/issues/87
-- opt.regexpengine = 1
opt.termguicolors = true
opt.cursorline = true
opt.cursorcolumn = true
opt.undofile = true
opt.undolevels = 1000
opt.undoreload = 10000
opt.cmdheight = 2
opt.laststatus = 2
opt.showmode = false
opt.completeopt = "menu,menuone,noselect"
opt.shortmess:append("c")
opt.list = true
opt.listchars = "tab:│ ,trail:•,extends:❯,precedes:❮"
opt.updatetime = 100
opt.signcolumn = "yes:2"
opt.background = "dark"
opt.timeoutlen = 300
opt.ttimeoutlen = 50
opt.mouse = ""
opt.history = 1000
opt.ttyfast = true
opt.viewoptions = "folds,options,cursor"
opt.hidden = true
opt.autoread = true
opt.fileformats = "unix,dos,mac"
opt.showcmd = true
opt.modeline = true
opt.modelines = 5
opt.startofline = false
opt.shelltemp = false
opt.backspace = "indent,eol,start"
opt.autoindent = true
opt.expandtab = true
opt.smarttab = true
opt.tabstop = 8
opt.softtabstop = 4
opt.shiftwidth = 4
opt.shiftround = true
opt.linebreak = true
opt.showbreak = "↪ "
opt.wrap = false
opt.scrolloff = 1
opt.scrolljump = 5
opt.wildmenu = true
opt.wildmode = "list:longest,full"
opt.wildignorecase = true
opt.wildchar = 9
opt.splitbelow = true
opt.splitright = true
opt.errorbells = false
opt.visualbell = false
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.smartindent = true
opt.backup = true
opt.backupdir = vim.fn.stdpath("cache") .. "/nvim"
opt.swapfile = false
opt.showmatch = true
opt.matchtime = 2
opt.number = true
opt.foldenable = true
opt.foldmethod = "indent"
opt.foldlevelstart = 99
opt.textwidth = 0
opt.colorcolumn = "87"

-- Clipboard - WSL support
local function is_wsl()
  local version = io.open("/proc/version", "r")
  if version then
    local content = version:read("*all")
    version:close()
    return content:lower():find("microsoft") ~= nil
  end
  return false
end

if is_wsl() then
  -- WSL clipboard support using PowerShell
  vim.g.clipboard = {
    name = 'WslClipboard',
    copy = {
      ['+'] = 'clip.exe',
      ['*'] = 'clip.exe',
    },
    paste = {
      ['+'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      ['*'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    },
    cache_enabled = 0,
  }
  
  -- URL opening for WSL - use Windows default browser
  vim.g.netrw_browsex_viewer = "cmd.exe /c start"
else
  opt.clipboard = "unnamedplus"  -- Use system clipboard for non-WSL
end

-- Set browsedir if supported
if vim.fn.has('browse') == 1 then
    opt.browsedir = "current"
end

-- Set grepprg if rg is available
if vim.fn.executable("rg") == 1 then
    opt.grepprg = "rg --no-heading --vimgrep --smart-case --follow"
    opt.grepformat = "%f:%l:%c:%m"
end

-- Keymaps
local function map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then options = vim.tbl_extend("force", options, opts) end
    keymap(mode, lhs, rhs, options)
end

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Window resizing
map("n", "<Up>", ":resize -2<CR>", { desc = "Decrease window height" })
map("n", "<Down>", ":resize +2<CR>", { desc = "Increase window height" })
map("n", "<Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })
map("n", "<Leader>+", ":exe 'resize ' .. (winheight(0) * 3/2)<CR>", { desc = "Increase window height" })
map("n", "<Leader>-", ":exe 'resize ' .. (winheight(0) * 2/3)<CR>", { desc = "Decrease window height" })

-- Misc mappings
map("n", "<Space>x", ":let @/=''<CR>", { desc = "Clear search highlight" })
map("n", "<F5>", ":setlocal spell! spelllang=en_us<CR>", { desc = "Toggle spell check" })
map("n", "<leader><Enter>", ":<C-u>buffers<CR>", { desc = "List buffers" })
map("n", "<leader>tn", ":tabnew<CR>", { desc = "New tab" })
map("n", "<leader>tc", ":tabclose<CR>", { desc = "Close tab" })

-- Buffer switching
for i = 1, 9 do
    map("n", "<leader>" .. i, ":" .. i .. "b<CR>", { desc = "Switch to buffer " .. i })
end
map("n", "<leader>0", ":10b<CR>", { desc = "Switch to buffer 10" })

-- Context highlighting toggle
map("n", "<F6>", function() require('plugins.context-highlight').toggle() end, { desc = "Toggle context highlighting" })

-- Autocommands
local function augroup(name)
    return vim.api.nvim_create_augroup("custom_" .. name, { clear = true })
end

-- Cursor setup
vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
    group = augroup("cursor_active"),
    callback = function()
        vim.opt.cursorline = true
        vim.opt.number = true
    end,
})

vim.api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
    group = augroup("cursor_inactive"),
    callback = function()
        vim.opt.cursorline = false
        vim.opt.number = false
    end,
})

-- Restore cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup("restore_cursor"),
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- FileType-specific settings
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("filetype_settings"),
    callback = function()
        local ft = vim.bo.filetype
        if ft == "css" or ft == "scss" then
            vim.wo.foldmethod = "marker"
            vim.wo.foldmarker = ","
        elseif ft == "python" then
            vim.wo.foldmethod = "indent"
            vim.bo.expandtab = true
            vim.bo.shiftwidth = 4
            vim.bo.tabstop = 4
            vim.wo.colorcolumn = "80"
        elseif ft == "markdown" then
            vim.wo.list = false
        elseif ft == "vim" then
            vim.wo.foldmethod = "indent"
            vim.bo.keywordprg = ":help"
        elseif ft == "c" or ft == "h" then
            vim.bo.expandtab = false
            vim.bo.tabstop = 8
            vim.bo.shiftwidth = 8
        elseif ft == "ruby" then
            vim.wo.foldmethod = "expr"
        elseif ft == "sh" then
            vim.wo.foldmethod = "syntax"
        elseif ft == "make" then
            vim.bo.expandtab = false
            vim.bo.tabstop = 4
            vim.bo.shiftwidth = 4
        end
    end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup("highlight_yank"),
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150, on_visual = true })
    end,
})