gem build *.gemspec
vagrant plugin install vagrant-mongodb

cd test

vagrant up
sleep 30
vagrant ssh server1 -c 'mongo --eval "printjson(rs.status())"'
vagrant provision
vagrant destroy -f

cd ..
