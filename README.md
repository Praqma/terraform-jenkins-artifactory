# Terraform your own cyber-dojo on AWS


## Step - Get your aws keys

Download your private key and put it in a folder ssh/mykey.pem

## Step - Build the images

    packer build -machine-readable packer.json

## Step - create a `terraform.tfvars` file

The contents of the file should look like this:

    aws_key_path = "ssh/mykey.pem"
    aws_key_name = "cyberdojo-key"

And the  AWS_ACCESS_KEY and AWS_SECRET_KEY should be availble in the environment.

## Step - run the terraform

    terraform plan
    terraform apply

## Step - Set up Jenkins

Get the initial admin password:

    ssh -i ssh/cyberdojo.pem ubuntu@<PUBLIC_IP> docker exec remotescripts_jenkins_1 cat /var/jenkins_home/secrets/initialAdminPassword

Then setup jenkins with an Admin user and default plugins.

Add a slave on the machine if needed. Install Self-Organizing Swarm Plug-in Modules plugin on the jenkins master then run:

    # Install JRE 8
    sudo apt-get install default-jre
    # Install Self-Organizing Swarm Plug-in Modules plugin
    curl -O  https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/3.4/swarm-client-3.4.jar
    java -jar swarm-client-3.4.jar -username slave_user -password slave_pwd -sslFingerprints " " -master http://localhost:8080 &



## Step - Set up artifactory

Browse to the artifactory server in the browser and set up admin user.

## Step - destroy your server

    terraform destroy
