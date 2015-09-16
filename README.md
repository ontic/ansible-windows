# Ansible Windows ![Status](https://img.shields.io/badge/project-maintained-green.svg)

## Introduction

This repository provides a shell provisioning script to bootstrap Ansible from within a Vagrant VM running on Windows.

## Example

```ruby
Vagrant.configure("2") do |config|
  
  config.vm.define "web" do |server|
    
    server.vm.box = "ubuntu/trusty64"
    server.vm.network "private_network", ip: "192.168.66.10"
    server.ssh.forward_agent = true
    
    server.vm.provider "virtualbox" do |box|
      box.name = "example"
      box.memory = 512
      box.cpus = 1
    end
    
    server.vm.provider "vmware_workstation" do |box|
      box.vmx['displayname'] = "example"
      box.vmx["memsize"] = "512"
      box.vmx["numvcpus"] = "1"
    end
    
    if Vagrant::Util::Platform.windows?
      server.vm.provision "shell" do |shell|
        shell.path = "ansible-windows/provision.sh"
        shell.args = "ansible/playbook.yml ansible/hosts"
      end
    else
      server.vm.provision "ansible" do |ansible|
        ansible.playbook = "ansible/playbool.yml"
        ansible.inventory_path = "ansible/hosts"
        ansible.sudo = true
      end
    end
  end
  
end
```

## License

Licensed under the BSD License. See the [LICENSE](/LICENSE) file for details.