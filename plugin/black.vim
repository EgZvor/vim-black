" black.vim
" Author: Łukasz Langa
" Created: Mon Mar 26 23:27:53 2018 -0700
" Requires: Vim Ver7.0+
" Version:  1.1
"
" Documentation:
"   This plugin formats Python files.
"
" History:
"  1.0:
"    - initial version
"  1.1:
"    - restore cursor/window position after formatting

if v:version < 700 || !has('python3')
    func! __BLACK_MISSING()
        echo "The black.vim plugin requires vim7.0+ with Python 3.6 support."
    endfunc
    command! Black :call __BLACK_MISSING()
    command! BlackVersion :call __BLACK_MISSING()
    finish
endif

if exists("g:load_black")
   finish
endif

let g:load_black = "py1.0"
if !exists("g:black_fast")
  let g:black_fast = 0
endif
if !exists("g:black_linelength")
  let g:black_linelength = 88
endif
if !exists("g:black_string_normalization")
  if exists("g:black_skip_string_normalization")
    let g:black_string_normalization = !g:black_skip_string_normalization
  else
    let g:black_string_normalization = 1
  endif
endif

command! -range=% Black :call black#Black(<line1>, <line2>)
command! BlackVersion :call black#BlackVersion()


function Blackify(type = '')
    if a:type == ''
        set opfunc=Blackify
        return 'g@'
    endif
    let start = getpos("'[")[1]
    let end = getpos("']")[1]
    call black#Black(start, end)
endfunction


nnoremap <expr> <Plug>(Blackify) Blackify()
nnoremap <expr> <Plug>(BlackifyLine) Blackify() .. '_'
