# Calculate and format context usage percentage from transcript for Claude Code statusline
# Args:
#   $argv[1] - transcript file path
# Returns:
#   Plain text in format "percentage_160k/percentage_200k|level" where level is "low", "medium", or "high", or empty string on error
#   Example: "103.2/82.6|high" - Over 160k limit (103.2%), 82.6% of 200k
# Note: This is the most expensive function as it parses the transcript file

function cc_statusline_context
    set -l transcript_path $argv[1]

    if test -z "$transcript_path"; or not test -f "$transcript_path"
        return
    end

    # Find the LAST assistant message in the transcript using single jq pass
    # This is much faster than line-by-line processing (100ms vs 5000ms)
    set -l last_assistant_json (jq -c 'select(.type == "assistant")' "$transcript_path" 2>/dev/null | tail -1)

    # Process the last assistant message if found
    if test -z "$last_assistant_json"
        return
    end

    # Extract all token types in one go using single jq command
    set -l usage_data (echo $last_assistant_json | jq -r '[.message.usage.input_tokens // 0, .message.usage.output_tokens // 0, .message.usage.cache_creation_input_tokens // 0, .message.usage.cache_read_input_tokens // 0] | @tsv' 2>/dev/null)

    # Parse the tab-separated values
    set -l input_tok (echo $usage_data | cut -f1)
    set -l output_tok (echo $usage_data | cut -f2)
    set -l cache_creation_tok (echo $usage_data | cut -f3)
    set -l cache_read_tok (echo $usage_data | cut -f4)

    # Validate numbers (set to 0 if empty or not a valid number)
    if test -z "$input_tok"; or not string match -qr '^[0-9]+$' -- "$input_tok"
        set input_tok 0
    end
    if test -z "$output_tok"; or not string match -qr '^[0-9]+$' -- "$output_tok"
        set output_tok 0
    end
    if test -z "$cache_creation_tok"; or not string match -qr '^[0-9]+$' -- "$cache_creation_tok"
        set cache_creation_tok 0
    end
    if test -z "$cache_read_tok"; or not string match -qr '^[0-9]+$' -- "$cache_read_tok"
        set cache_read_tok 0
    end

    # Calculate current context size
    # Total context = cache_read + cache_creation + input + output
    # - cache_read_input_tokens: all context currently in cache
    # - cache_creation_input_tokens: new tokens just added to cache
    # - input_tokens: new input tokens not cached
    # - output_tokens: response tokens
    set -l context_total (math "$cache_read_tok + $cache_creation_tok + $input_tok + $output_tok")

    # Calculate percentages against both limits
    if test $context_total -eq 0
        return
    end

    # Calculate percentages against both limits:
    # - 160k: Practical limit (Claude Code auto-compacts at 80% of 200k)
    # - 200k: Technical maximum context window
    # Display both to show practical vs absolute usage
    set -l limit_160k 160000
    set -l limit_200k 200000

    # Use bc for floating point calculation
    set -l percentage_160k (echo "scale=1; $context_total * 100 / $limit_160k" | bc 2>/dev/null)
    set -l percentage_200k (echo "scale=1; $context_total * 100 / $limit_200k" | bc 2>/dev/null)

    # Fallback to integer math if bc fails
    if test -z "$percentage_160k"; or test "$percentage_160k" = ""
        set percentage_160k (math "$context_total * 100 / $limit_160k")
    end
    if test -z "$percentage_200k"; or test "$percentage_200k" = ""
        set percentage_200k (math "$context_total * 100 / $limit_200k")
    end

    # Determine level based on percentage_160k (practical limit)
    set -l percentage_num (echo $percentage_160k | cut -d. -f1)

    # Handle empty percentage_num
    if test -z "$percentage_num"; or test "$percentage_num" = ""
        set percentage_num 0
    end

    set -l context_level low
    if test $percentage_num -ge 80
        set context_level high
    else if test $percentage_num -ge 60
        set context_level medium
    end

    # Output format: "percentage_160k/percentage_200k|level"
    printf "%.1f/%.1f%%|%s" $percentage_160k $percentage_200k $context_level
end
