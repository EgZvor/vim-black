# vim-black

This is a stripped down version of the official
[Black](https://github.com/psf/black)
plugin for Vim that does not handle external dependencies for you.

## Why?

[Black](https://github.com/psf/black)
is the uncompromising Python code formatter created by Łukasz Langa.
That repository also features a Vim plugin
that provides the `Black` command.
It formats the current file
according to the settings found in
either your Vim configuration files
or a `toml` file inside your project.

The problem with having a Vim plugin in the _Black_ repository
is that Vim plugin managers clone the entire project
which may not necessarily be what you want.
It also installs _Black_ automatically
in a virtual environment inside your `.vim` directory.
So I decided to make a "fork"
that does not do any of that and assumes
you already installed _Black_ in a virtual environment compatible
with the python interpreter used by your Vim.

## How to get started

Just assign `g:black_virtualenv`
to the virtual environment directory containing _Black_.

For example:

``` vim
let g:black_virtualenv = '~/.virtualenvs/black'
```

Consider using
[pipx](https://github.com/pipxproject/pipx)
to install _Black_ in a dedicated virtual environment.

``` bash
pipx install black
```

## Commands

- `:[range]Black` to format the selected lines
- `:BlackVersion` to get the currently used version of _Black_

## Example mappings

This plugin exposes two internal mappings (see `:h <Plug>`).
A good place to put the following mappings is in `.vim/after/ftplugin/python.vim`.

Add an operator to apply Black on `:h motion`.
For example, try `<space>bip`.
``` vim
nmap <buffer> <space>b <Plug>(Blackify)
```

Apply Black on the current line:
``` vim
nmap <buffer> <space>bb <Plug>(BlackifyLine)
```

## Configuration

Your pyproject.toml config file will be discovered automatically.
Failing to do that, the plugin will try using the following options.

- `g:black_fast` (defaults to `0`)
- `g:black_linelength` (defaults to `88`)
- `g:black_string_normalization` (defaults to `1`)
