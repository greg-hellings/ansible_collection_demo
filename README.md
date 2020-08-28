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

See the output [here](https://htmlpreview.github.io/?https://github.com/greg-hellings/ansible_collection_demo/01_SystemSetup.html)
for the playbook run.

## Login to the system and clone the repositories

```bash
vagrant ssh
cd ansible_collections/oasis_roles/
git clone https://github.com/oasis-roles/ansible_collection_system system
git clone https://github.com/oasis-roles/ansible_collection_osp osp
```

The role oasis\_roles.system is now ready for use. See the steps executed [here](https://htmlpreview.github.io/?https://github.com/greg-hellings/ansible_collection_demo/02_CloneRepos.html)
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

Observe that the results can be seen [here](https://htmlpreview.github.io/?https://github.com/greg-hellings/ansible_collection_demo/03_RunPlaybook.hml)

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

Once again, you can see the results [here](https://htmlpreview.github.io/?https://github.com/greg-hellings/ansible_collection_demo/04_CreateCollection.hml)

## BONUS ROUND!
### Adding existing roles from Github to the collection
