require 'chef/knife/ninefold_base'

class Chef
  class Knife
    class NinefoldServerDelete < Knife

      include Knife::NinefoldBase

      banner "knife ninefold server delete SERVER_ID [SERVER_ID..]"
      
      def run
        $stdout.sync = true

        @name_args.each do |instance_id|

          server = connection.servers.get(instance_id)

          addrs = connection.addresses.all.select {|a| a.isstaticnat.to_s == "true" && a.virtualmachineid == server.id}
          
          msg("Instance ID", server.id.to_s)
          msg("Name", server.name)
          msg("Flavor", server.serviceofferingname)
          msg("Image", server.templatename)
          msg("Public IP", addrs[0].ipaddress) if addrs[0]
          
          puts "\n"
          confirm("Do you really want to delete this server")
          
          server.destroy
          ui.warn("Deleted server #{server.id} named #{server.name}")
          if addrs[0]
            # addrs[0].disable_static_nat
            # print "\n#{ui.color("Waiting on static nat disabling", :magenta)}"
            # addrs[0].wait_for { print '.' ; ready? }
            # puts
            addrs[0].destroy
            # print "\n#{ui.color("Waiting on ip address release", :magenta)}"
            # addrs[0].wait_for { print '.' ; ready? }
            # puts
            ui.warn("Removed public IP allocation: #{addrs[0].ipaddress}")
          end
          
        end
      end

      def msg(label, value)
        if value && !value.empty?
          puts "#{ui.color(label, :cyan)}: #{value}"
        end
      end
      
    end
  end
end

