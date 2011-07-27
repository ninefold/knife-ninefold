require 'chef/knife/ninefold_base'

class Chef
  class Knife
    class NinefoldFlavorList < Knife

      include Knife::NinefoldBase
      
      banner "knife ninefold flavor list"

      def run
        $stdout.sync = true

        flavor_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Description', :bold)
        ]
        connection.flavors.all.each do |flavor|
          flavor_list << flavor.identity.to_s
          flavor_list << flavor.name
          flavor_list << flavor.displaytext
        end
        puts ui.list(flavor_list, :columns_across, 3)

      end
    end
  end
end
