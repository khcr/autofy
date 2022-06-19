#!/usr/bin/env ruby
#--
# This file is part of Sonic Pi: http://sonic-pi.net
# Full project source: https://github.com/samaaron/sonic-pi
# License: https://github.com/samaaron/sonic-pi/blob/main/LICENSE.md
#
# Copyright 2013 by Sam Aaron (http://sam.aaron.name).
# All rights reserved.
#
# Permission is granted for use, copying, modification, and
# distribution of modified versions of this work as long as this
# notice is included.
#++

require 'cgi'
require 'rbconfig'


require_relative "../core.rb"
require_relative "../lib/sonicpi/studio"

require_relative "../lib/sonicpi/server"
require_relative "../lib/sonicpi/util"
require_relative "../lib/sonicpi/osc/osc"
require_relative "../lib/sonicpi/lang/core"
require_relative "../lib/sonicpi/lang/minecraftpi"
require_relative "../lib/sonicpi/lang/midi"
require_relative "../lib/sonicpi/lang/ixi"
require_relative "../lib/sonicpi/lang/sound"
#require_relative "../lib/sonicpi/lang/pattern"
require_relative "../lib/sonicpi/runtime"

require 'multi_json'
require 'memoist'
require 'fileutils'

include SonicPi::Util

## This is where the server starts....
STDOUT.puts "Sonic Pi server booting..."
STDOUT.puts "The time is #{Time.now}"

# Start Compton if using Raspberry Pi: enables transparency to
# work. This really should be done by the GUI as it is nothing to do
# with the language runtime or server
# TODO: If we enable a headless server, this needs to move.
if os==:raspberry
  compton_cmd="/usr/bin/compton"
  if File.exist?(compton_cmd)
    STDOUT.puts  "Starting Compton for Raspberry Pi transparency"
    compton_pid = spawn("exec #{compton_cmd}",[:out,:err]=>"/dev/null")
    register_process(compton_pid)
  else
    STDOUT.puts('Compton not installed on your Raspberry Pi so transparency is not available')
    STDOUT.puts('If you wish to have transparency run the following in a terminal:')
    STDOUT.puts('sudo apt install compton')
  end
end

## Ensure ~/.sonic-pi/* user config, history and setting directories exist
[home_dir_path, project_path, log_path, cached_samples_path, config_path, system_store_path].each do |d|
  ensure_dir(d)
end

## Just check to see if the user still has an old settings.json and if
## so, remove it. This is now stored in system_cache_store_path
old_settings_file_path = File.absolute_path("#{home_dir_path}/settings.json")
File.delete(old_settings_file_path) if File.exist?(old_settings_file_path)

## Move across any config example files if they don't
## exist so the user has a starting point for
## modifying them.


begin
  if File.exists?(original_init_path)
    if (File.exists?(init_path))
      STDOUT.puts "Warning, you have an older init.rb file in #{original_init_path} which is now being ignored as your newer config/init.rb file is being used instead. Consider deleting your old init.rb (perhaps copying anything useful across first)."
    else
      STDOUT.puts "Found init.rb in old location #{original_init_path}. Moving it to the new config directory #{init_path}."
      FileUtils.mv(original_init_path, init_path)
    end
  end
rescue Exception => e
  STDOUT.puts "Warning: exception when comparing new and original init.rb paths"
  STDOUT.puts "Error message received:\n-----------------------"
  STDOUT.puts e.message
  STDOUT.puts e.backtrace.inspect
  STDOUT.puts e.backtrace
end




Dir["#{user_config_examples_path}/*"].each do |f|
  basename = File.basename(f)
  full_config_path = File.absolute_path("#{config_path}/#{basename}")
  unless File.exist?(full_config_path)
    FileUtils.cp(f, full_config_path)
  end
end

## Select the primary GUI protocol
gui_protocol = case ARGV[0]
           when "-t"
             # Qt GUI + tcp
             :tcp
           when "-u"
             # Qt GUI + udp
             :udp
           when "-w"
             # Web GUI + websockets
             :websockets
           else
             :udp
            end

STDOUT.puts "Using primary protocol: #{gui_protocol}"
STDOUT.puts "Detecting port numbers..."

# Port which the server listens to messages from the GUI
# server-listen-to-gui
server_port = ARGV[1] ? ARGV[1].to_i : 4557

