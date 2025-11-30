-- Set <space> as the leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

--------------------------------------------
-- General Settings
--------------------------------------------
local opt = vim.opt

opt.number = true
opt.cursorcolumn = true
opt.completeopt = "menuone,noselect"
opt.history = 500
opt.breakindent = true
opt.undofile = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 300
opt.inccommand = "split"
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 7
opt.ignorecase = true
opt.smartcase = true
opt.showmatch = true
opt.matchtime = 2
opt.termguicolors = true

-- Folding
opt.foldcolumn = "0"
opt.foldlevel = 99
opt.foldlevelstart = 10
opt.foldenable = true
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- Search
opt.hlsearch = true

-- Swap
opt.swapfile = false

-- Tabs & Indent
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true
opt.wrap = true
opt.linebreak = true

--------------------------------------------
-- Keymaps
--------------------------------------------
local map = vim.keymap.set

-- Save with Ctrl + s
map("n", "<C-s>", ":w<CR>", { silent = true, desc = "Save file" })
-- Sudo write (W)
vim.api.nvim_create_user_command("W", "lua require'utils'.sudo_write()", {})

-- Better movement in wrapped lines
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Move lines up/down (The Primeagen style)
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Resize windows
map("n", "<Up>", "<cmd>resize +2<cr>", { desc = "Resize window height +" })
map("n", "<Down>", "<cmd>resize -2<cr>", { desc = "Resize window height -" })
map("n", "<Left>", "<cmd>vertical resize -2<cr>", { desc = "Resize window width -" })
map("n", "<Right>", "<cmd>vertical resize +2<cr>", { desc = "Resize window width +" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Diagnostic keymaps (Using Trouble primarily now, but these are decent fallbacks)
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })

-- Search selected text
map("x", "//", function()
    vim.cmd('noau normal! "vy"')
    local text = vim.fn.getreg("v")
    vim.fn.setreg("v", {})
    text = string.gsub(text, "\n", "")
    -- Escape magic chars for regex search
    text = string.gsub(text, "[%[%)%^%$%.%*%+%?%%]", "%%%1")
    vim.fn.setreg("/", text)
    vim.cmd("set hlsearch")
end, { desc = "Search selected text" })

