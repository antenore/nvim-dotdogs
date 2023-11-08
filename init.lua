--  ============================================================================
--  ███╗   ██╗  | My Neovim dot(dogs)files
--  ████╗  ██║  | Use it at your own risk, before to ask questions, RTFM.
--  ██╔██╗ ██║  | To quit this file type :q
--  ██║╚██╗██║  | License: Apache 2.0
--  ██║ ╚████║  | Copyleft Antenore (tmow) Gatta 2022 — ∞
--  ╚═╝  ╚═══╝  | - https://antenore.simbiosi.org
--   ૮ ⚆ﻌ⚆ა     | - Partly based from https://github.com/ttys3/nvim-config.git
--  ===== Before everything else ===============================================
if vim.fn.has('win64') == 1 then
  -- vim.opt.shell='bash.exe'
  -- vim.opt.shellcmdflag = '-c'
  -- vim.opt.shellredir = '>%s 2>&1'
  -- vim.g.shellquote=''
  -- vim.g.shellxescape=''
  -- vim.g.shellxquote=''
  -- vim.opt.shellpipe='2>&1| tee'
  vim.opt.shell = 'cmd.exe'
end
vim.g.did_load_filetypes = 1 -- No default filetype.vim (nathom/filetype.nvim)
vim.g.mapleader = ','
vim.g.maplocalleader = ','
-- ===== Modules ===============================================================
local modules = {
  'utils',
  'general',
  'plugins',
}

for _, module in ipairs(modules) do
  local ok, err = pcall(require, module)
  if not ok then
    error('Error loading ' .. module .. '\n\n' .. err)
  end
  err = nil
end
--  ===== Mapping ==============================================================
vim.cmd [[autocmd BufWritePost general.lua source <afile> | Lazy install]]
vim.cmd [[autocmd BufWritePost plugins.lua source <afile> | Lazy install]]
-- ================================== EOF ======================================
-- vim:set ts=2 sts=2 sw=2 expandtab:
