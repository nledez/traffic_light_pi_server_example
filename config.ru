require './my_server.rb'

use Rack::ShowExceptions

run TrafficLightPiServer.new
