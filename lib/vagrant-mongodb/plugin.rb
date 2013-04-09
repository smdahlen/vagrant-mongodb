require 'vagrant-mongodb/actions/initiate'

module VagrantPlugins
  module MongoDb
    class Plugin < Vagrant.plugin('2')
      name 'MongoDb'
      description <<-DESC
        A Vagrant plugin that supports the configuration and initation
        of a MongoDb replica set.
      DESC

      def self.initiate(hook)
        hook.prepend(Actions::Initiate)
      end

      config(:mongodb) do
        require_relative 'config'
        Config
      end

      command(:mongodb) do
        require_relative 'commands'
        Commands::Commands
      end

      # initiate replica set after machine provisioning
      action_hook(:mongodb, :machine_action_provision, &method(:initiate))
      action_hook(:mongodb, :machine_action_up, &method(:initiate))
    end
  end
end
