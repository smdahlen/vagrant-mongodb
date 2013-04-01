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
        rs = @replsets.find { |r| r.name == name.to_sym }
        if !rs
          rs = ReplSet.new(name)
          @replsets << rs
        end
        block.call(rs)
      end

      class ReplSet
        attr_reader :name
        attr_reader :members

        def initialize(name)
          @name = name.to_sym
          @members = []
        end

        def member(name, options = {})
          member = @members.find { |m| m[:host] == name.to_sym }
          if member
            member.merge(options)
          else
            @members << options.merge({ :_id => @members.size, :host => name.to_sym })
          end
        end
      end
    end
  end
end
