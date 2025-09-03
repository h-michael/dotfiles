function fecse -d "Select ECS container and execute command"
  set CLUSTER_ARN (aws ecs list-clusters | jq -r '.clusterArns[]' | fzf)
  set SERVICE_ARN (aws ecs list-services --cluster $CLUSTER_ARN | jq -r '.serviceArns[]' | fzf)
  set SERVICE_NAME (aws ecs describe-services --cluster $CLUSTER_ARN --services $SERVICE_ARN | jq -r '.services[] | .serviceName')
  set TASK_ARN (aws ecs list-tasks --cluster $CLUSTER_ARN --service-name $SERVICE_NAME | jq -r '.taskArns[]' | fzf)
  set CONTAINER_NAME (aws ecs describe-tasks --cluster $CLUSTER_ARN --tasks $TASK_ARN | jq -r '.tasks[] | .containers[] | .name' | fzf)
  aws ecs execute-command --cluster $CLUSTER_ARN --task $TASK_ARN --container $CONTAINER_NAME --interactive --command "/bin/bash"
end