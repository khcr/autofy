require 'socket'
require 'osc-ruby'

client ||= OSC::Client.new("localhost", 4557)

msg = OSC::Message.new("/run-code", "SONIC-PI-CLI", "play [50, 55, 60]")

client.send(msg)