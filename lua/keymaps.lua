-- Twilight

vim.api.nvim_set_keymap('n', 'tw', ':Twilight<enter>', { noremap = false })
-- Buffers

vim.api.nvim_set_keymap('n', 'tk', ':blast<enter>', { noremap = false })
vim.api.nvim_set_keymap('n', 'tj', ':bfirst<enter>', { noremap = false })
vim.api.nvim_set_keymap('n', 'th', ':bprev<enter>', { noremap = false })
vim.api.nvim_set_keymap('n', 'tl', ':bnext<enter>', { noremap = false })
vim.api.nvim_set_keymap('n', 'td', ':bdelete<enter>', { noremap = false })
-- Files

vim.api.nvim_set_keymap('n', 'QQ', ':q!<enter>', { noremap = false })
vim.api.nvim_set_keymap('n', 'WW', ':w!<enter>', { noremap = false })
vim.api.nvim_set_keymap('n', 'E', '$', { noremap = false })
vim.api.nvim_set_keymap('n', 'B', '^', { noremap = false })
vim.api.nvim_set_keymap('n', 'TT', ':TransparentToggle<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', 'ss', ':noh<CR>', { noremap = true })
-- Splits

vim.api.nvim_set_keymap('n', '<C-W>,', ':vertical resize -10<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-W>.', ':vertical resize +10<CR>', { noremap = true })
vim.keymap.set('n', '<space><space>', '<cmd>set nohlsearch<CR>')

-- Quicker close split
vim.keymap.set('n', '<leader>qq', ':q<CR>', { silent = true, noremap = true })

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Noice
vim.api.nvim_set_keymap('n', '<leader>nn', ':Noice dismiss<CR>', { noremap = true })

vim.keymap.set('n', '<leader>ie', '<cmd>GoIfErr<cr>', {
  silent = true,
  noremap = true,
})

-- Yank and Paste to the OS clipboard
vim.keymap.set('n', '<leader>y', '"+y', {
  noremap = true,
  silent = true,
})
vim.keymap.set('v', '<leader>y', '"+y', {
  noremap = true,
  silent = true,
})
vim.keymap.set('n', '<leader>p', '"+p', {
  noremap = true,
  silent = true,
})
vim.keymap.set('v', '<leader>p', '"+p', {
  noremap = true,
  silent = true,
})

-- Yank Relative Path to OS clipboard
vim.keymap.set('n', '<leader>yp', function()
  local filepath = vim.fn.fnamemodify(vim.fn.expand '%', ':~:.')
  vim.fn.setreg('+', filepath)
  print('Copied relative file path: ' .. filepath)
end, {
  noremap = true,
  silent = true,
  desc = 'Copy relative file path',
})

-- Yank whole content to OS clipboard
vim.keymap.set('n', '<leader>yc', function()
  vim.cmd ':%y+'
  print 'Copied file contents'
end, {
  noremap = true,
  silent = true,
  desc = 'Copy entire file contents',
})

-- Yank file path and whole content to OS clipboard
vim.keymap.set('n', '<leader>ya', function()
  local filepath = vim.fn.fnamemodify(vim.fn.expand '%', ':~:.') -- Relative path
  local filecontent = table.concat(vim.fn.getline(1, '$'), '\n') -- Entire file content
  local combined = filepath .. '\n\n' .. filecontent -- Combine them with a separator
  vim.fn.setreg('+', combined) -- Copy to system clipboard
  print 'Copied file path and contents'
end, {
  noremap = true,
  silent = true,
  desc = 'Copy file path and contents',
})

-- Yank all file paths and contents from the current file's folder
vim.keymap.set('n', '<leader>yaf', function()
  local current_file = vim.fn.expand '%:p' -- Absolute path of the current file
  local folder_path = vim.fn.fnamemodify(current_file, ':h') -- Get folder path
  local files = vim.fn.glob(folder_path .. '/*', false, true) -- Get all files in the folder
  local result = {} -- To store combined file paths and contents

  for _, filepath in ipairs(files) do
    if vim.fn.isdirectory(filepath) == 0 then -- Skip directories
      local relative_path = vim.fn.fnamemodify(filepath, ':~:.') -- Relative path
      local file_content = vim.fn.readfile(filepath) -- Read file content
      table.insert(result, relative_path) -- Add relative path
      table.insert(result, '') -- Separator line
      table.insert(result, table.concat(file_content, '\n')) -- Add file content
      table.insert(result, '') -- Blank line between files
    end
  end

  -- Combine all results into a single string
  local combined = table.concat(result, '\n')
  vim.fn.setreg('+', combined) -- Copy to system clipboard
  print('Copied all file paths and contents from the folder: ' .. folder_path)
end, {
  noremap = true,
  silent = true,
  desc = "Copy all file paths and contents from the current file's folder",
})

