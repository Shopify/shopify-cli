# shellcheck shell=sh disable=1012,1001

# We're running in a highly-unpredictable environment here:
#
# For ZSH users with the CLOBBER option unset, > will fail if the file exists,
# and mktemp creates the file. By removing it first, we play it safe.
#
# We try as hard as reasonable to avoid weird user aliases and other
# configuration.

tempfile="$(\mktemp /tmp/shopify-bootstrap-stage2-XXXXXX)"
\rm -f "${tempfile}"

# The Makefile templates stage2.sh into the heredoc here.
\cat << 'EOF' > "${tempfile}"
#!/bin/bash

# In this file, unlike stage1.sh, we do not have to contend with the user's
# shell aliases and configuration, so we do not program nearly as defensively.

if [[ "${LOGNAME}" == "root" ]]; then
  >&2 echo "don't run this as root"
  exit 1
fi

case "$(uname -s)" in
  Darwin)
    mac=1
    shell="$(dscl . -read "/Users/${LOGNAME}" UserShell | awk '{print $NF}')"
    ;;
  Linux)
    linux=1
    shell="$(getent passwd "${LOGNAME}" | cut -d: -f7)"
    ;;
  *)
    echo "Unsupported platform!" >&2
    exit 1
    ;;
esac

is_mac() {
  test -n "${mac}"
}

is_linux() {
  test -n "${linux}"
}

install_dir="$HOME/.shopify-app-cli"

postmsg() {
  echo -e "\x1b[36mshopify-app-cli\x1b[0m is installed!"
  echo -e "Run \x1b[36mshopify help\x1b[0m to see what you can do, or read \x1b[36mhttps://github.com/Shopify/shopify-app-cli\x1b[0m."
  echo -e "To start developing on shopify, for example:"
  echo -e "  * run \x1b[36mshopify create project <appname>\x1b[0m"
}

install_prerequisites() {
  if is_mac; then
    install_xcode_clt
  elif is_linux; then
    check_linux_prerequisites
  fi
}

# Adapted from https://github.com/rtrouton/rtrouton_scripts/tree/master/rtrouton_scripts/install_xcode_command_line_tools
install_xcode_clt() {
  local cmd_line_tools_temp_file
  cmd_line_tools_temp_file="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
  local osx_vers
  osx_vers=$(sw_vers -productVersion | awk -F "." '{print $2}')

  if [[ "${osx_vers}" -lt 11 ]]; then
    >&2 echo "shopify-app-cli is only supported on El Capitan and higher."
    exit 1
  fi

  if /usr/bin/git --version >/dev/null 2>&1; then
    # if git succeeds, we already have the CLT, so no need to continue
    bs_success_message "Already have XCode Command Line Tools"
    return 0
  fi

  # Create the placeholder file which is checked by the softwareupdate tool
  # before allowing the installation of the Xcode command line tools.
  sudo touch "${cmd_line_tools_temp_file}"

  swupdate() {
    sudo softwareupdate -l "$@" \
      | awk '/\*\ Command Line Tools/ { $1=$1;print }' \
      | tail -1 \
      | sed 's/^[[ \t]]*//;s/[[ \t]]*$//;s/*//' \
      | cut -c 2-
  }

  # Find the last listed update in the Software Update feed with "Command Line Tools" in the name
  # shellcheck disable=SC2086
  cmd_line_tools="$(swupdate --no-scan)"

  # This can be empty for two reasons:
  # 1. CLT already installed
  # 2. Super new computer that has not yet scanned for updates.
  #
  # Since we would have returned earlier if we had a functional git,
  # we know that the CLT are not installed. So if this is empty,
  # it must be reason 2, and we should check for updates again, performing a
  # full scan. The reason we don't do this all the time is that it takes a
  # painfully long time.
  if [[ -z "${cmd_line_tools}" ]]; then
    echo "Checking for software updates"
    cmd_line_tools="$(swupdate)"
    # This shouldn't really happen, but... maybe things will be ok?
    if [[ -z "${cmd_line_tools}" ]]; then
      bs_success_message "Already have XCode Command Line Tools"
      return 0
    fi
  fi

  local ret

  echo "Installing XCode Command Line Tools"
  sudo softwareupdate -i "${cmd_line_tools}"
  ret=$?

  # Remove the temp file
  if [[ -f "${cmd_line_tools_temp_file}" ]]; then
    sudo rm "${cmd_line_tools_temp_file}"
  fi

  sudo xcodebuild -license accept

  bs_success_message "Successfully installed XCode Command Line Tools"

  return "${ret}"
}

