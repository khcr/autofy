#BACKGROUND PAGE
define :background_weather do |weather|
  
  if weather == "sunny_morning"
    morning
  elsif weather == "light_rain"
    light_rain
  elsif weather == "thunder"
    thunder
  elsif weather == "hot_summer_night"
    hot_summer_night
  elsif weather == "none"
    sleep 5
  end
  sleep 1
end

define :background_place do |place|
  
  if place == "city"
    city
  elsif place == "country_side"
    country_side
  elsif place == "space"
    space
  elsif place == "coffee_shop"
    coffee_shop
  elsif place == "none"
    sleep 5
  end
  sleep 1
end
