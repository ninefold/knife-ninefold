require 'chef/knife'

class Chef
  class Knife
    module NinefoldBase

      # :nodoc:
      # Would prefer to do this in a rational way, but can't be done b/c of
      # Mixlib::CLI's design :(
      def self.included(includer)
        includer.class_eval do

          deps do
            require 'fog'
            require 'net/ssh/multi'
            require 'readline'
            require 'chef/json_compat'

            Chef::Knife::Bootstrap.load_deps
          end
          
          option(:ninefold_compute_key,
                 :short => "-K KEY",
                 :long => "--ninefold_compute_key KEY",
                 :description => "Your Ninefold API Key",
                 :proc => Proc.new { |key| Chef::Config[:knife][:ninefold_compute_key] = key })

          option(:ninefold_compute_secret,
                 :short => "-S SECRET",
                 :long => "--ninefold_compute_secret SECRET",
                 :description => "Your Ninefold API Secret Secret",
                 :proc => Proc.new { |key| Chef::Config[:knife][:ninefold_compute_secret] = key })
          
        end
      end

      def connection
        unless Chef::Config[:knife][:ninefold_compute_key] && Chef::Config[:knife][:ninefold_compute_secret]
          ui.error "Ninefold compute key and/or secret not specified with -K and -S parameters,"
          ui.error "or set in knife.rb with:"
          ui.error 'knife[:ninefold_compute_key]  = "API key"'
          ui.error 'knife[:ninefold_compute_secret]  = "Secret key"'
          exit 1
        end
        @connection ||= Fog::Compute.new(
                                         :provider => 'Ninefold',
                                         :ninefold_compute_key => Chef::Config[:knife][:ninefold_compute_key],
                                         :ninefold_compute_secret => Chef::Config[:knife][:ninefold_compute_secret]
                                         )
      end

      def locate_config_value(key)
        key = key.to_sym
        Chef::Config[:knife][key] || config[key]
      end

    end
  end
end
