.PHONY: test all

all: test

doc: $(wildcard src/*.lua)
	ldoc -f markdown src/

test:
	cd tests && ./run_tests.sh
