require('nvim-treesitter.configs').setup({
    -- A list of parser names, or "all"
    ensure_installed = { 
        "c", "lua", "go", "gomod", 
        "html", "css", "markdown", 
        "sql", "dot", "dockerfile",
        "yaml"
    },
 })
