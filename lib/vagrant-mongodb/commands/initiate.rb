module VagrantPlugins
  module MongoDb
    module Commands
      class Initiate < Vagrant.plugin('2', :command)

        def execute
          options = {}
          opts = OptionParser.new do |o|
            o.banner = 'Usage: vagrant mongodb initiate [vm-name]'
            o.separator ''

            o.on('--provider provider', String,
              'Initiates replica set with the specific provider.') do |provider|
              options[:provider] = provider
            end
          end

          argv = parse_options(opts)
          options[:provider] ||= @env.default_provider
          options[:single_target] = true

          with_target_vms(argv, options) do |machine|

            if machine.config.mongodb
              machine.config.mongodb.auto_initiate = true

              env = { :machine => machine, :ui => @env.ui }
              callable = Vagrant::Action::Builder.new.tap do |b|
                b.use Vagrant::Action::Builtin::ConfigValidate
                b.use Actions::Initiate
              end

              @env.action_runner.run(callable, env)
            end
          end

          0
        end
      end
    end
  end
end
