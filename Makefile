# Ensure the workspace is setup
workspace_deps:
	test -d src || mkdir $(PWD)/src
	test -e src/gtk3 || ln -s $(PWD) src/.

# Main target is to build gtk3 itself
gtk3: workspace_deps
	GOPATH=$(PWD) go build -o builds/gtk3 gtk3 

.PHONY: gtk3
