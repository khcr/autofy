#SAMPLE PAGE

PATH = "/Users/khcr/Projets/GitHub/autofy/sonic_pi_buffers/samples/" # Keran

#SAMPLES WEATHER
define :morning do
  sample PATH + "mixkit-little-birds-singing-in-the-trees-17.wav", amp: 0.8
  sleep (rrand 8, 15)
end

define :light_rain do
  sample PATH + "mixkit-light-rain-looping-1249.wav", amp: 1
  sleep 96
end

define :thunder do
  sample PATH + "mixkit-thunderstorm-ambience-1289.wav", amp: 0.8
  sleep 28
end

define :hot_summer_night do
  sample PATH + "mixkit-summer-night-crickets-1787.wav", amp: 1
  sleep 32
end

#SAMPLES PLACE
define :city do
  sample PATH + "mixkit-urban-city-sounds-and-light-car-traffic-369.wav", amp: 0.5
  sleep 24
end

define :country_side do
  sample PATH + "mixkit-hens-and-rooster-ambience-1756.wav", amp: 0.3
  sample PATH + "mixkit-farm-animals-in-the-morning-7(1).wav", amp:0.2
  sleep 44
end

define :space do
  sample PATH + "mixkit-sci-fi-computer-technology-2501.wav", rate:(rrand 0.125, 1.5), cutoff: rrand(60, 120), amp:0.1
  sample PATH + "mixkit-space-void-ambiance-2006.wav", rate:(rrand 0.125, 3), amp:1
  sample PATH + "mixkit-asteroid-space-atmosphere-2004.wav", rate:(rrand 0.01, 0.3), amp:0.3
  sleep (rrand 7, 14)
end

define :coffee_shop do
  sample PATH + "mixkit-hotel-lobby-with-dining-area-ambience-453.wav", amp:0.7
  sleep 46
end







