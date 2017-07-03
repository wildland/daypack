#!/usr/bin/env bash
echo "Running Ruby script to finish development setup"
echo `ruby -e "$(curl -fsSL https://raw.githubusercontent.com/wildland/daypack/setup-osx.rb)"`
