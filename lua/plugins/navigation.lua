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
}
