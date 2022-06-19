#RHYTHM

#RYTHM PAGE

define :cymbal do |more, place|
  if place=="space"
    sample :elec_twip , amp:0.3
  else
    if more == 1
      if (get(:song) == 5.times.map{Random.rand(50)} or get(:song) == 1)
        sample :drum_cymbal_pedal, amp: 0
      else
        sample :drum_cymbal_pedal, amp: 0.2
      end
    elsif more >= 5
      sample :drum_cymbal_pedal, amp:1
    elsif more >1
      if get(:song) == 30.times.map{Random.rand(50)}
        sample :drum_cymbal_pedal, amp: 0.2
      else
        sample :drum_cymbal_pedal, amp: 1
      end
    end
  end
  
  sample :bd_tek, amp: choose([0, 0.1, 0.2, 0.3, 0.5]) if more >= 4
  
end



define :added_cymbal do |more, stage|
  if stage != "BEGINNING" and get(:song) == 45.times.map{Random.rand(50)}
    if more >= 5
      sample :drum_cymbal_pedal, amp: choose([0, 0.1, 0.2, 0.3, 1.5])
      sample :bd_fat, amp: choose([0, 0.1, 0.2, 0.3, 1])
    elsif more >=3
      sample :drum_cymbal_pedal, amp: choose([0, 0.1, 0.2, 0.3, 1.5])
      sample :bd_fat, amp: choose([0, 0.1, 0.2, 0.3, 1])
    end
  end
end

define :kick_hiphop do |more, place|
  if place == "space" and more >=5
    sample :elec_blup, amp:choose([0, 0.1, 0.2, 0.3, 1.5])
  else
    if more >=5
      sample :drum_cymbal_pedal, amp:6
      sample :drum_snare_hard, amp:choose([0, 0.1, 0.2, 0.3, 1.5])
    elsif more >=4
      sample :drum_cymbal_pedal, amp:3
      sample :drum_snare_hard, amp:choose([0, 0.1, 0.2, 0.3, 0.5])
    end
  end
end

define :snap do |more, stage|
  if (more >=4 and (get(:song) != 1 or get(:song) == 10.times.map{Random.rand(50)}))
    with_fx :flanger do
      sample :perc_snap2, rate: 0.8, amp: 0.2
    end
  end
end

define :snare_soft do |more, stage|
  sample :drum_snare_soft if (more >1 and stage != "BEGINNING" and (get(:song) != 1 or get(:song) == rrand_i(0, 5) or get(:song) == rrand_i(7, 15)))
end

define :snare_hard do |more|
  sample :drum_snare_hard, amp:choose([0, 0.1, 0.05, 0.15, 0.5]) if more >= 2
end

define :cymbal_open do |more|
  if (get(:song) == 20.times.map{Random.rand(50)} or get(:song) == 1)
    sample :drum_cymbal_open, amp:0
  else
    sample :drum_cymbal_open, amp:choose([0, 0.1, 0.2, 0.3, 0.5]) if more >= 1 and more <4
    sample :drum_cymbal_open, amp:choose([0.1, 0.2, 0.3,2]) if more >=4
  end
end

define :bass_soft do |place, stage|
  if stage != "BEGINNING"
    if place == "space"
      sample :elec_beep, amp: 0.5
    else
      sample :drum_bass_soft, amp:0.5
    end
  end
  
end


define :bass_hard do |more|
  sample :drum_bass_hard, amp:choose([0, 0.1,0.15,0.5]) if more > 1
end


define :rythm do |more, place, stage|
  cymbal more, place # >= 5, >=1
  bass_soft place, stage # not beginning
  snare_soft more, stage
  sleep 0.25
  sleep 0.25
  added_cymbal more, stage # not beginning, >=5, >= 3
  snap more, stage
  sleep 0.25
  sleep 0.25
  
  cymbal more, place
  snare_soft more, stage
  sleep 0.25
  sleep 0.25
  added_cymbal more, stage
  snap more, stage
  sleep 0.25
  sleep 0.25
  
  cymbal more, place
  kick_hiphop more, place
  sample :tabla_dhec, amp: 1 if more >=1
  snare_soft more, stage
  sleep 0.25
  sleep 0.25
  snare_hard more
  added_cymbal more, stage
  snap more, stage
  sleep 0.25
  sleep 0.25
  
  cymbal more, place
  sleep 0.25
  sleep 0.25
  snare_hard more
  added_cymbal more, stage
  snare_soft more, stage
  snap more, stage
  sleep 0.25
  sleep 0.25
  
  
  #2nd mesure
  
  cymbal more, place
  sleep 0.25
  sleep 0.25
  added_cymbal more, stage
  snap more, stage
  sleep 0.25
  sleep 0.25
  
  cymbal more, place
  bass_soft place, stage
  snare_soft more, stage
  sleep 0.25
  sleep 0.25
  added_cymbal more, stage
  snap more, stage
  sleep 0.25
  sleep 0.25
  
  cymbal more, place
  kick_hiphop more, place
  sample :tabla_dhec, amp: 1 if more >=1
  snare_soft more, stage
  cymbal_open more
  sleep 0.25
  sleep 0.25
  added_cymbal more, stage
  snap more, stage
  sleep 0.25
  sleep 0.25
  
  cymbal more, place
  sleep 0.25
  sleep 0.25
  added_cymbal more, stage
  bass_hard more
  snap more, stage
  sleep 0.25
  bass_hard more
  sleep 0.25
end


