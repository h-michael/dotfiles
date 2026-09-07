#!/usr/bin/env bash
# Generic TTL cache wrapper for tmux status-right commands.
#
# Every tmux session re-evaluates status-right on its own, so without
# caching, N sessions each re-run the wrapped command every
# status-interval. Sharing one cache file across sessions means the
# expensive command actually runs at most once per TTL, regardless of
# how many sessions exist.
#
# The cache-hit path uses only bash builtins (no date/stat/cat/id), so
# the per-tick cost is a single bash process. The write timestamp is
# stored as the first line of the cache file instead of relying on the
# file mtime, which sidesteps the BSD/GNU differences in date/stat.
#
# Usage: cached_status.sh <key> <ttl_seconds> <command...>
set -u
# noclobber makes `> file` an atomic create-if-absent, which is the lock
# primitive below. Writes that must overwrite use `>|`.
set -C
# extglob must be on before the functions below are parsed.
shopt -s extglob

key="$1"
ttl="$2"
shift 2

cache_dir="${TMPDIR:-/tmp}/tmux-status-cache-$UID"
cache_file="$cache_dir/$key"
lock_file="$cache_file.lock"

print_cache() {
  local -a lines
  [[ -r $cache_file ]] || return 1
  mapfile -t lines <"$cache_file"
  printf '%s\n' "${lines[@]:1}"
}

cache_is_fresh() {
  local ts
  [[ -r $cache_file ]] || return 1
  IFS= read -r ts <"$cache_file" || return 1
  [[ $ts == +([0-9]) ]] || return 1
  ((EPOCHSECONDS - ts < ttl))
}

# Only one process refreshes at a time; the rest print the stale value
# (stale-but-cheap beats a thundering herd of forks).
#
# If the holder dies without running its EXIT trap (SIGKILL, OOM, a
# wrapped command that hangs until tmux gives up on it) the lock would
# otherwise stay behind forever and every session would keep printing
# the same stale value. A lock older than the TTL is therefore treated
# as abandoned and taken over. The takeover itself is not atomic: two
# processes can both pass the staleness check and both proceed to
# refresh. That is harmless as long as each writes to its own temp file
# (see below), since the final mv is atomic and last-writer-wins.
acquire_lock() {
  local held
  if printf '%s\n' "$EPOCHSECONDS" 2>/dev/null >"$lock_file"; then
    return 0
  fi
  IFS= read -r held <"$lock_file" 2>/dev/null || held=0
  [[ $held == +([0-9]) ]] || held=0
  ((EPOCHSECONDS - held > ttl)) || return 1
  rm -f "$lock_file"
  printf '%s\n' "$EPOCHSECONDS" 2>/dev/null >"$lock_file"
}

if cache_is_fresh; then
  print_cache
  exit 0
fi

[[ -d $cache_dir ]] || mkdir -p "$cache_dir"

if acquire_lock; then
  # PID-specific temp file so two refreshers (possible after a stale
  # lock takeover) never interleave writes into the same file.
  tmp_file="$cache_file.tmp.$$"
  trap 'rm -f "$lock_file" "$tmp_file"' EXIT
  # Only replace the cache when the command succeeds, so a transient
  # failure (no battery, route lookup error) keeps the last good value
  # instead of blanking the status bar.
  if out=$("$@" 2>/dev/null); then
    printf '%s\n%s\n' "$EPOCHSECONDS" "$out" >|"$tmp_file" &&
      mv -f "$tmp_file" "$cache_file"
  fi
fi

print_cache || true
