#!/usr/bin/env ruby

require 'open3'

REMOTE_USER = 'taro_morita'
REMOTE_HOST = 'dev-tmorita'
REMOTE_DEST = '/var/www/rpst-v2/dev/'
PROJECT_DIR = __dir__

if ARGV.empty?
  puts 'Error: no arguments'
  exit 1
end

relative_path = ARGV[0]
local_full_path = File.expand_path(relative_path)

unless File.exist?(local_full_path)
  puts "Error: file not found - #{local_full_path}"
  exit 1
end

remote_full_path = File.join(REMOTE_DEST, relative_path)
remote_destination = "#{REMOTE_DEST}#{relative_path}"
command = [
  'rsync', '-avz', local_full_path, "#{REMOTE_USER}@#{REMOTE_HOST}:#{remote_destination}"
]

success = system(*command)

if success
  puts "File transferred successfully: #{relative_path}"
else
  puts "Error: file transfer failed - #{relative_path}"
end
