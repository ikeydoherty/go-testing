# Main target is to build gtk3 itself
gtk3: workspace_deps
	GOPATH=$(PWD) go build -o builds/gtk3 go-testing/gtk3 

# Ensure the workspace is setup
workspace_deps:
	test -d src || mkdir $(PWD)/src; \
	test -e src/go-testing || ln -s $(PWD) src/.


all: gtk3 workspace_deps

.PHONY: all
