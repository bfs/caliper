require 'json'
require 'bundler'

Bundler.require

ROOT_DIR = File.dirname(__FILE__)


if Sinatra::Application.environment() == :production
  log_path = '/var/log/caliper/'
  warn "Redirecting stdout and stderr to #{log_path}"
  STDOUT.reopen(File.new("#{log_path}api-out.log", 'a'))
  STDERR.reopen(File.new("#{log_path}api-err.log", 'a'))
end


class App < Sinatra::Base
  enable :show_exceptions
end

require_relative 'lib/caliper_browser'


require_relative 'routes/measure'