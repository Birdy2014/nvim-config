return {
    {
        "RRethy/vim-illuminate",
        config = function()
            require("illuminate").configure {
                providers = {
                    "lsp",
                    "treesitter",
                },
                delay = 100,
            }

            vim.api.nvim_create_augroup("illuminate_augroup", { clear = true })
            vim.api.nvim_create_autocmd("VimEnter", {
                group = "illuminate_augroup",
                callback = function()
                    vim.api.nvim_set_hl(0, "IlluminatedWordText", { link = "CursorLine", underline = false })
                    vim.api.nvim_set_hl(0, "IlluminatedWordRead", { link = "CursorLine", underline = false })
                    vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { link = "CursorLine", underline = false })
                end
            })
        end
    },

    {
        "stevearc/aerial.nvim",
        opts = {
            layout = {
                placement = "edge"
            },
            attach_mode = "global",
            highlight_on_hover = true,
        }
    },

    {
        "folke/trouble.nvim",
        opts = {
            position = "right"
        }
    },

    {
        "folke/todo-comments.nvim",
        opts = {},
    },

    {
        "vuki656/package-info.nvim",
        version = "*",
        dependencies = { "MunifTanjim/nui.nvim" },
        opts = {},
    },
}
