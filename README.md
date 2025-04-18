# android-cli-utils
This repository is a collection of command-line utilities created to streamline Android development tasks.

These scripts were written to solve specific problems I encountered during work, so they might not be universally useful — but I hope they can still offer some value.

If you have any suggestions or ideas for improvement, feel free to open an issue or reach out. I truly appreciate your feedback!


## install-latest-jbr.sh
This script automates downloading and installing the latest [JetBrains Runtime (JBR)](https://github.com/JetBrains/JetBrainsRuntime) SDK from GitHub.

Usage:
```
INSTALL_DIR=~/Downloads/jbr EXPECTED_OS_TAG=linux-x64 ./install-latest-jbr.sh
```