return {
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
}
