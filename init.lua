--[[

External Requirements:
- Neovim 0.9+
- Terminal with support for unicode and truecolors
- A patched font from https://www.nerdfonts.com/
- Language Servers:
    - clangd
    - pyright
    - rust_analyzer
    - tsserver
    - texlab
    - bashls

]]

-- TODO: Enable inlay hints

-- Disable unused providers
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

--- -----------------------
---        FILETYPES
--- -----------------------
vim.filetype.add({
    pattern = {
        [".*"] = {
            priority = -math.huge,
            function(path, bufnr)
                local content = vim.filetype.getlines(bufnr, 1)
                if vim.filetype.matchregex(content, [[#!.*fish]]) then
                    return "fish"
                elseif vim.filetype.matchregex(content, [[#!.*bash]]) then
                    return "bash"
                end
            end
        }
    }
})

--- -----------------------
---     CONFIGURATION
--- -----------------------
-- basics
vim.opt.compatible = false
vim.opt.hidden = true

-- visual
vim.opt.background = "dark"
vim.opt.breakindent = true
vim.opt.breakindentopt = "sbr"
vim.opt.cmdheight = 0
vim.opt.conceallevel = 1
vim.opt.linebreak = true
vim.opt.list = true
vim.opt.listchars = "tab:>-,trail:-,nbsp:+"
vim.opt.number = true
vim.opt.showbreak = "↪ "
vim.opt.showmode = false
vim.opt.termguicolors = true
vim.opt.title = true

-- split
vim.opt.eadirection = "hor"
vim.opt.equalalways = true
vim.opt.splitbelow = true
vim.opt.splitright = true

-- spelling
vim.opt.spelllang = { "en", "de_20" }

-- folding
vim.opt.foldlevel = 99

-- code style
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- mouse
vim.opt.mouse = "a"
vim.opt.mousemodel = "extend"

-- Gui settings
vim.opt.guifont = "monospace:h10"
vim.g.neovide_remember_window_size = false

-- other
vim.opt.inccommand = "nosplit"
vim.opt.scrolloff = 1
vim.opt.switchbuf:append("useopen")
vim.opt.timeoutlen = 500
vim.opt.undofile = true
vim.opt.virtualedit = "block"
vim.opt.shell = "/bin/sh" -- Fix performance issues with nvim-tree.lua and potentially some other bugs
vim.opt.backupcopy = "yes" -- Fix reloading issues with parcel
vim.opt.fsync = true -- Prevent potential data loss on system crash

vim.g._border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" }

--- -----------------------
---        PLUGINS
--- -----------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct

require("lazy").setup({
    --- Theme / Statusbars / Visual
    {
        "sainnhe/gruvbox-material",
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

    {
        "NvChad/nvim-colorizer.lua",
        opts = {
            filetypes = {
                "*",
                css = { css = true },
                sass = { css = true },
                scss = { css = true },
            },
            user_default_options = {
                RGB = true, -- #RGB hex codes
                RRGGBB = true, -- #RRGGBB hex codes
                names = false, -- "Name" codes like Blue or blue
                RRGGBBAA = false, -- #RRGGBBAA hex codes
                AARRGGBB = false, -- 0xAARRGGBB hex codes
                rgb_fn = false, -- CSS rgb() and rgba() functions
                hsl_fn = false, -- CSS hsl() and hsla() functions
                css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
                css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn
                -- Available modes for `mode`: foreground, background,  virtualtext
                mode = "background", -- Set the display mode.
                -- Available methods are false / true / "normal" / "lsp" / "both"
                -- True is same as normal
                tailwind = false, -- Enable tailwind colors
                -- parsers can contain values used in |user_default_options|
                sass = { enable = false, parsers = { css }, }, -- Enable sass colors
                virtualtext = "■",
            },
            -- all the sub-options of filetypes apply to buftypes
            buftypes = {},
        }
    },


    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "kyazdani42/nvim-web-devicons" },
        config = function()
            local function package_info_status()
                local status = require("package-info").get_status()
                if status == " " then
                    return ""
                end
                return status
            end

            local lualine = require("lualine")
            lualine.setup {
                options = {
                    theme = "gruvbox-material",
                    section_separators = {},
                    component_separators = "|",
                    icons_enabled = true,
                    globalstatus = true,
                },
                sections = {
                    lualine_a = { {"mode", upper = true} },
                    lualine_b = { {"branch", icon = ""}, { "diff" } },
                    lualine_c = {
                        { "filename", path = 1, file_status = true },
                        { "diagnostics", sources = { "nvim_diagnostic" } },
                        { "aerial", sep = " ❯ " },
                        { package_info_status },
                        { function() return vim.fn["vm#themes#statusline"]() end }
                    },
                    lualine_x = {
                        {
                            function()
                                local recording_register = vim.fn.reg_recording()
                                if recording_register == "" then
                                    return ""
                                end
                                return "@" .. recording_register
                            end
                        },
                        "encoding",
                        "fileformat",
                        "filetype"
                    },
                    lualine_y = { "progress" },
                    lualine_z = { "location"  },
                },
                extensions = { "nvim-tree", "aerial", "man", "quickfix" }
            }
        end
    },

    {
        "romgrk/barbar.nvim",
        tag = "v1.5.0",
        dependencies = { "kyazdani42/nvim-web-devicons" },
        opts = {
            closable = false,
            letters = "asdfjklöghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERUTYQP",
        }
    },

    {
        "kyazdani42/nvim-tree.lua",
        dependencies = { "kyazdani42/nvim-web-devicons" },
        config = function()
            vim.api.nvim_create_autocmd("BufWinEnter", {
                pattern = "NvimTree*",
                callback = function()
                    vim.opt_local.cursorline = true
                end
            })

            require("nvim-tree").setup {
                hijack_cursor = true,
                update_cwd = true,
                diagnostics = {
                    enable = true,
                    icons = {
                        hint = "",
                        info = "",
                        warning = "",
                        error = "",
                    }
                },
                update_focused_file = {
                    enable = true,
                },
                filters = {
                    dotfiles = true,
                    custom = {
                        "^%.git$",
                        "^node_modules$",
                        "^%.cache$",
                        "^%.ccls-cache$"
                    },
                },
                actions = {
                    change_dir = {
                        global = true
                    },
                    open_file = {
                        resize_window = true
                    },
                },
                view = {
                    width = 40,
                },
                renderer = {
                    highlight_git = true,
                },
                on_attach = function(bufnr)
                    local api = require("nvim-tree.api")

                    local function opts(desc)
                        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                    end

                    vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
                    vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
                    vim.keymap.set("n", "O", api.node.run.system, opts("Run System"))
                    vim.keymap.set("n", "<Tab>", api.node.open.preview, opts("Open Preview"))

                    vim.keymap.set("n", "c", api.tree.change_root_to_node, opts("CD"))
                    vim.keymap.set("n", "u", api.tree.change_root_to_parent, opts("Up"))

                    vim.keymap.set("n", "<", api.node.navigate.sibling.prev, opts("Previous Sibling"))
                    vim.keymap.set("n", ">", api.node.navigate.sibling.next, opts("Next Sibling"))
                    vim.keymap.set("n", "P", api.node.navigate.parent, opts("Parent Directory"))
                    vim.keymap.set("n", "<BS>", api.node.navigate.parent_close, opts("Close Directory"))
                    vim.keymap.set("n", "K", api.node.navigate.sibling.first, opts("First Sibling"))
                    vim.keymap.set("n", "J", api.node.navigate.sibling.last, opts("Last Sibling"))
                    vim.keymap.set("n", "[c", api.node.navigate.git.prev, opts("Prev Git"))
                    vim.keymap.set("n", "]c", api.node.navigate.git.next, opts("Next Git"))

                    vim.keymap.set("n", "I", api.tree.toggle_gitignore_filter, opts("Toggle Git Ignore"))
                    vim.keymap.set("n", "H", api.tree.toggle_hidden_filter, opts("Toggle Dotfiles"))

                    vim.keymap.set("n", "a", api.fs.create, opts("Create"))
                    vim.keymap.set("n", "D", api.fs.remove, opts("Delete"))
                    vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))
                    vim.keymap.set("n", "<C-r>", api.fs.rename_sub, opts("Rename: Omit Filename"))
                    vim.keymap.set("n", "d", api.fs.cut, opts("Cut"))
                    vim.keymap.set("n", "y", api.fs.copy.node, opts("Copy"))
                    vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
                    vim.keymap.set("n", "Y", api.fs.copy.relative_path, opts("Copy Relative Path"))
                    vim.keymap.set("n", "gy", api.fs.copy.filename, opts("Copy Name"))

                    vim.keymap.set("n", "R", api.tree.reload, opts("Refresh"))
                    vim.keymap.set("n", "q", api.tree.close, opts("Close"))
                    vim.keymap.set("n", "g?", api.tree.toggle_help, opts("Help"))
                end,
                -- sort files with numbers correctly
                sort_by = function(nodes)
                    table.sort(nodes, function(a, b)
                        local chars_a = {string.byte(a.name, 1, #a.name)}
                        local chars_b = {string.byte(b.name, 1, #b.name)}
                        local i_a = 1
                        local i_b = 1
                        for i = 1, math.max(#chars_a, #chars_b) do
                            c_a = chars_a[i_a]
                            c_b = chars_b[i_b]

                            if not c_a then
                                return true
                            elseif not c_b then
                                return false
                            end

                            -- compare numbers
                            local number_string_a = ""
                            while c_a and c_a >= 48 and c_a <= 57 do
                                number_string_a = number_string_a .. string.char(c_a)
                                i_a = i_a + 1
                                c_a = chars_a[i_a]
                            end

                            local number_string_b = ""
                            while c_b and c_b >= 48 and c_b <= 57 do
                                number_string_b = number_string_b .. string.char(c_b)
                                i_b = i_b + 1
                                c_b = chars_b[i_b]
                            end

                            if #number_string_a == 0 and #number_string_b > 0 then
                                return true
                            elseif #number_string_a > 0 and #number_string_b == 0 then
                                return false
                            elseif #number_string_a > 0 and #number_string_b > 0 then
                                return tonumber(number_string_a) < tonumber(number_string_b)
                            end

                            -- compare chars
                            if c_a ~= c_b then
                                return c_a < c_b
                            end
                            i_a = i_a + 1
                            i_b = i_b + 1
                        end
                    end)
                end
            }
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

    -- Workaround for https://github.com/neovim/neovim/issues/12517
    {
        "stevearc/stickybuf.nvim",
        opts = {
            get_auto_pin = function(bufnr)
                local buftype = vim.bo[bufnr].buftype
                local filetype = vim.bo[bufnr].filetype
                local bufname = vim.api.nvim_buf_get_name(bufnr)

                if filetype == "NvimTree" and (vim.wo.winfixwidth or vim.wo.winfixheight) then
                    return "filetype"
                end

                return require("stickybuf").should_auto_pin(bufnr)
            end
        }
    },

    {
        "smjonas/live-command.nvim",
        main = "live-command", -- lazy uses the deprecated "live_command" by default
        opts = {
            commands = {
                Normal = { cmd = "normal" },
            },
        }
    },

    {
        "b0o/incline.nvim",
        opts = {
            render = function(props)
                -- generate name
                local bufname = vim.api.nvim_buf_get_name(props.buf)
                if bufname == "" then
                    return "[No name]"
                end

                -- ":." is the filename relative to the PWD (=project)
                bufname = vim.fn.fnamemodify(bufname, ":.")

                -- find devicon for the bufname
                local icon = require("nvim-web-devicons").get_icon(bufname, nil, { default = true })

                -- cut the content if it takes more than half of the screen
                local max_len = vim.api.nvim_win_get_width(props.win) / 2

                if #bufname > max_len then
                    return icon .. " …" .. string.sub(bufname, #bufname - max_len, -1)
                else
                    return icon .. " " .. bufname
                end
            end,
            hide = {
                only_win = true
            }
        }
    },

    --- Navigation
    {
        "christoomey/vim-tmux-navigator"
    },

    {
        "phaazon/hop.nvim",
        opts = {
            keys = "asdghklöqwertyuiopzxcvbnmfjä"
        }
    },

    {
        "michaeljsmith/vim-indent-object"
    },

    {
        "nacro90/numb.nvim",
        opts = {
           show_numbers = true,
           show_cursorline = true
        }
    },

    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            defaults = {
                file_ignore_patterns = {
                    "node_modules"
                },
                preview = {
                    mime_hook = function(filepath, bufnr, opts)
                        local is_image = function(filepath)
                            local image_extensions = { "png", "jpg", "gif" }   -- Supported image formats
                            local split_path = vim.split(filepath:lower(), ".", {plain=true})
                            local extension = split_path[#split_path]
                            return vim.tbl_contains(image_extensions, extension)
                        end

                        if is_image(filepath) and vim.fn.executable("catimg") == 1 then
                            local term = vim.api.nvim_open_term(bufnr, {})
                            local width = vim.api.nvim_win_get_width(opts.winid)
                            local height = vim.api.nvim_win_get_height(opts.winid)
                            local function send_output(_, data, _ )
                                for _, d in ipairs(data) do
                                    vim.api.nvim_chan_send(term, d.."\r\n")
                                end
                            end
                            vim.fn.jobstart({
                                "catimg", "-w", width * 2, " -H", height * 2, filepath
                            },
                            { on_stdout=send_output, stdout_buffered=true })
                        else
                            require("telescope.previewers.utils").set_preview_message(bufnr, opts.winid, "Binary cannot be previewed")
                        end
                    end
                }
            }
        }
    },

    {
        "nvim-telescope/telescope-project.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        config = function()
            require("telescope").load_extension("project")
        end
    },

    {
        "haya14busa/vim-asterisk",
        config = function()
            vim.keymap.set({"n", "v"}, "*", "<Plug>(asterisk-*)")
            vim.keymap.set({"n", "v"}, "#", "<Plug>(asterisk-#)")
            vim.keymap.set({"n", "v"}, "g*", "<Plug>(asterisk-g*)")
            vim.keymap.set({"n", "v"}, "g#", "<Plug>(asterisk-g#)")
        end
    },

    {
        "cshuaimin/ssr.nvim",
        opts = {
            min_width = 50,
            min_height = 5,
            max_width = 120,
            max_height = 25,
            keymaps = {
                close = "q",
                next_match = "n",
                prev_match = "N",
                replace_confirm = "<cr>",
                replace_all = "<leader><cr>",
            },
        }
    },

    {
        "LeonHeidelbach/trailblazer.nvim",
        opts = {
            trail_options = {
                current_trail_mark_mode = "global_chron_buf_switch_group_line_sorted",
                multiple_mark_symbol_counters_enabled = false,
                number_line_color_enabled = false,
                symbol_line_enabled = true,
            },
            mappings = { },
        }
    },

    --- Coding
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

            local servers = { "clangd", "pyright", "rust_analyzer", "tsserver", "bashls", "texlab", "svelte", "nil_ls" }

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

    --- Other
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

    {
        "nvim-telescope/telescope-symbols.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
    },

    {
        "ojroques/nvim-osc52",
        config = function()
            function copy()
                if vim.v.event.operator == "y" and vim.v.event.regname == "c" then
                    require("osc52").copy_register("c")
                end
            end

            vim.api.nvim_create_autocmd("TextYankPost", { callback = copy })
        end
    },

    {
        "Darazaki/indent-o-matic",
        opts = {
            max_lines = 2048,
            standard_widths = { 2, 4, 8 },
            filetype_bash = {
                -- workaround for a very strange bug where the indent seems to only be taken from line 19???
                skip_multiline = false
            }
        }
    },

    {
        "windwp/nvim-autopairs",
        opts = {
            disable_filetype = { "TelescopePrompt" , "vim" },
            break_undo = false, -- Workaround for https://github.com/smjonas/live-command.nvim/issues/16
        }
    },

    {
        "folke/which-key.nvim",
        config = function()
            local hop = require("hop")
            local gitsigns = require("gitsigns")

            local wk = require("which-key")

            wk.setup {
                plugins = {
                    marks = true,
                    registers = true,
                    spelling = {
                        enabled = true,
                    }
                }
            }

            -- tmux
            local tmux_prefix = "<c-q>"
            local tmux_keys = { name = "tmux" }
            local tmux_key_assignment = {
                function()
                    vim.notify("This is not tmux")
                end,
                "tmux key"
            }
            for i = 0,9 do
                tmux_keys[tostring(i)] = tmux_key_assignment
            end
            -- FIXME: Add all keys
            for _, key in pairs({ "c", "x", "z", "[", "]", "-", "|" }) do
                tmux_keys[key] = tmux_key_assignment
            end

            -- normal
            wk.register {
                -- buffers
                ["<m-q>"] = { "<cmd>BufferClose<cr>", "Close Buffer" },
                ["<m-Q>"] = { "<cmd>BufferClose!<cr>", "Force Close Buffer" },
                ["<m-s>"] = { "<cmd>BufferPick<cr>", "Pick Buffer" },
                ["<m-k>"] = { "<cmd>BufferPrevious<cr>", "Previous Buffer" },
                ["<m-j>"] = { "<cmd>BufferNext<cr>", "Next Buffer" },
                ["<m-K>"] = { "<cmd>BufferMovePrevious<cr>", "Move Buffer Left" },
                ["<m-J>"] = { "<cmd>BufferMoveNext<cr>", "Move Buffer Right" },
                ["<m-1>"] = { "<cmd>BufferGoto 1<cr>", "Buffer 1" },
                ["<m-2>"] = { "<cmd>BufferGoto 2<cr>", "Buffer 2" },
                ["<m-3>"] = { "<cmd>BufferGoto 3<cr>", "Buffer 3" },
                ["<m-4>"] = { "<cmd>BufferGoto 4<cr>", "Buffer 4" },
                ["<m-5>"] = { "<cmd>BufferGoto 5<cr>", "Buffer 5" },
                ["<m-6>"] = { "<cmd>BufferGoto 6<cr>", "Buffer 6" },
                ["<m-7>"] = { "<cmd>BufferGoto 7<cr>", "Buffer 7" },
                ["<m-8>"] = { "<cmd>BufferGoto 8<cr>", "Buffer 8" },
                ["<m-9>"] = { "<cmd>BufferGoto 9<cr>", "Buffer 9" },
                ["<m-0>"] = { "<cmd>BufferLast<cr>", "Last Buffer" },
                ["<leader>b"] = {
                    name = "Sort Buffers",
                    d = { "<cmd>BufferOrderByDirectory<cr>", "By Directory" },
                    l = { "<cmd>BufferOrderByLanguage<cr>", "By Language" },
                },
                -- splits
                ["<leader>s"] = {
                    name = "Splits",
                    h = { "<cmd>vs<cr>", "Split Left" },
                    j = { "<cmd>sp<cr>", "Split Down" },
                    k = { "<cmd>sp<cr>", "Split Up" },
                    l = { "<cmd>vs<cr>", "Split Right" },
                },
                -- windows
                ["<c-+>"] = { "<cmd>resize +1<cr>", "Increase window height" },
                ["<c-->"] = { "<cmd>resize -1<cr>", "Decrease window height" },
                ["<c-s-<>"] = { "<cmd>vertical resize +1<cr>", "Increase window width" },
                ["<c-<>"] = { "<cmd>vertical resize -1<cr>", "Decrease window width" },
                -- Telescope
                ["<leader>f"] = {
                    name = "Find",
                    f = { "<cmd>Telescope find_files<cr>", "Find Files" },
                    l = { "<cmd>Telescope live_grep<cr>", "Find Lines" },
                    b = { "<cmd>Telescope buffers<cr>", "Find Buffers" },
                    h = { "<cmd>Telescope help_tags<cr>", "Find Help" },
                    s = { function() require("telescope.builtin").lsp_dynamic_workspace_symbols() end, "Find LSP Symbols" },
                    S = { "<cmd>Telescope symbols<cr>", "Find Symbols" },
                    p = { "<cmd>Telescope project<cr>", "Find Projects" },
                    m = { function() require("telescope.builtin").man_pages({ sections = { "ALL" } }) end, "Find Man Pages" },
                    r = { function() require("telescope.builtin").lsp_references({ jump_type = "never" }) end, "Find LSP References" },
                },
                -- LSP / Diagnostics
                ["K"] = { vim.lsp.buf.hover, "Hover" },
                ["g"] = {
                    h = { "<cmd>TroubleToggle lsp_references<cr>", "References" },
                    a = { vim.lsp.buf.code_action, "Code Action" },
                    r = { vim.lsp.buf.rename, "Rename symbol" },
                    D = { vim.lsp.buf.declaration, "Declaration" },
                    d = { vim.lsp.buf.definition, "Definition" },
                    i = { vim.lsp.buf.implementation, "Implementation" },
                },
                ["[d"] = { function() vim.diagnostic.goto_prev({ float = false }) end, "Previous Diagnostic" },
                ["]d"] = { function() vim.diagnostic.goto_next({ float = false }) end, "Next Diagnostic" },
                ["[D"] = { function() vim.diagnostic.goto_prev({ float = false, severity = vim.diagnostic.severity.ERROR }) end, "Previous Error Diagnostic" },
                ["]D"] = { function() vim.diagnostic.goto_next({ float = false, severity = vim.diagnostic.severity.ERROR }) end, "Next Error Diagnostic" },
                ["<leader>d"] = { function()
                    vim.diagnostic.open_float({
                        border = vim.g._border,
                    });
                end, "Open Diagnostic float" },
                -- toggle
                ["<leader>t"] = {
                    name = "Toggle",
                    t = { "<cmd>NvimTreeToggle<cr>", "Toggle NvimTree" },
                    T = { "<cmd>TroubleToggle todo<cr>", "Toggle Todos" },
                    s = { "<cmd>AerialToggle<cr>", "Toggle Symbols Outline" },
                    g = { function() require("neogit").open({ kind = "split" }) end, "Neogit" },
                    d = { "<cmd>TroubleToggle document_diagnostics<cr>", "Document Diagnostics" },
                    D = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "Workspace Diagnostics" },
                },
                -- open
                ["<leader>o"] = {
                    name = "Open",
                    t = { function() vim.cmd("terminal " .. (vim.env.SHELL or vim.opt.shell)) end, "Open terminal" }
                },
                -- hop
                ["s"] = { hop.hint_words, "Hop word" },
                ["S"] = { function() hop.hint_words({ multi_windows = true }) end, "Hop word Multi Window" },
                -- move line
                ["<m-c-k>"] = { ":m -2<cr>==", "Move line up" },
                ["<m-c-j>"] = { ":m +1<cr>==", "Move line down" },
                -- tmux
                [tmux_prefix] = tmux_keys,
                -- git
                ["[h"] = { gitsigns.prev_hunk, "Previous git hunk" },
                ["]h"] = { gitsigns.next_hunk, "Next git hunk" },
                -- trailblazer.nvim marks
                ["<leader>m"] = {
                    name = "Trail Marks",
                    n = { function() require("trailblazer").new_trail_mark() end, "New trail mark" },
                    b = { function() require("trailblazer").track_back() end, "Track back" },
                    d = { function() require("trailblazer").delete_all_trail_marks() end, "Delete all trail marks" },
                    p = { function() require("trailblazer").paste_at_last_trail_mark() end, "Paste at last trail mark" },
                    P = { function() require("trailblazer").paste_at_all_trail_marks() end, "Paste at all trail marks" },
                    s = { function() require("trailblazer").set_trail_mark_select_mode() end, "Set trail mark select mode" },
                },
                ["<A-h>"] = { function() require("trailblazer").peek_move_previous_up() end, "Peek previous mark" },
                ["<A-l>"] = { function() require("trailblazer").peek_move_next_down() end, "Peek next mark" },
                -- ssr.nvim
                ["<leader>sr"] = { function() require("ssr").open() end, "Open SSR" },
                -- other
                ["Y"] = { "y$", "Yank to end", noremap = false },
                ["<esc>"] = { "<cmd>noh<cr>", "Hide search highlight" },
                ["k"] = { "(v:count == 0 ? 'gk' : 'k')", "Up", expr = true },
                ["j"] = { "(v:count == 0 ? 'gj' : 'j')", "Down", expr = true },
                ["ö"] = { "[", "", noremap = false },
                ["ä"] = { "]", "", noremap = false },
                ["öö"] = { "[[", "" },
                ["ää"] = { "]]", "" },
                ["Ö"] = { "{", "", noremap = false },
                ["Ä"] = { "}", "", noremap = false },
            }

            -- visual
            wk.register({
                -- move line
                ["<m-c-k>"] = { ":m \"<-2<cr>gv=gv", "Move lines up" },
                ["<m-c-j>"] = { ":m \">+1<cr>gv=gv", "Move lines up" },
                -- osc52
                ["<leader>y"] = { function() require("osc52").copy_visual() end, "osc52 Yank" },
                -- hop
                ["s"] = { hop.hint_words, "Hop word" },
                ["S"] = { function() hop.hint_words({ multi_windows = true }) end, "Hop word Multi Window" },
                -- ssr.nvim
                ["<leader>sr"] = { function() require("ssr").open() end, "Open SSR" },
                -- Other
                ["<"] = { "<gv", "Unindent" },
                [">"] = { ">gv", "Indent" },
                ["ö"] = { "[", "", noremap = false },
                ["ä"] = { "]", "", noremap = false },
                ["öö"] = { "[[", "" },
                ["ää"] = { "]]", "" },
                ["Ö"] = { "{", "", noremap = false },
                ["Ä"] = { "}", "", noremap = false },
            }, { mode = "x" })

            -- terminal
            wk.register({
                ["<esc><esc>"] = { "<c-bslash><c-n>", "Exit Terminal Mode" },
                ["<c-h>"] = { "<c-bslash><c-n><cmd>TmuxNavigateLeft<cr>", "Window Left" },
                ["<c-j>"] = { "<c-bslash><c-n><cmd>TmuxNavigateDown<cr>", "Window Down" },
                ["<c-k>"] = { "<c-bslash><c-n><cmd>TmuxNavigateUp<cr>", "Window Up" },
                ["<c-l>"] = { "<c-bslash><c-n><cmd>TmuxNavigateRight<cr>", "Window Right" },
                ["<m-k>"] = { function() if vim.bo.buflisted then vim.cmd"BufferPrevious" end end, "Previous Buffer" },
                ["<m-j>"] = { function() if vim.bo.buflisted then vim.cmd"BufferNext" end end, "Next Buffer" },
                ["<m-q>"] = { function() if vim.bo.buflisted then vim.cmd"BufferClose!" else vim.cmd"bd!" end end, "Close Buffer" },
                ["<m-Q>"] = { function() if vim.bo.buflisted then vim.cmd"BufferClose!" else vim.cmd"bd!" end end, "Close Buffer" },
                ["<c-p>"] = { "<up>", "Previous Command" },
                ["<c-n>"] = { "<down>", "Next Command" },
            }, { mode = "t" })

            -- cmdline
            wk.register({
                ["<c-h>"] = { "<Left>", "Cursor left" },
                ["<c-l>"] = { "<Right>", "Cursor right" },
                ["<c-k>"] = { "<Up>", "Recall older command-line from history" },
                ["<c-j>"] = { "<Down>", "Recall more recent command-line from history" },
                ["<c-b>"] = { "<C-Left>", "Previous WORD" },
                ["<c-w>"] = { "<C-Right><Right>", "Next WORD" },
                ["<c-e>"] = { "<Right><C-Right><Left>", "End of next WORD" },
            }, { mode = "c", silent = false })
        end
    },
}, {
    performance = {
        rtp = {
            reset = false
        }
    }
})

--- -----------------------
---        AUTOCMDS
--- -----------------------
--- Remove trailing spaces
vim.cmd [[autocmd BufWritePre * %s/\s\+$//e]]

--- Enter insert mode when navigating to a terminal
vim.cmd [[autocmd BufWinEnter,WinEnter term://* startinsert]]

--- Format code on save
vim.api.nvim_create_augroup("fmt", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
    group = "fmt",
    callback = function()
        -- FIXME: This is a bad solution, but sync format seems to cause the lsp server to crash. Or does it? What?
        if vim.bo.filetype == "cpp" and vim.fn.filereadable(".clang-format") == 1 then
            vim.lsp.buf.format({ timeout_ms = 2000 })
        elseif vim.bo.filetype == "rust" then
            vim.lsp.buf.format({ timeout_ms = 2000 })
        end
    end
})

--- Highlightedjank
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank {
            higroup=(vim.fn["hlexists"]("HighlightedyankRegion") > 0 and "HighlightedyankRegion" or "IncSearch"),
            timeout=200
        }
    end
})

--- -----------------------
---     COMMANDS
--- -----------------------

function Sort()
    -- TODO: Support bang to reverse sort
    -- TODO: Respect end pos
    -- TODO: Handle unset mark
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    vim.cmd(string.format("'<,'>sort /.\\{%s\\}/", start_pos[2]))
end

vim.cmd[[command! -range=% -bang Sort lua Sort()]]

function compile_markdown()
    local filename = vim.api.nvim_buf_get_name(0)
    local output_filename = filename:match("^.+/(.+).md$") .. ".html"
    os.execute("pandoc --standalone --katex -o " .. output_filename .. " " .. filename .. " 2>/dev/null")
    vim.notify("File compiled to " .. output_filename)
end

vim.cmd[[command! -range=% -bang CompileMarkdown lua compile_markdown()]]

-- Create a custom namespace. This will aggregate signs from all other
-- namespaces and only show the one with the highest severity on a
-- given line
local ns = vim.api.nvim_create_namespace("my_namespace")

-- Get a reference to the original signs handler
local orig_signs_handler = vim.diagnostic.handlers.signs

-- Override the built-in signs handler
vim.diagnostic.handlers.signs = {
    show = function(_, bufnr, _, opts)
        -- Get all diagnostics from the whole buffer rather than just the
        -- diagnostics passed to the handler
        local diagnostics = vim.diagnostic.get(bufnr)

        -- Find the "worst" diagnostic per line
        local max_severity_per_line = {}
        for _, d in pairs(diagnostics) do
            local m = max_severity_per_line[d.lnum]
            if not m or d.severity < m.severity then
                max_severity_per_line[d.lnum] = d
            end
        end

        -- Pass the filtered diagnostics (with our custom namespace) to
        -- the original handler
        local filtered_diagnostics = vim.tbl_values(max_severity_per_line)
        orig_signs_handler.show(ns, bufnr, filtered_diagnostics, opts)
    end,
    hide = function(_, bufnr)
        orig_signs_handler.hide(ns, bufnr)
    end,
}

-- Workaround for https://github.com/neovim/neovim/issues/19649 taken from https://github.com/neovim/neovim/issues/19649#issuecomment-1327287313
local function getlines(location)
    local uri = location.targetUri or location.uri
    if uri == nil then
        return
    end
    local bufnr = vim.uri_to_bufnr(uri)
    if not vim.api.nvim_buf_is_loaded(bufnr) then
        vim.fn.bufload(bufnr)
    end
    local range = location.targetRange or location.range

    local lines = vim.api.nvim_buf_get_lines(bufnr, range.start.line, range["end"].line+1, false)
    return table.concat(lines, "\n")
end

vim.diagnostic.config({float = {format = function(diag)
    local message = diag.message
    local client = vim.lsp.get_active_clients({name = message.source})[1]
    if not client then
        return diag.message
    end

    local relatedInfo = {messages = {}, locations = {}}
    if diag.user_data.lsp.relatedInformation ~= nil then
        for _, info in ipairs(diag.user_data.lsp.relatedInformation) do
            table.insert(relatedInfo.messages, info.message)
            table.insert(relatedInfo.locations, info.location)
        end
    end

    for i, loc in ipairs(vim.lsp.util.locations_to_items(relatedInfo.locations, client.offset_encoding)) do
        message = string.format("%s\n%s (%s:%d):\n\t%s", message, relatedInfo.messages[i],
            vim.fn.fnamemodify(loc.filename, ":."), loc.lnum,
            getlines(relatedInfo.locations[i]))
    end

    return message
end}})
-- Workaround end
