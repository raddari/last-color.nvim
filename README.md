# 🎨 Last Color
**Last Color** saves the name of the last (successful) colorscheme change to your filesystem and allows you to recall it whenever you desire. As such, you can automatically set your colorscheme between sessions based on what you last used! See the end of this readme for an example.

## Why?
I'm *extremely* indecisive when choosing my colorscheme. I considered setting up my colors in a `.gitignore`d file, but **telescope**'s colorscheme picker is way too convenient compared to editing this file 🐵

## Installation
Ye olde standard plugin manager.
```lua
-- packer
use({ 'raddari/last-color.nvim' })
```

## Configuration
None. It'll call `setup` itself when loaded.

## Usage
Dead simple. I use this snippet in my `init.lua` to automatically use the last theme.
```lua
-- kanagawa as a backup, `recall()` can return `nil`.
local theme = require('last-color').recall() or 'kanagawa'
vim.cmd(('colorscheme %s'):format(theme))
```
There's also an Ex command to print the name; `:LastColor`.

TODO: showcase
