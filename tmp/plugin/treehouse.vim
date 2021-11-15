:lua print("init plugin")

if exists('g:loaded_treehouse')
  finish
endif

:lua require("treehouse").set_keymaps()

command! TreehouseToggle :lua require("treehouse").toggle_outline()
command! TreehouseOpen :lua require("treehouse").open_outline()
command! TreehouseClose :lua require("treehouse").close_outline()
command! TreehouseTest :lua require("treehouse").testing()

" au InsertLeave,WinEnter,BufEnter,BufWinEnter,TabEnter,BufWritePost * :lua require("treehouse")._refresh()

let g:loaded_treehouse = 1
