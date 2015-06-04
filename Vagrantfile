Vagrant.configure("2") do |config|

  config.vm.box = "centos-6.6-x86_64"
  config.vm.box_url = "https://github.com/tommy-muehle/puppet-vagrant-boxes/releases/download/1.0.0/centos-6.6-x86_64.box"

  config.vm.hostname = "profiler.move-elevator.dev"
  config.vm.network "private_network", ip: "192.168.33.230"

  config.ssh.forward_agent = true
  config.ssh.keep_alive = true
  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"

  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--memory", 1024]
    v.customize ["modifyvm", :id, "--name", "profiler-vm"]
  end

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.manifest_file = "default.pp"
    puppet.module_path = "puppet/modules"
    puppet.hiera_config_path = "hiera/hiera.yaml"
  end

end