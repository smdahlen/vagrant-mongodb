require 'vagrant-mongodb/version'
require 'vagrant-mongodb/plugin'
require 'vagrant-mongodb/errors'

module VagrantPlugins
  module MongoDb
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end

    I18n.load_path << File.expand_path('locales/en.yml', source_root)
    I18n.reload!
  end
end
