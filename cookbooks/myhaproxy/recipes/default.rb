#
# Cookbook:: myhaproxy
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
all_web_nodes = search('node',"role:web AND chef_environment:#{node.chef_environment}")

haproxy_install 'package' do

end
haproxy_config_global '' do
  chroot '/var/lib/haproxy'
  daemon true
  maxconn 256
  log '/dev/log local0'
  log_tag 'WARDEN'
  pidfile '/var/run/haproxy.pid'
  stats socket: '/var/lib/haproxy/stats level admin'
  tuning 'bufsize' => '262144'
end
haproxy_config_defaults '' do
  mode 'http'
  timeout connect: '5000ms',
          client: '5000ms',
          server: '5000ms'
end
haproxy_frontend 'http-in' do
  bind '*:80'
  default_backend 'servers'
end

all_web_nodes.each_with_index do |web_node,index|

  haproxy_backend 'servers' do
    server ["server#{index} #{web_node['cloud']['public_ipv4']}:80 maxconn 32"]
  end

end
