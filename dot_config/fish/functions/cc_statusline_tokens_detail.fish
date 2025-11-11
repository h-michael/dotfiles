# Extract detailed token information from transcript for Claude Code statusline
# Args:
#   $argv[1] - transcript file path
# Returns:
#   Plain text in format "input\toutput\tcached" (tab-separated values) or empty string on error

function cc_statusline_tokens_detail
    set -l transcript_path $argv[1]

    if test -z "$transcript_path"; or not test -f "$transcript_path"
        return
    end

    # Find the LAST assistant message in the transcript
    set -l last_assistant_json (jq -c 'select(.type == "assistant")' "$transcript_path" 2>/dev/null | tail -1)

    if test -z "$last_assistant_json"
        return
    end

    # Extract token counts: input, output, cache_read
    set -l usage_data (echo $last_assistant_json | jq -r '[.message.usage.input_tokens // 0, .message.usage.output_tokens // 0, .message.usage.cache_read_input_tokens // 0] | @tsv' 2>/dev/null)

    if test -z "$usage_data"
        return
    end

    echo $usage_data
end
