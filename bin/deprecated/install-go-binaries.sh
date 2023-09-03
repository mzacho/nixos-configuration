#!/usr/bin/env bash

modules=(golang.org/x/tools/cmd/goimports@latest
         golang.org/x/tools/gopls@latest
         golang.org/x/review/git-codereview@latest
         github.com/go-delve/delve/cmd/dlv@latest
         github.com/josharian/impl@latest
         github.com/fatih/gomodifytags@latest
         github.com/kisielk/errcheck@latest
         github.com/lighttiger2505/sqls@latest
         github.com/rogpeppe/godef@latest
         honnef.co/go/tools/cmd/staticcheck@latest)

BIN=${GOBIN:-${HOME}/go/bin}

# Check if a version of the module already exists
for m in ${modules[*]}; do
    # Remove full path and version suffix
    binary=$(basename ${m/\@*/})

    if [ -e $BIN/$binary ]; then
        echo "Skipping $binary: A version of already exists in $BIN"
        # TODO : Add --all flag to install all dependencies again
    else
        # TODO : echo "dry-run: go install $m"
        go install $m
    fi
done