# Port which the GUI uses to listen to messages from the server:
# server-send-to-gui
gui_port = ARGV[2] ? ARGV[2].to_i : 4558

# Port which the SuperCollider server scsynth listens to:
# (scsynth will automatically send replies back to the port
# from which the message originated from)
# scsynth
scsynth_port = ARGV[3] ? ARGV[3].to_i : 4556

# Port to use to send messages to SuperCollider.
# Typically this is the same as scsynth_port, but
# may differ if there's a relay between them
# scsynth-send
scsynth_send_port = ARGV[4] ? ARGV[4].to_i : scsynth_port

# Port which the server listens to for external OSC messges
# which will be automatically converted to cues.
# server-osc-cues
osc_cues_port = ARGV[5] ? ARGV[5].to_i : 4560

# Port which the Erlang scheduler/router listens to.
# erlang-router
erlang_port = ARGV[6] ? ARGV[6].to_i : 4561

# Port which the server uses to communicate via websockets
# websocket
websocket_port = ARGV[9] ? ARGV[9].to_i : 4562

# Create a frozen map of the ports so that this can
# essentially be treated as a global constant to the
# language runtime.
sonic_pi_ports = {
  server_port: server_port,
  scsynth_port: scsynth_port,
  scsynth_send_port: scsynth_send_port,
  osc_cues_port: osc_cues_port,
  erlang_port: erlang_port,
  websocket_port: websocket_port}.freeze


# Open up comms to the GUI.
# We need to do this now so we can communicate with it going forwards
begin
  case gui_protocol
  when :tcp
    gui = SonicPi::OSC::TCPClient.new("127.0.0.1", gui_port, use_encoder_cache: true)
  when :udp
    gui = SonicPi::OSC::UDPClient.new("127.0.0.1", gui_port, use_encoder_cache: true)
  when :websockets
    gui = SonicPi::OSC::WebSocketServer.new(websocket_port)
  end

rescue Exception => e
  STDOUT.puts "Exception when opening socket to talk to GUI"
  case gui_protocol
  when :tcp
    STDOUT.puts "Attempted to use TCP on port #{gui_port}"
  when :udp
    STDOUT.puts "Attempted to use UDP on port #{gui_port}"
  when :websockets
    STDOUT.puts "Attempted to use Websockets on port #{websocket_port}"
  end
  STDOUT.puts "Error message received:\n-----------------------"
  STDOUT.puts e.message
  STDOUT.puts e.backtrace.inspect
  STDOUT.puts e.backtrace
end



# Check ports to ensure they're available on this system.

# This information is very useful for error reporting so print it to
# STDOUT so it's automatically logged.
#
# Note: when booted by Sonic Pi.app all STDOUT is typically configured
# to pipe to ~/.sonic-pi/log/server-output.log by the C++ GUI which
# launches the Ruby process evaluating this file.

# First define a helper function to check to see if a given is available
# on the system and to tell the gui to exit if not.
check_port = lambda do |port|
  return false if port < 1024

  available = false
  begin
    s = SonicPi::OSC::UDPServer.new(port)
    s.stop
    available = true
  rescue Exception => e
    available = false
  end
  available
end

ensure_port_or_quit = lambda do |port, gui|
  if check_port.call(port)
    STDOUT.puts "  - OK"
  else
      STDOUT.puts "Port #{port} unavailable. Perhaps Sonic Pi is already running?"
    begin
      gui.send("/exited-with-boot-error", "Port unavailable: " + port.to_s + ", is Sonic Pi already running?")
    rescue Errno::EPIPE => e
      STDOUT.puts "GUI not listening, exit anyway."
    end
    STDOUT.flush
    exit
  end
end

# Next use this helper function to test all the ports.
# This will exit this script if a port isn't available.
unless (gui_protocol == :websockets)
  STDOUT.puts "Listen port: #{server_port}"
  ensure_port_or_quit.call(server_port, gui)
end

STDOUT.puts "Scsynth port: #{scsynth_port}"
ensure_port_or_quit.call(scsynth_port, gui)
STDOUT.puts "Scsynth send port: #{scsynth_send_port}"
ensure_port_or_quit.call(scsynth_send_port, gui)
STDOUT.puts "OSC cues port: #{osc_cues_port}"
ensure_port_or_quit.call(osc_cues_port, gui)
STDOUT.puts "Erlang port: #{erlang_port}"
ensure_port_or_quit.call(erlang_port, gui)
STDOUT.puts "Websocket port: #{websocket_port}"
ensure_port_or_quit.call(websocket_port, gui)

