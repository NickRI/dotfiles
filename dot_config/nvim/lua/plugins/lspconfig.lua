lspconfig = require('lspconfig')
util = require('lspconfig/util')

local cmp_lsp = require('cmp_nvim_lsp')
local format = require("lsp-format")

if vim.fn['g:neovide'] then
	vim.env.PATH = vim.env.PATH .. ":/Users/nikolai/go/bin"
end

lspconfig.gopls.setup({
    cmd = {"gopls", "serve"},
    root_dir = util.root_pattern("go.work", "go.mod", ".git"),
    capabilities = cmp_lsp.default_capabilities(),
	
    settings = {
        gopls = {
            analyses = {
				unreachable = true,
                unusedparams = true,
            },
            staticcheck = true,
        },
    },
    on_attach = function(client)
        format.on_attach(client)

		vim.keymap.set('n', 'K', vim.lsp.buf.hover, {buffer=0})
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {buffer=0})
        vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, {buffer=0})
        vim.keymap.set('n', 'gm', vim.lsp.buf.implementation, {buffer=0})
        vim.keymap.set('n', '<leader>dn', vim.diagnostic.goto_next, {buffer=0})
        vim.keymap.set('n', '<leader>df', vim.diagnostic.goto_prev, {buffer=0})
		vim.keymap.set('n', '<leader>re', vim.lsp.buf.rename, {})
    end
})
