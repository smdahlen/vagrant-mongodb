module VagrantPlugins
  module MongoDb
    module Commands
      class Commands < Vagrant.plugin('2', :command)
        def initialize(argv, env)
          super
          @main_args, @sub_command, @sub_args = split_main_and_subcommand(argv)
        end

        # TODO refactor to lookup generic commands
        # TODO display help if no sub command is provided
        def execute
          return if @sub_command.downcase != 'initiate'

          require_relative 'commands/initiate'
          Initiate.new(@sub_args, @env).execute
        end
      end
    end
  end
end
