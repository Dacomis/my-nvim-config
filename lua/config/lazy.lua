local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    -- import/override with your plugins
    { import = "plugins" },

    -- Mini.surround
    {
      "echasnovski/mini.surround",
      event = "VeryLazy",
      opts = {
        mappings = {
          add = "gsa",
          delete = "gsd",
          find = "gsf",
          find_left = "gsF",
          highlight = "gsh",
          replace = "gsr",
          update_n_lines = "gsn",
        },
      },
    },

    -- Mini.pairs
    {
      "echasnovski/mini.pairs",
      event = "VeryLazy",
      opts = {
        modes = { insert = true, command = true, terminal = false },
        skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
        skip_ts = { "string" },
        skip_unbalanced = true,
        markdown = true,
      },
      config = function(_, opts)
        LazyVim.mini.pairs(opts)
      end,
    },

    -- Mini.ai
    {
      "echasnovski/mini.ai",
      event = "VeryLazy",
      opts = function()
        local ai = require("mini.ai")
        return {
          n_lines = 500,
          custom_textobjects = {
            o = ai.gen_spec.treesitter({
              a = { "@block.outer", "@conditional.outer", "@loop.outer" },
              i = { "@block.inner", "@conditional.inner", "@loop.inner" },
            }),
            f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
            c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
            t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
            d = { "%f[%d]%d+" },
            e = {
              { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
              "^().*()$",
            },
            g = LazyVim.mini.ai_buffer,
            u = ai.gen_spec.function_call(),
            U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
          },
        }
      end,
      config = function(_, opts)
        require("mini.ai").setup(opts)
        LazyVim.on_load("which-key.nvim", function()
          vim.schedule(function()
            LazyVim.mini.ai_whichkey(opts)
          end)
        end)
      end,
    },

    -- Comments
    {
      "folke/ts-comments.nvim",
      event = "VeryLazy",
      opts = {},
    },

    -- Completion
    {
      "hrsh7th/nvim-cmp",
      event = "VeryLazy",
      opts = function(_, opts)
        local has_words_before = function()
          unpack = unpack or table.unpack
          local line, col = unpack(vim.api.nvim_win_get_cursor(0))
          return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
        end

        local cmp = require("cmp")

        opts.mapping = vim.tbl_extend("force", opts.mapping, {
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif vim.snippet.active({ direction = 1 }) then
              vim.schedule(function()
                vim.snippet.jump(1)
              end)
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif vim.snippet.active({ direction = -1 }) then
              vim.schedule(function()
                vim.snippet.jump(-1)
              end)
            else
              fallback()
            end
          end, { "i", "s" }),
        })
      end,
    },

    -- Catppuccin colorscheme
    {
      "catppuccin/nvim",
      name = "catppuccin",
      lazy = false,
      priority = 1000,
      config = function()
        require("catppuccin").setup({
          flavour = "latte",
          background = {
            light = "latte",
            dark = "latte",
          },
          transparent_background = true,
          show_end_of_buffer = false,
          term_colors = false,
          dim_inactive = {
            enabled = false,
            shade = "dark",
            percentage = 0.15,
          },
          integrations = {
            aerial = true,
            alpha = true,
            cmp = true,
            dashboard = true,
            flash = true,
            fzf = true,
            grug_far = true,
            gitsigns = true,
            headlines = true,
            illuminate = true,
            indent_blankline = { enabled = true },
            leap = true,
            lsp_trouble = true,
            mason = true,
            markdown = true,
            mini = true,
            native_lsp = {
              enabled = true,
              underlines = {
                errors = { "undercurl" },
                hints = { "undercurl" },
                warnings = { "undercurl" },
                information = { "undercurl" },
              },
            },
            navic = { enabled = true, custom_bg = "lualine" },
            neotest = true,
            neotree = true,
            noice = true,
            notify = true,
            semantic_tokens = true,
            snacks = true,
            telescope = true,
            treesitter = true,
            treesitter_context = true,
          },
        })
        vim.cmd.colorscheme("catppuccin")
      end,
    },

    -- Bufferline integration
    {
      "akinsho/bufferline.nvim",
      optional = true,
      event = "VeryLazy",
      opts = function(_, opts)
        if (vim.g.colors_name or ""):find("catppuccin") then
          opts.highlights = require("catppuccin.groups.integrations.bufferline").get()
        end
      end,
    },

    -- Telescope
    {
      "nvim-telescope/telescope.nvim",
      event = "VeryLazy",
      branch = "0.1.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-fzf-native.nvim",
      },
    },

    -- Which-key
    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      opts = {
        spec = {
          ["<leader>Y"] = { name = "[Y]ank to clipboard" },
        },
      },
    },

    -- Grug-far
    {
      "MagicDuck/grug-far.nvim",
      event = "VeryLazy",
      opts = { headerMaxWidth = 80 },
      cmd = "GrugFar",
      keys = {
        {
          "<leader>sr",
          function()
            local grug = require("grug-far")
            local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
            grug.open({
              transient = true,
              prefills = {
                filesFilter = ext and ext ~= "" and "*." .. ext or nil,
              },
            })
          end,
          mode = { "n", "v" },
          desc = "Search and Replace",
        },
      },
    },

    -- Git signs
    {
      "lewis6991/gitsigns.nvim",
      event = "LazyFile",
      opts = {
        signs = {
          add = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "" },
          topdelete = { text = "" },
          changedelete = { text = "▎" },
          untracked = { text = "▎" },
        },
        signs_staged = {
          add = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "" },
          topdelete = { text = "" },
          changedelete = { text = "▎" },
        },
        on_attach = function(buffer)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
          end
          map("n", "]h", gs.next_hunk, "Next Hunk")
          map("n", "[h", gs.prev_hunk, "Prev Hunk")
          map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
          map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk")
          map("n", "<leader>ghb", function()
            gs.blame_line({ full = true })
          end, "Blame Line")
        end,
      },
      config = function(_, opts)
        require("gitsigns").setup(opts)
        Snacks.toggle({
          name = "Git Signs",
          get = function()
            return require("gitsigns.config").config.signcolumn
          end,
          set = function(state)
            require("gitsigns").toggle_signs(state)
          end,
        }):map("<leader>uG")
      end,
    },

    {
      "folke/trouble.nvim",
      cmd = { "Trouble" },
      opts = {
        modes = {
          lsp = {
            win = { position = "right" },
          },
        },
      },
      keys = {
        { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
        { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
        { "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
        { "<leader>cS", "<cmd>Trouble lsp toggle<cr>", desc = "LSP references/definitions/... (Trouble)" },
        { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
        { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
        {
          "[q",
          function()
            if require("trouble").is_open() then
              require("trouble").prev({ skip_groups = true, jump = true })
            else
              local ok, err = pcall(vim.cmd.cprev)
              if not ok then
                vim.notify(err, vim.log.levels.ERROR)
              end
            end
          end,
          desc = "Previous Trouble/Quickfix Item",
        },
        {
          "]q",
          function()
            if require("trouble").is_open() then
              require("trouble").next({ skip_groups = true, jump = true })
            else
              local ok, err = pcall(vim.cmd.cnext)
              if not ok then
                vim.notify(err, vim.log.levels.ERROR)
              end
            end
          end,
          desc = "Next Trouble/Quickfix Item",
        },
      },
    },

    {
      "folke/todo-comments.nvim",
      cmd = { "TodoTrouble", "TodoTelescope" },
      event = "LazyFile",
      opts = {},
      -- stylua: ignore
      keys = {
        {
          "]t",
          function()
            require("todo-comments").jump_next()
          end,
          desc = "Next Todo Comment",
        },
        {
          "[t",
          function()
            require("todo-comments").jump_prev()
          end,
          desc = "Previous Todo Comment",
        },
        { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
        {
          "<leader>xT",
          "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>",
          desc = "Todo/Fix/Fixme (Trouble)",
        },
        { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
        { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
      },
    },

    -- LSP Configuration
    {
      "neovim/nvim-lspconfig",
      opts = {
        servers = {
          tsserver = {
            init_options = {
              maxTsServerMemory = 8192,
              importModuleSpecifierEnding = "minimal",
              preferences = {
                importModuleSpecifierPreference = "relative",
              },
            },
            settings = {
              typescript = {
                inlayHints = {
                  includeInlayParameterNameHints = "all",
                  includeInlayPropertyDeclarationTypeHints = true,
                  includeInlayFunctionParameterTypeHints = true,
                },
              },
              javascript = {
                inlayHints = {
                  includeInlayParameterNameHints = "all",
                  includeInlayPropertyDeclarationTypeHints = true,
                  includeInlayFunctionParameterTypeHints = true,
                },
              },
            },
          },
        },
      },
    },
  },

  defaults = {
    lazy = false,
    version = false,
  },

  install = { colorscheme = { "catppuccin", "tokyonight", "habamax" } },

  checker = {
    enabled = true,
    notify = false,
  },

  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
