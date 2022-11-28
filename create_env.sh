#!/bin/bash

RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

usage() {
	echo "Usage: $0 [ -g GIT_REPO ] [ -c CONDA_ENV ] [ -v PYTHON_VERSION ]" 1>&2
}

exit_abnormal() {
	usage
	exit 1
}
conv_conda() {
	local IFS=$'\n'; ret="$@"
	echo $ret
}
git_cd() {
	git clone "$1" && cd "$(basename "$1" .git)"
}
check_reqs() {
	num_req=$(echo $1 | wc -l)
	if [[ "$num_req" -gt "1" ]] ; then
		echo "Found more than 1 requirements file. Exiting."
		exit 1
	fi
}


while getopts ":g:c:v:" opt; do
	case $opt in 
		g) 
			repo="$OPTARG"
		;;
		c) 
			env_name="$OPTARG"
		;;
		v) 
			py_vers="$OPTARG"
		;;
		:) 
			echo "Error: -${OPTARG} reguires an argument."
			exit_abnormal
		;;
		*) 
			exit_abnormal
		;;
	esac
done

if [[ -z $repo ]] ; then
	echo -e "${RED}NO REPO PASSED, WILL CONTINUE UNDER ASSUMPTION THIS IS WORKING DIRECTORY${NC}"
else
	echo -e "${BLUE}Cloning git repo $repo and changing working directory${NC}"
	git_cd $repo
	echo $(pwd)
fi

echo "Decativating current conda environment" && conda deactivate
current_envs=($( conv_conda $(conda env list | awk '{ print $1 }')))

echo "Searching available environments for '$env_name'..."

for i in "${current_envs[@]}"
do
	if [[ "$i" == "$env_name" ]] ; then
        	echo -e "${BLUE}Found $i...matching $env_name \nActivating existing conda environment.${NC}"
		conda activate $env_name	
		break
	fi
done

if [[ "$CONDA_DEFAULT_ENV" != "" ]] ; then
	echo "Using existing environment $CONDA_DEFAULT_ENV"
else
	echo -e "${BLUE}Creating $env_name...${NC}"
	echo "Searching for requirements"
	req_path=$(find . -name "requirements.txt") && check_reqs $req_path
	if [[ -z "$req_path" ]]; then
		conda create --name $env_name python=$py_vers && conda activate $env_name
	else
		echo "y" | conda create --name $env_name --file $req_path python=$py_vers && conda activate $env_name
	fi 
fi

echo -e "${BLUE}Adding conda environment to jupyter${NC}"
echo "y" | conda install -c anaconda ipykernel
python -m ipykernel install --user --name=$CONDA_DEFAULT_ENV

echo "Install jupyter-notebook [y/n]?"
read instjup

if [[ "$instjup" == "y" ]] ; then
	echo "y" | conda install jupyter
fi

echo -e "\n${RED}DONE${NC}"


