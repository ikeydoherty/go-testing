# Change for your particular project, this is the _root_ level name.
PROJECT_NAME := go-testing

# For example, github.com/ikeydoherty/go-testing
PROJECT_PREFIX = github.com/ikeydoherty
PROJECT_ID := $(PROJECT_PREFIX)/$(PROJECT_NAME)

# Root of your project. For simple libraries/binaries this should just be
# src. For reusable libraries and such this should likely be src/$(PROJECT_ID)
PROJECT_ROOT := src/$(PROJECT_PREFIX)

# Main target is to build gtk3 itself
gtk3.dynbin: gotk3/gotk3/gtk.github

# Simple test
testconsumer.statbin:

# Ensure the workspace is setup
workspace_deps:
	test -d $(PROJECT_ROOT) || mkdir -p $(PWD)/$(PROJECT_ROOT); \
	test -e $(PROJECT_ROOT)/$(PROJECT_NAME) || ln -s $(PWD) $(PROJECT_ROOT)/.

# Defines a github target used in our vendoring
%.github: workspace_deps
	GOPATH=$(PWD) go build -pkgdir $(PWD)/pkg -buildmode=shared -i "github.com/$(subst .github,,$@)"

# Dynamic golang binary
%.dynbin: workspace_deps
	GOPATH=$(PWD) go build -linkshared -pkgdir $(PWD)/pkg -o builds/$(subst .dynbin,,$@) $(PROJECT_ID)/$(subst .dynbin,,$@) 

# "Normal" static binary
%.statbin: workspace_deps
	GOPATH=$(PWD) go build -pkgdir $(PWD)/pkg -o builds/$(subst .statbin,,$@) $(PROJECT_ID)/$(subst .statbin,,$@)

install: gtk3.dynbin
	test -d $(DESTDIR)/usr/bin || install -D -d -m 00755 $(DESTDIR)/usr/bin; \
	install -m 00755 builds/* $(DESTDIR)/usr/bin/.

all: gtk3.dynbin workspace_deps

clean:
	test ! -e $(PROJECT_ROOT) || rm -rvf $(PROJECT_ROOT); \
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
compliant: gtk3.compliant libtest.compliant testconsumer.compliant


.PHONY: all
