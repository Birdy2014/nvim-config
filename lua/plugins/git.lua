return {
    {
        "lewis6991/gitsigns.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            signs = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "" },
                topdelete = { text = "" },
                changedelete = { text = "▎" },
                untracked = { text = "▎" },
            },
        }
    },

    {
        "TimUntersberger/neogit",
        dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
        cmd = "Neogit",
        opts = {
            ignored_settings = {
                "NeogitPushPopup--force-with-lease",
                "NeogitPushPopup--force",
                "NeogitCommitPopup--allow-empty",
            },
            integrations = {
                diffview = true
            },
            disable_commit_confirmation = true -- Workaround for https://github.com/folke/noice.nvim/issues/232
        },
        init = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "NeogitCommitMessage",
                callback = function()
                    vim.opt_local.spell = true
                end
            })
        end
    },
}
