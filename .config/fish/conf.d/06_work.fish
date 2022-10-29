# https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
set -g USE_GKE_GCLOUD_AUTH_PLUGIN True
# https://cloud.google.com/iap/docs/using-tcp-forwarding#increasing_the_tcp_upload_bandwidth
set -g CLOUDSDK_PYTHON_SITEPACKAGES 1

function obct2utc
  set t (math 1514764800 + $argv[1])
  if is_linux
    date -d "@"$t
  end
  if is_mac
    date -r $t
  end
end
