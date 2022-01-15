# boolLab

Main purpose of this is to provide some sort of library for boolean expressions.
Up to now no real interface was built so you'll have to write something like the
`main.lua` or use the interactive lua prompt.

Almost everything will start by creating a **new expression object** and specfying
the expression by using either the **string** or **table+vars** (expr isn't easy
and therefore nor advisable) representation (`e = expression{str="a+b"}` or `e =
expression{tab={["00"]="0", ["01"]="1", ["10"]="0", ["11"]="0"}, vars={"a", "b"}}`
(the ordering of vars has to match the order of `0/1`s in the table keys))

After that some conversions of the internal representations may be needed before
running some operations (like creating a KKNF or a KDNF from the table).

For a description of these operations and conversions open `docs/index.html` in
your browser.

## Requirements
- \>`lua5.3`
- `lpeg` (for string parsing - install e.g. via `luarocks`)

All in all this lua lib does not have any more requirements only if you want to build
the documentation you'll need the `ldoc` lua lib and `lester` if you want to run
the tests.

## Documentation
Run `make doc` to build the docs (read by opening`docs/index.html` in the browser)

## Installation/Usage
Install `lua5.3` or above and `luarocks`. Install `lpeg` via `luarocks [--local]
--lua-version=<5.4/5.3> lpeg` and make sure it can be found via `$LUA_PATH` (for
me under linux that is `eval $(luarocks --lua-version=<5.4/5.3> path)`)

Typical way to download this package whould be `git clone <ssh/https url>` (and `git
pull` for getting the latest changes (restore the `main.lua` in advance by
runing `git checkout main.lua` in the `src` folder))

Then run the main.lua file via `lua main.lua` from within the
`src` folder. Currently there is no interactive usage except by using the lua
shell simply enter `lua` in the terminal, but I'd advise (as stated in the first
paragraph) in modification of the `main.lua` file for testing own boolean
formula.

### Windows
I don't use windows so I don't know exaxtly but probably the easiest way is via
WSL (Windows Subsystem for Linux)

If someone knows a better way for using unter windows, let me know (via an issue).

### MacOS
I don't use MacOS either, but as far as I researched `lua` and `luarocks` should
be available via homebrew.

If someone knows a better way for using unter macOS, let me know (via an issue).

### Linux
For most distros `lua` and `luarocks` should be in the repos.

Example on Raspberry Pi with raspian and `lua5.3`:
- `sudo apt install lua5.3 liblua5.3-dev luarocks`
- `git clone git@gitlab.lrz.de:lukas.h/boollab.git && cd boollab`
- `luarocks --local --lua-version=5.3 install lpeg`
- `eval $(luarocks --local --lua-version=5.3 path)`
- `cd src && lua5.3 main.lua`

(normally `--lua-version` is nice to be able to manage multiple lua versions
with `luarocks`, but it seems that the `luarocks` version of raspian doesn't
support this flag, so be carefull if you have other versions of `lua` installed,
for which lua-version `luarocks` is installing the library)
