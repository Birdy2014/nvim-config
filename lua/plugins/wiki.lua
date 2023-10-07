return {
    {
        "vimwiki/vimwiki",
        init = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "vimwiki",
                callback = function()
                    vim.opt_local.spell = true
                    vim.cmd("hi! link VimwikiSuperScript Normal")
                end
            })

            vim.g.vimwiki_list = {
                {
                    path = "$HOME/vimwiki",
                    syntax = "default",
                    template_path = "$HOME/vimwiki/templates",
                    template_default = "default",
                    template_ext = ".html",
                    nested_syntaxes = {
                        python = "python",
                        cpp = "cpp",
                        java = "java",
                        bsv = "bsv",
                    }
                }
            }

            vim.g.vimwiki_global_ext = 0
        end
    },

    {
        "iamcco/markdown-preview.nvim",
        build = "cd app && npm install",
        ft = "markdown",
        config = function()
            vim.keymap.set("n", "<leader>tp", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Toggle markdown preview" })
        end
    },

    {
        "jbyuki/nabla.nvim",
        config = function()
            local nabla = require("nabla")

            vim.keymap.set("n", "<leader>p", nabla.popup, { desc = "Preview Math in Popup" })
            vim.keymap.set("n", "<leader>tm", nabla.toggle_virt, { desc = "Toggle Math Preview" })
        end
    },
}
