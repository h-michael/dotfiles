#!/usr/bin/env fish
# Claude Code statusline for fish shell

# Start timer
set -l START_TIME_NS (date +%s%N 2>/dev/null)
if test -z "$START_TIME_NS"
    if command -v gdate >/dev/null 2>&1
        set START_TIME_NS (gdate +%s%N 2>/dev/null)
    else
        set START_TIME_NS (math (date +%s) "*" 1000000000)
    end
end

# Parse JSON input
set input (cat)

set MODEL_DISPLAY (echo $input | jq -r '.model.display_name')
set CURRENT_DIR (echo $input | jq -r '.workspace.current_dir')
set PROJECT_DIR (echo $input | jq -r '.workspace.project_dir')
set OUTPUT_STYLE (echo $input | jq -r '.output_style.name')
set SESSION_ID (echo $input | jq -r '.session_id')
set TOTAL_COST (echo $input | jq -r '.cost.total_cost_usd // 0')
set LINES_ADDED (echo $input | jq -r '.cost.total_lines_added // 0')
set LINES_REMOVED (echo $input | jq -r '.cost.total_lines_removed // 0')
set TOTAL_TOKENS (echo $input | jq -r '.cost.total_tokens // 0')
set TRANSCRIPT_PATH (echo $input | jq -r '.transcript_path // ""')

# Get token usage and timestamp from transcript
set -l transcript_data (cc_statusline_transcript_data "$TRANSCRIPT_PATH")
if test -n "$transcript_data"
    set INPUT_TOKENS (echo $transcript_data | cut -f1)
    set OUTPUT_TOKENS (echo $transcript_data | cut -f2)
    set CACHED_TOKENS (echo $transcript_data | cut -f3)
    set CACHE_CREATION_TOKENS (echo $transcript_data | cut -f4)
    set FIRST_TIMESTAMP (echo $transcript_data | cut -f5)
else
    set INPUT_TOKENS 0
    set OUTPUT_TOKENS 0
    set CACHED_TOKENS 0
    set CACHE_CREATION_TOKENS 0
    set FIRST_TIMESTAMP ""
end

# Build statusline
set statusline_parts

# Directory
set -l dir_text (cc_statusline_directory "$CURRENT_DIR" 3)
test -n "$dir_text"; and set -a statusline_parts (printf "\033[1;34m📁 %s\033[0m" "$dir_text")

# Model
set -l model_text (cc_statusline_model "$MODEL_DISPLAY")
test -n "$model_text"; and set -a statusline_parts (printf "\033[1;36m%s\033[0m" "$model_text")

# Git
set -l git_text (cc_statusline_git "$CURRENT_DIR")
if test -n "$git_text"
    if string match -qr '\[.*\]' "$git_text"
        set -l branch_part (string replace -r ' \[.*\]$' '' "$git_text")
        set -l status_part (string match -r '\[.*\]' "$git_text")
        set -a statusline_parts (printf "\033[1;35m%s\033[0m \033[1;33m%s\033[0m" "$branch_part" "$status_part")
    else
        set -a statusline_parts (printf "\033[1;35m%s\033[0m" "$git_text")
    end
end

# Code changes
set -l changes_text (cc_statusline_code_changes "$LINES_ADDED" "$LINES_REMOVED")
if test -n "$changes_text"
    set -l added_part (string match -r '^\+[0-9]+' "$changes_text")
    set -l removed_part (string match -r '/-[0-9]+$' "$changes_text")
    set removed_part (string replace '/' '' "$removed_part")
    set -a statusline_parts (printf "\033[1;32m%s\033[0m/\033[1;31m%s\033[0m" "$added_part" "$removed_part")
end

# Output style
set -l style_text (cc_statusline_output_style "$OUTPUT_STYLE")
test -n "$style_text"; and set -a statusline_parts (printf "\033[1;33m🎨 %s\033[0m" "$style_text")

# Context
if test "$INPUT_TOKENS" -ne 0 -o "$OUTPUT_TOKENS" -ne 0 -o "$CACHED_TOKENS" -ne 0 -o "$CACHE_CREATION_TOKENS" -ne 0
    set -l context_total (math "$CACHED_TOKENS + $CACHE_CREATION_TOKENS + $INPUT_TOKENS + $OUTPUT_TOKENS")
    set -l pct_160k (math "$context_total * 100 / 160000")
    set -l pct_200k (math "$context_total * 100 / 200000")

    if test $pct_160k -ge 80
        set -a statusline_parts (printf "\033[1;31m📊 %d/%d%%\033[0m" $pct_160k $pct_200k)
    else if test $pct_160k -ge 60
        set -a statusline_parts (printf "\033[1;33m📊 %d/%d%%\033[0m" $pct_160k $pct_200k)
    else
        set -a statusline_parts (printf "\033[1;32m📊 %d/%d%%\033[0m" $pct_160k $pct_200k)
    end
end

# Tokens
function format_token_count
    set -l count $argv[1]
    if test "$count" -ge 1000000
        printf "%.1fM" (math "$count / 1000000")
    else if test "$count" -ge 1000
        printf "%.0fk" (math "$count / 1000")
    else
        printf "%d" $count
    end
end

if test "$INPUT_TOKENS" -gt 0 -o "$OUTPUT_TOKENS" -gt 0 -o "$CACHED_TOKENS" -gt 0
    set -a statusline_parts (printf "\033[1;36m📥%s\033[0m" (format_token_count "$INPUT_TOKENS"))
    set -a statusline_parts (printf "\033[1;32m📤%s\033[0m" (format_token_count "$OUTPUT_TOKENS"))
    set -a statusline_parts (printf "\033[1;35m💾%s\033[0m" (format_token_count "$CACHED_TOKENS"))
end

# Cost
set -l cost_text (cc_statusline_cost "$TOTAL_COST")
test -n "$cost_text"; and set -a statusline_parts (printf "\033[1;33m💵 %s\033[0m" "$cost_text")

# Block timer
if test -n "$FIRST_TIMESTAMP"
    set -l current_ts (date -u +%s 2>/dev/null)
    set -l first_ts_seconds (date -j -f "%Y-%m-%dT%H:%M:%S" (string sub -l 19 "$FIRST_TIMESTAMP") +%s 2>/dev/null)

    if test -n "$current_ts" -a -n "$first_ts_seconds"
        set -l elapsed_seconds (math "$current_ts - $first_ts_seconds")
        set -l total_hours (math "$elapsed_seconds / 3600.0")
        set -l block_num (math "floor($total_hours / 5)")
        set -l block_start_hours (math "$block_num * 5")
        set -l elapsed_in_block (math "$total_hours - $block_start_hours")
        set -l progress_chars (math "floor(($elapsed_in_block / 5.0) * 16)")
        set -l bar (string repeat -n $progress_chars "█")
        set -l empty (string repeat -n (math "16 - $progress_chars") "░")
        set -a statusline_parts (printf "\033[37m⏳[%s%s] %.1fh\033[0m" "$bar" "$empty" $elapsed_in_block)
    end
end

# Timer
set -l timer_text (cc_statusline_timer "$START_TIME_NS")
test -n "$timer_text"; and set -a statusline_parts (printf "\033[90m⏱️ %s\033[0m" "$timer_text")

string join " " $statusline_parts
exit 0
