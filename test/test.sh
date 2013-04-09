cd test

vagrant up
vagrant ssh server1 -c 'mongo --eval "printjson(rs.status())"'
vagrant destroy -f

cd ..
