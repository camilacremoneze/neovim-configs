local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
        lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Essentials
    "nvim-lua/plenary.nvim",
    "folke/which-key.nvim",
    "nvim-tree/nvim-tree.lua",
    "nvim-telescope/telescope.nvim",

    -- LSP Logic
    {
        "neovim/nvim-lspconfig",
        dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
        config = function() require("plugins.lsp") end
    },

    -- AI
    "github/copilot.vim",
    -- require("plugins.opencode"),

    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                flavour = "frappe",
                integrations = {
                    telescope = { enabled = true },
                    mason = true,
                    nvimtree = true,
                    which_key = true,
                    native_lsp = {
                        enabled = true,
                        underlines = {
                            errors = { "undercurl" },
                            hints = { "undercurl" },
                            warnings = { "undercurl" },
                            information = { "undercurl" },
                        },
                    },
                },
            })
            vim.cmd.colorscheme("catppuccin-frappe")
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            -- This 'pcall' (protected call) prevents the crash if files aren't found yet
            local status_ok, configs = pcall(require, "nvim-treesitter.configs")
            if not status_ok then return end

            configs.setup({
                ensure_installed = { "go", "lua", "vim", "vimdoc", "markdown" },
                auto_install = true,
                highlight = {
                    enable = true,
                    -- Setting this to false prevents conflict with standard Vim regex
                    additional_vim_regex_highlighting = false,
                },
                indent = { enable = true },
            })
        end,
    },
})

require("which-key").setup()
require("nvim-tree").setup()
