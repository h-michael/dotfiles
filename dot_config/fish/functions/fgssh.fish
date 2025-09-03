function fgssh -d "SSH to selected GCP instance"
  eval (gcloud compute instances list --format="table[no-heading] (name,zone,status)" | fzf | awk '{printf "gcloud compute ssh \"%s\" --zone \"%s\" --tunnel-through-iap", $1, $2}')
end