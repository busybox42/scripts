#!/bin/ruby

require 'socket'
require 'json'
require 'yaml'
require 'optparse'

# Default hosts/port
hostname = 'localhost'
port = 4028

# Arguments
cmd = ARGV[0]
cmd2 = ''

# Options
options = {}
opt_parser = OptionParser.new do |opt|
	opt.banner = "Usage: cgapi.rb COMMAND [OPTIONS]"
	opt.separator  ""
	opt.separator  "Commands"
	opt.separator  "     version"
	opt.separator  "     config"
	opt.separator  "     summary"
	opt.separator  "     pools"
	opt.separator  "     devs"
	opt.separator  "     edevs"
	opt.separator  "     pga N"
	opt.separator  "     pgacount"
	opt.separator  "     switchpool N"
	opt.separator  "     enablepool N"
	opt.separator  "     addpool URL,USR,PASS"
	opt.separator  "     poolpriority N"
	opt.separator  "     poolquota N,Q"
	opt.separator  "     disablepool N"
	opt.separator  "     removepool N"
	opt.separator  "     save filename"
	opt.separator  "     quit"
	opt.separator  "     notify"
	opt.separator  "     privileged"
	opt.separator  "     pgaenable N"
	opt.separator  "     pgadisable N"
	opt.separator  "     pgaidentify N"
	opt.separator  "     devdetails"
	opt.separator  "     restart"
	opt.separator  "     stats"
	opt.separator  "     estats"
	opt.separator  "     check cmd"
	opt.separator  "     failover-only true/false"
	opt.separator  "     coin"
	opt.separator  "     debug setting"
	opt.separator  "     setconfig name,N"
	opt.separator  "     usbstats"
	opt.separator  "     pgaset N,opt[,val]"
	opt.separator  "     zero Which,true/false"
	opt.separator  "     hotplug N"
	opt.separator  "     asc N"
	opt.separator  "     ascenable N"
	opt.separator  "     ascdisable N"
	opt.separator  "     ascidentify N"
	opt.separator  "     asccount"
	opt.separator  "     ascset N,opt[,val]"
	opt.separator  "     lcd"
	opt.separator  "     lockstats"
  opt.on("-g","--grep STRING","String to grep output for.", String) { |val| cmd2 = val }
  opt.on("-H","--host N","Hostname to connect to.", String) { |val| hostname = val }
  opt.on("-P","--port N","Port to connect to", Integer) { |val| port = val }
  opt.on("-h","--help","help") do
		puts opt_parser
    exit
	end
end
opt_parser.parse!

# Work around for bad JSON
if cmd == "stats"
  cmd = "estats"
end

# Print help if options passed in wrong order
if cmd.include? "-"
  puts opt_parser
  exit
end
if cmd == "help"
  puts opt_parser
  exit
end

# Request to cgminer
request = {"command":cmd,"parameter":"0"}.to_json

# Connect to cgminer api
begin
  cg = TCPSocket.open(hostname, port)
  cg.write request
  results = cg.gets
  # Work around for bad JSON
  results.gsub!('[,', '[')
  if cmd2.to_s.empty?
    puts "Query #{cmd}"
    puts YAML.dump(JSON.parse(results.strip))
  else
    a = YAML.dump(JSON.parse(results.strip))
    a.each_line.grep(/#{cmd2}/).each do |line| puts "#{line}" end
  end
  cg.close
rescue => e
  puts "Error: \"#{e.message.chomp}\""
end