check_linux_prerequisites() {
  if [ -n "${SKIP_PREREQS}" ]; then
    return 0;
  fi

  # shellcheck disable=1091,2153
  case "$(source /etc/os-release && echo "${ID_LIKE}")" in
    debian)
      if [[ -n $(check_executables "git ruby") ]]; then
        bs_error_message "please install dependencies with 'sudo apt-get install git-core ruby'"
        exit 1
      fi
      bs_success_message "Successfully installed shopify-app-cli prerequisites"
      ;;
    *fedora*)
      if [[ -n $(check_executables "git ruby25") ]]; then
        bs_error_message "please install dependencies with 'sudo yum install git ruby25'"
        exit 1
      fi
      bs_success_message "Successfully installed shopify-app-cli prerequisites"
      ;;
    *)
      bs_error_message "Only apt (e.g. Ubuntu, Debian) and yum (e.g. CentOS, Fedora) are supported"
      bs_error_message "in this install script. To proceed, figure out how to install the equivalent"
      bs_error_message "of: build-essential, git-core, and ruby. Then, export SKIP_PREREQS=1 and run"
      bs_error_message "this script again. At the end, /usr/bin/ruby must exist and be >= 2.0.0"
      exit 1
      ;;
  esac
}

check_executables() {
  packages=("$1")
  missing=""
  for package in $packages; do
    if [[ -z $(which $package) ]]; then
      bs_error_message "$package not installed"
      missing="$missing $package"
    fi
  done
  echo $missing
}

clone_shopify_cli() {
  if [[ -d "${install_dir}/.git" ]]; then
    bs_success_message "already have shopify-app-cli"
  else
    local git_url
    git_url="${SHOPIFY_CLI_BOOTSTRAP_GIT_URL:-git@github.com:shopify/shopify-app-cli.git}"

    # Very intentionally do the git clone as the logged in user so ssh keys aren't an issue.
    mkdir -p "${install_dir}"
    echo "Cloning Shopify/shopify-app-cli into ${install_dir}"
    false
    (cd "${install_dir}" && git clone "${git_url}" .)
    if [[ $? -ne 0 ]]; then
      bs_error_message "git clone failed. Have you set up SSH keys yet?"
      bs_error_message "https://help.github.com/articles/generating-an-ssh-key"
      bs_error_message ""
      bs_error_message "If you know that you've set up auth for HTTPS but not SSH, run:"
      bs_error_message "  export SHOPIFY_CLI_BOOTSTRAP_GIT_URL=https://github.com/shopify/shopify-app-cli.git"
      bs_error_message "And then run this script again."
      exit 1
    fi

    bs_success_message "cloned shopify/shopify-app-cli"
  fi

  case "${shell}" in
    */bash)
      install_bash_shell_shim
      ;;
    */zsh)
      # Pretty much every zsh user just uses ~/.zshrc so we won't worry about
      # all that file detection stuff we do with bash.
      install_zsh_shell_shim
      ;;
    */fish)
      install_fish_shell_shim
      ;;
    *)
      >&2 echo "shopify-app-cli is not supported on your shell (${shell} -- bash, zsh, and fish are supported)."
      ;;
  esac
}

