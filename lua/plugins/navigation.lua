return {
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
        "haya14busa/vim-asterisk",
        config = function()
            vim.keymap.set({"n", "v"}, "*", "<Plug>(asterisk-*)")
            vim.keymap.set({"n", "v"}, "#", "<Plug>(asterisk-#)")
            vim.keymap.set({"n", "v"}, "g*", "<Plug>(asterisk-g*)")
            vim.keymap.set({"n", "v"}, "g#", "<Plug>(asterisk-g#)")
        end
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
}