-- Yank all file paths and contents from the entire project
vim.keymap.set('n', '<leader>yap', function()
  -- Get the project root using the current working directory
  local project_root = vim.fn.getcwd()
  local files = vim.fn.glob(project_root .. '/**/*', false, true) -- Recursively get all files
  local result = {} -- To store combined file paths and contents

  for _, filepath in ipairs(files) do
    if vim.fn.isdirectory(filepath) == 0 then -- Skip directories
      local relative_path = vim.fn.fnamemodify(filepath, ':~:.') -- Relative path
      local file_content = vim.fn.readfile(filepath) -- Read file content
      table.insert(result, relative_path) -- Add relative path
      table.insert(result, '') -- Separator line
      table.insert(result, table.concat(file_content, '\n')) -- Add file content
      table.insert(result, '') -- Blank line between files
    end
  end

  -- Combine all results into a single string
  local combined = table.concat(result, '\n')
  vim.fn.setreg('+', combined) -- Copy to system clipboard
  print('Copied all file paths and contents from the project: ' .. project_root)
end, {
  noremap = true,
  silent = true,
  desc = 'Copy all file paths and contents from the entire project',
})

-- Yank all file paths and contents from the entire project and transform it to XML
vim.keymap.set('n', '<leader>yax', function()
  -- Get the project root using the current working directory
  local project_root = vim.fn.getcwd()
  local files = vim.fn.glob(project_root .. '/**/*', false, true) -- Recursively get all files
  local result = {} -- To store XML structure

  table.insert(result, '<project>') -- Start XML root tag

  for _, filepath in ipairs(files) do
    if vim.fn.isdirectory(filepath) == 0 then -- Skip directories
      local relative_path = vim.fn.fnamemodify(filepath, ':~:.') -- Relative path
      local file_content = vim.fn.readfile(filepath) -- Read file content
      table.insert(result, string.format('  <file path="%s">', relative_path)) -- File start tag
      table.insert(result, '    <![CDATA[') -- Start CDATA section for content
      table.insert(result, table.concat(file_content, '\n')) -- Add file content
      table.insert(result, '    ]]>') -- End CDATA section
      table.insert(result, '  </file>') -- File end tag
    end
  end

  table.insert(result, '</project>') -- End XML root tag

  -- Combine all results into a single string
  local xml_content = table.concat(result, '\n')
  vim.fn.setreg('+', xml_content) -- Copy to system clipboard
  print('Copied all files and contents as XML from project: ' .. project_root)
end, {
  noremap = true,
  silent = true,
  desc = 'Copy all files and contents as XML from the entire project',
})

-- Yank all file paths and contents from the entire project, transform it to XML, and update the docs/config.xml file
vim.keymap.set('n', '<leader>yau', function()
  -- Get the project root and output file path
  local project_root = vim.fn.getcwd()
  local output_file = project_root .. '/docs/config.xml'

  -- Recursively get all files excluding the output file
  local files = vim.fn.glob(project_root .. '/**/*', false, true)
  local result = {}

  table.insert(result, '<project>') -- Start XML root tag

  for _, filepath in ipairs(files) do
    if vim.fn.isdirectory(filepath) == 0 and filepath ~= output_file then -- Skip directories and output file
      local relative_path = vim.fn.fnamemodify(filepath, ':~:.') -- Relative path
      local file_content = vim.fn.readfile(filepath) -- Read file content
      table.insert(result, string.format('  <file path="%s">', relative_path)) -- File start tag
      table.insert(result, '    <![CDATA[') -- Start CDATA section for content
      table.insert(result, table.concat(file_content, '\n')) -- Add file content
      table.insert(result, '    ]]>') -- End CDATA section
      table.insert(result, '  </file>') -- File end tag
    end
  end

  table.insert(result, '</project>') -- End XML root tag

  -- Combine all results into a single string
  local xml_content = table.concat(result, '\n')

  -- Write the XML content to the output file
  vim.fn.writefile(vim.split(xml_content, '\n'), output_file)

  -- Notify the user
  print('Updated XML in: ' .. output_file)
end, {
  noremap = true,
  silent = true,
  desc = 'Update XML file with all files and contents from project',
})

-- Close Location List (:lclose)
vim.keymap.set('n', '<leader>l', ':lclose<CR>', {
  noremap = true,
  silent = true,
})

-- Undo Tree
vim.keymap.set('n', '<leader>u', ':UndotreeToggle<CR>', {
  noremap = true,
  silent = true,
})

-- Nvim Tree
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', {
  noremap = true,
  silent = true,
})
