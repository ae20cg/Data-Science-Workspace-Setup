# Data-Science-Workspace-Setup

This repo is meant to set-up and test the script for a data scientist workspace.

I got sick of running the same commands every time and googling which command installs conda environment into jupyter.

This script is pretty simple and currently only supports conda, although I imagine it would be easy to tweak to support pyenv or venv.

To run:
`source ./create_env.sh -g [ git repo ] -c [ new conda environment name ] -v [ which python version (if none, latest release will be used) ]` 

