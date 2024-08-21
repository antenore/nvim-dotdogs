local status_ok, none_ls = pcall(require, "none-ls")
if not status_ok then
  return
end

none_ls.setup({
    sources = {
        -- none_ls.builtins.formatting.terraform_fmt,
    },
})
