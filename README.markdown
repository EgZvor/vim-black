# vim-black

This is a stripped down version of the official
[Black](https://github.com/psf/black) plugin for Vim that does not handle
external dependencies for you.

[Black](https://github.com/psf/black) is the uncompromising Python code
formatter created by Łukasz Langa. The repository is also featuring a Vim
plugin that provides the `Black` command. It formats the current file according
to settings found in either your Vim configuration files or a `toml` file
inside your project.


The problem with having a Vim plugin in the `Black` repository is that Vim
plugin managers clone the entire project which may not necessarily be what you
want. It also installs `Black` automatically in a virtual environment inside
your `.vim` directory. So I decided to make a "fork" that does not do any of
that and assumes you already installed `Black` and made it available to the
python interpreter used by your Vim.

## Commands and shortcuts:

- `:Black` to format the entire file (ranges not supported)
- `:BlackUpgrade` to upgrade _Black_ inside the virtualenv
- `:BlackVersion` to get the current version of _Black_ inside the virtualenv

## Configuration:

- `g:black_fast` (defaults to `0`)
- `g:black_linelength` (defaults to `88`)
- `g:black_skip_string_normalization` (defaults to `0`)
- `g:black_virtualenv` (defaults to `~/.vim/black` or `~/.local/share/nvim/black`)
