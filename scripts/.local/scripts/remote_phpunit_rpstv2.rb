#!/usr/bin/env ruby

require 'open3'

remote_user = 'taro_morita'
remote_host = 'dev-tmorita'
remote_dest = '/var/www/rpst-v2/dev'
phpunit_config_path = File.join(remote_dest, "tests/app/phpunit/v9/phpunit.xml.dist")

if ARGV.empty?
  puts 'error: no arguments'
  exit 1
end

relative_path = ARGV[0]
remote_full_path = File.join(remote_dest, relative_path)

phpunit_exec = [
  'php',
  File.join(remote_dest, 'vendor/bin/phpunit'),
  '-c', phpunit_config_path, remote_full_path
].join(' ')
command = [
  'ssh', '-q', "#{remote_user}@#{remote_host}", phpunit_exec
]

success = system(*command)
