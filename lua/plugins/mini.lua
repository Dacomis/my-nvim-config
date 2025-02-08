require('mini.ai').setup()
require('mini.surround').setup()
require('mini.operators').setup()
require('mini.pairs').setup()
require('mini.bracketed').setup()
require('mini.files').setup()
require('mini.sessions').setup {
  autoread = true,
  autowrite = true,
  directory = vim.fn.stdpath 'data' .. '/sessions',
  file = '',
}
