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

The problem with having a Vim plugin in the `Black` repository
is that Vim plugin managers clone the entire project
which may not necessarily be what you want.
It also installs `Black` automatically
in a virtual environment inside your `.vim` directory.
So I decided to make a "fork"
that does not do any of that and assumes
you already installed `Black` in a virtual environment compatible
with the python interpreter used by your Vim.

## How to get started

Just assign `g:black_virtualenv`
to the virtual environment directory containing Black.

For example:

```
let g:black_virtualenv = '~/.virtualenvs/black'
```

Consider using
[pipx](https://github.com/pipxproject/pipx)
to install Black in a dedicated virtual environment.

```
pipx install black
```

## Commands:

- `:[range]Black` to format the selected lines
- `:BlackVersion` to get the currently used version of _Black_

## Configuration:

- `g:black_fast` (defaults to `0`)
- `g:black_linelength` (defaults to `88`)
- `g:black_string_normalization` (defaults to `1`)
