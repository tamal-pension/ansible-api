# vagrant plugin install vagrant-aws 
# vagrant up --provider=aws
# vagrant destroy -f && vagrant up --provider=aws
# vagrant rsync-auto

TOPIC_NAME = "pre_playbook_errors"
ACCOUNT_ID = "339712742264"
AWS_REGION = "eu-west-1"
ES_CLUSTER = 'pension-test-#{Etc.getpwuid(Process.uid).name}'
Vagrant.configure("2") do |config|
  config.vm.provision "shell", inline: <<-SHELL  
    set -euxo pipefail
    echo "start vagrant file"
    cd /vagrant
    aws s3 cp s3://resource-pension-stg/get-pip.py - | python3
    echo $PWD
    export VAULT_PASSWORD=#{`op read "op://Security/ansible-vault tamal-pension-stg/password"`.strip!}
    echo "$VAULT_PASSWORD" > vault_password
    if [ -f "main.sh" ]; then
      echo "Local main.sh found. Run the local main.sh script..."
      bash main.sh -r #{AWS_REGION} -e "playbook_name=ansible-elasticsearch discord_message_owner_name=#{Etc.getpwuid(Process.uid).name}" --topic-name #{TOPIC_NAME} --account-id #{ACCOUNT_ID}
    else
      echo "Local main.sh not found. running the main.sh script from the URL..."
      curl -s https://raw.githubusercontent.com/inqwise/ansible-automation-toolkit/master/main_amzn2023.sh | bash -s -- -r #{AWS_REGION} -e "playbook_name=ansible-elasticsearch discord_message_owner_name=#{Etc.getpwuid(Process.uid).name}" --topic-name #{TOPIC_NAME} --account-id #{ACCOUNT_ID}
    fi
    rm vault_password
  SHELL

  config.vm.provider :aws do |aws, override|
  	override.vm.box = "dummy"
    override.ssh.username = "ec2-user"
    override.ssh.private_key_path = "~/.ssh/id_rsa"
    aws.access_key_id             = `op read "op://Security/aws pension-stg/Security/Access key ID"`.strip!
    aws.secret_access_key         = `op read "op://Security/aws pension-stg/Security/Secret access key"`.strip!
    aws.keypair_name = Etc.getpwuid(Process.uid).name
    override.vm.allowed_synced_folder_types = [:rsync]
    override.vm.synced_folder ".", "/vagrant", type: :rsync, rsync__exclude: ['.git/','ansible-galaxy/'], disabled: false
    collection_path = ENV['COMMON_COLLECTION_PATH'] || '~/git/ansible-common-collection'
    override.vm.synced_folder collection_path, '/vagrant/ansible-galaxy', type: :rsync, rsync__exclude: '.git/', disabled: false
    
    aws.region = AWS_REGION
    aws.security_groups = ["sg-077f8d7d58d420467"]
    aws.ami = "ami-0fa86d752d8b7d1ff"
    aws.instance_type = "r6g.medium"
    aws.subnet_id = "subnet-0a5b54a2e357621e5"
    aws.associate_public_ip = true
    aws.iam_instance_profile_name = "bootstrap-role"
    aws.tags = {
      Name: 'vagrant-pension'
    }
  end
end