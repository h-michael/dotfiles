# ssh to ec2 instance
function fsec2 -d "SSH to selected EC2 instance"
    set IP (lsec2 $argv | fzf | awk -F "\t" '{print $2}')
    if [ $status -eq 0 -a "$IP" != "" ]
        echo ">>> SSH to $IP"
        ssh $IP
    end
end
