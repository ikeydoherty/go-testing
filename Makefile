# Change for your particular project
PROJECT_NAME := go-testing

# Main target is to build gtk3 itself
gtk3.dynbin: gotk3/gotk3/gtk.github

# Ensure the workspace is setup
workspace_deps:
	test -d src || mkdir $(PWD)/src; \
	test -e src/$(PROJECT_NAME) || ln -s $(PWD) src/.

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

# Ensure our own code is compliant..
compliant:
	pushd gtk3; \
	go fmt; \
	GOPATH=$(PWD)/ golint; \
	GOPATH=$(PWD)/ go vet;

.PHONY: all
