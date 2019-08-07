#!/bin/sh
# shellcheck disable=1001,1012,2039,1090
# 1001,1012 stop complaints about '\awk' syntax to bypass aliases.
# 2039 stops complaints about array references not being POSIX.
# 1090 stops complaints about sourcing non-constant paths.

# We program rather defensively here, since this is evaluated in the context of
# the user's shell, and there can be pretty aggressive configuration there.

# This must be outside of the function context for $0 to work properly
__shell="$(\ps -p $$ | \awk 'NR > 1 { sub(/^-/, "", $4); print $4 }')"
__shellname="$(basename "${__shell}")"

case "${__shellname}" in
  zsh)  __shopify_cli_source_dir="$(\dirname "$0:A")" ;;
  bash) __shopify_cli_source_dir="$(builtin cd "$(\dirname "${BASH_SOURCE[0]}")" && \pwd)" ;;
  *)
    >&2 \echo "shopify-cli is not compatible with your shell (${__shell})"
    \return 1
    ;;
esac

#### Handlers for bin/dev-shell-support environment manipulation
#### See bin/dev-shell-support for documentation.
shopify_cli__source() { source "$1"; }
shopify_cli__setenv() { export "$1=$2"; }
shopify_cli__append_path() { export "PATH=${PATH}:$1"; }
shopify_cli__lazyload() { type "$1" >/dev/null 2>&1 || eval "$1() { source $2 ; $1 \"\$@\"; }"; }
shopify_cli__prepend_path() {
  PATH="$(
    /usr/bin/awk -v RS=: -v ORS= -v "prepend=$1" '
      BEGIN         { print prepend }
                    { gsub(/\n$/,"", $0) }
      $0 != prepend { print ":" $0 }
    ' <<< "${PATH}"
  )"
  export PATH
}

while read -r line; do
  eval "${line}"
done < <("${__shopify_cli_source_dir}/bin/shopify-cli-shell-support" env "${__shellname}")

unset -f shopify_cli__source
unset -f shopify_cli__setenv
unset -f shopify_cli__append_path
unset -f shopify_cli__prepend_path
unset -f shopify_cli__lazyload

### END MUCKING WITH THE USER'S ENVIRONMENT

__mtime_of_shopify_cli_script="$(\date -r "${__shopify_cli_source_dir}/shopify.sh" +%s)"

shopify() {
  # reload __shopify_cli__ function
  local current_mtime
  current_mtime="$(\date -r "${__shopify_cli_source_dir}/shopify.sh" +%s)"

  if [[ "${current_mtime}" != "${__mtime_of_shopify_cli_script}" ]]; then
    . "${__shopify_cli_source_dir}/shopify.sh"
  fi
  __shopify_cli__ "$@"
}

__shopify_cli__() {
  for cmd in chruby_auto rvm rbenv iterm2_preexec; do
    if command -v "${cmd}" >/dev/null 2>&1 ; then
      export "SHOPIFY_CLI_CONFLICTING_TOOL_${cmd}=1"
    fi
  done

  # https://discourse.shopify.io/t/running-dev-up-changes-the-display-language-of-apple-terminal/1556
  export LANG="${LANG-en_US.UTF-8}"
  export LANGUAGE="${LANGUAGE-en_US.UTF-8}"
  export LC_ALL="${LC_ALL-en_US.UTF-8}"

  local bin_path
  bin_path="${__shopify_cli_source_dir}/bin/shopify"

  local tmpfile
  tmpfile="$(\mktemp -u)" # Create a new tempfile

  exec 9>"${tmpfile}" # Open the tempfile for writing on FD 9.
  exec 8<"${tmpfile}" # Open the tempfile for reading on FD 8.
  \rm -f "${tmpfile}" # Unlink the tempfile. (we've already opened it).

  local return_from_shopify_cli
  local with_gems
  local install_dir="$HOME/.shopify-cli"
  if [[ "${__shopify_cli_source_dir}" == "${install_dir}" ]] || [ ! -t 0 ]; then
    with_gems="FALSE"
  else
    with_gems="TRUE"
  fi
  if [[ "$1" == "--with-gems" ]]; then
    shift
    with_gems="TRUE"
  elif [[ "$1" == "--without-gems" ]]; then
    shift
    with_gems="FALSE"
  fi

  if [[ ${with_gems} == "TRUE" ]]; then
    /usr/bin/env ruby "${bin_path}" "$@"
  else
    "${bin_path}" "$@"
  fi
  return_from_shopify_cli=$?

  local finalizers
  finalizers=()

  local fin
  while \read -r fin; do
    finalizers+=("${fin}")
  done <&8

  exec 8<&- # close FD 8.
  exec 9<&- # close FD 9.

  for fin in "${finalizers[@]}"; do
    case "${fin}" in
      cd:*)
        # shellcheck disable=SC2164
        cd "${fin//cd:/}"
        ;;
      setenv:*)
        # shellcheck disable=SC2163
        export "${fin//setenv:/}"
        ;;
      reload_shopify_cli_from:*)
        # Force chruby to re-scan next time it runs.
        unset -f chruby 2>/dev/null
        source "${fin//reload_shopify_cli_from:/}/shopify.sh"
        ;;
      *)
        ;;
    esac
  done

  \return ${return_from_shopify_cli}
}

# . "${__shopify_cli_source_dir}/sh/hooks/hooks.${__shellname}"
