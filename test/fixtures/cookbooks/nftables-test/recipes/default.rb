nftables 'default' do
  input_policy 'drop'
  table_ip_nat true
  table_ip6_nat true
end

nftables_rule 'allow loopback' do
  interface 'lo'
  protocol :none
end

nftables_rule 'allow icmp' do
  protocol :icmp
end

nftables_rule 'allow world to ssh' do
  dport 22
  source '0.0.0.0/0'
  command [:log, :accept]
  log_group 0
end

nftables_rule 'allow world to mosh' do
  protocol :udp
  dport 60000..61000
  source '0.0.0.0/0'
end

# allow established connections
nftables_rule 'established' do
  stateful [:related, :established]
  protocol :none # explicitly don't specify protocol
end

# ipv6 needs ICMP to reliably work, so ensure it's enabled if ipv6
nftables_rule 'ipv6_icmp' do
  protocol :'ipv6-icmp'
end

nftables_rule 'ssh22' do
  dport 22
  command [:log, :accept]
  log_prefix 'TEST_PREFIX:'
end

nftables_rule 'ssh2222' do
  dport [2222, 2200]
  command [:log, :counter, :accept]
end

# other rules
nftables_rule 'temp1' do
  dport 1234
  command :drop
end

nftables_rule 'temp2' do
  dport 1235
  command :reject
end

nftables_rule 'addremove' do
  dport 1236
end

nftables_rule 'addremove2' do
  dport 1236
  command :drop
end

nftables_rule 'protocolnum' do
  protocol 112
end

nftables_rule 'prepend' do
  dport 7788
  position 5
end

bad_ip = '192.168.99.99'
nftables_rule "block-#{bad_ip}" do
  source bad_ip
  position 49
  command :reject
end

nftables_rule 'ipv6-source' do
  dport 80
  source '2001:db8::ff00:42:8329'
end

nftables_rule 'range' do
  dport 1000..1100
end

nftables_rule 'array' do
  dport [1234, 5000..5100, '5678']
end

nftables_rule 'RPC Port Range In' do
  dport 5000..5100
  protocol :tcp
  direction :in
end

nftables_rule 'HTTP HTTPS' do
  dport [80, 443]
  protocol :tcp
  direction :out
end

nftables_rule 'dport2433' do
  description 'This should not be included'
  include_comment false
  source '127.0.0.0/8'
  dport 2433
  direction :in
end

nftables_rule 'esp' do
  protocol :esp
end

nftables_rule 'ah' do
  protocol :ah
end

nftables_rule 'esp-ipv6' do
  source '::'
  protocol :esp
end

nftables_rule 'ah-ipv6' do
  source '::'
  protocol :ah
end

nftables_rule 'redirect' do
  direction :pre
  dport 5555
  redirect_port 6666
  command :redirect
end
