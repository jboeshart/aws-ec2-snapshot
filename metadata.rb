name             'aws-ec2-snapshot'
maintainer       'Jason Boeshart'
maintainer_email 'jason.boeshart@gmail.com'
license          'GPL v2'
description      'Installs/Configures aws-ec2-snapshot'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url       'https://github.com/jboeshart/aws-ec2-snapshot'
supports         'centos'
supports         'rhel'
supports         'fedora'
supports         'windows'
version          '1.0.1'

depends          "windows", ">= 1.37.0"
depends          "awscli", ">= 1.1.1"
