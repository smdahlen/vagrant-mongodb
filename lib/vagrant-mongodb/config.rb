module VagrantPlugins
  module MongoDb
    class Config < Vagrant.plugin('2', :config)
      attr_reader :replsets

      def initialize
        @replsets = []
        @translator = Helpers::Translator.new('config')
      end

      # override default merge behavior
      # TODO look into merge strategy
      def merge(other)
        return self
      end

      def validate(machine)
        errors = []
        @replsets.each do |rs|
          if rs.members.size < 3
            errors << @translator.t('replset_size', { :name => rs.name })
          end
          rs.members.each do |m|
            if !machine.env.machine_names.find { |name| name == m[:host] }
              errors << @translator.t('unknown_member', { :member => m[:host] })
            end
          end
        end

        { 'MongoDb' => errors }
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
            member.merge!(options)
          else
            @members << options.merge({ :_id => @members.size, :host => name.to_sym })
          end
        end
      end
    end
  end
end
