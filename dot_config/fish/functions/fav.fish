function fav -d "Select AWS profile"
    aws-vault exec (aws-vault list | sed '1,2d' | fzf --prompt="Select profile" | awk '{print $1}')
end
