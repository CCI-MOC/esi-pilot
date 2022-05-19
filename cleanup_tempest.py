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
