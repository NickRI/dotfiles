require('nightfox').setup({
    options = {
        styles = {
            comments = "italic",
            keywords = "bold",
            types = "italic,bold",
        }
    }
})

-- load the configurations
vim.cmd("colorscheme nordfox")
