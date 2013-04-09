module VagrantPlugins
  module MongoDb
    class Config < Vagrant.plugin('2', :config)
      attr_reader :replsets
      attr_accessor :auto_initiate

      def initialize
        @replsets = []
        @auto_initiate = UNSET_VALUE
      end

      # TODO look into appropriate merge strategy
      def merge(other)
        # other.replsets.each do |o|
        #   rs = @replsets.find { |r| r.name == o.name }
        #   if rs
        #     o.members.each do |member|
        #       rs.member member[:host], member
        #     end
        #   else
        #     @replsets << other
        #   end
        # end

        # self
      end

      def finalize!
        @auto_initiate = true if @auto_initiate == UNSET_VALUE
      end

      def validate(machine)
        errors = []
        @replsets.each do |rs|
          if rs.members.size < 3
            errors << I18n.t('vagrant_mongodb.config.replica_set_size', {
              :name => rs.name
            })
          end
          rs.members.each do |m|
            if !machine.env.machine_names.find { |name| name == m[:host] }
              errors << I18n.t('vagrant_mongodb.config.unknown_member', {
                :member => m[:host]
              })
            end
          end
        end

        { 'MongoDb' => errors }
      end

      def replset(name, &block)
        rs = @replsets.find { |r| r.name == name.to_sym }
        if !rs
          rs = ReplicaSet.new(name)
          @replsets << rs
        end
        block.call(rs)
      end

      class ReplicaSet
        attr_reader :name
        attr_reader :members
        attr_accessor :ignore_private_ip

        def initialize(name)
          @name = name.to_sym
          @members = []
          @ignore_private_ip = false
        end

        def member(name, options = {})
          member = @members.find { |m| m[:host] == name.to_sym }
          if member
            options.delete(:_id)
            member.merge!(options)
          else
            @members << options.merge({
              :_id => @members.size,
              :host => name.to_sym
            })
          end
        end
      end
    end
  end
end
