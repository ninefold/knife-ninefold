require 'chef/knife/ninefold_base'

class Chef
  class Knife
    class NinefoldServerList < Knife

      include Knife::NinefoldBase

      banner "knife ninefold server list"

      def run
        $stdout.sync = true

        server_list = [
          ui.color('Instance ID', :bold),
          ui.color('Name', :bold),
          ui.color('Public IP', :bold),
          ui.color('Private IP', :bold),
          ui.color('Flavor', :bold),
          ui.color('Image', :bold),
          ui.color('Zone', :bold)
        ]
        connection.servers.all.each do |server|
          # Get public IP:
          addrs = connection.addresses.all.select {|a| a.isstaticnat.to_s == "true" && a.virtualmachineid == server.id}
          public_ip = addrs[0] ? addrs[0].ipaddress : 'No public IP' 
          
          server_list << server.identity.to_s
          server_list << server.name
          server_list << public_ip
          server_list << server.ipaddress
          server_list << server.serviceofferingname
          server_list << server.templatename
          server_list << server.zonename
        end
        puts ui.list(server_list, :columns_across, 7)

      end
    end
  end
end

