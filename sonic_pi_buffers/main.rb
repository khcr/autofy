#USER DEFINABLE VARIABLES
set :bpm, 90
set :weather, "light_rain"
set :place, "forest"
set :intensity, 3 #from 0 to 5
set :mood, 3 #from 0 to 5

#GLOBAL VARIABLES
#global global ones
set :counter, 0
set :song, 0
set :d_beg,10 # rrand_i(get(:bpm)*8/60, get(:bpm)*25/60)
set :d_bridge,10# rrand_i(get(:bpm)*40/60, get(:bpm))
set :d_end,10# rrand_i(get(:bpm)*8/60, get(:bpm)*25/60)
set :d_nor1,10 #rrand_i(get(:bpm)*120/60, get(:bpm)*140/60)
set :d_nor2, 10#rrand_i(get(:bpm)*120/60, get(:bpm)*140/60)

#for the chords
set :cur_note, :c4
set :cur_mode , (modes_from_mood(get(:mood), "BEGINNING").choose())
set :cur_theme_chords, (method(mode_theme(get(:cur_mode))).call(get(:cur_note)))


#for the rhythm
set :theme_duration, 8 # 2 measures
set :max_sweep, 0.8
set :theme_rhythm, (theme_timestamps get(:theme_duration))
set :cadence_rhythm, (cadence_rhythm get(:theme_duration))

#STRUCTURE AND COUNTER
set :current_stage, "BEGINNING"

in_thread(name: :counter_stages) do
  loop do
    use_bpm get(:bpm)
    cue :tick
    set :counter, get(:counter) + 1
    sleep 1
    set :current_stage, get_stage(get(:counter))
    if get(:counter) == get(:d_beg) + get(:d_bridge) + get(:d_nor1) + get(:d_nor2) + get(:d_end)
      set :counter, 0
      set :song, get(:song) + 1
    end
  end
end


define :get_stage do |counter|
  if counter <= get(:d_beg)
    set :get_stage, "BEGINNING"
  elsif counter <= get(:d_nor1) + get(:d_beg)
    set :get_stage, "NOR1"
  elsif counter <= get(:d_bridge) + get(:d_nor1) + get(:d_beg)
    set :get_stage, "BRIDGE"
  elsif counter <= get(:d_nor2) + get(:d_bridge) + get(:d_nor1) + get(:d_beg)
    set :get_stage, "NOR2"
  elsif counter <= get(:d_end) + get(:d_nor2) + get(:d_bridge) +get(:d_nor1) + get(:d_beg)
    set :get_stage, "END"
  end
  
end

#place and weather loop #TODO: change the sample size to be able to change directly
in_thread(name: :bckg_weather) do
  loop do
    sync :tick
    background_weather get(:weather)
  end
end
in_thread(name: :bckg_place) do
  loop do
    sync :tick
    background_place get(:place)
  end
end

#LOOP FOR MELODY AND CHORDS

in_thread(name: :chords) do
  loop do
    use_bpm get(:bpm)
    sync :tick
    use_synth :sine
    with_fx :gverb, mix:0.5,spread:0.6,amp:0.4,damp:0.1,room: 80,tail_level: 1 do
      
      with_fx :vowel,voice: 3, vowel_sound: 4, amp: 3,mix: 0.2, pre_amp: 0.2 do
        with_fx :tanh, mix: 0.1,krunch: 0.2 do
          
          mood = get(:mood)
          current_stage = get(:current_stage)
          cur_note = get :cur_note
          cur_theme_chords = get :cur_theme_chords
          cur_mode = get :cur_mode
          
          sweep_theme cur_theme_chords, get(:theme_rhythm), get(:theme_duration), get(:max_sweep) #on joue le truc
          
          #le moment ou ca passe a bridge: cadence
          next_stage = get_stage (get(:counter) + get(:theme_duration))
          if next_stage != current_stage and (next_stage == "BEGINNING" or next_stage == "BRIDGE" or next_stage == "NOR2")
            
            next_theme_chords,cadence_chords,next_mode,next_note = next_theme_cadence cur_theme_chords,cur_note,cur_mode, mood, current_stage
            theme_rhythm = theme_timestamps get(:theme_duration) #rythme accord
            cadence_rhythm = cadence_rhythm get(:theme_duration) #rythme cadence
            
            #cadence
            sweep_theme cadence_chords, cadence_rhythm,get(:theme_duration), get(:max_sweep)
            cur_theme_chords = next_theme_chords
            set :cur_mode, next_mode
            set :cur_note, next_note
            
            #set prochaines chords
            set :cur_theme_chords, next_theme_chords
            
          end
        end
      end
      
    end
  end
end

in_thread(name: :melody) do
  note_prob = (get(:intensity).to_f/5)/2 + 0.5
  with_fx :reverb do
    loop do
      use_synth :hollow
      play_melody get(:cur_note),get(:cur_mode),get(:cur_theme_chords),get(:theme_duration),note_prob
    end
  end
