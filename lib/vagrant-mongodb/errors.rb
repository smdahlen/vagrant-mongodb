module VagrantPlugins
  module MongoDb
    module Errors
      class MongoDbError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_mongodb.errors")
      end

      class InitiateError < MongoDbError
        error_key(:initiate)
      end
    end
  end
end
