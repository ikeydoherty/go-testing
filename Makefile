# Main target is to build gtk3 itself
gtk3: gotk3/gotk3/gtk.github
	GOPATH=$(PWD) go build -linkshared -pkgdir $(PWD)/pkg -o builds/gtk3 go-testing/gtk3 

# Ensure the workspace is setup
workspace_deps:
	test -d src || mkdir $(PWD)/src; \
	test -e src/go-testing || ln -s $(PWD) src/.

# Defines a github target used in our vendoring
%.github: workspace_deps
	GOPATH=$(PWD) go build -pkgdir $(PWD)/pkg -buildmode=shared -i "github.com/$(subst .github,,$@)"

all: gtk3 workspace_deps

# Ensure our own code is compliant..
compliant:
	pushd gtk3; \
	go fmt; \
	GOPATH=$(PWD)/ golint; \
	GOPATH=$(PWD)/ go vet;

.PHONY: all
