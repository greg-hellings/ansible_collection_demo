Vagrant.configure("2") do |config|
  config.vm.box = "greg-hellings/fedora-32-x86_64"
  config.vm.provider :libvirt do |libvirt, override|
    libvirt.memory = 4096
    libvirt.cpus = 2
  end
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbook.yml"
  end
end
