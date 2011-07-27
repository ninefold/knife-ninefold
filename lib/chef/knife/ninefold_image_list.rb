require 'chef/knife/ninefold_base'

class Chef
  class Knife
    class NinefoldImageList < Knife

      include Knife::NinefoldBase
      
      banner "knife ninefold image list"

      def run
        $stdout.sync = true

        image_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Hypervisor', :bold),
          ui.color('Zone', :bold)
        ]
        connection.images.all.each do |image|
          image_list << image.identity.to_s
          image_list << image.name
          image_list << image.hypervisor
          image_list << image.zonename
        end
        puts ui.list(image_list, :columns_across, 4)

      end
    end
  end
end

