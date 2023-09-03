#/usr/bin/env bash

cd ~/lib/lsp-java/install

./mvnw -Djdt.js.server.root=$HOME/.emacs.d/.cache/lsp/eclipse.jdt.ls/ \
     -Djunit.runner.root=$HOME/.emacs.d/eclipse.jdt.ls/test-runner/ \
     -Djunit.runner.fileName=junit-platform-console-standalone.jar \
     -Djava.debug.root=$HOME/.emacs.d/.cache/lsp/eclipse.jdt.ls/bundles clean package \
     -Djdt.download.url="https://download.eclipse.org/jdtls/milestones/1.14.0/jdt-language-server-1.14.0-202207211651.tar.gz"

cd -
