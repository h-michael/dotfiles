function cc_statusline_transcript_data -d "Extract token usage and timestamp from transcript"
    set -l transcript_path $argv[1]

    test -z "$transcript_path"; and return
    test -f "$transcript_path"; or return

    # Get first message timestamp
    set -l first_ts (jq -r 'select(.type == "user" or .type == "assistant") | .timestamp' "$transcript_path" 2>/dev/null | head -1)

    # Get last assistant message token usage
    set -l usage_data (jq -c 'select(.type == "assistant")' "$transcript_path" 2>/dev/null | tail -1 | jq -r '[.message.usage.input_tokens // 0, .message.usage.output_tokens // 0, .message.usage.cache_read_input_tokens // 0, .message.usage.cache_creation_input_tokens // 0] | @tsv' 2>/dev/null)

    test -n "$usage_data" -a -n "$first_ts"; and printf "%s\t%s\n" $usage_data $first_ts
end