install_bash_shell_shim() {
  local bp
  bp="${HOME}/.bash_profile"

  # If the user doesn't already have a .bash_profile, this is kind of complex:
  # The order of preference for login shell config files is:
  # .bash_profile -> .bash_login -> .profile
  # If we create a higher precedence one, the lower is masked.
  # Additionally, .bashrc is loaded for non-login shells and .bash_profile isn't.
  # So what we will do is create .bash_profile which will:
  # 1. Source .bash_login if it exists
  # 2. Source .profile if is exists and .bash_login did not
  # 4. Source shopify.sh
  #
  # And additionally, we will append to .bashrc which will load shopify-app-cli if it exists
  # and the shell is also interactive.
  #
  # See:
  # * http://howtolamp.com/articles/difference-between-login-and-non-login-shell/
  # * http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_03_01.html

  if [[ -f "${bp}" ]]; then
    : # nothing to add to .bash_profile at this stage.
  elif [[ -f "${HOME}/.bash_login" ]]; then
    echo "source ~/.bash_login" >> "${bp}"
  elif [[ -f "${HOME}/.profile" ]]; then
    echo "source ~/.profile" >> "${bp}"
  fi

  if ! grep -q "shopify.sh" "${bp}" 2>/dev/null; then
    {
      echo ''
      echo '# load shopify-app-cli, but only if present and the shell is interactive'
      echo "if [[ -f \"${install_dir}/shopify.sh\" ]]; then source \"${install_dir}/shopify.sh\"; fi"
    } >> "${bp}"
  fi

  if ! grep -q "shopify.sh" "${HOME}/.bashrc" 2>/dev/null; then
    {
      echo ''
      echo '# load shopify-app-cli, but only if present and the shell is interactive'
      echo "if [[ -f \"${install_dir}/shopify.sh\"  ]] && [[ $- == *i* ]]; then"
      echo "  source \"${install_dir}/shopify.sh\""
      echo 'fi'
    } >> "${HOME}/.bashrc"
  fi

  bs_success_message "shell set up for shopify-app-cli"
  bs_success_message "\x1b[1;44;31mNOTE:\x1b[39m added lines to the end of ~/.bash_profile and ~/.bashrc\x1b[0m"
}

install_zsh_shell_shim() {
  local rcfile
  rcfile="${HOME}/.zshrc"
  touch "${rcfile}"
  if grep -q "${install_dir}/shopify.sh" "${rcfile}"; then
    bs_success_message "shell already set up for shopify-app-cli"
    return
  fi

  echo -e "\n[ -f \"${install_dir}/shopify.sh\" ] && source \"${install_dir}/shopify.sh\"" >> "${rcfile}"
  bs_success_message "shell set up for shopify-app-cli"
  bs_success_message "\x1b[1;44;31mNOTE:\x1b[39m added a line to the end of ${rcfile}\x1b[0m"
}

install_fish_shell_shim() {
  local rcfile
  rcfile="${HOME}/.config/fish/config.fish"
  mkdir -p "$(dirname "${rcfile}")"
  touch "${rcfile}"
  if grep -q "${install_dir}/shopify.fish" "${rcfile}"; then
    bs_success_message "shell already set up for shopify-app-cli"
    return
  fi

  echo -e "\nif test -f \"${install_dir}/shopify.fish\"\n  source \"${install_dir}/shopify.fish\"\nend" >> "${rcfile}"
  bs_success_message "shell set up for shopify-app-cli"
  bs_success_message "\x1b[1;44;31mNOTE:\x1b[39m added a line to the end of ${rcfile}\x1b[0m"
}

bs_success_message() {
  >&9 echo -e "\x1b[32m✔︎\x1b[0m $1"
}

bs_error_message() {
  >&3 echo -e "\x1b[31m✗\x1b[0m $1"
}

__bs_run_func_with_margin() {
  local func
  func=$1; shift

  local prefix_red prefix_green prefix_cyan
  prefix_red=$'s/^/\x1b[31m┃\x1b[0m /'
  prefix_green=$'s/^/\x1b[32m┃\x1b[0m /'
  prefix_cyan=$'s/^/\x1b[36m┃\x1b[0m /'

  (
    set -o pipefail
    { {
    # move stderr to FD 3
    ${func} 8>&2 2>&3 | sed "${prefix_cyan}"
    # prefix output from 3 (relocated stderr) with red
    } 3>&1 1>&2 | sed "${prefix_red}"
    # prefix output from FD 9 with green
    } 9>&1 1>&2 | sed "${prefix_green}"
  )
}


