#!/usr/bin/env bash
set -x
# wait-for-it.sh

TIMEOUT=15
QUIET=0

echoerr() {
  if [ "$QUIET" -ne 1 ]; then printf "%s\n" "$*" 1>&2; fi
}

usage() {
  exitcode="$1"
  cat << USAGE >&2
Usage: $0 host:port [-t timeout] [-- command args]
  -t TIMEOUT | --timeout=TIMEOUT  Timeout in seconds, zero for no timeout
  -q | --quiet                  Don't output any status messages
  -- COMMAND ARGS               Execute command with args after the test finishes
USAGE
  exit "$exitcode"
}

wait_for_port() {
  local host="$(echo "$1" | cut -d: -f1)"
  local port="$(echo "$1" | cut -d: -f2)"
  local timeout="$2"
  local start_time

  start_time=$(date +%s)

  while :; do
    if nc -z "$host" "$port" >/dev/null 2>&1; then
      echoerr "$host:$port is available after $(( $(date +%s) - start_time )) seconds"
      return 0
    fi

    if [ "$timeout" -gt 0 ] && [ "$(( $(date +%s) - start_time ))" -ge "$timeout" ]; then
      echoerr "Timeout occurred after $timeout seconds waiting for $host:$port"
      return 1
    fi

    sleep 1
  done
}

wait_for_host_port() {
  local host_port="$1"
  local timeout="$2"
  local host="$(echo "$host_port" | cut -d: -f1)"
  local port="$(echo "$host_port" | cut -d: -f2)"

  if [ -z "$host" ] || [ -z "$port" ]; then
    echoerr "Error: Invalid host:port format. Expected 'host:port'."
    return 1
  fi

  echoerr "Waiting for $host:$port to be available..."
  wait_for_port "$host_port" "$timeout"
}

# Process arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    *:*)
      HOST_PORT="$1"
      shift
      ;;
    -q|--quiet)
      QUIET=1
      shift
      ;;
    -t|--timeout)
      TIMEOUT="$2"
      if [ -z "$TIMEOUT" ]; then
        echoerr "Error: --timeout requires an argument."
        usage 1
      fi
      shift 2
      ;;
    --timeout=*)
      TIMEOUT="${1#*=}"
      shift
      ;;
    --)
      shift
      CLI_ARGS=($@)
      break
      ;;
    -h|--help)
      usage 0
      ;;
    *)
      echoerr "Error: Unknown argument: $1"
      usage 1
      ;;
  esac
done

if [ -z "$HOST_PORT" ]; then
  echoerr "Error: host:port not specified."
  usage 1
fi

wait_for_host_port "$HOST_PORT" "$TIMEOUT"
RESULT=$?

if [ $RESULT -eq 0 ] && [ -n "${CLI_ARGS[*]}" ]; then
  exec "${CLI_ARGS[@]}"
fi

exit $RESULT
