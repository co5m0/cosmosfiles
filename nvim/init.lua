--

--------------------------------------------
-- General
--------------------------------------------

-- Variable set
local set = vim.opt
local map = vim.api.nvim_set_keymap

-- line number
set.number = true

-- column cursor
set.cursorcolumn = true

-- menuone = Use the popup menu also when there is only one match.
-- noselect = Do not select a match in the menu, force the user to
set.completeopt = 'menuone,noselect'

-- Sets how many lines of history VIM has to remember
set.history = 500

-- Set to auto read when a file is changed from the outside
set.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
    callback = function()
        vim.api.nvim_command("checktime")
    end
})

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- :W sudo saves the file
-- (useful for handling the permission-denied error)
map('c', 'W', "<esc>:lua require'utils'.sudo_write()<CR>", { silent = true })

--------------------------------------------
-- User Interface
--------------------------------------------

-- Set 7 lines to the cursor - when moving vertically using j/k
set.so = 7

-- Ignore case when searching
set.ignorecase = true

-- When searching try to be smart about cases
set.smartcase = true

-- Don't redraw while executing macros (good performance config)
set.lazyredraw = true

-- For regular expressions turn magic on
set.magic = true

-- Show matching brackets when text indicator is over them
set.showmatch = true

-- How many tenths of a second to blink when matching brackets
set.mat = 2

-- No annoying sound on errors
set.tm = 500

-- Add a bit extra margin to the left
set.foldcolumn = 'auto'

--------------------------------------------
-- Colors and Fonts
--------------------------------------------

-- Set utf8 as standard encoding and en_US as the standard language
set.encoding = 'utf8'

-- Use Unix as the standard file type
set.ffs = 'unix,dos,mac'

--------------------------------------------
-- Text, tab and indent related
--------------------------------------------

-- Use spaces instead of tabs
set.expandtab = true

-- 1 tab == 4 spaces
set.shiftwidth = 4
set.tabstop = 4

-- Linebreak on 500 characters
set.lbr = true
set.tw = 500

-- Smart indent
set.si = true

-- Wrap lines
set.wrap = true

--------------------------------------------
-- Moving around, tabs, windows and buffers
--------------------------------------------

set.stal = 2

