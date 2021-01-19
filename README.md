# MOMOD

**This a WIP repo. Don't try to use it yet!**

MOMOD = <u>M</u>aster <u>O</u>f <u>M</u>y <u>O</u>wn <u>D</u>omain

Ansible based self-hosting of web sites and web apps with a focus on keeping things simple.

Currently:

- Only Ubuntu Server is supported.
- Lets Encrypt wildcard DNS support but only via a Gandi.net registered Domain
- Monolithic Ansible task files unless it really is useful to split tasks into sub-files.
- Prefer tweaking rather than templating core system config files (so we don't overwrite upstream changes)

Tested with Qemu. Running on Linode VPS and Hetzner VPS.

## Getting Started

### Project Layout

A container directory containing two directories with MOMOD checked out in /momod and your own configuration in /local.
```
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
```
mkdir -p my-momod/local/{fetched,files,secrets}
```
cd into 'my-momod' and clone this repository:
```
cd my-momod
git clone https://github.com/adrinux/momod.git
```

Copy the inventory file template (or create your own) to local:

```
cp momod/templates/hosts.ini.template local/hosts.ini
```

Edit the inventory file and add your hosts (there are two servers defined for VMs set up with [Sausiq](https://github.com/adrinux/sausiq), feel free to modify or remove those.)

Copy the group_vars and host_vars templates to local:
`
cp -r momod/templates/group_vars local/
cp -r momod/templates/host_vars local/
`
Edit both template files to fit your environment - user name, ssh keys, server name and IP etc.

cd into the momod directory and install roles from Ansible Galaxy and specified Ansible Collections:

```
cd momod
ansible-galaxy install -r requirements.yml
```

At this point you should have a directory structure something like this:
```
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
- TODO Run setup play
- TODO Run main role

## Development

It's useful to use a local virtual machine for development (and for practice runs). Personally I use Qemu on my Linux desktop PC. For an easy way to get a Qemu VM of an Ubuntu Server cloud image up and runnig see my [Sausiq](https://github.com/adrinux/sausiq) project.


## Sponsor / Donate
I need to set this up.
