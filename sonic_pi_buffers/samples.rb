#SAMPLE PAGE


#SAMPLES WEATHER
define :morning do
  sample "C:/Users/clema/Downloads/mixkit-little-birds-singing-in-the-trees-17.wav",rate:(rrand 0.125, 1.5),amp:0.1
  sleep (rrand 8, 15)
end

define :light_rain do
  sample "C:/Users/clema/Downloads/mixkit-light-rain-looping-1249.wav", amp:1
  sleep 96
end

define :thunder do
  sample "C:/Users/clema/Downloads/mixkit-thunderstorm-ambience-1289.wav", amp:0.8
  sleep 28
end

define :hot_summer_night do
  sample "C:/Users/clema/Downloads/mixkit-summer-night-crickets-1787.wav"
  sleep 32
end

#SAMPLES PLACE
define :city do
  sample "C:/Users/clema/Downloads/mixkit-urban-city-sounds-and-light-car-traffic-369.wav", amp:0.1
  sleep 24
end

define :country_side do
  sample "C:/Users/clema/Downloads/mixkit-hens-and-rooster-ambience-1756.wav", amp: 0.2
  sample "C:/Users/clema/Downloads/mixkit-farm-animals-in-the-morning-7(1).wav", amp:0.1
  sleep 44
end
define :forest do
  sample "C:/Users/clema/Downloads/mixkit-meadow-birds-isolated-28.wav", amp: 0.2
  sleep 33
end

define :space do
  sample "C:/Users/clema/Downloads/mixkit-sci-fi-computer-technology-2501.wav", rate:(rrand 0.125, 1.5), cutoff: rrand(60, 120), amp:0.1
  sample "C:/Users/clema/Downloads/mixkit-space-void-ambiance-2006.wav", rate:(rrand 0.125, 3), amp:1
  sample "C:/Users/clema/Downloads/mixkit-asteroid-space-atmosphere-2004.wav", rate:(rrand 0.01, 0.3), amp:0.3
  sleep (rrand 7, 14)
end

define :coffee_shop do
  sample "C:/Users/clema/Downloads/mixkit-hotel-lobby-with-dining-area-ambience-453.wav", amp:0.7
  sleep 46
end

define :fireplace do
  sample "C:/Users/clema/Downloads/mixkit-campfire-crackles-1330.wav", amp:2
  sleep 24
end

define :sea do
  sample "C:/Users/clema/Downloads/mixkit-people-bathing-in-the-sea-ambience-348.wav", amp:0.1, rate:(rrand 0.125, 1.5)
  sample "C:/Users/clema/Downloads/mixkit-sea-waves-with-birds-loop-1185.wav", amp: 0.1, rate:(rrand 0.125, 1.5)
  sleep 36
end





