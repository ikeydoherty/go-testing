# Change for your particular project, this is the _root_ level name.
PROJECT_NAME := go-testing

# Root of your project. For simple libraries/binaries this should just be
# src. For reusable libraries and such this should likely be src/github.com
PROJECT_ROOT := src

# Main target is to build gtk3 itself
gtk3.dynbin: gotk3/gotk3/gtk.github

# Ensure the workspace is setup
workspace_deps:
	test -d $(PROJECT_ROOT) || mkdir -p $(PWD)/$(PROJECT_ROOT); \
	test -e $(PROJECT_ROOT)/$(PROJECT_NAME) || ln -s $(PWD) $(PROJECT_ROOT)/.

# Defines a github target used in our vendoring
%.github: workspace_deps
	GOPATH=$(PWD) go build -pkgdir $(PWD)/pkg -buildmode=shared -i "github.com/$(subst .github,,$@)"

# Dynamic golang binary
%.dynbin: workspace_deps
	GOPATH=$(PWD) go build -linkshared -pkgdir $(PWD)/pkg -o builds/$(subst .dynbin,,$@) $(PROJECT_NAME)/$(subst .dynbin,,$@) 

# "Normal" static binary
%.statbin: workspace_deps
	GOPATH=$(PWD) go build -pkgdir $(PWD)/pkg -o builds/$(subst .statbin,,$@) $(PROJECT_NAME)/$(subst .statbin,,$@)

install: gtk3.dynbin
	test -d $(DESTDIR)/usr/bin || install -D -d -m 00755 $(DESTDIR)/usr/bin; \
	install -m 00755 builds/* $(DESTDIR)/usr/bin/.

all: gtk3.dynbin workspace_deps

clean:
	test ! -e src/$(PROJECT_NAME) || rm -rvf src/$(PROJECT_NAME); \
	test ! -d $(PWD)/pkg || rm -rvf $(PWD)/pkg; \
	test ! -d $(PWD)/builds || rm -rvf $(PWD)/builds

%.compliant:
	@ ( \
		pushd "$(subst .compliant,,$@)" || exit 1; \
		go fmt || exit 1; \
		GOPATH=$(PWD)/ golint || exit 1; \
		GOPATH=$(PWD)/ go vet || exit 1; \
	);

# Ensure our own code is compliant..
compliant: gtk3.compliant libtest.compliant


.PHONY: all