-- From vim defaults.vim
-- ---
-- When editing a file, always jump to the last known cursor position.
-- Don't do it when the position is invalid, when inside an event handler
-- (happens when dropping a file on gvim) and for a commit message (it's
-- likely a different one than last time).
-- https://github.com/creativenull/dotfiles/blob/9ae60de4f926436d5682406a5b801a3768bbc765/config/nvim/init.lua#L70-L86
vim.api.nvim_create_autocmd('BufReadPost', {
    callback = function(args)
        local valid_line = vim.fn.line([['"]]) >= 1 and vim.fn.line([['"]]) < vim.fn.line('$')
        local not_commit = vim.b[args.buf].filetype ~= 'commit'

        if valid_line and not_commit then
            vim.cmd([[normal! g`"]])
        end
    end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    }
end

--------------------------------------------
-- Mappings
--------------------------------------------

local options = { noremap = true }
local cmd_options = { noremap = true, silent = true }

-- helper func
---Horizontally resize window, if there are more than one window
---@param amount number
---@return nil
function resize_win_hor(amount)
    if #vim.api.nvim_list_wins() > 1 then
        vim.cmd(string.format('resize %s%d', amount > 0 and '+' or '', amount))
    end
end

---Vertically resize window, if there are more than one window
---@param amount number
---@return nil
function resize_win_vert(amount)
    if #vim.api.nvim_list_wins() > 1 then
        vim.cmd(string.format('vertical resize %s%d', amount > 0 and '+' or '', amount))
    end
end

-- Save with Ctrl + s
map('n', '<C-s>', ':w %<CR>', options)


-- Remap VIM 0 to first non-blank character
map('', '0', '^', {})

-- search selected text in the current buffer using //
vim.api.nvim_exec(
  [[
  function! g:VSetSearch(cmdtype)
    let temp = @s
    norm! gv"sy
    let @/ = '\V' . substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
    let @s = temp
  endfunction

  xnoremap // :<C-u>call g:VSetSearch('/')<CR>/<C-R>=@/<CR><CR>
]],
  false
)

-- Move a line of text using ALT+[jk] or Command+[jk] on mac
-- Move lines up/down
map("n", "<leader>j", "mz:m+<cr>`z", cmd_options)
map("n", "<leader>k", "mz:m-2<cr>`z", cmd_options)
map("v", "<leader>j", ":m'>+<cr>`<my`>mzgv`yo`z", cmd_options)
map("v", "<leader>k", ":m'<-2<cr>`>my`<mzgv`yo`z", cmd_options)

-- from https://github.com/creativenull/dotfiles/blob/9ae60de4f926436d5682406a5b801a3768bbc765/config/nvim/init.lua#L70-L86
-- Unbind default bindings for arrow keys, trust me this is for your own good
vim.keymap.set({ 'n', 'i', 'v' }, '<Up>', '')
vim.keymap.set({ 'n', 'i', 'v' }, '<Down>', '')
vim.keymap.set({ 'n', 'i', 'v' }, '<Left>', '')
vim.keymap.set({ 'n', 'i', 'v' }, '<Right>', '')
vim.keymap.set({ 'n', 'i', 'v' }, '<C-h>', '')
vim.keymap.set({ 'n', 'i', 'v' }, '<C-j>', '')
vim.keymap.set({ 'n', 'i', 'v' }, '<C-k>', '')
vim.keymap.set({ 'n', 'i', 'v' }, '<C-l>', '')

-- Resize window panes, we can use those arrow keys
-- to help use resize windows - at least we give them some purpose
vim.keymap.set('n', '<Up>', function()
    resize_win_hor(2)
end, { desc = 'Resize window horizontally (inc)' })
vim.keymap.set('n', '<Down>', function()
    resize_win_hor(-2)
end, { desc = 'Resize window horizontally (dec)' })
vim.keymap.set('n', '<Left>', function()
    resize_win_vert(-2)
end, { desc = 'Resize window vertically (inc)' })
vim.keymap.set('n', '<Right>', function()
    resize_win_vert(2)
end, { desc = 'Resize window vertically (dec)' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- Delete trailing white space on save, useful for some filetypes ;)
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*" },
    callback = function()
        local save_cursor = vim.fn.getpos(".")
        pcall(function() vim.cmd [[%s/\s\+$//e]] end)
        vim.fn.setpos(".", save_cursor)
    end,
})

--------------------------------------------
-- Plugin manager
--------------------------------------------

vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
    -- NOTE: First, some plugins that don't require any configuration

    -- Autoclose brackets
    'chun-yang/auto-pairs',

    -- TabLine
    'crispgm/nvim-tabline',

    -- Catppuccin theme
    { "catppuccin/nvim",       name = "catppuccin", priority = 1000 },

    -- NOTE: This is where your plugins related to LSP can be installed.
    --  The configuration is done below. Search for lspconfig to find it below.
    {
        -- LSP Configuration & Plugins
        'neovim/nvim-lspconfig',
        dependencies = {
            -- Useful status updates for LSP
            -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            { 'j-hui/fidget.nvim', opts = {} },

            -- Additional lua configuration, makes nvim stuff amazing!
            'folke/neodev.nvim',
        },
    },

    {
        -- Autocompletion
        'hrsh7th/nvim-cmp',
        dependencies = {
            -- Snippet Engine & its associated nvim-cmp source
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',

            -- Adds LSP completion capabilities
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-path',

            -- Adds a number of user-friendly snippets
            'rafamadriz/friendly-snippets',
        },
    },

    {
        -- Set lualine as statusline
        'nvim-lualine/lualine.nvim',
        -- See `:help lualine.txt`
        opts = {
            options = {
                icons_enabled = false,
                theme = 'auto',
                component_separators = '|',
                section_separators = '',
            },
        },
    },

    {
        -- Add indentation guides even on blank lines
        'lukas-reineke/indent-blankline.nvim',
        -- Enable `lukas-reineke/indent-blankline.nvim`
        -- See `:help ibl`
        main = 'ibl',
        opts = {},
    },

    -- "gc" to comment visual regions/lines
    { 'numToStr/Comment.nvim', opts = {},           lazy = false },

    -- Fuzzy Finder (files, lsp, etc)
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            -- Fuzzy Finder Algorithm which requires local dependencies to be built.
            -- Only load if `make` is available. Make sure you have the system
            -- requirements installed.
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                -- NOTE: If you are having trouble with this installation,
                --       refer to the README for telescope-fzf-native for more instructions.
                build = 'make',
                cond = function()
                    return vim.fn.executable 'make' == 1
                end,
            },
        },
    },

    {
        -- Highlight, edit, and navigate code
        'nvim-treesitter/nvim-treesitter',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
        },
        build = ':TSUpdate',
    },
    -- lite git integration
    {
        "chrisgrieser/nvim-tinygit",
        ft = { "gitrebase", "gitcommit" }, -- so ftplugins are loaded
        dependencies = {
            "stevearc/dressing.nvim",
            -- "ibhagwan/fzf-lua",
            "rcarriga/nvim-notify", -- optional, but will lack some features without it
        },
    },

    -- lazygit integration
    {
        "kdheepak/lazygit.nvim",
    	cmd = {
    		"LazyGit",
    		"LazyGitConfig",
    		"LazyGitCurrentFile",
    		"LazyGitFilter",
    		"LazyGitFilterCurrentFile",
    	},
    },

    -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
    --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
    --    up-to-date with whatever is in the kickstart repo.
    --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
    --
    --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
    -- { import = 'custom.plugins' },
}, {})

--------------------------------------------
-- Setup plugins
--------------------------------------------

-- Setup auto Comment
-- Broken setup, idk how why it works
require('Comment').setup({
    toggler = {
        ---Line-comment toggle keymap
        line = '<C-/>',
    },
    ---LHS of operator-pending mappings in NORMAL and VISUAL mode
    opleader = {
        ---Line-comment keymap
        line = '<C-_>',
    },
})

-- Setup theme
vim.cmd.colorscheme "catppuccin"

-- Setup neovim lua configuration
require('neodev').setup()

-- Setup Tabline
require('tabline').setup({
    show_index = true,          -- show tab index
    show_modify = true,         -- show buffer modification indicator
    show_icon = false,          -- show file extension icon
    fnamemodify = ':t',         -- file name modifier
    modify_indicator = '+',     -- modify indicator
    no_name = 'No name',        -- no name buffer name
    brackets = { '', '' },      -- file name sourranding
    inactive_tab_max_length = 0 -- max length of inactive tab titles, 0 to ignore
})

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- -- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
    ---@diagnostic disable-next-line: missing-fields
    require('nvim-treesitter.configs').setup {
        -- Add languages to be installed here that you want installed for treesitter
        ensure_installed = { 'c', 'cpp', 'yaml', 'json', 'hcl', 'terraform', 'go', 'lua', 'python', 'nix', 'typescript', 'vim' },

        highlight = { enable = true },
        indent = { enable = true, disable = { 'python' } },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = '<c-space>',
                node_incremental = '<c-space>',
                scope_incremental = '<c-s>',
                node_decremental = '<c-backspace>',
            },
        },
        textobjects = {
            select = {
                enable = true,
                lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                keymaps = {
                    -- You can use the capture groups defined in textobjects.scm
                    ['aa'] = '@parameter.outer',
                    ['ia'] = '@parameter.inner',
                    ['af'] = '@function.outer',
                    ['if'] = '@function.inner',
                    ['ac'] = '@class.outer',
                    ['ic'] = '@class.inner',
                },
            },
            move = {
                enable = true,
                set_jumps = true, -- whether to set jumps in the jumplist
                goto_next_start = {
                    [']m'] = '@function.outer',
                    [']]'] = '@class.outer',
                },
                goto_next_end = {
                    [']M'] = '@function.outer',
                    [']['] = '@class.outer',
                },
                goto_previous_start = {
                    ['[m'] = '@function.outer',
                    ['[['] = '@class.outer',
                },
                goto_previous_end = {
                    ['[M'] = '@function.outer',
                    ['[]'] = '@class.outer',
                },
            },
            swap = {
                enable = true,
                swap_next = {
                    ['<leader>a'] = '@parameter.inner',
                },
                swap_previous = {
                    ['<leader>A'] = '@parameter.inner',
                },
            },
        },
    }
end, 0)

-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
    -- NOTE: Remember that lua is a real programming language, and as such it is possible
    -- to define small helper and utility functions so you don't have to repeat yourself
    -- many times.
    --
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local nmap = function(keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

    -- See `:help K` for why this keymap
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

    -- Lesser used LSP functionality
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    nmap('<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, '[W]orkspace [L]ist Folders')

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })
end

-- Configure terraform lsp
-- require'lspconfig'.terraformls.setup{}
-- require'lspconfig'.tsserver.setup{}

local servers = { 'tsserver', 'terraformls', 'tflint', "gopls", "lua_ls" }
local lspconfig = require 'lspconfig'
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
        on_attach = on_attach,
    }
