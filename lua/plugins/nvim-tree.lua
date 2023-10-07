return {
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
}
