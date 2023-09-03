#!/usr/bin/env bash

cd ~/lib/skopeo-upstream
make docs
rsync -v docs/*.1 /usr/local/share/man/man1/
cd - >/dev/null
