include_recipe 'chef-sugar'
include_recipe 'firewall'

firewall 'default' do
  action :install
end

firewall_rule 'ssh22' do
  port 22
  command :allow
end

firewall_rule 'ssh2222' do
  port [2222, 2200]
  command :allow
end

firewall_rule 'compile' do
  port 777
  command :allow
  ensure_applied true
  action :nothing # has no effect with ensure_applied
end

# other rules
firewall_rule 'temp1' do
  port 1234
  command :deny
end

firewall_rule 'temp2' do
  port 1235
  command :reject
end

firewall_rule 'addremove' do
  port 1236
  command :allow
  only_if { rhel? } # don't do this on ufw, will reset ufw on every converge
end

firewall_rule 'addremove2' do
  port 1236
  command :deny
end

firewall_rule 'protocolnum' do
  protocol 112
  command :allow
  only_if { rhel? } # debian ufw doesn't support protocol numbers
end

firewall_rule 'prepend' do
  port 7788
  position 5
end

# something to check for duplicates
(0..1).each do |i|
  firewall_rule "duplicate#{i}" do
    port 1111
    command :allow
    description 'same comment'
  end

  firewall_rule "duplicate#{i}" do
    port [5432, 5431]
    command :allow
    description 'same comment'
  end
end

bad_ip = '192.168.99.99'
firewall_rule "block-#{bad_ip}" do
  source bad_ip
  position 49
  command :reject
end

firewall_rule 'ipv6-source' do
  port 80
  source '2001:db8::ff00:42:8329'
  command :allow
end

firewall_rule 'range' do
  port 1000..1100
  command :allow
end

firewall_rule 'array' do
  port [1234, 5000..5100, '5678']
  command :allow
end
