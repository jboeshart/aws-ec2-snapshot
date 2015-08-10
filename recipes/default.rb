#
# Cookbook Name:: aws-ec2-snapshot
# Recipe:: default
#
#
#

case node["platform_family"]
when "rhel"
  include_recipe 'aws-ec2-snapshot::linux'
when "windows"
  include_recipe 'aws-ec2-snapshot::windows'
end
