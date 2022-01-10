.PHONY: test all

all: test

doc: $(wildcard src/*.lua)
	ldoc -f markdown -p boolLab src/

test:
	cd tests && ./run_tests.sh
