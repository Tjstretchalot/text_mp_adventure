-- it's particularly hard to seed lua for some reason

math.randomseed(os.time())
for i=1, 100 do
  for i=1, 10 do math.random() end
  math.randomseed(100000*math.random())
  for i=1, 10 do math.random() end
end
