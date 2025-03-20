# Ansible Install

<img src="https://upload.wikimedia.org/wikipedia/commons/2/24/Ansible_logo.svg" alt="Ansible Logo" width="72px">



This repo provides a simple way to set up OpenSSH and configure public keys on multiple Ubuntu machines to prepare them for Ansible automation.

## Features
✅ Installs OpenSSH on target Ubuntu machines.  
✅ Adds your public SSH keys for seamless Ansible access.  
✅ Includes a sample `hosts.txt` file for Ansible inventory.  

---

## Step 1: Clone the Repository

To get started, clone this repository to your local machine:

```bash
git clone https://github.com/michaelbolanos/ansible-install.git
cd ansible-install/scripts
```

---

## Step 2: Configure Your Hosts File

Edit the `hosts.txt` file to include the IP addresses or hostnames of the machines you want to manage with Ansible:

```plaintext
192.168.1.100
192.168.1.101
192.168.1.102
```

---

## Step 3: Install OpenSSH via Curl or Wget

Run the following command on each Ubuntu machine to install OpenSSH.

### Using `curl`
```bash
curl -sSL https://raw.githubusercontent.com/michaelbolanos/ansible-install/main/scripts/install_ssh.sh | bash
```

### Using `wget`
```bash
wget -qO- https://raw.githubusercontent.com/michaelbolanos/ansible-install/main/scripts/install_ssh.sh | bash
```

---

## Step 4: Copy SSH Keys to Remote Machines

To enable passwordless SSH authentication, use the provided `ssh-keys.sh` script. Run this from your control machine:

```bash
bash ssh-keys.sh
```

This script will:

```bash
# Copy SSH public key to each host in hosts.txt
while read -r host; do
    ssh-copy-id -i ~/.ssh/id_rsa.pub "ubuntu@$host"
done < hosts.txt
```

- Copies your SSH public key to each host listed in `hosts.txt`
- Ensures secure key-based authentication

---

## Step 5: Verify SSH Access

Once keys are copied, test SSH access to the remote machines:

```bash
ssh ubuntu@192.168.1.100
```

If login works without a password prompt, you're ready to use Ansible! 🎉

---

## Next Steps: Set Up Ansible

Now that SSH is configured, install Ansible and begin automating your infrastructure.

```bash
sudo apt update && sudo apt install -y ansible
```

You can now create an Ansible inventory file and start managing your machines

---

