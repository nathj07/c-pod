require 'nat-pmp.rb'

NatPMP.map 633, 13033, 30, :tcp do |map|
  puts "Executing sleep 10 with #{map.inspect}"
  sleep 10
end
