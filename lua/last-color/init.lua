local api = vim.api
local uv = vim.loop
local cache_file = string.format('%s/last-color', vim.fn.stdpath('data'))

local M = {}

local open_cache_file = function(mode)
  -- 438(10) == 666(8) [owner/group/others can read/write]
  local flags = 438
  local fd = assert(uv.fs_open(cache_file, mode, flags))
  return fd
end

local read_cache_file = function()
  local fd = open_cache_file('r')
  local stat = assert(uv.fs_fstat(fd))
  local data = assert(uv.fs_read(fd, stat.size, -1))
  assert(uv.fs_close(fd))

  local colorscheme = string(data):gsub('[\n\r]', '')
  return colorscheme
end

local write_cache_file = function(colorscheme)
  local fd = open_cache_file('w')
  assert(uv.fs_write(fd, string.format('%s\n', colorscheme), -1))
  assert(uv.fs_close(fd))
end

--- Read the cached colorscheme from disk.
--- @return string|nil colorscheme
M.recall = function()
  local ok, result = pcall(read_cache_file)
  return ok and result or nil
end

--- Creates the autocommand which saves the last ':colorscheme' to disk, along
--- with the Ex command 'LastColor'. This is automatically called when the
--- plugin is loaded.
M.setup = function()
  api.nvim_create_autocmd('ColorScheme', {
    group = api.nvim_create_augroup('last-color', { clear = true }),
    pattern = '*',
    desc = 'Save colorscheme name to filesystem when changed',
    callback = function(info)
      local new_scheme = info.match
      local valid_schemes = vim.fn.getcompletion('', 'color')
      -- fix for #2
      if not vim.tbl_contains(valid_schemes, new_scheme) then
        return nil
      end

      local ok, result = pcall(write_cache_file, new_scheme)
      if not ok then
        vim.api.nvim_err_writeln(string.format('cannot write to cache file: %s', result))
        -- delete the autocommand to prevent further error notifications
        return true
      end
    end,
  })

  api.nvim_create_user_command('LastColor', function(_)
    print(M.recall())
  end, { desc = 'Prints the cached colorscheme' })
end

return M
