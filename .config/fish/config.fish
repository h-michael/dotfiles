# https://mise.jdx.dev/dev-tools/shims.html#shims-vs-path
#$HOME/.local/bin/mise activate fish | source
eval ($HOME/.local/bin/mise activate fish --shims)

starship init fish | source
