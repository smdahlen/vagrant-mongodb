module VagrantPlugins
  module MongoDb
    class Config < Vagrant.plugin('2', :config)
      attr_reader :replsets

      def initialize
        @replsets = []
      end

      # Override default merge behavior
      # TODO look into merge strategy
      def merge(other)
        return self
      end

      def validate(machine)
        # TODO check that member names have a matching vm definition
        # TODO check that each replica set has 3+ members
        # TODO warn if replica set has even number of members
      end

      def replset(name, &block)
        rs = ReplSet.new(name)
        block.call(rs)
        @replsets << rs
      end

      class ReplSet
        attr_reader :name
        attr_reader :members

        def initialize(name)
          @name = name
          @members = []
        end

        def member(name, options = {})
          @members << options.merge({ :_id => @members.size, :host => name})
        end
      end
    end
  end
end
