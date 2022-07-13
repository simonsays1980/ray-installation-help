#!/bin/bash
echo "Starting ..."
echo "Create virtual environment ..."
echo "Remove virtual environment with name '.venv' if existent ... "
if [[ -d ".venv" ]] 
then
    read -p "Are you sure? " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]] 
    then
        echo "Removing virtual environment '.venv" ... 
        rm -rf .venv
    else
        echo "Virtual environment '.venv' already exists and cannot be removed ..."
        exit 1
    fi
fi

echo "Create new virtual environment '.venv' and activate it ..."
python -m venv .venv
export venv_path=`readlink -f ".venv/bin/activate"`
source $venv_path

echo "Upgrade pip ..."
python -m pip install --upgrade pip

echo "Install ray nightly for Python 3.9.x ..."
python -m pip install -U --no-cache-dir https://s3-us-west-2.amazonaws.com/ray-wheels/latest/ray-3.0.0.dev0-cp39-cp39-manylinux2014_x86_64.whl

echo "Install ray rllib, tune and ml ... "
python -m pip install -U --no-cache-dir "ray[rllib,tune,ml]"

echo "Install linter requirements ..."
python -m pip install -U --no-cache-dir -r python/requirements_linter.txt

echo "Install tensorflow and torch ... "
python -m pip install tensorflow torch 

echo "Install atari requirements for testing ..."
python -m pip install "gym[atari]" "gym[accept-rom-license]" atari_py

#echo "Upgrade 'typing-extensions' module ..."
#python -m pip install --upgrade typing-extensions 

echo "Test linter ... "
scripts/format.sh

echo "All done ..."