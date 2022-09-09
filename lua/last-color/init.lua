local api = vim.api
local uv = vim.loop

local M = {}
local cache_path = vim.fn.stdpath('data') .. '/last_color'

--- Open the file where the colorscheme name is saved.
--- See `:h uv.fs_open()` for a better description of parameters.
---
--- @param mode string r for read, w for write
--- @return integer|nil fd
local open_cache_file = function(mode)
  --- 438(10) == 666(8) [owner/group/others can read/write]
  local flags = 438
  local fd, err = uv.fs_open(cache_path, mode, flags)
  if err then
    vim.api.nvim_notify(('Error opening last_color cache file:\n\n%s'):format(err), vim.log.levels.ERROR, {})
  end
  return fd
end

--- Creates the autocommand which remembers when a colorscheme is changed,
--- along with the Ex command 'LastColor'.
--- This is automatically called when the plugin is loaded.
M.setup = function()
  api.nvim_create_autocmd('ColorScheme', {
    group = api.nvim_create_augroup('last-color', { clear = true }),
    pattern = '*',
    desc = 'Save colorscheme name to filesystem when changed',
    callback = function(info)
      local fd = open_cache_file('w')
      if not fd then
        -- delete the autocommand to prevent further error notifications
        -- if we can't open the cache file
        return true
      end

      local colorscheme = info.match .. '\n'
      assert(uv.fs_write(fd, colorscheme, -1))
      assert(uv.fs_close(fd))
    end,
  })

  api.nvim_create_user_command('LastColor', function(_)
    print(M.recall())
  end, { desc = 'Prints the last color used in :colorscheme' })
end

--- Reads the cache to find the name of the last `:colorscheme` argument.
---
--- @return string|nil colorscheme
M.recall = function()
  local fd = open_cache_file('r')
  if not fd then
    return nil
  end

  local stat = assert(uv.fs_fstat(fd))
  local data = assert(uv.fs_read(fd, stat.size, -1))
  assert(uv.fs_close(fd))

  local colorscheme, _ = data:gsub('[\n\r]', '')
  return colorscheme
end

return M
