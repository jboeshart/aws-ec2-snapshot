#
# Cookbook Name:: aws-ec2-snapshot
# Recipe:: default
#
#
#

case node["platform_family"]
when "windows"
  include_recipe 'aws-ec2-snapshot::windows'
else
  include_recipe 'aws-ec2-snapshot::linux'
end
