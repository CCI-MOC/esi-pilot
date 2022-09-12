import subprocess
import os

p = subprocess.Popen(['openstack', 'project list', '-f', 'json'], stdout=subprocess.PIPE)
out = p.communicate()[0].decode("utf-8")
out_list=list(eval(out))

for d in out_list:
  if d['Name'].startswith('tempest'):
    os.system('openstack project delete %s' % d['Name'])

p1 = subprocess.Popen(['openstack', 'user list', '-f', 'json'], stdout=subprocess.PIPE)
out1 = p1.communicate()[0].decode("utf-8")
out_list1=list(eval(out1))

for d1 in out_list1:
  if d1['Name'].startswith('tempest'):
    os.system('openstack user delete %s' % d1['Name'])

p2 = subprocess.Popen(['openstack', 'port list', '-f', 'json'], stdout=subprocess.PIPE)
out2 = p2.communicate()[0].decode("utf-8")
out_list2=list(eval(out2))

for d in out_list2:
  if d['Name'].startswith('tempest'):
    os.system('openstack port delete %s' % d['Name'])

p3 = subprocess.Popen(['openstack', 'network list', '-f', 'json'], stdout=subprocess.PIPE)
out3 = p3.communicate()[0].decode("utf-8")
out_list3=list(eval(out3))

for d in out_list3:
  if d['Name'].startswith('tempest'):
    os.system('openstack network delete %s' % d['Name'])
