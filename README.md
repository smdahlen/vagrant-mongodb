Vagrant MongoDb
===============
`vagrant-mongodb` is a Vagrant 1.1 plugin that supports the configuration
and initiation of a MongoDb replica set. The longer-term goal is to support
various MongoDb administrative tasks.

The current implementation is a proof-of-concept supporting the larger
objective of using Vagrant as a cloud management interface for development
and production environments.

The plugin communicates with the replica set members over SSH using the
`mongo` command.

The plugin has been tested with Vagrant 1.1.5 and a Ubuntu 12.04 guest.

Install
-------
Install the plugin following the typical Vagrant 1.1 procedure:

    $ vagrant plugin install vagrant-mongodb

Configure
---------
The MongoDb replica set must be configured within the project's `Vagrantfile`:

```ruby
config.mongodb.auto_initiate = false

config.mongodb.replset :rs0 do |rs|
  rs.ignore_private_ip = false
  rs.member :server1, :priority => 1
  rs.member :server2, :priority => 2
  rs.member :server3, :priority => 1
end
```

The first argument to `rs.member` is the machine name defined within the
configuration. The second argument is optional accepting a hash of options
for the replica set member. These options are defined within MongoDb's
[replica set configuration reference][1].

By default, the plugin will lookup and use a static IP address for a
member machine if a private network is specified. To disable this, set
the replica set attribute, `ignore_private_ip`, to false.

To disable the plugin hooks and initiate a replica set manually, set the
`auto_initiate` attribute to false.

*NOTE*: The plugin does not support configuration defined within a
multi-machine `define` block.

Run
---
By default, the plugin hooks into the `vagrant up` and `vagrant provision`
commands. It will detect when a replica set's members are available and
and call initiate.

To manually initiate a replica set, invoke the following sub-command:

    $ vagrant mongodb initiate db0 --provider <provider>

`db0` is a machine defined within the `Vagrantfile` belonging to a
replica set that will be initiated. The provider may be specified to
initiate a replica set not backed by VirtualBox.

Contribute
----------
Contributions are welcome.

1. Fork the project
1. Clone the forked repository
1. Install project dependencies (`bundle install`)
1. Confirm tests pass (`bundle exec rake test`)
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Push to the branch (`git push origin my-new-feature`)
1. Create new Pull Request
