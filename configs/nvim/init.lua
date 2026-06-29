-- ============================================================================
--  Neovim config  (~/.config/nvim/init.lua)
-- ============================================================================
--  Modern, single-file setup built on lazy.nvim.
--    - Nord theme (matches the rest of the dotfiles)
--    - Treesitter, Telescope, LSP (mason), completion, formatting
--    - Git signs, file tree, statusline, which-key, and quality-of-life plugins
--
--  Leader key is <Space>. Press <Space> and wait to see available mappings
--  (which-key popup). First launch auto-installs lazy.nvim and all plugins.
-- ============================================================================

-- Leader must be set before plugins load.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable unused remote-plugin providers. None of the plugins here need them,
-- so turning them off silences the optional :checkhealth warnings.
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- ----------------------------------------------------------------------------
--  Options
-- ----------------------------------------------------------------------------
local opt = vim.opt

opt.number = true                -- absolute number on the cursor line
opt.relativenumber = true        -- relative numbers elsewhere (fast j/k motions)
opt.mouse = "a"                  -- mouse in all modes
opt.clipboard = "unnamedplus"    -- use the system clipboard
opt.breakindent = true           -- wrapped lines keep indentation
opt.undofile = true              -- persistent undo across sessions
opt.ignorecase = true            -- case-insensitive search...
opt.smartcase = true             -- ...unless the query has uppercase
opt.signcolumn = "yes"           -- always show the sign column (no text shift)
opt.updatetime = 250             -- faster CursorHold / diagnostics
opt.timeoutlen = 400             -- which-key popup delay
opt.splitright = true            -- vertical splits open to the right
opt.splitbelow = true            -- horizontal splits open below
opt.inccommand = "split"         -- live preview of :substitute
opt.cursorline = true            -- highlight the current line
opt.scrolloff = 8                -- keep 8 lines visible around the cursor
opt.termguicolors = true         -- 24-bit color (needed by the theme)
opt.wrap = false                 -- no soft wrap by default
opt.list = true                  -- show some whitespace...
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Indentation: 4 spaces by default.
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4

-- ----------------------------------------------------------------------------
--  Core keymaps (plugin-specific maps live next to their plugins below)
-- ----------------------------------------------------------------------------
local map = vim.keymap.set

-- Clear search highlight.
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Better window navigation (Ctrl + h/j/k/l).
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Resize splits with arrows.
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Grow window height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Shrink window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Shrink window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Grow window width" })

-- Move selected lines up/down in visual mode.
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep the cursor centered when jumping/searching.
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Paste over a selection without clobbering the yank register.
map("x", "<leader>p", [["_dP]], { desc = "Paste (keep register)" })

-- Save / quit.
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write file" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit window" })

-- Highlight yanked text briefly.
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight on yank",
  callback = function() vim.highlight.on_yank() end,
})

-- ----------------------------------------------------------------------------
--  Bootstrap lazy.nvim
-- ----------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
opt.rtp:prepend(lazypath)

