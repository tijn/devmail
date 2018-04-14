all: devmail docs

devmail:
	crystal build --release src/devmail.cr

docs:
	crystal docs

.PHONY: all docs
