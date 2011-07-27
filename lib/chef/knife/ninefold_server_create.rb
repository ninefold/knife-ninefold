require 'chef/knife/ninefold_base'

class Chef
  class Knife
    class NinefoldServerCreate < Knife

      include Knife::NinefoldBase

      banner "knife ninefold server create (options)"
      
      option :flavor,
        :short => "-f FLAVOR",
        :long => "--flavor FLAVOR",
        :description => "The flavor of server; default is 67 - Compute Small PRD (1.7 GB)",
        :proc => Proc.new { |f| Chef::Config[:knife][:flavor] = f.to_i },
        :default => 67

      option :image,
        :short => "-I IMAGE",
        :long => "--image IMAGE",
        :description => "The image of the server; Default is 421 - XEN Ubuntu 10.04 LTS 64bit",
        :proc => Proc.new { |i| Chef::Config[:knife][:image] = i.to_i },
        :default => 421

      option :server_name,
        :short => "-S NAME",
        :long => "--server-name NAME",
        :description => "The server name"
      
      option :bootstrap,
        :short => "-b",
        :long => "--bootstrap",
        :description => "If we should chef bootstrap this node; default is to not bootstrap",
        :boolean => true,
        :default => false

      option :chef_node_name,
        :short => "-N NAME",
        :long => "--node-name NAME",
        :description => "The Chef node name for your new node"

      option :ssh_user,
        :short => "-x USERNAME",
        :long => "--ssh-user USERNAME",
        :description => "The ssh username; default is 'ubuntu'",
        :default => "ubuntu"

      option :ssh_password,
        :short => "-P PASSWORD",
        :long => "--ssh-password PASSWORD",
        :description => "The ssh password; default is 'Password01'",
        :default => "Password01"

      option :identity_file,
        :short => "-i IDENTITY_FILE",
        :long => "--identity-file IDENTITY_FILE",
        :description => "The SSH identity file used for authentication"

      option :prerelease,
        :long => "--prerelease",
        :description => "Install the pre-release chef gems"

      option :bootstrap_version,
        :long => "--bootstrap-version VERSION",
        :description => "The version of Chef to install",
        :proc => Proc.new { |v| Chef::Config[:knife][:bootstrap_version] = v }

      option :distro,
        :short => "-d DISTRO",
        :long => "--distro DISTRO",
        :description => "Bootstrap a distro using a template; default is 'ubuntu10.04-gems'",
        :proc => Proc.new { |d| Chef::Config[:knife][:distro] = d },
        :default => "ubuntu10.04-gems"

      option :template_file,
        :long => "--template-file TEMPLATE",
        :description => "Full path to location of template to use",
        :proc => Proc.new { |t| Chef::Config[:knife][:template_file] = t },
        :default => false

      option :run_list,
        :short => "-r RUN_LIST",
        :long => "--run-list RUN_LIST",
        :description => "Comma separated list of roles/recipes to apply",
        :proc => lambda { |o| o.split(/[\s,]+/) },
        :default => []

      def run
        $stdout.sync = true

        server = connection.servers.create(:templateid => locate_config_value(:image),
                                           :serviceofferingid => locate_config_value(:flavor),
                                           :zoneid => 1,
                                           :name => config[:server_name])

        server.reload # fetch generated name etc.

        puts "#{ui.color("Instance ID", :cyan)}: #{server.id}"
        puts "#{ui.color("Name", :cyan)}: #{server.name}"
        puts "#{ui.color("Flavor", :cyan)}: #{server.serviceofferingname}"
        puts "#{ui.color("Image", :cyan)}: #{server.templatename}"

        print "\n#{ui.color("Waiting on server", :magenta)}"
        # wait for it to be ready to do stuff
        server.wait_for { print "."; ready? }
        puts

        @ip = connection.addresses.new(:zoneid => 1)
        @ip.save
        @ip.reload
        print "\n#{ui.color("Waiting on IP address allocation", :magenta)}"
        @ip.wait_for { print '.' ; ready? }
        puts "\n"
        # Enable static NAT to this server
        @ip.enable_static_nat(server)
        # Map inbound connections
        ipfw_tcp = connection.ip_forwarding_rules.new(:address => @ip, :protocol => 'TCP', :startport => 1, :endport => 65535)
        ipfw_tcp.save
        ipfw_udp = connection.ip_forwarding_rules.new(:address => @ip, :protocol => 'UDP', :startport => 1, :endport => 65535)
        ipfw_udp.save
        print "\n#{ui.color("Waiting on Inbound TCP&UDP connection mapping", :magenta)}"
        ipfw_tcp.wait_for {print '.' ; ready?}
        ipfw_udp.wait_for {print '.' ; ready?}
        puts
        puts "#{ui.color("Public IP Address", :cyan)}: #{@ip.ipaddress}"
        

        if config[:bootstrap]
          bootstrap_for_node(server).run
        end
      end

      def bootstrap_for_node(server)
        bootstrap = Chef::Knife::Bootstrap.new
        bootstrap.name_args = [@ip.ipaddress]
        bootstrap.config[:run_list] = config[:run_list]
        bootstrap.config[:ssh_user] = config[:ssh_user] || "root"
        bootstrap.config[:ssh_password] = config[:ssh_password]
        bootstrap.config[:identity_file] = config[:identity_file]
        bootstrap.config[:chef_node_name] = config[:chef_node_name] || server.name
        bootstrap.config[:prerelease] = config[:prerelease]
        bootstrap.config[:bootstrap_version] = locate_config_value(:bootstrap_version)
        bootstrap.config[:distro] = locate_config_value(:distro)
        # bootstrap will run as root...sudo (by default) also messes up Ohai on CentOS boxes
        bootstrap.config[:use_sudo] = true unless config[:ssh_user] == 'root'
        bootstrap.config[:template_file] = locate_config_value(:template_file)
        bootstrap.config[:environment] = config[:environment]
        bootstrap
      end
    end
  end
end

