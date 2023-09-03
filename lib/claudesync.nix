{ lib
, buildPythonPackage
, fetchPypi
, pythonRelaxDepsHook

# build-system
, setuptools-scm

# dependencies
, click
, click-completion
, pathspec
, pytest
, setuptools
, sseclient-py
, tqdm
, crontab
, python-crontab
, brotli
, anthropic
, cryptography

# dev dependencies  
, pytest-cov
  
 }:

buildPythonPackage rec {
  pname = "claudesync";
  version = "0.6.1";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-3tm4pE8Oblbp7bLkfnjPvt1+ZGFvqR32MZqbbgkwwUE=";
  };

  postPatch = ''
    # don't test bash builtins
    # rm testing/test_argcomplete.py
  '';

  build-system = [
    setuptools-scm
  ];

  dependencies = [
    click
    click-completion
    pathspec
    pytest
    setuptools
    sseclient-py
    tqdm    
    crontab
    python-crontab
    brotli
    anthropic
    cryptography
  ];

  nativeCheckInputs = [
    pytest-cov
    pythonRelaxDepsHook  
  ];

  pythonRelaxDeps = true;
  pythonRemoveDeps = [
    "claudesync"
  ];

  meta = {
    changelog = "https://github.com/jahwag/ClaudeSync/releases/tag/v${version}";
    description = "ClaudeSync is a Python tool that automates the synchronization of local files with Claude.ai Projects";
    homepage = "https://github.com/jahwag/ClaudeSync";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mzacho ];
  };
}
