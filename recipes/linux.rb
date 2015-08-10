#
# Cookbook Name:: aws-ec2-snapshot
# Recipe:: linux
#

# Install wget
package 'wget' do
  action :install
end

# Creat the backerupper user
user 'backerupper' do
  supports :manage_home => true
  comment 'User for EC2 snapshots'
  uid 5555
  home '/home/backerupper'
  shell '/bin/bash'
end

# Configure the AWS CLI tools with the backerupper AWS credentials (if not using an IAM instance role), may not have to do this
# if it's already taken care of in the awscli-cookbook installation

# Drop in the bash script
directory '/opt/aws' do
  owner 'backerupper'
  group 'backerupper'
  mode '755'
  action :create
end

template '/opt/aws/ebs-snapshot.sh' do
  source 'ebs-snapshot.erb'
  owner 'backerupper'
  mode '755'
  variables(
    :snapshot_retention => node['aws-ec2-snapshot']['days_to_keep_snapshot']
  )
end

# Create a crontab entry for the backerupper user
cookbook_file '/var/spool/cron/backerupper' do
  source 'backerupper'
  owner 'backerupper'
  group 'backerupper'
  mode '600'
  action :create
end

# If the system isn't configured to use an IAM role we need to copy in the
# configuration for the AWS CLI in order for things to work properly.
if node['aws-ec2-snapshot']['instance_uses_iam_role'] == false
  # Create the directory for the aws config
  directory '/home/backerupper/.aws' do
    owner 'backerupper'
    group 'backerupper'
    mode '770'
    action :create
  end
  # Create the credentials file
  template '/home/backerupper/.aws/credentials' do
    source 'credentials.erb'
    owner 'backerupper'
    group 'backerupper'
    mode '770'
    variables(
      :aws_access_key_id => node['aws-ec2-snapshot']['aws_access_key_id'],
      :aws_secret_access_key => node['aws-ec2-snapshot']['aws_secret_access_key']
    )
  end
  # Create the config file
  template '/home/backerupper/.aws/config' do
    source 'config.erb'
    owner 'backerupper'
    group 'backerupper'
    mode '770'
    variables(
      :region => node['aws-ec2-snapshot']['region']
    )
  end
end

# Touch the log file and give it permissions if it doesn't exist

file '/var/log/ebs-snapshot.log' do
  owner 'backerupper'
  mode '775'
  action :create
end
