require 'vagrant-mongodb/helpers/translator'
require 'vagrant-mongodb/actions/replset_initiate'

module VagrantPlugins
  module MongoDb
    class Plugin < Vagrant.plugin('2')
      name 'MongoDb'
      description <<-DESC
        This plugin manages a MongoDb replica set.
      DESC

      def self.replset_initiate(hook)
        setup_logging
        setup_i18n
        hook.before(Vagrant::Action::Builtin::Provision, Actions::ReplSetInitiate)
      end

      config(:mongodb) do
        require_relative 'config'
        Config
      end

      # initiate replica set after machine provisioning
      action_hook(:replset_initiate, :machine_action_provision, &method(:replset_initiate))
      action_hook(:replset_initiate, :machine_action_up, &method(:replset_initiate))

      def self.setup_i18n
        I18n.load_path << File.expand_path(
          'locales/en.yml',
          MongoDb.source_root)
        I18n.reload!

        Helpers::Translator.plugin_namespace = 'vagrant_mongodb'
      end

      def self.setup_logging
        level = nil
        begin
          level = Log4r.const_get(ENV['VAGRANT_LOG'].upcase)
        rescue NameError
          # This means that the logging constant wasn't found,
          # which is fine. We just keep `level` as `nil`. But
          # we tell the user.
          level = nil
        end

        # Some constants, such as "true" resolve to booleans, so the
        # above error checking doesn't catch it. This will check to make
        # sure that the log level is an integer, as Log4r requires.
        level = nil if !level.is_a?(Integer)

        # Set the logging level on all "vagrant" namespaced
        # logs as long as we have a valid level.
        if level
          logger = Log4r::Logger.new('vagrant_mongodb')
          logger.outputters = Log4r::Outputter.stderr
          logger.level = level
          logger = nil
        end
      end
    end
  end
end
