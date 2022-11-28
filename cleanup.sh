jupyter kernelspec uninstall $1
conda deactivate
conda env remove --name $1
