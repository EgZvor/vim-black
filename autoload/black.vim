python3 << EndPython3
import black
import collections
import os
import sys
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


def Black(from_line, to_line):
    configs = get_configs()
    mode = black.Mode(
        line_length=configs["line_length"],
        string_normalization=configs["string_normalization"],
        is_pyi=vim.current.buffer.name.endswith(".pyi"),
    )
    b = vim.current.buffer
    from_line -= 1
    lines_to_format = b[from_line:to_line]
    head = lines_to_format[0]
    indent = head[:-len(head.lstrip())]
    buffer_str = "\n".join(
        line.replace(indent, "", 1) for line in lines_to_format
    )
    mode.line_length -= len(indent)
    try:
        new_buffer_str = black.format_file_contents(
            buffer_str,
            fast=configs["fast"],
            mode=mode,
        )
    except black.NothingChanged:
        print("Already well formatted, good job!")
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
        vim.current.buffer[from_line:to_line] = [
            line and indent + line
            for line in new_buffer_str.split("\n")[:-1]
        ]
        for i, j, cursor in cursors:
            window = vim.tabpages[i].windows[j]
            try:
                window.cursor = cursor
            except vim.error:
                window.cursor = (len(window.buffer), 0)
        print("Finished formatting, yay!")


def get_configs():
    path_pyproject_toml = black.find_pyproject_toml(
        vim.eval("fnamemodify(getcwd(), ':t')")
    )
    if path_pyproject_toml:
        toml_config = black.parse_pyproject_toml(path_pyproject_toml)
    else:
        toml_config = {}

    return {
        flag.var_name: flag.cast(
            toml_config.get(flag.name, vim.eval(flag.vim_rc_name))
        )
        for flag in FLAGS
    }


def BlackVersion():
    print(f"Black, version {black.__version__} on Python {sys.version}.")
EndPython3


function black#Black(from_line, to_line)
  :execute "py3 Black(" . a:from_line . ", " . a:to_line . ")"
endfunction


function black#BlackVersion()
  :py3 BlackVersion()
endfunction
