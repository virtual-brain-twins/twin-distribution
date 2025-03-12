## Setting Up an Ubuntu Vagrant Box in VirtualBox - Manual creation

### 1. Install Ubuntu Server in VirtualBox
- Install **Ubuntu Server** (GUI is not needed since Vagrant uses SSH only).
- Set the **hostname, username, and password** to `vagrant`.
- During installation, select **OpenSSH Server**.

### 2. Initial Configuration After Installation
Once logged in as `vagrant`, execute the following commands:

``` 
sudo -i
```

This logs you in as the root user.

``` 
visudo -f /etc/sudoers.d/vagrant
```

Add the following line to grant `vagrant` passwordless sudo access:

```plaintext
vagrant ALL=(root) NOPASSWD: ALL
```

``` 
usermod -aG sudo vagrant  # Add vagrant user to sudo group
su - vagrant  # Switch to vagrant user
chmod 700 .ssh  # Set correct permissions for .ssh directory
```

### 3. Add Vagrant Public Key
``` 
wget -O .ssh/authorized_keys https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub
chmod 600 .ssh/authorized_keys  # Set correct permissions for authorized_keys
```

### 4. Clean History
``` 
history -c  # Clear history
history -w  # Write the cleaned history
exit  # Return to root shell
```

### 5. Install Required Packages
``` 
apt install -y dkms linux-headers-$(uname -r) build-essential
```

### 6. Install VirtualBox Guest Additions (the version must be the same as the one from VirtualBox)
Power off the VM:
``` 
poweroff
```

On your **local machine**, download and attach the VirtualBox Guest Additions ISO:
- **Download ISO:** [VirtualBox Guest Additions](https://download.virtualbox.org/virtualbox/7.1.6/VBoxGuestAdditions_7.1.6.iso)
- Attach the ISO to the Virtual Machine.

Power up the VM and execute the following commands as `vagrant`:

``` 
sudo -i
mount /dev/cdrom /mnt  # Mount the CDROM
/mnt/VBoxLinuxAdditions.run  # Install Linux Additions
poweroff  # Shutdown the VM
```

### 7. Package the Vagrant Box
On your **local machine**, navigate to the folder where the Vagrant box will be created:
``` 
cd path/to/folder
```

Run the following commands:
``` 
vagrant package --base vbt_ubuntu --output vbt_ubuntu.box  # Create a Vagrant box
vagrant box add vbt_ubuntu.box --name vbt/ubuntu  # Add the box to local Vagrant
vagrant box list  # Verify if the box was added
```

### 8. Using the Custom Vagrant Box
In your `Vagrantfile`, specify the box:

```ruby
config.vm.box = "vbt/ubuntu"
```

### 9. Optional: For a new VBT Vagrant box release, the following command generated the checksum for the generated .box file:

Powershell: 
````powershell
Get-FileHash "C:\path\to\vbt_ubuntu.box" -Algorithm SHA256
````

Bash: 
````powershell
sha256sum /mnt/c/path/to/vbt_ubuntu.box
````


## Setting Up an Ubuntu Vagrant Box in VirtualBox - Automate creation using Packer

``` 
packer build ubuntu.pkr.hcl
```

