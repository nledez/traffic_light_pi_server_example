require 'traffic_light_pi_server'

#class TrafficLightPiServer < Sinatra::Base
class TrafficLightPiServer
  configure do
    @@line_map = {
      :gauche => {
        :red => 0,
        :green => 3,
      },
      :devant => {
        :red => 6,
        :orange => 10,
        :green => 11,
      },
      :droite => {
        :red => 4,
        :green => 5,
      },
      :fond => {
        :red => 12,
        :orange => 13,
        :green => 14,
      },
    }
    init_lights
  end
end

#TrafficLightPiServer.run!
