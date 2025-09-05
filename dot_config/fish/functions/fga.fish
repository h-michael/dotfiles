# switch gcloud configurations
function fga -d "Switch gcloud configurations"
    gcloud config configurations list --format="table[no-heading] (name,is_active,name,properties.core.account,properties.core.project)" | fzf | awk '{print $1}' | xargs gcloud config configurations activate
end
