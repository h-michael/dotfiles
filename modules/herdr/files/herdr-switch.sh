# Workspace switcher for a herdr popup ([[keys.command]] type = "popup").
# Linked worktrees are shown as "<parent workspace>/<worktree workspace>",
# where the parent is the open workspace on the repository's main checkout.
# Status icons and colors mirror herdr's sidebar defaults (status_icon and
# status_color in herdr's src/client/shell.rs).

herdr=${HERDR_BIN_PATH:-herdr}

# Workspaces running an agent come first, each group sorted by name.
# Membership comes from `agent list` rather than agent_status, which
# cannot tell an agent in the unknown state from a pane without one.
list=$("$herdr" workspace list | jq -r --argjson agents "$("$herdr" agent list)" '
  def icon:
    if . == "blocked" then "\u001b[31m●"
    elif . == "done" then "\u001b[36m●"
    elif . == "working" then "\u001b[33m●"
    elif . == "idle" then "\u001b[32m○"
    else "\u001b[90m·" end + "\u001b[0m";
  ($agents.result.agents | map({key: .workspace_id, value: true}) | from_entries) as $has_agent
  | .result.workspaces as $all
  | ($all
     | map(select(.worktree and (.worktree.is_linked_worktree | not))
           | {key: .worktree.repo_root, value: .label})
     | from_entries) as $parent
  | $all
  | map({
      name: (if .worktree.is_linked_worktree
             then ($parent[.worktree.repo_root] // .worktree.repo_name) + "/" + .label
             else .label end),
      status: .agent_status,
      id: .workspace_id,
      no_agent: ($has_agent[.workspace_id] | not)
    })
  | sort_by(.no_agent, (.name | ascii_downcase))
  | .[]
  | "\(.status | icon) \(.name)\t\(.id)"')

selected=$(printf '%s\n' "$list" | fzf \
  --ansi \
  --layout=reverse \
  --border=rounded \
  --no-multi \
  --info=inline \
  --delimiter='\t' \
  --with-nth=1 \
  --prompt="Select workspace: ") || exit 0

"$herdr" workspace focus "$(printf '%s' "$selected" | cut -f2)" >/dev/null
