#!/usr/bin/env bash
__bindir="$(builtin cd "$(\dirname "${BASH_SOURCE[0]}")" && \pwd)"
exec /usr/bin/env ruby --disable=gems ${__bindir}/shopify.rb