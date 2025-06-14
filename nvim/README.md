# Personal nvim-config
This is my neovim config, stored here mainly so I can quickly copy it to a new
computer, but feel free to see if you find something interesting.

Under here follows a list of some useful stuff that I now won't ever forget
again!


## List of dependencies
- codelldb: debugging C/C++/Rust code, found in most package managers, or with
    Mason. Important: edit path to executable in `lua/plugins/adapters/lldb.lua`
- silicon: pretty code screenshots, install with rust: `cargo install silicon`,
    with [gruvbox added](https://github.com/Aloxaf/silicon#adding-new-syntaxes--themes)
- ripgrep (optional-recommended): for Telescope, installable with most package
    managers or `cargo`
- fd (optional-recommended): for Telescope, installable with most package
    managers or `cargo`, as `fd` or `fd-find`
- latex: sigh... install this on your own, and edit the used pdf-viewer and things...
    I use zathura with mupdf as backend
- pylatexenc (optional): for inline latex in Markdown, installed using `pip`
- shellcheck (optional): for bash scripts

Oh, and nvim is needed as well, version 0.10 I think (for some plugins).

Maybe others I didn't think off. I'll add them once I installed nvim on a new
pc and saw that my config didn't work like it should.


## Structure
This follows the Lazy directory structure. All plugins can be found under
`lua/plugins/`. Each separate plugin has its own file, those who work closely
together sit together in a file (f.e. completions).

All plugin-specific keybinds are specified in the file that adds the plugin,
and all are added using `which-key`, with `<leader>x`, with `x` the first letter
of the action that it does (f.e. `<leader>l` for everything lsp related).

Other broader keybinds are specified in `lua/keybinds.lua`.

There are 3 other files under `lua/` that aren't plugins:
- `functions.lua`: currently only has the `Discord` function, that works by
    selecting text in visual mode and calling `:<,>Discord`. The command will
    yank the selected text to your global clipboard, and surround it with
    Markdown-style codeblock, ready to paste in Discord (or any other app/site
    capable of rendering Markdown code blocks), with the language from the
    current file.
- `folds.lua`: I honestly don't really know how it works anymore, it just
    improves default folds a bit without a fold-specific plugin (uses Treesitter)
- `autocommands.lua`: my collection of autocommands:
    - One to turn off relative numbers where they are not needed (special buffers
        and in command-mode, or unfocused buffers)
    - One to remove all trailing whitespace on entering command-mode
    - One to turn on signcolumn in insert-mode only


## Default settings
These are my highly opinionated vim-settings found in `init.lua`
- numbers and relative numbers on the side
- tabs stay as tabs and render as 4 spaces (why would you write a tab explicitly
    as 4 spaces and take away the freedom of others on how they want to render
    their tabs?)
- softwrap disabled, otherwise things get difficult to read. You should wrap
    yourself, and that's also why I use `colorcolumn` in insert-mode.
- scrolloff on 2
- signcolumn shows signs over the numbers, because I want as much horizontal
    space as I can get (mainly for split views)
- laststatus to 3 to only show 1 statusline, even on split windows, I think it
    looks a bit cleaner

