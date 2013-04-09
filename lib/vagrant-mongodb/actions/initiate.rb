module VagrantPlugins
  module MongoDb
    module Actions
      class Initiate
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @rs = replica_set
          @logger = Log4r::Logger.new('vagrant::mongodb::initiate')
        end

        def call(env)
          @app.call(env)

          # check if machine belongs to a configured replica set
          return unless @rs

          # check if auto initiate is enabled
          return unless @machine.config.mongodb.auto_initiate

          # check if the replica set is already initiated
          if initiated?
            env[:ui].info I18n.t('vagrant_mongodb.info.initiated', {
              :name => @rs.name
            })
            return
          end
            
          env[:ui].info I18n.t('vagrant_mongodb.info.checking', {
            :name => @rs.name
          })

          if all_members_available?
            env[:ui].info I18n.t('vagrant_mongodb.info.initiating', {
              :name => @rs.name
            })

            # execute rs.initiate() on first replica set member
            command = "mongo --eval 'printjson(rs.initiate(#{generate_json}))'"
            @machine.communicate.execute(command) do |type, data|
              raise Errors::InitiateError if data =~ /"ok" : 0/
            end

            # wait until the replica set is initiated
            retryable(:tries => 6, :sleep => 30) do
              raise 'not ready' if !initiated?
            end
          end
        end

        private

        # return the replset the machine is a member of
        def replica_set
          return nil if @machine.config.mongodb.nil?

          @machine.config.mongodb.replsets.find do |rs|
            rs.members.find do |member|
              member[:host] == @machine.name
            end
          end
        end

        # check if the replica set has already been initiated
        def initiated?
          @logger.info "Checking if '#{@rs.name}' has already been initiated"
          command = "mongo --eval 'printjson(rs.status())'"
          @machine.communicate.execute(command) do |type, data|
            return true if data =~ /"ok" : 1/
          end

          false
        rescue Vagrant::Errors::VagrantError
          false
        end

        # check if the given machine has mongod running
        def member_available?(machine)
          @logger.info "Checking if '#{machine.name}' mongod is available"
          return false if !machine.communicate.ready?

          # try executing the mongo command on the machine several times
          # to allow for a process to start after provisioning
          command = 'mongo --eval "db.runCommand({ ping: 1 })"'
          retryable(:tries => 3, :sleep => 10) do
            machine.communicate.execute(command)
            @logger.info "'#{machine.name}' mongod is available"
          end
          true
        rescue
          false
        end

        # check if all members of the replica set have mongod running
        def all_members_available?
          @rs.members.each do |member|
            machine = @machine.env.machine(member[:host], @machine.provider_name)
            return false if !member_available?(machine)
          end
          true
        end

        # generate replica set JSON document replacing host name with ip
        def generate_json
          members = []
          @rs.members.each do |member|
            machine = @machine.env.machine(member[:host], @machine.provider_name)
            copy = member.dup
            copy[:host] = get_ip_address(machine)
            members << copy
          end

          { :_id => @rs.name, :members => members }.to_json
        end

        # return the ip address of the given machine
        def get_ip_address(machine)
          ip = nil
          unless @rs.ignore_private_ip
            machine.config.vm.networks.each do |network|
              key, options = network[0], network[1]
              ip = options[:ip] if key == :private_network
              next if ip
            end
          end

          ip || machine.ssh_info[:host]
        end
      end
    end
  end
end
