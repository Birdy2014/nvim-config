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

require("lazy").setup("plugins", {
    defaults = {
        version = "*"
    },
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
