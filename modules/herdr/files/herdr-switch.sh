# Tab switcher for a herdr popup ([[keys.command]] type = "popup").
# One row per tab, shown as "<workspace> · <tab>", so two agents in the
# same workspace can be told apart by tab name. Linked worktrees are
# shown as "<parent workspace>/<worktree workspace>", where the parent is
# the open workspace on the repository's main checkout. Status icons and
# colors mirror herdr's sidebar defaults (status_icon and status_color in
# herdr's src/client/shell.rs).

herdr=${HERDR_BIN_PATH:-herdr}

# Tabs waiting on the user come first: blocked (needs input), then done
# (finished while unseen), the same order as herdr's
# tab_attention_priority in src/app/api_helpers.rs. Other tabs running an
# agent follow, then tabs without one. Each group is sorted by name and
# then tab number. Membership comes from `agent list` rather than
# agent_status, which cannot tell an agent in the unknown state from a
# pane without one.
list=$(jq -n -r \
  --argjson workspaces "$("$herdr" workspace list)" \
  --argjson tabs "$("$herdr" tab list)" \
  --argjson agents "$("$herdr" agent list)" '
  def icon:
    if . == "blocked" then "\u001b[31m●"
    elif . == "done" then "\u001b[36m●"
    elif . == "working" then "\u001b[33m●"
    elif . == "idle" then "\u001b[32m○"
    else "\u001b[90m·" end + "\u001b[0m";
  def attention:
    if . == "blocked" then 0 elif . == "done" then 1 else 2 end;
  ($agents.result.agents | map({key: .tab_id, value: true}) | from_entries) as $has_agent
  | $workspaces.result.workspaces as $all
  | ($all
     | map(select(.worktree and (.worktree.is_linked_worktree | not))
           | {key: .worktree.repo_root, value: .label})
     | from_entries) as $parent
  | ($all
     | map({key: .workspace_id,
            value: (if .worktree.is_linked_worktree
                    then ($parent[.worktree.repo_root] // .worktree.repo_name) + "/" + .label
                    else .label end)})
     | from_entries) as $name
  | $tabs.result.tabs
  | map({
      name: ($name[.workspace_id] // .workspace_id),
      tab: .label,
      number: .number,
      status: .agent_status,
      id: .tab_id,
      no_agent: ($has_agent[.tab_id] | not)
    })
  | sort_by((.status | attention), .no_agent, (.name | ascii_downcase), .number)
  | .[]
  | "\(.status | icon) \(.name) · \(.tab)\t\(.id)"')

selected=$(printf '%s\n' "$list" | fzf \
  --ansi \
  --layout=reverse \
  --border=rounded \
  --no-multi \
  --info=inline \
  --delimiter='\t' \
  --with-nth=1 \
  --prompt="Select tab: ") || exit 0

"$herdr" tab focus "$(printf '%s' "$selected" | cut -f2)" >/dev/null
