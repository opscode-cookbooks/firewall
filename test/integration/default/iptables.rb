# these tests only for redhat with iptables
expected_rules = [
  # we included the .*-j so that we don't bother testing comments
  /-A INPUT -i lo .*-j ACCEPT/,
  /-A INPUT -p icmp .*-j ACCEPT/,
  /-A INPUT -m state --state RELATED,ESTABLISHED .*-j ACCEPT/,
  /-A INPUT -p tcp -m tcp -m multiport --dports 22 .*-j ACCEPT/,
  /-A INPUT -p tcp -m tcp -m multiport --dports 2200,2222 .*-j ACCEPT/,
  /-A INPUT -p tcp -m tcp -m multiport --dports 1234 .*-j DROP/,
  /-A INPUT -p tcp -m tcp -m multiport --dports 1235 .*-j REJECT --reject-with icmp-port-unreachable/,
  /-A INPUT -p tcp -m tcp -m multiport --dports 1236 .*-j DROP/,
  /-A INPUT -p vrrp .*-j ACCEPT/,
  %r{-A INPUT -s 192.168.99.99(/32)? -p tcp -m tcp .*-j REJECT --reject-with icmp-port-unreachable},
]

expected_ipv6_rules = [
  /-A INPUT -i lo .*-j ACCEPT/,
  /-A INPUT -p icmp .*-j ACCEPT/,
  %r{-A INPUT( -s ::/0 -d ::/0)? -m state --state RELATED,ESTABLISHED .*-j ACCEPT},
  /-A INPUT.* -p ipv6-icmp .*-j ACCEPT/,
  %r{-A INPUT( -s ::/0 -d ::/0)? -p tcp -m tcp -m multiport --dports 22 .*-j ACCEPT},
  %r{-A INPUT( -s ::/0 -d ::/0)? -p tcp -m tcp -m multiport --dports 2200,2222 .*-j ACCEPT},
  %r{-A INPUT( -s ::/0 -d ::/0)? -p tcp -m tcp -m multiport --dports 1234 .*-j DROP},
  %r{-A INPUT( -s ::/0 -d ::/0)? -p tcp -m tcp -m multiport --dports 1235 .*-j REJECT --reject-with icmp6-port-unreachable},
  %r{-A INPUT( -s ::/0 -d ::/0)? -p tcp -m tcp -m multiport --dports 1236 .*-j DROP},
  %r{-A INPUT( -s ::/0 -d ::/0)? -p vrrp .*-j ACCEPT},
  %r{-A INPUT -s 2001:db8::ff00:42:8329/128( -d ::/0)? -p tcp -m tcp -m multiport --dports 80 .*-j ACCEPT},
]

describe command('iptables-save') do
  its(:stdout) { should match(/COMMIT/) }

  expected_rules.each do |r|
    its(:stdout) { should match(r) }
  end

  # we try to get firewall to add this rule twice, but we expect to see it once!
  duplicate_rule1 = '-A INPUT -p tcp -m tcp -m multiport --dports 1111 -m comment --comment "same comment" -j ACCEPT'
  its(:stdout) { should count_occurences(duplicate_rule1, 1) }

  duplicate_rule2 = '-A INPUT -p tcp -m tcp -m multiport --dports 5431,5432 -m comment --comment "same comment" -j ACCEPT'
  its(:stdout) { should count_occurences(duplicate_rule2, 1) }
end

describe command('ip6tables-save') do
  its(:stdout) { should match(/COMMIT/) }

  expected_ipv6_rules.each do |r|
    its(:stdout) { should match(r) }
  end
end

describe service('iptables') do
  it { should be_enabled }
  it { should be_running }
end
