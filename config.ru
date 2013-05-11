require 'my_server'

use Rack::ShowExceptions

run TrafficLightPiServer.new
