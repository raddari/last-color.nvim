local uv = vim.loop
local cache_file = string.format('%s/last-color', vim.fn.stdpath('data'))

local M = {}

---@param mode string
---@param slot string|nil
local open_cache_file = function(mode, slot)
  local filename = slot and ('%s.%s'):format(cache_file, slot) or cache_file
  -- 438(10) == 666(8) [owner/group/others can read/write]
  local flags = 438
  return uv.fs_open(filename, mode, flags)
end

---@param slot string|nil
local read_cache_file = function(slot)
  local fd, err_name, err_msg = open_cache_file('r', slot)
  if not fd then
    if err_name == 'ENOENT' then
      -- cache never written: ok, :colorscheme never executed
      return nil
    end
    error(string.format('%s: %s', err_name, err_msg))
  end

  local stat = assert(uv.fs_fstat(fd))
  local data = assert(uv.fs_read(fd, stat.size, -1))
  assert(uv.fs_close(fd))

  local colorscheme = tostring(data):gsub('[\n\r]', '')
  return colorscheme
end

---@param colorscheme string name of colorscheme
---@param slot string|nil name of slot to use
local write_cache_file = function(colorscheme, slot)
  local fd = assert(open_cache_file('w', slot))
  assert(uv.fs_write(fd, string.format('%s\n', colorscheme), -1))
  assert(uv.fs_close(fd))
end

---@type string|nil name of slot in use
M.current_slot = nil

--- Read the cached colorscheme from disk.
--- @return string|nil colorscheme
M.recall = function()
  local ok, result = pcall(read_cache_file, M.current_slot)
  return ok and result or nil
end

---Sets the current slot to read/write colorscheme to.
---@return string|nil slot previous slot in use
M.slot = function(name)
  local old = M.current_slot
  M.current_slot = name
  return old
end

--- Creates the autocommand which saves the last ':colorscheme' to disk, along
--- with the Ex command 'LastColor'. This is automatically called when the
--- plugin is loaded.
M.setup = function()
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('last-color', { clear = true }),
    pattern = '*',
    desc = 'Cache colorscheme name to disk on change',
    callback = function(info)
      local new_scheme = info.match
      local valid_schemes = vim.fn.getcompletion('', 'color')
      -- fix for #2
      if not vim.tbl_contains(valid_schemes, new_scheme) then
        return nil
      end

      local ok, result = pcall(write_cache_file, new_scheme, M.current_slot)
      if not ok then
        vim.api.nvim_err_writeln(string.format('cannot write to cache file: %s', result))
        -- delete the autocommand to prevent further error notifications
        return true
      end
    end,
  })

  vim.api.nvim_create_user_command('LastColor', function(_)
    print(M.recall())
  end, { desc = 'Prints the cached colorscheme' })
end

return M
