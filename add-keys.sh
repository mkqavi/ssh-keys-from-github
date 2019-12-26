#!/bin/sh
usage() {
  printf "Usage: ./add-keys.sh [-v] USERNAME\n"
  exit 1
}

SUDO=""
PM=""
PMSHORT=""
SILENT=true
TODEVNULL="> /dev/null"
# Get options
while getopts v opt; do
  case $opt in
    v)
      SILENT=false
      TODEVNULL=""
      ;;
    \?)
      usage
  esac
done
USER=${@:$OPTIND:1}
if [ -z $USER ]; then
  printf "Username missing\n"
  usage
fi
# Check for root
if [ $(whoami) != root ]; then
  SUDO="sudo"
fi
# Check for package manager
if command -v pacman > /dev/null; then
  if ! $SILENT; then
    printf "Using pacman\n"
  fi
  PM="$SUDO pacman -S"
  PMSHORT="pacman"
elif command -v brew > /dev/null; then
  if ! $SILENT; then
    printf "Using brew\n"
  fi
  PM="brew install"
  PMSHORT="brew"
elif command -v apt-get > /dev/null; then
  if ! $SILENT; then
    printf "Using apt\n"
  fi
  PM="$SUDO apt-get install"
  PMSHORT="apt"
elif command -v yum > /dev/null; then
  if ! $SILENT; then
    printf "Using yum\n"
  fi
  PM="$SUDO yum install"
  PMSHORT="yum"
else
  if ! $SILENT; then
    printf "No package manager found; please install the following packages yourself:\ncurl\njq\nbase64\n"
  fi
fi
# Check for curl
if ! command -v curl > /dev/null; then
  if ! $SILENT; then
    printf "No curl found, trying to install\n"
  fi
  $PM curl $TODEVNULL
fi
# Get keys from GitHub
KEYS=$(curl -s -L https://api.github.com/users/$USER/keys)
# Check for jq
if ! command -v jq > /dev/null; then
  if ! $SILENT; then
    printf "No jq found, trying to install\n"
  fi
  $PM jq $TODEVNULL
fi
# Check for base64
if ! command -v base64 > /dev/null; then
  if ! $SILENT; then
    printf "No base64 found, trying to install\n"
  fi
  if $PMSHORT == "pacman" || $PMSHORT == "yum"; then
    $PM libb64 $TODEVNULL
  elif $PMSHORT == "brew"; then
    $PM base64 $TODEVNULL
  elif $PMSHORT == "apt"; then
    $PM libb64-0d $TODEVNULL
  fi
fi
# Transform JSON to appendable keys
for ROW in $(printf "$KEYS" | jq -r ".[] | @base64"); do
  printf "$ROW" | base64 --decode | jq -r ".key"
done
