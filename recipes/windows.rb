#
# Cookbook Name:: aws-ec2-snapshot
# Recipe:: windows
#
#

# If the server isn't using an IAM role we drop the keys passed in through
# the attributes for the node.
if node['aws-ec2-snapshot']['instance_uses_iam_role'] == false
  aws_access_key_id = node['aws-ec2-snapshot']['aws_access_key_id']
  aws_secret_access_key = node['aws-ec2-snapshot']['aws_secret_access_key']
end

# Copy in the files needed for the scripts to function
directory 'C:\ebs-snapshot' do
  action :create
end

cookbook_file 'C:\ebs-snapshot\1-start-ebs-snapshot.ps1' do
  source '1-start-ebs-snapshot.ps1'
  action :create
end

cookbook_file 'C:\ebs-snapshot\2-run-backup.cmd' do
  source '2-run-backup.cmd'
  action :create
end

template 'C:\ebs-snapshot\3-ebs-snapshot.ps1' do
  source '3-ebs-snapshot.erb'
  variables(
    :aws_access_key_id => "$env:AWS_ACCESS_KEY_ID = \"#{aws_access_key_id}\"",
    :aws_secret_access_key => "$env:AWS_SECRET_ACCESS_KEY = \"#{aws_secret_access_key}\"",
    :ps_aws_access_key_id => "-AccessKey #{aws_access_key_id}",
    :ps_aws_secret_access_key => "-SecretKey #{aws_secret_access_key}",
    :snapshot_retention => node['aws-ec2-snapshot']['days_to_keep_snapshot']
  )
end

# Set up the scheduled task
windows_task 'EC2 EBS Snapshot' do
  user 'SYSTEM'
  command 'powershell -ExecutionPolicy bypass -file C:\\ebs-snapshot\\1-start-ebs-snapshot.ps1'
  run_level :highest
  frequency :daily
  start_time '00:00'
  action :create
end
