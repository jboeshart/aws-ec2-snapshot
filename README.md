# aws-ec2-snapshot

Chef cookbook for installing the aws-ec2-snapshot functionality on both Windows and Linux. This is based on the great set of scripts from [Casey Labs](https://github.com/CaseyLabs) and will be kept as in-sync as possible with their scripts to keep feature parity.

This can use either an instance IAM role or specified keys from an IAM user to handle the backups. It is, however, **strongly** recommended that an instance IAM role is used to provide proper security and reduce the risk of keys being exposed.

By default, snapshots are retained for 7 days before being deleted. This is configureable via the days_to_keep_snapshot attribute.

Requires the awscli-cookbook to handle the AWS CLI installation. Ensure that it's in the runlist of the system in question.

Curently supported on the following platforms, though it will likely work on others and should work on most Fedora-based distros:
- Centos 6.5
- Centos 6.6
- Windows 2008 R2
- Windows 2012 R2

Enhancements will be made to future versions to support other Linux flavors. 

## Attributes:
- instance_uses_iam_role: Set to false if the server was not built with an IAM role that with the policies required. Defaults to true.
- aws_access_key_id: Specifies the AWS access key ID for the account with permissions. Not used if IAM role is set to true.
- aws_secret_access_key: Specifies the AWS secret access key for the account with permissions. Not used if IAM role is set to true.
- days_to_keep_snapshot: Specifies the number of days to keep the snapshot.
- region: The region that the server is in. Not used if IAM role is set to true and is only used in the Linux recipe.

## What It Does
### Linux:
- Creates the backerupper user.
- Configures the AWS CLI tools with the backerupper AWS credentials only if not using an IAM instance role. Note that this is not determined dynamically, it's specified in the attributes of the node.
- Drops in the bash script to handle the backups.
- Creates a crontab entry for the backerupper user.

### Windows:
- Installs the scripts for the backups to c:\ebs-snapshot.
- If instance_uses_iam_role is false, the script will put the specified IAM keys in the powershell script so that it will run successfully.
- Creates a scheduled task to run the backup. The scheduled task runs under the SYSTEM account and is scheduled to kick off at midnight server time.

## IAM Role Requirements:
For this script to work you either need to have an instance IAM role or an IAM user with the following policy attached. Again, if you can use an instance role, that's recommended.

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
