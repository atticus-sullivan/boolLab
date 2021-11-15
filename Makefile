.PHONY: test all

all: test

test:
	cd tests && ./run_tests.sh
