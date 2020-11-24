# MOMOD

**This a WIP repo. Don't try to use it yet!**

MOMOD = <u>M</u>aster <u>O</u>f <u>M</u>y <u>O</u>wn <u>D</u>omain

Ansible based self-hosting of web sites and web apps with a focus on keeping things simple.

Currently:

- Only Ubuntu Server is supported.
- Lets Encrypt wildcard DNS support but only via a Gandi.net registered Domain
- Monolithic Ansible task files unless it really is useful to split tasks into sub-files.

Tested with Qemu. Running on Linode VPS and Hetzner VPS.

## Getting Started

Clone this repository and cd into it:
```
git clone https://github.com/adrinux/momod.git
cd momod
```

Copy the inventory file:

```
cp templates/hosts.ini.template hosts.ini
```

Edit the inventory file and add your hosts (there are two servers defined for VMs set up with [Sausiq](https://github.com/adrinux/sausiq), feel free to modify or remove those.)


Install roles from Ansible Galaxy:

```
ansible-galaxy install -r requirements.yml

```

TODO Add and fill host vars
TODO Fill out user account data
TODO Run setup role
TODO Run main role

## An explanation of Project Layout


## Development

It's useful to use a local virtual machine for development (and for practice runs). Personally I use Qemu on my Linux desktop PC. For an easy way to get a Qemu VM of an Ubuntu Server cloud image up and runnig see my [Sausiq](https://github.com/adrinux/sausiq) project.


## Sponsor / Donate
I need to set this up.gws
