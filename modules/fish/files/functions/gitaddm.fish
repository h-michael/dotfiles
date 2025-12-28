function gitaddm -d "git add modified files"
    git status -s | grep -v 'M ' | sed -e 's/^?? //' | xargs git add
end
