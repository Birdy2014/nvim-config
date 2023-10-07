return {
    {
        "sainnhe/gruvbox-material",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd("colorscheme gruvbox-material")

            vim.defer_fn(function()
                vim.g.terminal_color_0 = "#282828"
                vim.g.terminal_color_1 = "#cc241d"
                vim.g.terminal_color_2 = "#98971a"
                vim.g.terminal_color_3 = "#d79921"
                vim.g.terminal_color_4 = "#458588"
                vim.g.terminal_color_5 = "#b16286"
                vim.g.terminal_color_6 = "#689d6a"
                vim.g.terminal_color_7 = "#a89984"

                -- TODO: inlay hint
                -- vim.cmd[[highlight link LspInlayHint Comment']]
            end, 0)
        end
    },
}
