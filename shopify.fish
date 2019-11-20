#!/usr/bin/env fish
# vi: ft=fish

set -g __shopify_source_dir (pushd (dirname (status -f)) ; pwd ; popd)

#### Handlers for bin/shopify-cli-shell-support environment manipulation
#### See bin/shopify-cli-shell-support for documentation.
function shopify_cli__source; source $argv[1]; end
function shopify_cli__setenv; set -gx $argv[1] $argv[2]; end
function shopify_cli__append_path; set -gx PATH $PATH $argv[1]; end
function shopify_cli__prepend_path; set -gx PATH $argv[1] $PATH; end

eval "$__shopify_source_dir/bin/shopify-cli-shell-support" env fish | while read line
  eval "$line"
end

functions --erase shopify_cli__source
functions --erase shopify_cli__setenv
functions --erase shopify_cli__append_path
functions --erase shopify_cli__prepend_path

set -g __mtime_of_shopify_script (date -r "$__shopify_source_dir/shopify.fish" +%s)
function shopify
  # reload __shopify__ function
  set -l current_mtime (date -r "$__shopify_source_dir/shopify.fish" +%s)

  if test "$current_mtime" != "$__mtime_of_shopify_script"
    source "$__shopify_source_dir/shopify.fish"
  end
  __shopify__ $argv
end

function __shopify__
  # Read as MACOS_SW_VERSION ||= `sw_vers -productVersion`
  set -qg MACOS_SW_VERSION; or set -gx MACOS_SW_VERSION (sw_vers -productVersion)

  set -l finalizers (mktemp /tmp/shopify-finalize-XXXXXX)
  function cleanup-finalizer-tmpfile --on-process %self
    rm -f "$finalizers"
  end

  set -l bin_path "$__shopify_source_dir/bin/shopify"

  set -l with_gems ''
  if test "$__shopify_source_dir" = "/opt/shopify"; and isatty stdin
    set with_gems "FALSE"
  else
    set with_gems "TRUE"
  end
  if test "$argv[1]" = "--with-gems"
    # i.e. shift
    set -e argv[1]
    set with_gems "TRUE"
  else if test "$argv[1]" = "--without-gems"
    # i.e. shift
    set -e argv[1]
    set with_gems "FALSE"
  end

  if test "$with_gems" = "TRUE"
    eval /usr/bin/env ruby $bin_path $argv 9>$finalizers
  else
    eval $bin_path $argv 9>$finalizers
  end
  set -l return_from_shopify $status

  while read fin
    switch "$fin"
      case cd:\*
        set -l newdir (echo "$fin" | sed 's/^cd://')
        cd "$newdir"
      case setenv:\*
        set -l assignment (echo "$fin" | sed 's/^setenv://' | tr = \\n)
        set -x "$assignment[1]" "$assignment[2]"
      case reload_shopify_from:\*
        set -l root (echo "$fin" | sed 's/^reload_shopify_from://')
        source "$root/shopify.fish"
    end
  end < "$finalizers"

  return $return_from_shopify
end
