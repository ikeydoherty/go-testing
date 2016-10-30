# Main target is to build gtk3 itself
gtk3:
	GOPATH=$(pwd) go build -o builds/gtk3 gtk3 

.PHONY: gtk3
