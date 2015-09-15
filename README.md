aws-ec2-snapshot Cookbook
===========================
Chef cookbook for installing the aws-ec2-snapshot functionality on both Windows and Linux. This is based on the great set of scripts from [Casey Labs](https://github.com/CaseyLabs) and will be kept as in-sync as possible with their scripts to keep feature parity.

This can use either an instance IAM role or specified keys from an IAM user to handle the backups. It is, however, **strongly** recommended that an instance IAM role is used to provide proper security and reduce the risk of keys being exposed.

By default, snapshots are retained for 7 days before being deleted. This is configureable via the days_to_keep_snapshot attribute.

Requirements
------------
#### Cookbook Dependencies
- `awscli` - Handles the AWS CLI installation.
- `windows` - Needed for Windows things.

### Platforms
- Centos 6.x
- Centos 7.x
- Amazon Linux
- Windows 2012 R2
- This likely works on other Linux distros and versions of Windows, but hasn't been officially tested

Recipes
-------
#### aws-ec2-snapshot::default
Determines the platform of the system and runs the appropriate recipe (Windows or Linux)

#### aws-ec2-snapshot::linux
- Creates the backerupper user.
- Configures the AWS CLI tools with the backerupper AWS credentials only if not using an IAM instance role. Note that this is not determined dynamically, it's specified in the attributes of the node.
- Drops in the bash script to handle the backups.
- Creates a crontab entry for the backerupper user.

#### aws-ec2-snapshot::windows
- Installs the scripts for the backups to c:\ebs-snapshot.
- If instance_uses_iam_role is false, the script will put the specified IAM keys in the powershell script so that it will run successfully.
- Creates a scheduled task to run the backup. The scheduled task runs under the SYSTEM account and is scheduled to kick off at midnight server time.

Attributes
----------
- `node['aws-ec2-snapshot']['instance_uses_iam_role']` - Set to false if the server was not built with an IAM role that with the policies required. Defaults to true.
- `node['aws-ec2-snapshot']['aws_access_key_id']` - Specifies the AWS access key ID for the account with permissions. Not used if IAM role is set to true.
- `node['aws-ec2-snapshot']['aws_secret_access_key']` - Specifies the AWS secret access key for the account with permissions. Not used if IAM role is set to true.
- `node['aws-ec2-snapshot']['days_to_keep_snapshot']` - Specifies the number of days to keep the snapshot.
- `node['aws-ec2-snapshot']['region']` - The AWS region that the server is in. Not used if IAM role is set to true and is only used in the Linux recipe.

Usage
-----
Include the aws-ec2-snapshot cookbook in your run list.

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[aws-ec2-snapshot]"
  ]
}
```

IAM Role Requirements
---------------------
For this script to work you either need to have an instance IAM role with the following policy attached, or an IAM user with the following policy attached.

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1426256275000",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSnapshot",
                "ec2:CreateTags",
                "ec2:DeleteSnapshot",
                "ec2:DescribeSnapshots",
                "ec2:DescribeVolumes",
                "ec2:DescribeInstances"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```

License
-------
This software is licensed under the GNU General Public License v2.0.
