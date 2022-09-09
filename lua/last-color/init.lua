local api = vim.api
local uv = vim.loop

local M = {}
local cache_path = vim.fn.stdpath('data') .. '/last_color'

local open_cache_file = function(mode)
  -- 438(10) == 666(8) [owner/group/others can read/write]
  local flags = 438
  local fd = uv.fs_open(cache_path, mode, flags)
  return fd
end

--- Creates the autocommand which remembers when a colorscheme is changed,
--- along with the ex-command 'LastColor'.
--- This is automatically called when the plugin is loaded.
M.setup = function()
  api.nvim_create_autocmd('ColorScheme', {
    group = api.nvim_create_augroup('last-color', { clear = true }),
    pattern = '*',
    desc = 'Cache colorscheme when changed',
    callback = function(info)
      local fd = open_cache_file('w')
      local colorscheme = info.match .. '\n'
      assert(uv.fs_write(fd, colorscheme, -1))
      assert(uv.fs_close(fd))
    end,
  })

  api.nvim_create_user_command('LastColor', function(_)
    print(M.recall())
  end, { desc = 'Prints the last color used in :colorscheme' })
end

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
