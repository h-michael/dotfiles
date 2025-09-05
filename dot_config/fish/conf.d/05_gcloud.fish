function grolediff -d "diff between GCP IAM roles"
    diff -y --color \
        (gcloud iam roles describe $argv[1] | psub) \
        (gcloud iam roles describe $argv[2] | psub)
end
