-- it's particularly hard to seed lua for some reason
require('socket')

math.randomseed(socket.gettime() * 1000)
for i=1, 10 do math.random() end