end

in_thread(name: :pads) do
  loop do
    with_fx :hpf, cutoff: 90 do
      with_fx :distortion, distort: 0.6,mix:0.5 do
        use_synth :dark_ambience
        chords = get(:cur_theme_chords)
        note_duration = get(:theme_duration)/4
        chords.each() do |c|
          c.each() do |i|
            play i, decay: 2, pitch: 12, amp: 0.2
          end
          
          sleep note_duration
        end
      end
    end
  end
end


in_thread(name: :chill_rythm) do
  base_cutoff = 105
  with_fx :lpf,cutoff: base_cutoff  do |c|
    with_fx :level, amp: 0 do |a|
      loop do
        
        if get(:current_stage) == "BEGINNING"
          puts "---------- LENGTH BEG: #{get(:d_beg)} ----------"
          #control c, cutoff: 130, cutoff_slide: get(:d_beg)
          control a, amp: 1, amp_slide: get(:d_beg)
        end
        if get(:current_stage) == "NORMAL"
          puts "---------- LENGTH NORMAL: #{get(:d_nor1)},  #{get(:d_nor2)}----------"
          control c, cutoff: base_cutoff, cutoff_slide: rrand(0, get(:d_beg))
        end
        if get(:current_stage) == "BRIDGE"
          puts "---------- LENGTH BRIDGE: #{get(:d_bridge)} ----------"
          control c, cutoff: choose([10, 20, base_cutoff, base_cutoff, base_cutoff, base_cutoff]), cutoff_slide: rrand(5, 10)
        end
        if get(:current_stage) == "END"
          puts "---------- LENGTH END: #{get(:d_end)} ----------"
          control a, amp: 0.1, amp_slide: get(:d_end)
        end
        
        use_bpm get(:bpm)
        cue :tick
        rythm get(:intensity),get(:place), get(:current_stage)
      end
    end
  end
end


define :play_melody do |note,mode,theme,duration,prob_note|
  
  melody_offset = 12
  base_note = note+ melody_offset
  chord_duration = duration.to_f/theme.length
  amp_value = 3
  min_pan = -0.2
  max_pan = 0.2
  min_decay = 0.3
  max_decay = 0.8
  note_prob_array = [prob_note,prob_note,prob_note,prob_note].shuffle()
  phrase_prob_array = [1,1,0,0].shuffle()
  note_prob_array = note_prob_array.zip(phrase_prob_array).map{|p1,p2| p1.to_f*p2.to_f}
  mode_map = {'major' => :major, 'dorian'=> :dorian,'lydian'=> :lydian,'mixolydian'=> :mixolydian,'minor'=> :minor,'harmonic_major'=>:harmonic_major}
  #cur_mode = mode_map[mode]
  theme.zip(note_prob_array).each() do |c,p|
    case rrand_i(1,1)
    
    when 1
      #arpegiate
      note_duration = chord_duration.to_f/c.length
      note_duration  = chord_duration/4
      arpeggio = c.map{|n| n + melody_offset}.shuffle.slice(0,4)
      
      arpeggio.each() do |n|
        if rrand(0,1) < p
          play n,decay: rrand(0.5, 1),amp: amp_value,pan: rrand(min_pan, max_pan),decay: rrand(min_decay, max_decay)
        end
        sleep note_duration
        
      end
    when 2
      
      #sequence
      note_duration = chord_duration.to_f/4
      #select random starting note
      
      cur_scale = scale(base_note, mode_map[mode])
      starting_note = [0,2,4,6].choose()
      #go up or down
      sequence_direction = [-1,1].choose()
      sequence =  * [0,1,2].map{|i| i * sequence_direction}
      
      sleep note_duration
      
      sequence.each() do |i|
        if rrand(0,1) < p
          play cur_scale[starting_note +sequence[i]], amp: amp_value, pan: rrand(min_pan, max_pan),decay: rrand(min_decay, max_decay)
        end
        sleep note_duration
      end
      
    when 3
      
      #enclosure
      cur_scale = scale(base_note, mode_map[mode])
      #choose starting note
      
      #find manually element index
      
      target_degree =  base_note +  [0,1,3,4].choose()
      note_duration = chord_duration/4
      sleep note_duration
      if rrand(0,1) < p
        play cur_scale[target_degree+1], amp: amp_value,pan: rrand(min_pan, max_pan), decay: rrand(min_decay, max_decay)
      end
      
      sleep note_duration
      if rrand(0,1) < p
        play cur_scale[target_degree-1], amp: amp_value,pan: rrand(min_pan, max_pan),decay: rrand(min_decay, max_decay)
      end
      
      sleep note_duration
      if rrand(0,1) < p
        play cur_scale[target_degree], amp: amp_value, pan: rrand(min_pan, max_pan),decay: rrand(min_decay, max_decay)
      end
      
      sleep note_duration
    end
  end
end

