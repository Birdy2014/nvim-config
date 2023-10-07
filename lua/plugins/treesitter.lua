return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        dependencies = { "yioneko/nvim-yati", "yioneko/vim-tmindent" },
        config = function()
            require("nvim-treesitter.configs").setup {
                -- NOTE: comment parser is slow
                ensure_installed = { "bash", "c", "c_sharp", "cmake", "cpp", "css", "cuda", "dart", "dockerfile", "dot", "fish", "gdscript", "glsl", "go", "gomod", "hjson", "html", "java", "javascript", "jsdoc", "json", "json5", "kotlin", "latex", "lua", "make", "markdown", "markdown_inline", "ninja", "nix", "org", "php", "pug", "python", "rasi", "regex", "rust", "scss", "svelte", "toml", "tsx", "typescript", "verilog", "vim", "vue", "yaml" },
                highlight = {
                    enable = true,
                },
                indent = {
                    enable = false,
                },
                yati = {
                    enable = true,
                    default_lazy = true,
                    default_fallback = function(lnum, computed, bufnr)
                        if vim.tbl_contains(tm_fts, vim.bo[bufnr].filetype) then
                            return require("tmindent").get_indent(lnum, bufnr) + computed
                        end
                        -- or any other fallback methods
                        return require("nvim-yati.fallback").vim_auto(lnum, computed, bufnr)
                    end,
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<CR>",
                        node_incremental = "<CR>",
                        -- scope_incremental = "grc",
                        node_decremental = "<BS>",
                    },
                }
            }

            vim.wo.foldmethod = "expr"
            vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
        end
    },

    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("nvim-treesitter.configs").setup {
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,

                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@comment.outer",
                            ["ic"] = "@comment.inner",
                        },
                    },
                },
            }
        end
    },
}
