require 'traffic_light_pi_server'

use Rack::ShowExceptions

run TrafficLightPiServer.new
