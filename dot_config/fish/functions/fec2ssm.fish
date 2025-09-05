function fec2ssm -d "Select EC2 instance and start SSM session"
    aws ec2 describe-instances | jq -r '.Reservations[].Instances[] | [.InstanceId, .KeyName] | @tsv' | fzf | awk '{print $1}' | xargs aws ssm start-session --target
end
