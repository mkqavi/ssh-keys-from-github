#!/bin/sh
USER=$1
SUDO=""
PM=""
PMSHORT=""
# Check for root
if [ $(whoami) != root ]; then
  SUDO="sudo"
fi
# Check for package manager
if command -v pacman > /dev/null; then
  printf "Using pacman\n"
  PM="$SUDO pacman -S"
  PMSHORT="pacman"
elif command -v brew > /dev/null; then
  printf "Using brew\n"
  PM="brew install"
  PMSHORT="brew"
elif command -v apt-get > /dev/null; then
  printf "Using apt\n"
  PM="$SUDO apt-get install"
  PMSHORT="apt"
elif command -v yum > /dev/null; then
  printf "Using yum\n"
  PM="$SUDO yum install"
  PMSHORT="yum"
else
  printf "No package manager found; please install the following packages yourself:\ncurl\njq\nbase64\n"
fi
# Check for curl
if ! command -v curl > /dev/null; then
  printf "No curl found, trying to install\n"
  $PM curl
fi
# Get keys from GitHub
KEYS=$(curl -s -L https://api.github.com/users/$USER/keys)
# Check for jq
if ! command -v jq > /dev/null; then
  printf "No jq found, trying to install\n"
  $PM jq
fi
# Check for base64
if ! command -v base64 > /dev/null; then
  printf "No base64 found, trying to install\n"
  if $PMSHORT == "pacman" || $PMSHORT == "yum"; then
    $PM libb64
  elif $PMSHORT == "brew"; then
    $PM base64
  elif $PMSHORT == "apt"; then
    $PM libb64-0d
  fi
fi
# Transform JSON to appendable keys
for ROW in $(printf "$KEYS" | jq -r ".[] | @base64"); do
  printf "$ROW" | base64 --decode | jq -r ".key"
done
