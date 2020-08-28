# Ansible Collection Demo

## Before You Begin

Before you begin you will need to install [vagrant](http://vagrantup.com),
[vagrant-libvirt](https://github.com/vagrant-libvirt/vagrant-libvirt), and
[ansible](https://github.com/ansible/ansible). After that, you will need to
install the devroles.devel collection in Ansible like such:

`ansible-galaxy collection install devroles.devel`

## Begin

Begin the demo by bringing up the Ansible machine (requires vagrant/libvirt)

`vagrant up --no-provision`

Depending on the speed of your system and the speed of your Internet connection, this
could run for a while.

## Run the playbook to setup the system

`vagrant provision`

See the output [here](https://htmlpreview.github.io/?https://github.com/greg-hellings/ansible_collection_demo/blob/master/01_SystemSetup.html)
for the playbook run.

## Login to the system and clone the repositories

```bash
vagrant ssh
cd ansible_collections/oasis_roles/
git clone https://github.com/oasis-roles/ansible_collection_system system
git clone https://github.com/oasis-roles/ansible_collection_osp osp
```

The role oasis\_roles.system is now ready for use. See the steps executed [here](https://htmlpreview.github.io/?https://github.com/greg-hellings/ansible_collection_demo/blob/master/02_CloneRepos.html)
although it's not really much more than some git clones. Now here is what the home directory looks like
under the ansible\_collections/ folder:

<pre>[vagrant@localhost ~]$ tree ansible_collections/ -L 3
<font color="#0087FF">ansible_collections/</font>
└── <font color="#0087FF">oasis_roles</font>
    ├── <font color="#0087FF">osp</font>
    │   ├── AUTHORS
    │   ├── galaxy.yml
    │   ├── LICENSE
    │   ├── <font color="#0087FF">plugins</font>
    │   ├── README.md
    │   ├── requirements.yml
    │   ├── <font color="#0087FF">roles</font>
    │   ├── <font color="#0087FF">tests</font>
    │   └── tox.ini
    └── <font color="#0087FF">system</font>
        ├── AUTHORS
        ├── galaxy.yml
        ├── Jenkinsfile
        ├── LICENSE
        ├── <font color="#0087FF">plugins</font>
        ├── README.md
        ├── requirements.yml
        ├── <font color="#0087FF">roles</font>
        ├── <font color="#0087FF">tests</font>
        └── tox.ini

9 directories, 13 files</pre>

## Create a sample playbook

```bash
vagrant ssh
cat > playbook.yml << EOD
- hosts: localhost
  roles:
    - oasis_roles.system.users_and_groups
  vars:
    users_and_groups_add_modify_users:
      - name: someuser
EOD
. ~/ansible-venv/bin/activate
ansible-playbook playbook.yml
```

You should now be able to change to the user "someuser" using

```bash
sudo su - someuser
pwd
```

Observe that the results can be seen [here](https://htmlpreview.github.io/?https://github.com/greg-hellings/ansible_collection_demo/blob/master/03_RunPlaybook.html)

## Create a new role or collection

```bash
vagrant ssh
. ~/ansible-venv/bin/activate
cd ansible_collections/
ansible-galaxy collection init --collection-skeleton ~/meta_ansible_collection_template testing.tests
cd testing/tests
git init .
git submodule add https://github.com/oasis-roles/meta_test tests
cd roles
ansible-galaxy init test_role
cd test_role
# Create the tasks for the role
cat > tasks/main.yml << EOD
- name: do the things
  debug:
    msg: I can do all the things!
EOD
# Create a test for the role
cat > molecule/docker/tests/test_null.py << EOD
def test_nothing(host):
    assert host.file("/etc").exists
EOD
cd ../..
```

You have now created your first role inside of a collection! You can test it now with tox-ansible
very easily. (Getting Docker running on Fedora 32 is beyond the scope of this document, but you
can find more about it [here](https://fedoramagazine.org/docker-and-fedora-32/) including a description
of why it does not work out of the box).

```bash
# List all the environments
tox -l
# Run the specific scenario we need
tox -e test_role-docker
```

Once again, you can see the results [here](https://htmlpreview.github.io/?https://github.com/greg-hellings/ansible_collection_demo/blob/master/04_CreateCollection.html)

## BONUS ROUND!
### Adding existing roles from Github to the collection

Before you go farther, you will need to have a clean git tree. This can be done by committing whatever
you have in the collection so far. On the Vagrant VM you will need to set the global git config
with your email and user name before making that commit

```bash
git config --global user.name "Greg Hellings"
git config --global user.email greg.hellings@gmail.com
```

Say I have a role that already lives somewhere that I want to move into my new collection. Is
there a way to do that efficiently? Well, since you asked! Some of these changes are very specific
to our OASIS collections, and each role will require manually checking which parts of the molecule.yml
file are edited, etc. However, the process is relatively straightforward and some parts of it are
automated with the sanitize\_role.sh file that lives in this repository.

```bash
. ~/ansible-venv/bin/activate
cd ~/ansible_collections/testing/tests
git init . && git add . && git commit -m "First commit of test collection"
# This command requires no uncommited changes
git subtree add -P roles/users_and_groups https://github.com/oasis-roles/users_and_groups master
# Removes lots of shared things all our roles have
/vagrant/sanitize_role.sh
# Edit the molecule files
vi roles/users_and_groups/molecule/docker/molecule.yml
# Remove things like the Github/Travis badge from the README.md file
vi roles/users_and_groups/README.md
# For MOST roles, these will be redundant, same with the ones in the openstack scenarios
git rm roles/users_and_groups/molecule/docker/{create.yml,destroy.yml,Dockerfile.j2}
# For this particular role, this file is empty, and that causes breakages
git rm roles/users_and_groups/molecule/docker/tests/test_null.py
tox -l
tox -e users_and_groups-docker
# Shows that all the history of the existing role lives in this repository, now
git log
```

You can see a walkthrough of this by checking out my recording of it. As always, you can find it
[here](https://htmlpreview.github.io/?https://github.com/greg-hellings/ansible_collection_demo/master/blob/05_ImportRole.html).