# Yey! all ports are availale if we get this far...  Ensure this is now
# visible in the log by flushing STDOUT - just in case you're tailing it
# in the ternimal with tail -f ~/.sonic-pi/log/server-output.log



# Now we need to set up a server to listen to messages from the GUI.  If
# we're running with websockets, then this is the same entity as the gui
# comms which is already a websocket server
begin
  case gui_protocol
  when :tcp
    STDOUT.puts "Opening TCP Server to listen to GUI on port: #{server_port}"
    osc_server = SonicPi::OSC::TCPServer.new(server_port, use_decoder_cache: true)
  when :udp
    STDOUT.puts "Opening UDP Server to listen to GUI on port: #{server_port}"
    osc_server = SonicPi::OSC::UDPServer.new(server_port, use_decoder_cache: true)
  when :websockets
    STDOUT.puts "Listening to GUI on websocket"
    osc_server = gui
  end
rescue Exception => e
  begin
    STDOUT.puts "Exception when opening a socket to listen from GUI!"
    STDOUT.puts e.message
    STDOUT.puts e.backtrace.inspect
    STDOUT.puts e.backtrace
    STDOUT.flush
    gui.send("/exited-with-boot-error", "Failed to open server port " + server_port.to_s + ", is scsynth already running?")
  rescue Errno::EPIPE => e
    STDOUT.puts "GUI not listening, exit anyway."
    STDOUT.flush
  end
  exit
end

STDOUT.flush

# # Next fire up a websockets server.
# begin
#   case gui_protocol
#   when :tcp
#     ws = SonicPi::OSC::WebSocketServer.new(websocket_port)
#   when :udp
#     ws = SonicPi::OSC::WebSocketServer.new(websocket_port)
#   when :websockets
#     ws = gui
#   end
# rescue Exception => e
#   begin
#     STDOUT.puts "Exception when opening a websocket on port: #{websocket_port}"
#     STDOUT.puts e.message
#     STDOUT.puts e.backtrace.inspect
#     STDOUT.puts e.backtrace
#     gui.send("/exited-with-boot-error", "Failed to open websocket port " + websocket_port.to_s)
#   rescue Errno::EPIPE => e
#     STDOUT.puts "GUI not listening, exit anyway."
#   end
#   exit
# end

user_methods = Module.new
name = "SonicPiLang" # this should be autogenerated
klass = Object.const_set name, Class.new(SonicPi::Runtime)

klass.send(:include, user_methods)
klass.send(:include, SonicPi::Lang::Core)
klass.send(:include, SonicPi::Lang::Sound)
klass.send(:include, SonicPi::Lang::Minecraft)
klass.send(:include, SonicPi::Lang::Midi)
klass.send(:include, SonicPi::Lang::Ixi)
klass.send(:include, SonicPi::Lang::Support::DocSystem)
klass.send(:extend, Memoist)

# This will pick up all memoizable fns in all modules as they share the
# same docsystem.
# TODO think of a better way to modularise this stuff when we move to
# using namespaces...

SonicPi::Lang::Core.memoizable_fns.each do |f|
  klass.send(:memoize, f)
end

klass.send(:define_method, :inspect) { "Runtime" }
#klass.send(:include, SonicPi::Lang::Pattern)

ws_out = Queue.new

begin
  STDOUT.puts "Starting Server Runtime"
  sp =  klass.new sonic_pi_ports, ws_out, user_methods
  STDOUT.puts "Server Runtime Initialised"

  # read in init.rb if exists
  if File.exists?(init_path)
    sp.__spider_eval(File.read(init_path), silent: true)
  else
    STDOUT.puts "Could not find init.rb file: #{init_path} "
  end

  sp.__print_boot_messages

rescue Exception => e
  STDOUT.puts "Failed to start server: " + e.message
  STDOUT.puts e.backtrace.join("\n")
  gui.send("/exited-with-boot-error", "Server Exception:\n #{e.message}\n #{e.backtrace}")
  exit
