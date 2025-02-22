-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "gd", require("telescope.builtin").lsp_definitions, { silent = true })

-- Yank Relative Path to OS clipboard
vim.keymap.set("n", "<leader>yp", function()
  local filepath = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.")
  vim.fn.setreg("+", filepath)
  print("Copied relative file path: " .. filepath)
end, {
  noremap = true,
  silent = true,
  desc = "[Y]ank [P]ath to clipboard",
})

-- Yank whole content to OS clipboard
vim.keymap.set("n", "<leader>yc", function()
  vim.cmd(":%y+")
  print("Copied file contents")
end, {
  noremap = true,
  silent = true,
  desc = "[Y]ank [C]ontent to clipboard",
})

-- Yank file path and content to OS clipboard
vim.keymap.set("n", "<leader>yf", function()
  local filepath = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.") -- Relative path
  local filecontent = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  local combined = filepath .. "\n\n" .. filecontent -- Combine them with a separator
  vim.fn.setreg("+", combined) -- Copy to system clipboard
  print("Copied file path and contents")
end, {
  noremap = true,
  silent = true,
  desc = "[Y]ank [F]ile to clipboard",
})

-- Yank all file paths and contents from the current file's folder
vim.keymap.set("n", "<leader>yaf", function()
  local current_file = vim.fn.expand("%:p") -- Absolute path of the current file
  local folder_path = vim.fn.fnamemodify(current_file, ":h") -- Get folder path
  local files = vim.fn.glob(folder_path .. "/*", false, true) -- Get all files in the folder
  local result = {} -- To store combined file paths and contents

  for _, filepath in ipairs(files) do
    if vim.fn.isdirectory(filepath) == 0 then -- Skip directories
      local relative_path = vim.fn.fnamemodify(filepath, ":~:.") -- Relative path
      local file_content = vim.fn.readfile(filepath) -- Read file content
      table.insert(result, relative_path) -- Add relative path
      table.insert(result, "") -- Separator line
      table.insert(result, table.concat(file_content, "\n")) -- Add file content
      table.insert(result, "") -- Blank line between files
    end
  end

  -- Combine all results into a single string
  local combined = table.concat(result, "\n")
  vim.fn.setreg("+", combined) -- Copy to system clipboard
  print("Copied all file paths and contents from the folder: " .. folder_path)
end, {
  noremap = true,
  silent = true,
  desc = "Copy all file paths and contents from the current file's folder",
})

-- Yank all file paths and contents from the entire project
vim.keymap.set("n", "<leader>yap", function()
  -- Get the project root using the current working directory
  local project_root = vim.fn.getcwd()
  local files = vim.fn.glob(project_root .. "/**/*", false, true) -- Recursively get all files
  local result = {} -- To store combined file paths and contents

  for _, filepath in ipairs(files) do
    if vim.fn.isdirectory(filepath) == 0 then -- Skip directories
      local relative_path = vim.fn.fnamemodify(filepath, ":~:.") -- Relative path
      local file_content = vim.fn.readfile(filepath) -- Read file content
      table.insert(result, relative_path) -- Add relative path
      table.insert(result, "") -- Separator line
      table.insert(result, table.concat(file_content, "\n")) -- Add file content
      table.insert(result, "") -- Blank line between files
    end
  end

  -- Combine all results into a single string
  local combined = table.concat(result, "\n")
  vim.fn.setreg("+", combined) -- Copy to system clipboard
  print("Copied all file paths and contents from the project: " .. project_root)
end, {
  noremap = true,
  silent = true,
  desc = "Copy all file paths and contents from the entire project",
})

-- Yank all file paths and contents from the entire project, transform it to XML, and update the docs/config.xml file
vim.keymap.set("n", "<leader>yax", function()
  local config_root = vim.fn.stdpath("config")
  local output_file = config_root .. "/docs/config.xml"

  -- Target specific LazyVim config folders
  local config_paths = {
    "/lua/config/",
    "/lua/plugins/",
    "init.lua",
  }

  local result = { "<project>" }
  for _, path in ipairs(config_paths) do
    local files = vim.fn.glob(config_root .. path .. "*.lua", false, true)
    for _, filepath in ipairs(files) do
      if vim.fn.isdirectory(filepath) == 0 then
        local relative_path = vim.fn.fnamemodify(filepath, ":~:.")
        local file_content = vim.fn.readfile(filepath)
        table.insert(result, string.format('  <file path="%s">', relative_path))
        table.insert(result, "    <![CDATA[")
        table.insert(result, table.concat(file_content, "\n"))
        table.insert(result, "    ]]>")
        table.insert(result, "  </file>")
      end
    end
  end
  table.insert(result, "</project>")

  -- Create docs directory if it doesn't exist
  local docs_dir = config_root .. "/docs"
  if vim.fn.isdirectory(docs_dir) == 0 then
    vim.fn.mkdir(docs_dir, "p")
  end

  vim.fn.writefile(vim.split(table.concat(result, "\n"), "\n"), output_file)
  print("Updated Neovim config XML in: " .. output_file)
end, {
  desc = "Export Neovim config to XML",
})
