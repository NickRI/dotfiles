require('telescope').setup({
    extensions = {
        file_browser = {
            hidden = true
        },
        project = {
            hidden_files = false
        }
    }
})

require('telescope').load_extension('file_browser')
require('telescope').load_extension('project')
require('telescope').load_extension('gh')

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>br', ':Telescope file_browser<cr>', {})
vim.keymap.set('n', '<leader>bs', builtin.buffers, {})
vim.keymap.set('n', '<leader>pp', ':Telescope project<cr>', {})
vim.keymap.set('n', '<leader>di', builtin.diagnostics, {})
vim.keymap.set('n', '<leader>ht', builtin.help_tags, {})
vim.keymap.set('n', '<leader>r', builtin.lsp_references, {})
vim.keymap.set('n', '<leader>d', builtin.lsp_definitions, {})
vim.keymap.set('n', '<leader>t', builtin.lsp_type_definitions, {})
vim.keymap.set('n', '<leader>i', builtin.lsp_implementations, {})
