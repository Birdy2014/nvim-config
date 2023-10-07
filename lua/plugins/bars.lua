return {
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
}