__bs_print_bare_title() {
  local line_color
  line_color="\x1b[36m"

  local padding
  padding="$(__bs_padding "━" "┏")"
  local reset_color
  reset_color="\x1b[0m"

  echo -e "${line_color}┏${padding}${reset_color}"
}

__bs_print_bare_footer() {
  local line_color
  line_color="\x1b[36m"

  local padding
  padding="$(__bs_padding "━" "┗")"
  local reset_color
  reset_color="\x1b[0m"

  echo -e "${line_color}┗${padding}${reset_color}"
}

__bs_print_title() {
  local current_phase
  current_phase=$1; shift
  local n_phases
  n_phases=$1     ; shift
  local title
  title=$1        ; shift

  local line_color title_color reset_color
  line_color="\x1b[36m"
  title_color="\x1b[35m"
  reset_color="\x1b[0m"

  local prefix
  prefix="${line_color}┏━━ 🦄  "

  local text
  text="${prefix}${title_color}${current_phase}/${n_phases}: ${title} "

  local padding
  padding="$(__bs_padding "━" "${text}")"

  echo -e "${text}${line_color}${padding}${reset_color}"
}

__bs_print_fail_footer() {
  local color reset
  color="\x1b[31m"
  reset="\x1b[0m"

  local text
  text="\r${color}┗━━ 💥  Failed! Aborting! "

  local padding
  padding="$(__bs_padding "━" "${text}")"

  echo -e "${text}${padding}${reset}"
}

__bs_padding() {
  local padchar text
  padchar=$1; shift
  text=$1   ; shift

  # ANSI escape sequences (like \x1b[31m) have zero width.
  # when calculating the padding width, we must exclude them.
  local text_without_nonprinting
  text_without_nonprinting="$(
    echo -e "${text}" | sed -E $'s/\x1b\\[[0-9;]+[A-Za-z]//g'
  )"
  local prefixlen
  prefixlen="${#text_without_nonprinting}"

  local termwidth
  termwidth="$(tput cols)"
  local padlen
  ((padlen = termwidth - prefixlen))

  # I don't fully understand what's going on here.
  # It's magic and it works ¯\_(ツ)_/¯
  # Basically though, print N of the padding character,
  # where N is the terminal width minus the width of the text.
  local s
  s="$(printf "%-${padlen}s" "${padchar}")"
  echo "${s// /${padchar}}"
}

main() {
  __bs_print_title 1 2 "Installing Prerequisites"
  if __bs_run_func_with_margin install_prerequisites; then
    __bs_print_bare_footer
  else
    __bs_print_fail_footer
    exit 1
  fi

  __bs_print_title 2 2 "Installing shopify-app-cli"
  if __bs_run_func_with_margin clone_shopify_cli; then
    __bs_print_bare_footer
  else
    __bs_print_fail_footer
    exit 1
  fi

  __bs_print_bare_title
  __bs_run_func_with_margin postmsg
  __bs_print_bare_footer
}
main "$@"
EOF

if \test $? -ne 0; then
  \echo "couldn't write bootstrap stage 2!" >&2
  \rm -f "${tempfile}"
  \false
else
  \bash "${tempfile}"
  if \test $? -eq 0; then
    \rm -f "${tempfile}"
    # re-exec the user's shell to pick up the new shopify-app-cli function.
    case "$(\uname -s)" in
      Darwin)
        \exec "$(\dscl . -read "/Users/${LOGNAME}" UserShell | /usr/bin/awk '{print $NF}')" --login
        ;;
      Linux)
        \exec "$(\getent passwd "${LOGNAME}" | \cut -d: -f7)" --login
        ;;
      *)
        \echo "Unsupported platform!" >&2
        ;;
    esac
  else
    \rm -f "${tempfile}"
    \false
  fi
fi
