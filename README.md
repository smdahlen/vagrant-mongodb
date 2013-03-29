Vagrant MongoDb
===============
`vagrant-mongodb` is a Vagrant 1.1+ plugin that supports the configuration
and initiation of a MongoDb replica set. The longer-term goal is to support
various MongoDb administrative tasks.

Status
------
The current implementation is a proof-of-concept supporting the larger
objective of using Vagrant as a cloud management interface for development
and production environments.

The plugin has been tested with Vagrant 1.1.4 and Ubuntu 12.04 guest.

Installation
------------
Install the plugin following the typical Vagrant 1.1 procedure:

    vagrant plugin install vagrant-mongodb

Usage
-----
The MongoDb replica set must be configured within the project's `Vagrantfile`:

```ruby
config.mongodb.replset :rs0 do |rs|
  rs.member :server1, :priority => 1
  rs.member :server2, :priority => 2
  rs.member :server3, :priority => 1
end
```

The first argument to `rs.member` is the machine name defined within the
configuration. The second argument is optional taking a hash of options
for the replica set member. These options are defined within MongoDb's
[replica set configuration reference][1].

The plugin hooks into the `vagrant up` command automatically. It detects
when all members of the replica set are available before calling 
`rs.initiate()`. Communication with the replica set occurs over SSH using
the `mongo` shell command.

Contribute
----------
Contributions are welcome.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
