# 🎨 Last Color
**Last Color** saves the name of the last (successful) colorscheme change to your filesystem and allows you to recall it whenever you desire. As such, you can automatically set your colorscheme between sessions based on what you last used! See the [usage](#usage) section for an example.

## Installation
Ye olde plugin manager.
```lua
{ 'raddari/last-color.nvim' }
```

## Configuration
None.

## Usage
### Simple
Drop something like this in your `init.lua`:
```lua
-- kanagawa as a backup, `recall()` can return `nil`.
local theme = require('last-color').recall() or 'kanagawa'
vim.cmd(('colorscheme %s'):format(theme))
```
### Different Colorscheme Slots
If you use a plugin like [`f-person/auto-dark-mode.nvim`](https://github.com/f-person/auto-dark-mode.nvim), you can choose which 'slot' the colorscheme will save to/load from:
```lua
-- LazySpec
return {
  'f-person/auto-dark-mode.nvim',
  config = {
    set_dark_mode = function()
      local last_color = require('last-color')
      -- last-color will now write to `<cache_dir>/last-color.dark` for any subsequent `colorscheme` commands
      last_color.slot('dark')
      -- last-color will now read from `<cache_dir>/last-color.dark`
      vim.cmd.colorscheme(last_color.recall())
    end,
    set_light_mode = function()
      local last_color = require('last-color')
      -- last-color will now write to `<cache_dir>/last-color.light` for any subsequent `colorscheme` commands
      last_color.slot('light')
      -- last-color will now read from `<cache_dir>/last-color.light`
      vim.cmd.colorscheme(last_color.recall())
    end,
  },
}
```

## Showcase
Using the simple lua snippet above:

![last-color](https://user-images.githubusercontent.com/25364469/189385514-563ca684-41c9-42db-a2a6-12921f4f3095.gif)
