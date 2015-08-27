_trans_port="9040"
_dns_port="5353"
iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports $_dns_port
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

_non_tor="192.168.1.0/24 192.168.0.0/24"
for _clearnet in $_non_tor 127.0.0.0/8; do
  iptables -t nat -A OUTPUT -d $_clearnet -j RETURN
  iptables -A OUTPUT -d $_clearnet -j ACCEPT
done

iptables -t nat -A OUTPUT -p tcp --syn -j REDIRECT --to-ports $_trans_port
