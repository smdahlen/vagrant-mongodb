module VagrantPlugins
  module MongoDb
    module Actions
      class ReplSetInitiate
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app = app
          @config = env[:global_config].mongodb
          @machine = env[:machine]
          @translator = Helpers::Translator.new('actions.replset_initiate')
          @logger = Log4r::Logger.new('vagrant_mongodb::actions::replset_initiate')
        end

        def call(env)
          @app.call(env)

          # check if the current machine is a member of a replica set
          @logger.info "Checking if '#{@machine.name}' is part of a replica set..."
          rs = get_replset(@machine.name) if @config
          return if !rs

          # ensure all members are available before initiating replica set
          if all_members_available?(rs)
            env[:ui].info @translator.t('initiate', { :name => rs.name })
            command = "mongo --eval 'printjson(rs.initiate(#{generate_json(rs)}))'"
            env[:machine].communicate.execute(command) do |type, data|
              raise Errors::ReplSetInitiateError if data =~ /"ok" : 0/
            end
          end
        end

        private

        # return the replset containing the machine name
        def get_replset(name)
          @config.replsets.find do |rs|
            rs.members.find do |member|
              member[:host] == name
            end
          end
        end

        # check if the given machine has mongod running
        def member_available?(machine)
          @logger.info "Checking if '#{machine.name}' mongod is available..."
          return false if !machine.communicate.ready?

          # try executing the mongo command on the machine several times
          # to allow for a process to start after provisioning
          command = 'mongo --eval "db.runCommand({ ping: 1 })"'
          retryable(:tries => 3, :sleep => 10) do
            machine.communicate.execute(command)
            @logger.info "'#{machine.name}' mongod is available..."
          end
          true
        rescue
          false
        end

        # check if all members of the replica set have mongod running
        def all_members_available?(rs)
          global_env = @machine.env
          rs.members.each do |member|
            machine = global_env.machine(member[:host], @machine.provider_name)
            return false if !member_available?(machine)
          end
          true
        end

        # generate replica set JSON document replacing host name with ip
        def generate_json(rs)
          global_env = @machine.env
          members = rs.members.dup
          members.each do |member|
            machine = global_env.machine(member[:host], @machine.provider_name)
            member[:host] = get_ip_address(machine)
            @logger.info "Using ip address '#{member[:host]}' for '#{@machine.name}'..."
          end

          { :_id => rs.name, :members => members }.to_json
        end

        # return the ip address of the given machine
        def get_ip_address(machine)
          ip = nil
          machine.config.vm.networks.each do |network|
            key, options = network[0], network[1]
            ip = options[:ip] if key == :private_network
            next if ip
          end

          ip || machine.ssh_info[:host]
        end
      end
    end
  end
end
