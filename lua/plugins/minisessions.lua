local session_dir = vim.fn.expand('~/.config/nvim/sessions/')
if vim.fn.isdirectory(session_dir) == 0 then
    vim.fn.mkdir(session_dir, "p")
end

require('mini.sessions').setup({
    -- Directory where sessions are stored
    directory = session_dir,

    -- Autosave settings
    autoread = true, -- Automatically read session if present
    autowrite = true, -- Automatically write session on VimExit
    file = 'Session.vim',
    force = {
        read = false,
        write = true
    }, -- Overwrite existing session files

    -- Hooks for custom actions
    hooks = {
        pre = {
            read = nil,
            write = nil
        },
        post = {
            read = nil,
            write = nil
        }
    }
})
