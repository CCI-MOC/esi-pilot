# create a "test" project
openstack project create test
# create a user "test" within the "test" project, set the password to "test-password"
openstack user create --project test --password test-password test
# add owner and member role to "test" user
openstack role add --user test --project test owner
openstack role add --user test --project test member

# optional: create a sub-project of "test" project and a sub-project's user
openstack project create --parent test test-subproject
openstack user create --project test-subproject --password test-subproject-password test-subproject
openstack role add --user test --project test-subproject member
openstack role add --user test-subproject --project test-subproject lessee
