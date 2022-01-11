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
Install `lua5.3` or above and run the main file via `lua main.lua` from within the
`src` folder.
