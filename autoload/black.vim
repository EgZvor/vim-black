python3 << EndPython3
import collections
import sys
import traceback
from distutils.util import strtobool
from pathlib import Path
from typing import List, Tuple

import vim


class Flag(collections.namedtuple("FlagBase", "name, cast")):
    @property
    def var_name(self) -> str:
        return self.name.replace("-", "_")

    @property
    def vim_rc_name(self) -> str:
        name = self.var_name
        if name == "line_length":
            name = name.replace("_", "")
        return "g:black_" + name


FLAGS = [
    Flag(name="line_length", cast=int),
    Flag(name="fast", cast=strtobool),
    Flag(name="string_normalization", cast=strtobool),
]


def _get_virtualenv_site_packages(venv_path, pyver):
    if sys.platform[:3] == "win":
        return venv_path / "Lib" / "site-packages"
    return venv_path / "lib" / f"python{pyver[0]}.{pyver[1]}" / "site-packages"


def _initialize_black_env() -> None:
    pyver = sys.version_info[:2]
    if pyver < (3, 6):
        print("Sorry, Black requires Python 3.6+ to run.")
        return

    virtualenv_path = Path(vim.eval("g:black_virtualenv")).expanduser()
    if not virtualenv_path.is_dir():
        print("Virtual environment: {} does not exist".format(virtualenv_path))
        return
    virtualenv_site_packages = str(
        _get_virtualenv_site_packages(virtualenv_path, pyver)
    )
    if virtualenv_site_packages not in sys.path:
        sys.path.insert(0, virtualenv_site_packages)


_initialize_black_env()
import black


def _get_indent(line: str) -> str:
    indent = ""
    for char in line:
        if not char.isspace():
            break
        indent += char
    return indent


def _indent_split(lines: List[str]) -> Tuple[str, List[str]]:
    indent = _get_indent(lines[0])
    return indent, [line.replace(indent, "", 1) for line in lines]


def _add_indent(line: str, indent: str) -> str:
    if not line:
        return line
    return indent + line


def _get_configs() -> dict:
    path_pyproject_toml = black.find_pyproject_toml(
        (vim.eval("expand('%:p:h')"),)
    )
    if path_pyproject_toml:
        toml_config = black.parse_pyproject_toml(path_pyproject_toml)
    else:
        toml_config = {}

    return {
        flag.var_name: flag.cast(toml_config.get(flag.name, vim.eval(flag.vim_rc_name)))
        for flag in FLAGS
    }


def Black(from_line: int, to_line: int) -> None:
    configs = _get_configs()
    mode = black.Mode(
        line_length=configs["line_length"],
        string_normalization=configs["string_normalization"],
        is_pyi=vim.current.buffer.name.endswith(".pyi"),
    )
    lines_to_format = vim.current.buffer[from_line:to_line]
    indent, lines_to_format = _indent_split(lines_to_format)
    mode.line_length -= len(indent)
    try:
        new_buffer_str = black.format_file_contents(
            "\n".join(lines_to_format),
            fast=configs["fast"],
            mode=mode,
        )
    except black.NothingChanged:
        print("Already well formatted, good job!")
    except Exception:
        traceback.print_exception(*sys.exc_info())
    else:
        current_buffer = vim.current.window.buffer
        cursors = []
        for i, tabpage in enumerate(vim.tabpages):
            if tabpage.valid:
                for j, window in enumerate(tabpage.windows):
                    if window.valid and window.buffer == current_buffer:
                        cursors.append((i, j, window.cursor))
        vim.current.buffer[from_line:to_line] = [
            _add_indent(line, indent) for line in new_buffer_str.split("\n")[:-1]
        ]
        for i, j, cursor in cursors:
            window = vim.tabpages[i].windows[j]
            try:
                window.cursor = cursor
            except vim.error:
                window.cursor = (len(window.buffer), 0)
        print("Finished formatting, yay!")


def BlackVersion():
    print(f"Black, version {black.__version__} on Python {sys.version}.")


EndPython3


function black#Black(from_line, to_line)
    execute "py3 Black(" . (a:from_line - 1) . ", " . a:to_line . ")"
endfunction


function black#BlackVersion()
    py3 BlackVersion()
endfunction
