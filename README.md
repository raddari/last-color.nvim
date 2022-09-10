# 🎨 Last Color
**Last Color** saves the name of the last (successful) colorscheme change to your filesystem and allows you to recall it whenever you desire. As such, you can automatically set your colorscheme between sessions based on what you last used! See the [usage](#usage) section for an example.

## Why?
I'm *extremely* indecisive when choosing my colorscheme. I considered setting up my colors in a `.gitignore`d file, but **telescope**'s colorscheme picker is way too convenient compared to editing a file 🐵

## Installation
Ye olde plugin manager.
```lua
-- packer
use({ 'raddari/last-color.nvim' })
```

## Configuration
None. It'll call `setup` itself when loaded.

## Usage
Dead simple. I use the snippet below in my `init.lua` to automatically use the last theme. There's also an Ex command; `:LastColor`.
```lua
-- kanagawa as a backup, `recall()` can return `nil`.
local theme = require('last-color').recall() or 'kanagawa'
vim.cmd(('colorscheme %s'):format(theme))
```
I personally don't lazy load my plugins, but I'm sure you could modify the snippet to account for that 😀

## Showcase
Using the lua snippet above:

![last-color](https://user-images.githubusercontent.com/25364469/189385514-563ca684-41c9-42db-a2a6-12921f4f3095.gif)

## Issues
Please open an issue for any problems you encounter, or suggestions for improving the code quality. This is my first plugin, so I'm still learning and looking to improve 😁
