#!/bin/bash
# Helper functions for Conjur Policy as Code GitHub Action

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_debug() {
  if [ "${DEBUG}" == "true" ]; then
    echo -e "${BLUE}[DEBUG]${NC} $1"
  fi
}

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
  echo "::error::$1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Input validation
validate_input() {
  local value="$1"
  local name="$2"
  
  if [ -z "$value" ]; then
    log_error "Required input '$name' is missing or empty"
    exit 1
  fi
  
  log_debug "Input '$name' is valid"
}

# Check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Validate that required commands are available
validate_commands() {
  for cmd in "$@"; do
    if ! command_exists "$cmd"; then
      log_error "Required command '$cmd' is not installed"
      exit 1
    fi
  done
}