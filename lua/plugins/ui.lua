return {
    {
        "rcarriga/nvim-notify",
        opts = {
            stages = "fade",
        }
    },

    -- BUG: not working in neovide with multigrid: https://github.com/folke/noice.nvim/issues/17
    {
        "folke/noice.nvim",
        version = "*",
        dependencies = { "MunifTanjim/nui.nvim" },
        opts = {
            cmdline = {
                enabled = true,
                view = "cmdline_popup",
                opts = {}, -- global options for the cmdline. See section on views
                ---@type table<string, CmdlineFormat>
                format = {
                    cmdline = { pattern = "^:", icon = "", lang = "vim" },
                    search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
                    search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
                    filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
                    lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
                    help = { pattern = "^:%s*he?l?p?%s+", icon = "󰋖" },
                    input = {}, -- Used by input()
                },
            },
            messages = {
                enabled = true,
                view = "mini",
                view_error = "mini",
                view_warn = "mini",
                view_history = "messages",
                view_search = "virtualtext",
            },
            notify = {
                enabled = true,
                view = "mini",
            },
            lsp = {
                -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
                hover = {
                    enabled = true,
                    silent = false, -- set to true to not show a message if hover is not available
                    view = nil, -- when nil, use defaults from documentation
                    ---@type NoiceViewOptions
                    opts = {
                        border = {
                            style = vim.g._border,
                            padding = { 0, 1 },
                        },
                        position = { row = 2, col = 0 },
                    }, -- merged with defaults from documentation
                },
                signature = {
                    enabled = true,
                    auto_open = {
                        enabled = true,
                        trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
                        luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
                        throttle = 50, -- Debounce lsp signature help request by 50ms
                    },
                    view = nil, -- when nil, use defaults from documentation
                    ---@type NoiceViewOptions
                    opts = {
                        border = {
                            style = vim.g._border,
                            padding = { 0, 1 },
                        },
                        position = { row = 2, col = 0 },
                    }, -- merged with defaults from documentation
                }
            },
            -- you can enable a preset for easier configuration
            presets = {
                bottom_search = false, -- use a classic bottom cmdline for search
                command_palette = true, -- position the cmdline and popupmenu together
                long_message_to_split = true, -- long messages will be sent to a split
                inc_rename = false, -- enables an input dialog for inc-rename.nvim
                lsp_doc_border = false, -- add a border to hover docs and signature help
            },
            views = {
                mini = {
                    timeout = 5000,
                }
            },
        }
    },

    -- Maybe vim.ui.select will be included in noice.nvim
    {
        "stevearc/dressing.nvim",
        opts = {
            input = {
                enabled = false,
            },
            select = {
                enabled = true,
                backend = { "telescope", "builtin" },

                -- Trim trailing `:` from prompt
                trim_prompt = true,

                -- Options for telescope selector
                -- These are passed into the telescope picker directly. Can be used like:
                -- telescope = require("telescope.themes").get_ivy({...})
                telescope = nil,
            }
        }
    },

    {
        "lewis6991/satellite.nvim",
        config = function()
            require("satellite").setup()
        end
    },

    {
        "goolord/alpha-nvim",
        dependencies = { "kyazdani42/nvim-web-devicons" },
        config = function()
            local alpha_config = require("alpha.themes.theta").config
            local dashboard = require("alpha.themes.dashboard")
            alpha_config.layout[6].val = {
                { type = "text", val = "Quick links", opts = { hl = "SpecialComment", position = "center" } },
                { type = "padding", val = 1 },
                dashboard.button("e", "󰈔  New file", "<cmd>ene<cr>"),
                dashboard.button("SPC f f", "󰈞  Find file", "<cmd>Telescope find_files<cr>"),
                dashboard.button("SPC f p", "󰃀  Open Projects", "<cmd>Telescope project<cr>"),
                dashboard.button("SPC f m", "󰞋  Find Man Pages", "<cmd>Telescope man_pages sections=['ALL']<cr>"),
                dashboard.button("SPC t t", "󰙅  Open File Tree", "<cmd>NvimTreeToggle<cr>"),
                dashboard.button("q", "󰅙  Quit" , "<cmd>qa<cr>"),
            }
            require("alpha").setup(alpha_config)
        end
    },

    {
        "lukas-reineke/indent-blankline.nvim",
        opts = {
            buftype_exclude = { "terminal" },
            filetype_exclude = { "alpha", "lazy", "help", "man", "NvimTree", "aerial", "noice", "markdown" },
            space_char_blankline = " ",
            show_current_context = true
        }
    },
}
