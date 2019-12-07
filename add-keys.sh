#!/bin/sh
USER=$1
SUDO=""
# Check for root
if [ $(whoami) != root ]; then
  SUDO="sudo"
fi
# Check for curl
if ! command -v curl > /dev/null; then
  printf "No curl found, trying to install"
  $SUDO pacman -S curl
fi
# Get keys from GitHub
KEYS=$(curl -s -L https://api.github.com/users/$USER/keys)
# Check for jq
if ! command -v jq > /dev/null; then
  printf "No jq found, trying to install"
  $SUDO pacman -S jq
fi
# Check for base64
if ! command -v base64 > /dev/null; then
  printf "No base64 found, trying to install"
  $SUDO pacman -S libb64
fi
# Transform JSON to appendable keys
for ROW in $(printf "$KEYS" | jq -r ".[] | @base64"); do
  printf "$ROW" | base64 --decode | jq -r ".key"
done
