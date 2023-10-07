return {
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
}
