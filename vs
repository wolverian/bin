#!/bin/sh

brew unlink "$1"
brew link --overwrite "$1@$2"