end

at_exit do
  STDOUT.puts "Server is exiting."
  begin
    STDOUT.puts "Shutting down GUI..."
    gui.send("/exited")
  rescue Errno::EPIPE => e
    STDOUT.puts "GUI not listening."
  end
  STDOUT.puts "Goodbye :-)"
end

register_api = lambda do |server|
  server.add_method("/run-code") do |args|
    gui_id = args[0]
    code = args[1].force_encoding("utf-8")
    sp.__spider_eval code
  end

  server.add_method("/save-and-run-buffer") do |args|
    gui_id = args[0]
    buffer_id = args[1]
    code = args[2].force_encoding("utf-8")
    workspace = args[3]
    sp.__save_buffer(buffer_id, code)
    sp.__spider_eval code, {workspace: workspace}
  end

  server.add_method("/save-buffer") do |args|
    gui_id = args[0]
    buffer_id = args[1]
    code = args[2].force_encoding("utf-8")
    sp.__save_buffer(buffer_id, code)
  end

  server.add_method("/exit") do |args|
    gui_id = args[0]
    sp.__exit
  end

  server.add_method("/stop-all-jobs") do |args|
    gui_id = args[0]
    sp.__stop_jobs
  end

  server.add_method("/load-buffer") do |args|
    gui_id = args[0]
    sp.__load_buffer args[1]
  end

  server.add_method("/buffer-newline-and-indent") do |args|
    gui_id = args[0]
    id = args[1]
    buf = args[2].force_encoding("utf-8")
    point_line = args[3]
    point_index = args[4]
    first_line = args[5]
    sp.__buffer_newline_and_indent(id, buf, point_line, point_index, first_line)
  end

  server.add_method("/buffer-section-complete-snippet-or-indent-selection") do |args|
    gui_id = args[0]
    id = args[1]
    buf = args[2].force_encoding("utf-8")
    start_line = args[3]
    finish_line = args[4]
    point_line = args[5]
    point_index = args[6]
    sp.__buffer_complete_snippet_or_indent_lines(id, buf, start_line, finish_line, point_line, point_index)
  end

  server.add_method("/buffer-indent-selection") do |args|
    gui_id = args[0]
    id = args[1]
    buf = args[2].force_encoding("utf-8")
    start_line = args[3]
    finish_line = args[4]
    point_line = args[5]
    point_index = args[6]
    sp.__buffer_indent_lines(id, buf, start_line, finish_line, point_line, point_index)
  end

  server.add_method("/buffer-section-toggle-comment") do |args|
    gui_id = args[0]
    id = args[1]
    buf = args[2].force_encoding("utf-8")
    start_line = args[3]
    finish_line = args[4]
    point_line = args[5]
    point_index = args[6]
    sp.__toggle_comment(id, buf, start_line, finish_line, point_line, point_index)
  end

  server.add_method("/buffer-beautify") do |args|
    gui_id = args[0]
    id = args[1]
    buf = args[2].force_encoding("utf-8")
    line = args[3]
    index = args[4]
    first_line = args[5]
    sp.__buffer_beautify(id, buf, line, index, first_line)
  end

  server.add_method("/ping") do |args|
    gui_id = args[0]
    id = args[1]
    STDOUT.puts "Received /ping, sending /ack to GUI"
    gui.send("/ack", id)
  end

  server.add_method("/start-recording") do |args|
    gui_id = args[0]
    sp.recording_start
  end

  server.add_method("/stop-recording") do |args|
    gui_id = args[0]
    sp.recording_stop
  end

  server.add_method("/delete-recording") do |args|
    gui_id = args[0]
    sp.recording_delete
  end

  server.add_method("/save-recording") do |args|
    gui_id = args[0]
    filename = args[1]
    sp.recording_save(filename)
  end

  server.add_method("/reload") do |args|
    gui_id = args[0]
    dir = File.dirname("#{File.absolute_path(__FILE__)}")
    Dir["#{dir}/../lib/**/*.rb"].each do |d|
      load d
    end
    puts "reloaded"
  end

  server.add_method("/mixer-invert-stereo") do |args|
    gui_id = args[0]
    sp.set_mixer_invert_stereo!
  end

  server.add_method("/mixer-standard-stereo") do |args|
    gui_id = args[0]
    sp.set_mixer_standard_stereo!
  end

  server.add_method("/mixer-stereo-mode") do |args|
    gui_id = args[0]
    sp.set_mixer_stereo_mode!
  end

  server.add_method("/mixer-mono-mode") do |args|
    gui_id = args[0]
    sp.set_mixer_mono_mode!
  end

  server.add_method("/mixer-hpf-enable") do |args|
    gui_id = args[0]
    freq = args[1].to_f
    sp.set_mixer_hpf!(freq)
  end

  server.add_method("/mixer-hpf-disable") do |args|
    gui_id = args[0]
    sp.set_mixer_hpf_disable!
  end

  server.add_method("/mixer-lpf-enable") do |args|
    gui_id = args[0]
    freq = args[1].to_f
    sp.set_mixer_lpf!(freq)
  end

  server.add_method("/mixer-lpf-disable") do |args|
    gui_id = args[0]
    sp.set_mixer_lpf_disable!
  end

  server.add_method("/mixer-amp") do |args|
    gui_id = args[0]
    amp = args[1]
    silent = args[2] == 1
    sp.set_volume!(amp, true, silent)
  end

  server.add_method("/enable-update-checking") do |args|
    gui_id = args[0]
    sp.__enable_update_checker
  end

  server.add_method("/disable-update-checking") do |args|
    gui_id = args[0]
    sp.__disable_update_checker
  end

  server.add_method("/check-for-updates-now") do |args|
    gui_id = args[0]
    sp.__update_gui_version_info_now
  end

  server.add_method("/version") do |args|
    gui_id = args[0]
    v = sp.__current_version
    lv = sp.__server_version
    lc = sp.__last_update_check
    plat = host_platform_desc
    gui.send("/version", v.to_s, v.to_i, lv.to_s, lv.to_i, lc.day, lc.month, lc.year, plat.to_s)
  end

  server.add_method("/gui-heartbeat") do |args|
    gui_id = args[0]
    sp.__gui_heartbeat gui_id
  end

  server.add_method("/midi-ins") do |args|
    gui_id = args[0]
    ins = args[1..-1]
    sp.__update_midi_ins(ins)
  end

  server.add_method("/midi-outs") do |args|
    gui_id = args[0]
    outs = args[1..-1]
    sp.__update_midi_outs(outs)
  end

  server.add_method("/midi-start") do |args|
    gui_id = args[0]
    silent = args[1] == 1
    sp.__midi_system_start(silent)
  end

  server.add_method("/midi-stop") do |args|
    gui_id = args[0]
    silent = args[1] == 1
    sp.__midi_system_stop(silent)
  end

  server.add_method("/midi-reset") do |args|
    gui_id = args[0]
    silent = args[1] == 1
    sp.__midi_system_reset(silent)
  end

  server.add_method("/midi-cue") do |args|
    gui_id = args[0]
    path = args[1]
    args = args[2..-1]
    sp.__register_midi_cue_event(path, args)
  end

  server.add_method("/cue-port-external") do |args|
    gui_id = args[0]
    sp.__cue_server_internal!(false)
  end

    server.add_method("/cue-port-internal") do |args|
    gui_id = args[0]
    sp.__cue_server_internal!(true)
  end

  server.add_method("/cue-port-stop") do |args|
    gui_id = args[0]
    sp.__stop_start_cue_server!(true)
  end

  server.add_method("/cue-port-start") do |args|
    gui_id = args[0]
    sp.__stop_start_cue_server!(false)
  end

  server.add_method("/external-osc-cue") do |args|
    gui_id = args[0]
    ip = args[0]
    port = args[1]
    address = args[2]
    osc_args = args[3..-1]
    sp.__register_external_osc_cue_event(Time.now, ip, port, address, osc_args)
  end
end

register_api.call(osc_server)
# register_api.call(ws) unless gui_protocol == :websockets

puts "\n\n"
puts "This is Sonic Pi #{sp.__current_version} running on #{os} with ruby version #{RUBY_VERSION} with api #{RbConfig::CONFIG['ruby_version']}."
puts "Sonic Pi Server successfully booted."
puts "-----------------------------------\n\n"


STDOUT.flush

continue = true
while continue
  message = ws_out.pop
  if message[:type] == :exit
    continue = false
  end
end

# out_t.join
