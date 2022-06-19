define :modulation_cadence do |mode_from,mode_to|
  
  cadence = mode_from
  modes = ['major','minor','dorian','lydian', 'mixolydian','harmonic_major']
  
  #major - major
  if ['major','lydian','mixolydian'].include?(mode_from) && ['major','lydian','mixolydian'].include?(mode_to)
    cadence = ([:major_cadence1]).choose
  end
  #major-minor
  if ['major','lydian','mixolydian'].include?(mode_from) && ['minor','dorian','harmonic_major'].include?(mode_to)
    cadence = ([:major_minor_cadence1]).choose
  end
  #minor-minor
  if ['minor','dorian','harmonic_major'].include?(mode_from) && ['minor','dorian','harmonic_major'].include?(mode_to)
    cadence = ([:minor_cadence1]).choose
  end
  #minor-major
  if ['minor','dorian','harmonic_major'].include?(mode_from) && ['major','lydian','mixolydian'].include?(mode_to)
    cadence = ([:minor_major_cadence1]).choose
  end
  
  return cadence
end


define :mode_theme do |mode|
  next_theme = []
  if mode == 'major'
    next_theme = ([:major_theme1]).choose
  end
  if mode == 'minor'
    next_theme = ([:minor_theme1]).choose
  end
  if mode  == 'lydian'
    next_theme = ([:lydian_theme1]).choose
  end
  if mode  == 'mixolydian'
    next_theme = ([:mixolydian_theme1]).choose
  end
  if mode  == 'harmonic_major'
    next_theme = ([:harmonic_major_theme1]).choose
  end
  if mode  == 'dorian'
    next_theme = ([:dorian_theme1]).choose
  end
  return next_theme
end

define :next_theme_cadence do |current_theme,note,mode,mood,stage|
  theme = []
  cadence = []
  case  rrand_i(1,3)
  
  when 1
    #modulate
    modes = modes_from_mood mood,stage
    next_mode = modes.choose
    theme =  method(mode_theme(next_mode)).call(note)
    cadence = method(modulation_cadence(mode,next_mode)).call(note)
    next_note = note
  when 2
    #move to relative    
    modes = modes_from_mood mood,stage
    next_mode = modes.choose()
    relative_chord_map = {'major' => :major, 'dorian'=> :minor,'lydian'=> :major,'mixolydian'=> :major,'minor'=> :minor,'harmonic_major'=> :major}
    
    mode_value_map = {'major'=> 0,'harmonic_major'=> 0, 'dorian'=> 2,'lydian'=> 5,'mixolydian'=> 7,'minor'=> 9}
    next_note = note + mode_value_map[next_mode]-mode_value_map[mode]
    theme = method(mode_theme(next_mode)).call(next_note)
    cadence = [chord(next_note - 7,relative_chord_map[mode]), chord(next_note -5, relative_chord_map[next_mode]),chord(next_note,relative_chord_map[next_mode])]
    #end
  when 3
    puts "move to fourth"
    #move to fourth
    next_note = note + 5
    if next_note.to_i < :c4.to_i
      next_note += 12
    end
    
    if next_note.to_i >= :c5.to_i
      next_note -= 12
    end
    
    next_mode = mode
    cadence = method(to_fourth_cadence mode).call(next_note)
    theme = method(mode_theme(next_mode)).call(next_note)
    
    
  end
  #choose next chord grid
  
  if next_note.to_i < :C4.to_i
    next_note += 12
  end
  
  if next_note.to_i >= :C5.to_i
    next_note -= 12
  end
  
  return theme,cadence,next_mode,next_note
end


define :modes_from_mood do |mood,stage|
  case mood
  when 5
    modes = ['lydian','mixolydian']
  when 4
    modes = ['major','lydian','mixolydian']
  when 3
    if stage == "BRIDGE"
      modes = ['dorian','minor']
    else
      modes = ['major','lydian','mixolydian']
    end
  when 2
    modes = ['minor']
  when 1
    if stage == "BRIDGE"
      modes = ['minor','harmonic_major']
    else
      modes = ['dorian']
    end
  when 0
    modes = ['dorian','harmonic_major']
  end
  return modes
end



#basic methods

#play notes of a given chord given a length, in a sweep fashion
define :sweep_chord do |chord,sweep_length|
  chord.each do |i|
    play i, decay: rrand(0.2, 0.5)
    sleep sweep_length/chord.length
  end
end

#play two measures (theme_duration = 8 beats), chords is an array
define :sweep_theme do |chords,timestamps,theme_duration,max_sweep|
  cursor = 0
  chords.zip(timestamps).each do |c,t|
    sweep_duration = rrand(0.1,max_sweep)
    sleep t-cursor
    play c[0]-24, decay: 0.6,amp:0.3
    sweep_chord c, sweep_duration
    
    cursor = t + sweep_duration
  end
  sleep theme_duration-cursor
end


#defines the rhythm for the chords
define :theme_timestamps do |length|
  eighth = length/8
  t1 = ([0,eighth]).choose
  t2 = 2*eighth + ([0,eighth]).choose
  t3 = 4*eighth + ([0,eighth]).choose
  t4 = 6*eighth + ([0,eighth]).choose
  return [t1,t2,t3,t4]
end

define :cadence_rhythm do |length,num_chords|
  
  eighth = length.to_f/8
  rhythm = []
  
  if num_chords == 4
    rhythm = [0, 2*eighth, 4*eighth,6*eighth]
  end
  
  if num_chords == 3
    rhythm = [0, 2*eighth, 4*eighth]
  end
  
  if num_chords == 2
    rhythm = [0,4*eighth]
  end
  
  return rhythm
  
end


