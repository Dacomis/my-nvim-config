-- Set leader key before loading plugins

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Load lazy.nvim for plugin management
require 'plugins.lazy'

-- Load core configurations
require 'options'
require 'keymaps'
require 'misc'

-- Load plugin configurations
-- Note: These will only load after lazy.nvim has loaded the plugins
require 'plugins.lualine'
require 'plugins.treesitter'
require 'plugins.lsp'
require 'plugins.dap'
require 'plugins.gitsigns'
require 'plugins.tele'
require 'plugins.trouble'
require 'plugins.neogit'
require 'plugins.harpoon'
require 'plugins.mini'
require 'plugins.minisessions'
require 'plugins.misc'

-- vim: ts=8 sts=2 sw=2 et
