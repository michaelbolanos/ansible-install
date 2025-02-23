import os
import subprocess

HOSTS_FILE = "hosts.txt"

def check_ansible():
    """Check if Ansible is installed and display the version."""
    try:
        result = subprocess.run(["ansible", "--version"], capture_output=True, text=True, check=True)
        print("✅ Ansible is installed:\n", result.stdout.split("\n")[0])
    except FileNotFoundError:
        print("❌ Ansible is NOT installed. Install it using: sudo apt update && sudo apt install -y ansible")

def list_hosts():
    """Read and list hosts from the hosts file."""
    if not os.path.exists(HOSTS_FILE):
        print(f"❌ Hosts file '{HOSTS_FILE}' not found.")
        return []

    with open(HOSTS_FILE, "r") as file:
        hosts = [line.strip() for line in file if line.strip()]
    
    if hosts:
        print("📜 Hosts listed in the file:")
        for host in hosts:
            print(f"  - {host}")
    else:
        print("⚠️ No hosts found in the file.")
    
    return hosts

def verify_ssh_access(hosts):
    """Verify SSH access to each host."""
    print("\n🔄 Checking SSH access to hosts...\n")
    for host in hosts:
        try:
            result = subprocess.run(["ssh", "-o", "BatchMode=yes", f"ubuntu@{host}", "echo SSH_OK"], 
                                    capture_output=True, text=True, timeout=5)
            if "SSH_OK" in result.stdout:
                print(f"✅ SSH access successful: {host}")
            else:
                print(f"⚠️ SSH access failed: {host}")
        except subprocess.TimeoutExpired:
            print(f"⏳ Timeout: SSH access failed for {host}")
        except Exception as e:
            print(f"❌ Error checking {host}: {e}")

if __name__ == "__main__":
    print("🔧 Running Admin Tasks...\n")
    
    check_ansible()
    hosts = list_hosts()
    
    if hosts:
        verify_ssh_access(hosts)

    print("\n✅ Admin tasks completed.")