end

lspconfig.yamlls.setup {
    settings = {
        yaml = {
            schemaStore = {
                url = "https://www.schemastore.org/api/json/catalog.json",
                enable = true,
            }
        }
    },
    -- on_attach = on_attach
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    pattern = { "*.tf", "*.tfvars", "*.go", "*.ts" },
    -- callback = vim.lsp.buf.format(),
    command = 'Format'
})

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- nvim-cmp setup
local cmp = require 'cmp'
local luasnip = require 'luasnip'

cmp.setup {
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert {
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    },
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    },
}

-- set terraform file type
vim.cmd [[autocmd BufRead,BufNewFile *.tf,*.tfvars set filetype=terraform]]
vim.cmd [[autocmd BufRead,BufNewFile *.tfstate,*.tfstate.backup set filetype=json]]
vim.cmd [[autocmd BufRead,BufNewFile *.yaml,*.yml set filetype=yaml]]

-- tinygit
vim.api.nvim_create_user_command('Commit', function(_)
    require("tinygit").smartCommit()
end, { desc = 'Format current buffer with LSP' })

-- Telescope
-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
local actions = require("telescope.actions")
require('telescope').setup {
    defaults = {
        mappings = {
            i = {
                ['<esc>'] = actions.close
            },
        },
    },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
    -- Use the current buffer's path as the starting point for the git search
    local current_file = vim.api.nvim_buf_get_name(0)
    local current_dir
    local cwd = vim.fn.getcwd()
    -- If the buffer is not associated with a file, return nil
    if current_file == '' then
        current_dir = cwd
    else
        -- Extract the directory from the current file's path
        current_dir = vim.fn.fnamemodify(current_file, ':h')
    end

    -- Find the Git root directory from the current file's path
    local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
    if vim.v.shell_error ~= 0 then
        print 'Not a git repository. Searching on current working directory'
        return cwd
    end
    return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
    local git_root = find_git_root()
    if git_root then
        require('telescope.builtin').live_grep {
            search_dirs = { git_root },
        }
    end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })

