#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
BLUE='\033[0;34m'

function Warn {
    printf "${YELLOW}$1${NC}\n"
}

function Success {
    printf "${GREEN}$1${NC}\n"
}

function Error {
    printf "${RED}$1${NC}\n"
}

function Ask {
    printf "${BLUE}$1${NC}\n"
}

function pause() {
    read -p "$*"
}