--------------------------------------------
-- Autocommands
--------------------------------------------
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
autocmd("TextYankPost", {
    group = augroup("YankHighlight", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Auto-save/Read check
autocmd({ "FocusGained", "BufEnter" }, {
    pattern = "*",
    command = "checktime",
})

-- Restore cursor position
autocmd("BufReadPost", {
    callback = function(args)
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        local line_count = vim.api.nvim_buf_line_count(args.buf)
        if mark[1] > 0 and mark[1] <= line_count then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Filetypes
vim.filetype.add({
    extension = {
        tf = "terraform",
        tfvars = "terraform",
        tfstate = "json",
        yaml = "yaml",
        yml = "yaml",
    },
})

--------------------------------------------
-- Lazy Plugin Manager
--------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Libraries
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",

    -- Theme
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("catppuccin")
        end,
    },

    -- Better Lua Development (Replaces deprecated neodev)
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                { path = "luvit-meta/library", words = { "vim%.uv" } },
            },
        },
    },
    { "Bilal2453/luvit-meta",  lazy = true },

    -- UI: Noice (Modern Notifications)
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "rcarriga/nvim-notify",
        },
        opts = {
            lsp = {
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
            },
            presets = {
                bottom_search = true,
                command_palette = true,
                long_message_to_split = true,
                inc_rename = false,
                lsp_doc_border = false,
            },
        },
    },

    -- Utilities (Mini.nvim replaces comment.nvim, autopairs, surround)
    {
        "echasnovski/mini.nvim",
        version = "*",
        config = function()
            require("mini.surround").setup({
                mappings = {
                    add = "gza",            -- Add surrounding in Normal and Visual modes
                    delete = "gzd",         -- Delete surrounding
                    find = "gzf",           -- Find surrounding (to the right)
                    find_left = "gzF",      -- Find surrounding (to the left)
                    highlight = "gzh",      -- Highlight surrounding
                    replace = "gzr",        -- Replace surrounding
                    update_n_lines = "gzn", -- Update `n_lines`
                },
            })
            require("mini.pairs").setup()
            require("mini.comment").setup()
        end,
    },

    -- UI: Lualine
    {
        "nvim-lualine/lualine.nvim",
        opts = {
            options = {
                theme = "palenight",
                globalstatus = true,
                component_separators = "|",
                section_separators = "",
            },
            sections = {
                lualine_c = { { "filename", path = 1 } }, -- Relative path
            },
        },
    },

    -- UI: Indent Guides
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {},
    },

    -- UI: Tabline
    {
        "crispgm/nvim-tabline",
        config = function()
            require("tabline").setup({
                show_index = true,
                show_modify = true,
                show_icon = false,
                modify_indicator = "+",
                no_name = "No name",
            })
        end,
    },

    -- Git: Gitsigns (Gutter & Blame)
    {
        "lewis6991/gitsigns.nvim",
        opts = {
            signs = {
                add = { text = "+" },
                change = { text = "~" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
            },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns
                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end
                -- Actions
                map("n", "]c", function()
                    if vim.wo.diff then
                        return "]c"
                    end
                    vim.schedule(function()
                        gs.next_hunk()
                    end)
                    return "<Ignore>"
                end, { expr = true, desc = "Next Hunk" })
                map("n", "[c", function()
                    if vim.wo.diff then
                        return "[c"
                    end
                    vim.schedule(function()
                        gs.prev_hunk()
                    end)
                    return "<Ignore>"
                end, { expr = true, desc = "Prev Hunk" })
                map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage Hunk" })
                map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset Hunk" })
                map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview Hunk" })
                map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "Toggle Line Blame" })
                map("n", "<leader>hd", gs.diffthis, { desc = "Diff This" })
            end,
        },
    },

    -- Git
    { "kdheepak/lazygit.nvim", cmd = "LazyGit" },

    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.6",
        dependencies = {
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        config = function()
            local telescope = require("telescope")
            local builtin = require("telescope.builtin")

            telescope.setup({
                defaults = {
                    mappings = { i = { ["<esc>"] = require("telescope.actions").close } },
                },
            })
            pcall(telescope.load_extension, "fzf")

            -- Keymaps
            vim.keymap.set("n", "<leader>?", builtin.oldfiles, { desc = "[?] Find recently opened files" })
            vim.keymap.set("n", "<leader>p", builtin.find_files, { desc = "Search Git Files" })
            vim.keymap.set("n", "<C-p>", builtin.git_files, { desc = "Search Files" })
            vim.keymap.set("v", "<C-f>", function()
                local text = vim.getVisualSelection()
                builtin.current_buffer_fuzzy_find({ default_text = text })
            end)
            vim.keymap.set("n", "<C-o>", builtin.buffers, { desc = "Open Buffers" })
            vim.keymap.set("n", "<C-F>", function()
                -- telescope live_grep in git root
                -- function to find the git root directory based on the current buffer's path
                local function find_git_root()
                    -- use the current buffer's path as the starting point for the git search
                    local current_file = vim.api.nvim_buf_get_name(0)
                    local current_dir
                    local cwd = vim.fn.getcwd()
                    -- if the buffer is not associated with a file, return nil
                    if current_file == "" then
                        current_dir = cwd
                    else
                        -- extract the directory from the current file's path
                        current_dir = vim.fn.fnamemodify(current_file, ":h")
                    end

                    -- find the git root directory from the current file's path
                    local git_root = vim.fn.systemlist(
                        "git -c " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel"
                    )[1]
                    if vim.v.shell_error ~= 0 then
                        print("not a git repository. searching on current working directory")
                        return cwd
                    end
                    return git_root
                end

                -- custom live_grep function to search in git root
                local git_root = find_git_root()
                builtin.live_grep({
                    search_dirs = { git_root },
                })
            end, { desc = "[S]earch Files" })

            vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
            vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
        end,
    },

    -- UI: Trouble (Better Diagnostics)
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {},
        cmd = "Trouble",
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics (Trouble)" },
            { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
            { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>",      desc = "Symbols (Trouble)" },
            {
                "<leader>cl",
                "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                desc = "LSP Definitions / references / ... (Trouble)",
            },
            { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
            { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",  desc = "Quickfix List (Trouble)" },
        },
    },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "c",
                    "cpp",
                    "go",
                    "lua",
                    "python",
                    "rust",
                    "tsx",
                    "javascript",
                    "typescript",
                    "vim",
                    "vimdoc",
                    "terraform",
                    "hcl",
                    "json",
                    "yaml",
                },
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["aa"] = "@parameter.outer",
                            ["ia"] = "@parameter.inner",
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                        },
                    },
                },
            })
        end,
    },

    -- Formatting (Conform)
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        opts = {
            formatters_by_ft = {
                lua = { "stylua" },
                python = { "isort", "black" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                terraform = { "terraform_fmt" },
                json = { "prettier" },
                yaml = { "prettier" },
            },
            format_on_save = { timeout_ms = 500, lsp_fallback = true },
        },
    },

    -- LSP Configuration
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            { "j-hui/fidget.nvim", opts = {} },
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
            local lspconfig = require("lspconfig")

            -- Define servers and settings
            -- NOTE: Ensure these servers are installed via Nix/system!
            local servers = {
                terraformls = {},
                tflint = {},
                gopls = {},
                rust_analyzer = {},
                lua_ls = {
                    settings = {
                        Lua = {
                            completion = { callSnippet = "Replace" },
                        },
                    },
                },
                yamlls = {
                    settings = {
                        yaml = {
                            schemaStore = { enable = true, url = "https://www.schemastore.org/api/json/catalog.json" },
                        },
                    },
                },
            }

            for server_name, config in pairs(servers) do
                config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})
                vim.lsp.config[server_name] = config
                vim.lsp.enable(server_name)
            end

            -- LSP Attach Auto-Config
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc)
                        vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                    end
                    map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
                    map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
                    map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
                    map("K", vim.lsp.buf.hover, "Hover Documentation")
                    map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
                    map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
                    map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
                end,
            })
        end,
    },

    -- Typescript Tools (Dedicated plugin)
    {
        "pmizio/typescript-tools.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
        opts = {
            settings = {
                tsserver_file_preferences = {
                    includeInlayParameterNameHints = "all",
                    includeCompletionsForModuleExports = true,
                    quotePreference = "auto",
                },
            },
        },
    },

    -- Completion
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            require("luasnip.loaders.from_vscode").lazy_load()
            luasnip.config.setup({})

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                completion = { completeopt = "menu,menuone,noinsert" },
                mapping = cmp.mapping.preset.insert({
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    ["<C-p>"] = cmp.mapping.select_prev_item(),
                    ["<C-y>"] = cmp.mapping.confirm({ select = true }),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-l>"] = cmp.mapping(function()
                        if luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        end
                    end, { "i", "s" }),
                    ["<C-h>"] = cmp.mapping(function()
                        if luasnip.locally_jumpable(-1) then
                            luasnip.jump(-1)
                        end
                    end, { "i", "s" }),
                }),
                sources = {
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "path" },
                },
            })
        end,
    },
})
