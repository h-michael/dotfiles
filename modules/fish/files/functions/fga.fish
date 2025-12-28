# switch gcloud configurations
function fga -d "Switch gcloud configurations"
    set -l config (gcloud config configurations list \
        --format="table[no-heading] (name,is_active,properties.core.account,properties.core.project)" | \
        fzf --prompt="Select gcloud config: " \
            --header="NAME   ACTIVE   ACCOUNT   PROJECT" | \
        awk '{print $1}')

    if test -n "$config"
        gcloud config configurations activate $config
    end
end