local function telescope_live_grep_open_files()
    require('telescope.builtin').live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
    }
end

local is_inside_work_tree = {}

local function project_files()
    local opts = {} -- define here if you want to define something

    local cwd = vim.fn.getcwd()
    if is_inside_work_tree[cwd] == nil then
        vim.fn.system("git rev-parse --is-inside-work-tree")
        is_inside_work_tree[cwd] = vim.v.shell_error == 0
    end

    if is_inside_work_tree[cwd] then
        require('telescope.builtin').git_files(opts)
    else
        require('telescope.builtin').find_files(opts)
    end
end

function vim.getVisualSelection()
	vim.cmd('noau normal! "vy"')
	local text = vim.fn.getreg('v')
	vim.fn.setreg('v', {})

	text = string.gsub(text, "\n", "")
	if #text > 0 then
		return text
	else
		return ''
	end
end

vim.keymap.set('n', '<C-f>', ':Telescope current_buffer_fuzzy_find<cr>', opts)
vim.keymap.set('v', '<C-f>', function()
	local text = vim.getVisualSelection()
	require('telescope.builtin').current_buffer_fuzzy_find({ default_text = text })
end, opts)

-- vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, { desc = '[S]earch [/] in Open Files' })
-- vim.kfymap.set('n', '<leader>pv', search_file_with_telescope , { desc = '[S]earch Files' })
vim.keymap.set('n', '<C-[>', require('telescope.builtin').builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<C-p>', project_files, { desc = 'Search [G]it [F]iles' })
-- vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
-- vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
-- vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
-- vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
-- vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
-- vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
-- vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
