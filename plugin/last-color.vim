" Title:       Last Color
" Description: Remember your last call to :colorscheme
" Maintainer:  raddari <https://github.com/raddari>

" Prevents the plugin from being loaded multiple times. If the loaded
" variable exists, do nothing more. Otherwise, assign the loaded
" variable and continue running this instance of the plugin.
if exists("g:loaded_lastcolor")
  finish
endif
let g:loaded_lastcolor = 1

lua require('last-color').setup()
