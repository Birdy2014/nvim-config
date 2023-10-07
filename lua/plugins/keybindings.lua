return {
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
}
