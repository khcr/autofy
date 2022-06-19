#CHORDS LIST

#THEMES AND CADENCES
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


define :minor_theme1 do |note|
  return [
    chord(note+8,:M),
    chord(note-2, :sus4, invert: 3),
    chord(note +3, :add4),
    chord(note-12, :minor7, invert: 3),
  ]
end

define :major_theme1 do |note|
  ref_chords =[
    [:Eb3, :Bb3, :G4, :Bb4, :D5, :G5],
    [:Ab2, :Gb3, :C4, :F4, :C5],
    [:G2, :F3, :B3, :Eb4, :Bb4],
    [:C3, :G3, :Eb4, :G4, :Bb4],
  ]
  
  return ref_chords.map {|chord| chord.map {|i| i + (note-:eb3.to_i)}}
  
end


define :dorian_theme1 do |note|
  return [
    chord(note,:minor),
    chord(note -7, :major,invert:3),
    chord(note,:minor),
    chord(note -7, :minor,invert:3)
  ]
end

define :lydian_theme1 do |note|
  return [
    chord(note,:maj9),
    chord(note+4, :min),
    chord(note+2,:maj9),
    chord(note,:major7)
  ]
end

define :mixolydian_theme1 do |note|
  return [
    chord(note,:M),
    chord(note-2, :M),
    chord(note,:M),
    chord(note-2,:M),
  ]
end

define :harmonic_major_theme1 do |note|
  return [
    chord(note,:major),
    chord(note -7, :minor,invert:3),
    chord(note,:major),
    chord(note -7, :minor,invert:3)
  ]
end

define :cadence_to_4_minor do |note|
  return [
    chord(note, :dom7),
    chord(note-7,:minor7, invert: 3)
  ]
end
define :cadence_to_4_major do |note|
  return [
    chord(note, :dom7),
    chord(note-7,:major7, invert: 3)
  ]
end

define :cadence_major_to_5_minor do |note|
  return [
    chord(note,:maj),
    chord(note+2,:min),
    chord(note-7,:maj, invert: 3),
    chord(note -5, :min,invert: 3)
  ]
end

define :minor_major_cadence1 do |note|
  return [
    chord(note + 5, :minor),
    chord(note+7, :dom7),
    chord(note, :major7,invert:3)
  ]
end


define :major_cadence1 do |note|
  return [
    chord(note + 5, :major),
    chord(note+7, :dom7),
    chord(note, :major7,invert:3)
  ]
end

define :minor_cadence1 do |note|
  return [
    chord(note + 5, :m),
    chord(note+7, :dom7),
    chord(note, :minor7,invert:3)
  ]
end

define :major_minor_cadence1 do |note|
  return [
    chord(note + 5, :major),
    chord(note+7, :dom7),
    chord(note, :minor7,invert:3)
  ]
end

define :to_fourth_cadence do |mode_from|
  
  cadence = []
  
  if mode_from == ('major'||'lydian'||'mixolydian')
    cadence = :cadence_to_4_major
  else
    cadence = :cadence_to_4_minor
  end
  return cadence
end