-- ----------------------------------------------------------------------------
--  Plugins
-- ----------------------------------------------------------------------------
require("lazy").setup({
  -- Colorscheme: Nord (loaded first so everything else is themed).
  {
    "gbprod/nord.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("nord").setup({ transparent = false, terminal_colors = true })
      vim.cmd.colorscheme("nord")
    end,
  },

  -- Icons (used by several plugins below).
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Which-key: discoverable keybindings popup.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- Statusline.
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "nord",
        globalstatus = true,
        section_separators = "",
        component_separators = "|",
      },
    },
  },

  -- File explorer (neo-tree).
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Explorer toggle" },
    },
    opts = {
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
      window = { width = 32 },
    },
  },

  -- Fuzzy finder.
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Grep (live)" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help tags" },
      { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
      { "<leader>fd", "<cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
      { "<leader><leader>", "<cmd>Telescope find_files<CR>", desc = "Find files" },
    },
    config = function()
      require("telescope").setup({})
      pcall(require("telescope").load_extension, "fzf")
    end,
  },

  -- Treesitter: better syntax highlighting and indentation.
  -- Pinned to the stable `master` branch: the newer `main` branch is a rewrite
  -- with a different API and no `nvim-treesitter.configs` module.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash", "c", "lua", "luadoc", "markdown", "markdown_inline",
          "python", "javascript", "typescript", "tsx", "json", "yaml",
          "toml", "html", "css", "go", "rust", "dockerfile", "vim", "vimdoc",
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Git: inline signs + hunk actions.
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function m(mode, l, r, desc)
          map(mode, l, r, { buffer = bufnr, desc = desc })
        end
        m("n", "]h", gs.next_hunk, "Next git hunk")
        m("n", "[h", gs.prev_hunk, "Prev git hunk")
        m("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        m("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        m("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        m("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
      end,
    },
  },

  -- LSP: install + configure language servers via mason.
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim", config = true },
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      { "j-hui/fidget.nvim", opts = {} }, -- LSP progress UI
    },
    config = function()
      -- Runs when any LSP attaches to a buffer: set buffer-local maps.
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local function m(keys, fn, desc)
            map("n", keys, fn, { buffer = event.buf, desc = "LSP: " .. desc })
          end
          m("gd", require("telescope.builtin").lsp_definitions, "Goto definition")
          m("gr", require("telescope.builtin").lsp_references, "Goto references")
          m("gI", require("telescope.builtin").lsp_implementations, "Goto implementation")
          m("K", vim.lsp.buf.hover, "Hover docs")
          m("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          m("<leader>ca", vim.lsp.buf.code_action, "Code action")
          m("[d", vim.diagnostic.goto_prev, "Prev diagnostic")
          m("]d", vim.diagnostic.goto_next, "Next diagnostic")
        end,
      })

      -- Advertise nvim-cmp's extra capabilities to servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok then
        capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
      end

      local servers = {
        lua_ls = {
          settings = { Lua = { diagnostics = { globals = { "vim" } } } },
        },
        pyright = {},
        ruff = {},
        ts_ls = {},
        gopls = {},
        rust_analyzer = {},
        bashls = {},
        jsonls = {},
        yamlls = {},
      }

      -- Some servers are built from source by mason and need their language
      -- toolchain present (e.g. gopls needs `go`). Only auto-install those when
      -- the toolchain exists, so a missing toolchain doesn't error on startup.
      -- The server is still configured below, so it activates later if you
      -- install the toolchain and the server binary.
      local function has(bin) return vim.fn.executable(bin) == 1 end
      local needs_toolchain = { gopls = "go" }

      local ensure_installed = {}
      for name in pairs(servers) do
        local tool = needs_toolchain[name]
        if not tool or has(tool) then
          table.insert(ensure_installed, name)
        end
      end

      require("mason").setup()
      require("mason-tool-installer").setup({
        ensure_installed = { "stylua", "black", "isort", "prettier" },
      })
      require("mason-lspconfig").setup({
        ensure_installed = ensure_installed,
        handlers = {
          function(server_name)
            local cfg = servers[server_name] or {}
            cfg.capabilities = vim.tbl_deep_extend(
              "force", {}, capabilities, cfg.capabilities or {}
            )
            require("lspconfig")[server_name].setup(cfg)
          end,
        },
      })
    end,
  },

  -- Autocompletion.
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      { "L3MON4D3/LuaSnip", build = "make install_jsregexp" },
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        completion = { completeopt = "menu,menuone,noinsert" },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
          { name = "buffer" },
        },
      })
    end,
  },

  -- Format on save (conform.nvim).
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    keys = {
      { "<leader>cf", function() require("conform").format({ async = true, lsp_fallback = true }) end, desc = "Format buffer" },
    },
    opts = {
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
      },
    },
  },

  -- Quality-of-life editing plugins.
  { "numToStr/Comment.nvim", event = "VeryLazy", opts = {} },        -- gcc / gc to comment
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },      -- auto close brackets
  { "kylechui/nvim-surround", event = "VeryLazy", opts = {} },        -- ys/cs/ds surround
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
  },
}, {
  ui = { border = "rounded" },
  checker = { enabled = true, notify = false }, -- background update checks
})
