# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 2.2.0"

module OS
  def OS.windows?
    (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def OS.mac?
    (/darwin/ =~ RUBY_PLATFORM) != nil
  end

  def OS.unix?
    !OS.windows?
  end

  def OS.linux?
    OS.unix? and not OS.mac?
  end
end

# Vagrant file for setting up a build environment for Proton.
if OS.linux?
  cpus = `nproc`.to_i
  # meminfo shows KB and we need to convert to MB
  memory = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 2
elsif OS.mac?
  cpus = `sysctl -n hw.physicalcpu`.to_i
  # sysctl shows bytes and we need to convert to MB
  memory = `sysctl hw.memsize | sed -e 's/hw.memsize: //'`.to_i / 1024 / 1024 / 2
else
  cpus = 1
  memory = 1024
  puts "Vagrant launched from unsupported platform."
end
puts "Platform: " + cpus.to_s + " CPUs, " + memory.to_s + " MB memory"

Vagrant.configure(2) do |config|
  #libvirt doesn't have a decent synced folder, so we have to use vagrant-sshfs.
  #This is not needed for virtualbox, but I couldn't find a way to use a
  #different synced folder type per provider, so we always use it.
  config.vagrant.plugins = "vagrant-sshfs"

  config.vm.provider "virtualbox" do |v|
    v.cpus = cpus
    v.memory = memory
  end

  config.vm.provider "libvirt" do |v|
    v.cpus = cpus
    v.memory = memory
    v.random_hostname = true
    v.default_prefix = ENV['USER'].to_s.dup.concat('_').concat(File.basename(Dir.pwd))
  end

  #ubuntu1804-based build VM
  config.vm.define "ubuntu1804", primary: true do |ubuntu1804|

    ubuntu1804.vm.box = "generic/ubuntu1804"

    ubuntu1804.vm.synced_folder "./vagrant_share/", "/vagrant/", create: true, type: "sshfs", sshfs_opts_append: "-o cache=no"
    ubuntu1804.vm.synced_folder ".", "/home/vagrant/wine-ge", id: "wine-ge", type: "rsync", rsync__exclude: ["vagrant_share"]

    ubuntu1804.vm.provision "shell", privileged: "true", inline: <<-SHELL

      #install dependencies

      apt-get update
      apt-get install -y lxd lxd-client

      #allow vagrant user to run lxc containers
      adduser vagrant lxd

      # setup lxc containers
      sudo -u vagrant cat buildbot/preseed | lxd init --preseed
      sudo -u vagrant lxc launch images:ubuntu/bionic/amd64 buildbot-bionic-amd64
      sudo -u vagrant lxc launch images:ubuntu/bionic/i386 buildbot-bionic-i386
      sudo -u vagrant lxc exec buildbot-bionic-amd64 bash $(echo ubuntu | passwd --stdin ubuntu)
      sudo -u vagrant lxc exec buildbot-bionic-i386 bash $(echo ubuntu | passwd --stdin ubuntu)


    SHELL
  end
end
