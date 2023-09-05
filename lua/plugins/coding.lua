return {
    {
        "neovim/nvim-lspconfig",
        version = "*",
        dependencies = { "hrsh7th/cmp-nvim-lsp" },
        config = function()
            local lspconfig = require("lspconfig")

            function on_lsp_attach()
                local clients = vim.lsp.get_active_clients()
                local bufnr = vim.api.nvim_get_current_buf()

                for _, client in ipairs(clients) do
                    if client.server_capabilities.goto_definition then
                        vim.api.nvim_buf_set_option(bufnr, "tagfunc", "v:lua.vim.lsp.tagfunc")
                    end

                    if client.server_capabilities.document_formatting then
                        vim.api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr()")
                    end
                end
            end

            -- Required for denols
            vim.g.markdown_fenced_languages = {
                "ts=typescript"
            }

            local servers = { "clangd", "pyright", "rust_analyzer", "tsserver", "bashls", "texlab", "svelte", "nil_ls", "denols" }

            local server_config = {
                rust_analyzer = {
                    ["rust-analyzer"] = {
                        checkOnSave = {
                            command = "clippy",
                            --extraArgs = { "--offline" }
                        }
                    }
                },
                texlab = {
                    texlab = {
                        build = {
                            executable = "pdflatex",
                            onSave = true
                        }
                    }
                }
            }

            for _, lsp in ipairs(servers) do
                local conf = {
                    capabilities = require("cmp_nvim_lsp").default_capabilities(),
                    on_attach = on_lsp_attach,
                    settings = server_config[lsp] or {}
                }
                if lsp == "clangd" then
                    conf.cmd = { "clangd", "--header-insertion=never" }

                    -- possible workaround for stuck diagnostics with clangd
                    conf.flags = {
                        allow_incremental_sync = false,
                        debounce_text_changes = 500
                    }
                elseif lsp == "bashls" then
                    conf.filetypes = { "sh", "bash" }
                end
                lspconfig[lsp].setup(conf)
            end

            local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }

            for type, icon in pairs(signs) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
            end

            vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
                virtual_text = false, -- redundant due to lsp_lines
                signs = true,
                underline = true,
                update_in_insert = true,
                severity_sort = true
            })
        end
    },

    {
        "nvim-treesitter/nvim-treesitter",
        version = "*",
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
        "L3MON4D3/LuaSnip"
    },

    {
        "hrsh7th/nvim-cmp",
        commit = "1cad30fcffa282c0a9199c524c821eadc24bf939",
        dependencies = {
            "hrsh7th/cmp-calc",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "kdheepak/cmp-latex-symbols",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip"
        },
        config = function()
            vim.opt.shortmess:append("c")

            local has_words_before = function()
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
            end

            local luasnip = require("luasnip")

            local cmp = require("cmp")

            local lspkind = {
                Text = "󰉿",
                Method = "󰆧",
                Function = "󰊕",
                Constructor = "",
                Field = "",
                Variable = "󰀫",
                Class = "󰠱",
                Interface = "",
                Module = "",
                Property = "󰜢",
                Unit = "󰑭",
                Value = "󰎠",
                Enum = "",
                Keyword = "󰌋",
                Snippet = "",
                Color = "󰏘",
                File = "󰈙",
                Reference = "󰈇",
                Folder = "󰉋",
                EnumMember = "",
                Constant = "󰏿",
                Struct = "󰙅",
                Event = "",
                Operator = "󰆕",
                TypeParameter = "",
            }

            local mapping_tab = function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif has_words_before() then
                    cmp.complete()
                else
                    fallback()
                end
            end

            local mapping_shift_tab = function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                else
                    fallback()
                end
            end

            cmp.setup({
                window = {
                    completion = {
                        border = vim.g._border
                    },
                    documentation = {
                        border = vim.g._border
                    },
                },
                completion = {
                    completeopt = "menuone,noselect",
                },
                preselect = cmp.PreselectMode.None,
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = {
                    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-d>"] = cmp.mapping.scroll_docs(4),
                    ["<C-e>"] = cmp.mapping.close(),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(mapping_tab, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(mapping_shift_tab, { "i", "s" }),
                },
                sources = {
                    { name = "calc" },
                    { name = "nvim_lsp" },
                    { name = "path" },
                    { name = "luasnip" },
                    { name = "latex_symbols" },
                    {
                        name = "buffer",
                        option = {
                            get_bufnrs = function()
                                local bufs = {}
                                for _, win in ipairs(vim.api.nvim_list_wins()) do
                                    bufs[vim.api.nvim_win_get_buf(win)] = true
                                end
                                return vim.tbl_keys(bufs)
                            end,
                            keyword_pattern = [[\k\+]]
                        }
                    },
                },
                formatting = {
                    format = function(entry, vim_item)
                        local ELLIPSIS_CHAR = "…"
                        local MAX_LABEL_WIDTH = 30

                        local label = vim_item.abbr
                        local truncated_label = vim.fn.strcharpart(label, 0, MAX_LABEL_WIDTH)
                        if truncated_label ~= label then
                            vim_item.abbr = truncated_label .. ELLIPSIS_CHAR
                        end

                        vim_item.kind = lspkind[vim_item.kind]
                        vim_item.menu = ({
                            calc = "[Calc]",
                            nvim_lsp = "[LSP]",
                            path = "[Path]",
                            luasnip = "[Snippet]",
                            latex_symbols = "[Latex]",
                            buffer = "[Buffer]",
                        })[entry.source.name]
                        return vim_item
                    end
                },
                sorting = {
                    comparators = {
                        cmp.config.compare.locality,
                        cmp.config.compare.recently_used,
                        cmp.config.compare.score,
                        cmp.config.compare.offset,
                        cmp.config.compare.order,
                    },
                },
                experimental = {
                    ghost_text = true
                }
            })

            cmp.setup.cmdline("/", {
                formatting = {
                    format = function(entry, vim_item)
                        vim_item.kind = nil
                        vim_item.menu = nil
                        return vim_item
                    end
                },
                mapping = {
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(mapping_tab, { "c" }),
                    ["<S-Tab>"] = cmp.mapping(mapping_shift_tab, { "c" }),
                },
                sources = {
                    {
                        name = "buffer",
                        option = {
                            get_bufnrs = function()
                                local bufs = {}
                                for _, win in ipairs(vim.api.nvim_list_wins()) do
                                    bufs[vim.api.nvim_win_get_buf(win)] = true
                                end
                                return vim.tbl_keys(bufs)
                            end
                        }
                    }
                }
            })

            cmp.setup.cmdline(":", {
                formatting = {
                    format = function(entry, vim_item)
                        vim_item.kind = nil
                        vim_item.menu = nil
                        return vim_item
                    end
                },
                mapping = {
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(mapping_tab, { "c" }),
                    ["<S-Tab>"] = cmp.mapping(mapping_shift_tab, { "c" }),
                },
                sources = {
                    { name = "cmdline", keyword_length = 2 } -- keyword_length is a workaround for https://github.com/hrsh7th/cmp-cmdline/issues/75 on :w
                }
            })
        end
    },

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

    {
        "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
        opts = {},
    },

    --- Languages
    {
        "lluchs/vim-wren",
        ft = "wren"
    },

    {
        "mtikekar/vim-bsv",
        ft = "bsv"
    },
}
