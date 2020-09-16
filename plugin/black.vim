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
    command! BlackUpgrade :call __BLACK_MISSING()
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

python3 << EndPython3
import black
import collections
import os
import sys
import time
import vim
from distutils.util import strtobool


class Flag(collections.namedtuple("FlagBase", "name, cast")):
  @property
  def var_name(self):
    return self.name.replace("-", "_")

  @property
  def vim_rc_name(self):
    name = self.var_name
    if name == "line_length":
      name = name.replace("_", "")
    return "g:black_" + name


FLAGS = [
  Flag(name="line_length", cast=int),
  Flag(name="fast", cast=strtobool),
  Flag(name="string_normalization", cast=strtobool),
]


def Black():
  start = time.time()
  configs = get_configs()
  mode = black.FileMode(
    line_length=configs["line_length"],
    string_normalization=configs["string_normalization"],
    is_pyi=vim.current.buffer.name.endswith('.pyi'),
  )

  buffer_str = '\n'.join(vim.current.buffer) + '\n'
  try:
    new_buffer_str = black.format_file_contents(
      buffer_str,
      fast=configs["fast"],
      mode=mode,
    )
  except black.NothingChanged:
    print(f'Already well formatted, good job. (took {time.time() - start:.4f}s)')
  except Exception as exc:
    print(exc)
  else:
    current_buffer = vim.current.window.buffer
    cursors = []
    for i, tabpage in enumerate(vim.tabpages):
      if tabpage.valid:
        for j, window in enumerate(tabpage.windows):
          if window.valid and window.buffer == current_buffer:
            cursors.append((i, j, window.cursor))
    vim.current.buffer[:] = new_buffer_str.split('\n')[:-1]
    for i, j, cursor in cursors:
      window = vim.tabpages[i].windows[j]
      try:
        window.cursor = cursor
      except vim.error:
        window.cursor = (len(window.buffer), 0)
    print(f'Reformatted in {time.time() - start:.4f}s.')

def get_configs():
  path_pyproject_toml = black.find_pyproject_toml(vim.eval("fnamemodify(getcwd(), ':t')"))
  if path_pyproject_toml:
    toml_config = black.parse_pyproject_toml(path_pyproject_toml)
  else:
    toml_config = {}

  return {
    flag.var_name: flag.cast(toml_config.get(flag.name, vim.eval(flag.vim_rc_name)))
    for flag in FLAGS
  }


def BlackVersion():
  print(f'Black, version {black.__version__} on Python {sys.version}.')

EndPython3

command! Black :py3 Black()
command! BlackVersion :py3 BlackVersion()
