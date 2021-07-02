# MOMOD

**This a WIP repo.**
**Currently Working**

- Sets up user accounts (with a great zsh prompt).
- Configures hostname, timezone, unattended upgrades.

Going backwards a little at the moment. Stripping out some legacy functionality I'd added out of habit and modernizing.

**WIP**
- Replace geerlingguy.firewall role with something built in to Ubuntu hirsute server, either UFW or Firewalld.

**Next**
- Hardens ssh, adds a firewall installs fail2ban.
- Installs nginx webserver
- Installs and sets up a send-only configuration of postfix.
- Can set up Letsencrypt wildcard certificates via Gandi DNS
- Installs Podman
- Can launch a Miniflux feed reader podman pod
- Set up up a reverse proxy for https for all services and easy to remember URLs eg miniflux.momod.com
- Set up wireguard
- Set up a vpn connection between host and server
- Host containers inside a private network only accessible via vpn

---------------------

MOMOD = **M**aster **O**f **M**y **O**wn **D**ata

Ansible based self-hosting of web sites and web apps with a focus on keeping things as simple as possible.

Currently:

- Only Ubuntu Server is supported, currently Ubuntu 21.04 Hirsute Hippo but will stabilise on 22.04 LTS once it becomes available.
- Lets Encrypt wildcard DNS support but only via a Gandi.net registered Domain.
- Monolithic Ansible task files unless it really is useful to split tasks into sub-files.
- Prefer tweaking rather than templating core system config files (so we don't overwrite upstream changes)

Currently testing with Qemu VM and a Vultr VPS. **(eventually)** Running on Linode VPS and Hetzner VPS.
(Note: Vultr have Ubuntu 21.04 images available but don't automatically set up your ssh key in root's authorized_keys, you'll  need to password login and set that up manually before running Momod roles.)

## Getting Started

### Dependencies

There are some dependencies required for the Ansible control host you install Momod on:

- [Ansible](https://github.com/ansible/ansible) obviously.
- Wireguard, with public and private keys generated (detailed below)
- Optionally the [Meslo Nerd Font](https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k) if you use Zsh. For more information on the Zsh configuration see "Momod Shell Configuration" below.

### Project Layout

A container directory containing two directories with MOMOD checked out in /momod and your own configuration in /local.

```bash
/my-momod
|-/local
|-/momod
```

#### An explanation of Project Layout

By default no local configuration or 'secrets' are present in the /momod directory. Hopefully this keeps development easy and frictionless as well as allowing easy updates (just 'git pull').

Passwords, crypotographic keys and other configuration you don't want to commit to a public VCS repository should all be in the /local directory. I leave it to the user to decide how you will keep this information backed up and if desired under version control.

(My personal approach is to init a git repository in /local but not add a remote and rely on my muliple backup types to guard against disk failure. This doesn't allow for easy sync between different devices however.)


### Setup

Create a containing directory (named as you choose) with children like so:

```bash
mkdir -p my-momod/local/{fetched,files,secrets}
```

cd into 'my-momod' and clone this repository:

```bash
cd my-momod
git clone https://github.com/adrinux/momod.git
```

Copy the inventory file template (or create your own) to local:

```bash
cp momod/templates/hosts.ini.template local/hosts.ini
```

Edit hosts.ini and add your hosts (there are two servers defined for VMs set up with [Sausiq](https://github.com/adrinux/sausiq), feel free to remove those, they're not really useful beyond basic setup). Make sure your new hosts are part of the `[setup]` group as well as any other groups you'd like.

Copy the group_vars and host_vars templates to local:

```bash
cp -r momod/templates/group_vars local/
cp -r momod/templates/host_vars local/
```

Rename `server.example.com.yml` file to match your domain name or in the case of a local VM use the IP address. For example to match the qemu VMs listed in the example `hosts.ini`  create `local/host_vars/192.168.122.21.yml` and `local/host_vars/192.168.122.22.yml`. For a new remote server it may be necessary to use the public IP until your DNS resolves to the new server.

Edit both template files to fit your environment - user name, user password hash, ssh keys, server name and IP etc. The templates are largely self-documenting. You will need to add an IPV6 address in addition to the IPV4.

The user account passwords in the vars file must be SHA-512 ($6$) hashes. To generate a password hash via the linux cli you'll need the mkpasswd application, usually a part of the debian whois package. With that installed:

```bash
mkpasswd -m sha-512
```

cd into the momod directory and install roles from Ansible Galaxy and specified Ansible Collections:

```bash
cd momod
ansible-galaxy install -r requirements.yml
```

At this point you should have a directory structure something like this:

```bash
/my-momod
|
|-/local
| |- hosts.ini
| |- /fetched
| |- /files
| |- /group_vars
| |- /host_vars
| |- /secrets
|
|-/momod
| |- /play
| |- /roles
| |- /roles-collections
| |- /roles-galaxy
| |- /templates
```

### Running the setup playbook

Before you run any play manually connect to your server with ssh to answer the authenticity prompt and save the server to known_hosts. You need to know the default user and should have already configured `setup_ansible_user` in your host_vars file for each server. Using the normal default user of root and our example qemu VMs:

```bash
ssh root@192.168.122.21
ssh root@192.168.122.22
```

Check your hosts.ini by listing your hosts. From within the momod directory:

```bash
ansible all --list-hosts
```

Then run the setup playbook:

```bash
ansible-playbook play/setup.yml
```

The setup playbook specifies the `[setup]` group and will only run on hosts in that group.
Once setup has run successfully remove your hosts from setup in hosts.ini.
If you ever wish to rerun setup you'll need to change `setup_ansible_user` to your `ansible_user account`, usually yourself.

### Test SSH login

Your user account (as defined in host_vars/your-host-ip-or-name.yml) should now be set up. Try logging in:

```bash
ssh 192.168.122.21
ssh 192.168.122.22
```

### Run the main playbook

The main playbook is intended to do further setup: update software; automatic software updates; security hardening (sshd, firewall, fail2ban), useful tools etc. On first run this will install a lot of packages - be patient!

```bash
ansible-playbook play/main.yml
```

TODO: Document Postfix related DNS entries (DKIM etc).


## Enabling and Running applications

There is some preparation work to be done.

### Setting up Wireguard on the server

Running Momod's Wireguard roles will set this up automatically. Wireguard keys for the server are generated during a play/main.yml then downloaded and can be found in your-momod/local/files/wireguard/ directory. These are needed for the next step.

### Setting up Wireguard on your client

If you've not previosly set up Wireguard, run these commands on your local Ansible control host (your desktop, laptop etc where you've installed Momod) - from here on referred to as the Wireguard 'client':

```bash
sudo -s
cd /etc/wireguard
umask 077
wg genkey > privatekey
wg pubkey < privatekey > publickey
```
This should leave you with something like this in /etc/wireguard:
```bash
.rw------- 45 root root  4 Jun 14:55  privatekey
.rw------- 45 root root  4 Jun 14:55  publickey
```

(If you've previously set up Wireguard and already have keys I leave it to you to make your setup fit with Momod...)

Copy your client public key into the momod/local directory, location dependen on where you put your momod folder:

```bash
mkdir -p /path-to-your-momod/local/files/wireguard
sudo cp /etc/wireguard/publickey /path-to-your-momod/local/files/wireguard/client-publickey
sudo chown yourself:yourself  /path-to-your-momod/local/files/wireguard/client-publickey
```
Next create a configuration file on your client machine at /etc/wireguard/momod0.conf and add the following contents, replacing with your generated keys as appropriate:

```bash
[Interface]
Address = 10.30.0.2/24
ListenPort = 51820
PrivateKey = CLIENT-PRIVATE-KEY

[Peer]
PublicKey = SERVER-PUBLIC-KEY
AllowedIPs = 10.30.0.0/24
Endpoint = YOUR-SERVER-IP-ADDRESS:51820
```

And a second conf file for our second Wireguard interface:

```bash
[Interface]
Address = 172.30.0.2/24
ListenPort = 51821
PrivateKey = CLIENT-PRIVATE-KEY

[Peer]
PublicKey = SERVER-PUBLIC-KEY
AllowedIPs = 172.30.0.0/24
Endpoint = YOUR-SERVER-IP-ADDRESS:51821
```

Set permissions:

```bash
sudo chmod 600 /etc/wireguard/momod0.conf
sudo chmod 600 /etc/wireguard/momod1.conf
```

Enable and start the Wireguard service on your client:

```bash
sudo systemctl enable wg-quick@momod0
sudo systemctl start wg-quick@momod0
sudo systemctl enable wg-quick@momod1
sudo systemctl start wg-quick@momod1
```

Check Wireguard status:

```bash
sudo wg
```

This will show the server details but not yet any transfered data, since we haven't started Wireguard on the server.

### Applications preparation (& starting Wireguard on the server )

Run the apps-prep play to prepare the filesystem, Wireguard etc for starting web applications.

```bash
ansible-playbook play/apps-prep.yml
```



### Enabling an application service

- Uncomment a service in the enabled_services list of your host_vars/servername.yml
- Run the applications role

Currently running this role is easiest done by uncommenting the podman and applications roles in play/dev.yml and running that play.
TODO Add an applications play for enabling and disabling services

### Stopping and starting application services

Must be carried out as the user running the service. Each service has it's own user. e.g. for Miniflux

```bash
sudo su - miniflux
systemctl --user stop pod-miniflux
```
TODO Probably need a one liner for this sort of task...


## Momod Shell Configuration

The setup play will run the momod-zsh-config role to set up a powerful and pretty Zsh on the server using [Powerlevel10k](https://github.com/romkatv/powerlevel10k), [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search), [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions), [zoxide](https://github.com/ajeetdsouza/zoxide) and [exa](https://github.com/ogham/exa).

This role adds several useful aliases, see `roles/momod-zsh-config/files/dot-zshrc` for details.

## Things to be aware of

### Be careful adding more than 10 users

To run rootless Podman containers requires assigning user namespace uid and gid for Podman to remap uid and gid inside the container to those on the container host. This is done per application, adding lines to /etc/subuid and /etc/subgid files via 'usermod'.

Creating normal user accounts Ubuntu appears to assign uid/gid from 100000 upwards.
Momod assigns uid/gid from 1000000 upwards.
Thus if you add much more than 10 normal user accounts to the server (how many admins do you need?!) you may end up with a collision of uid/gid values.

You can set the values Momod uses to avoid such a collision by redefining the default variables``` SERVICENAME_subuid_base`` set in ```roles/applications/defaults/main.yml```  in your group_vars or host_vars.

## Development

Whilst initial development used Qemu VMs on my Linux desktop PC created with [Sausiq](https://github.com/adrinux/sausiq) this doesn't allow for proper testing of Letsencrypt, Wireguard and so on. So you'll need a VPS (or an actual server...) running Ubuntu 21.04.

There is an Ansible playbook play/dev.yml for testing new roles.


## Sponsor / Donate

I need to set this up.
