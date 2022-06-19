## Useful commands

- Display audio devices: `arecord -l`
- Start the container: `docker run -it --rm --platform linux/arm/v7 sonicpi`

# AUTOFI
This project was made for the course COM-418: Computers and Music. The goal is to create Lo-Fi music that is endlessly generated by a computer, and is accessible on a website: similarly to web radios one can find online. The user can personnalize the music to change different parameters: the background, the speed, and generally the mood.

## About LOFI
Lofi/LoFi/Lo-Fi (hip-hop in particular) is a popular genre of music mostly used to study or relax. It usually doesn't have any lyrics, is quite repetitive and where distortion, hum or background noise are often present. Recreating the repetitivness is easy, however creating music that is not too repetitive is harder.

## Tools we used
We used principaly the software Sonic Pi by Sam Aaron, in Ruby, as it enabled users to code music live, which is exactly what we needed.

## How to run this project on your computer

### Interactive interface

The interface is basically seperate in two collumns. The right one have three different settings button. The highest is the play/pause button which is clickable. The second, controls the BPM of the music. And the most important one, we called it : "The mood controler pannel". Each axis have six stages and you can click on the pannel to change the mood of the song.
The second collumns controls all possible background effect or ambiance that you want. By clicking on them you can have sound from a particular weather or a particular place in background of the music. Also you could see the background image changing depending on which background you choose.
### Overall structure
Hopefully you know a little bit about music!
We decided to have song-like structures, to try to simulate the radio effect, where songs change one after the other. A song is made different stages: a beginning, a "normal" middle part (`NOR1`), a bridge, another "normal" middle part(`NOR2`), and an end. In pop music, the normal middle part is usually the verse and chorus. A counter counts each beat, and signals when a change is made between each stage, and also when the song ends (the counter has reached the end stage). The stages have a randomized duration, to get the songs to last between 3 and 6 minutes no matter the tempo.

Inside a stage, the structure is in loop of 2 measures (meaning 8 beats).
### Rhythm
The rhythm is dependent of one user parameters: the intensity which ranges from 0 to 5. At 0, there is no rhythm, at 1 a bit more and etc. until 5. To be able to code the different rhythms, one can imagine that the 2 measures form a grid of semi-quavers (so 32 in total), and we place the different rhythms that we want to play on this grid. To make it a bit more entertaining, there is a lot of different randomization: many sounds have a randomized amplitude, some instruments are added or removed according to the song (to have a difference between two songs). 
Effects are also added to the rhythms according to the stage we are at: at the end of a song, the global rhythm amplitude decays, and comes back at the beginning of the next song. During the bridge, a low pass filter was added for some songs, to give a muffled sound. 
### Chord Progressions
The chords are grouped in themes, which are always made of 4 chords. The themes are created manually but can be transposed in any key (see <em>chords_list.rb</em>). The theme selection depends on the mood controler pannel. To match the desired mood, several modes (scales) are used. The modes used are (from happiest to saddest) : "mixolydian", "lydian", "major", "minor", "dorian", "harmonic major". The themes are generated at the following song section changes : at the beginning of the song, when passing from the normal part to the bridge, and inversely. To ensure a smooth transition form a theme to another, a cadence is placed between them, which is computed according to the key and the mode of each theme.

### Melody
### Background
The background noises are sampled from the website https://mixkit.co/free-sound-effects/ to get different atmospheres, characteristic of Lo-Fi music. The user can therefore choose different weathers:
- light rain
- thunder
- sunny morning (you can hear birds chirping)
- hot summer night (you can hear crickets)
- No weather
and different places: 
- Country-side (hens and chickens!)
- Coffee-shop (people talking in the background)
- City
- Space (I will let you discover this one by yourself...)
- Nowhere 

### Instruments Effects 
The chords are played by 3 instruments : synth keys, pads and bass.
- The synth keys sweep through each chord. The duration of the sweep is set randomly for each chord. the chords are placed randomly on the down and up beats. The instrument is built as a sine wave going through a light distortion, a formant filter and finally a reverb. it imitates the sound of an electric piano or a Rhodes.
- the pads play all notes of one chord at the same time but transpose one octave higher, the chords are played at regular interval. The instrument is built as an ambiant pad synth going through a distortion and a high-pass filter. It is used to fill the space and the high-passed distortion add a <em>lofi grain</em> to the sound.
- the bass plays only the first note of each chord tranposed 2 octaves lower. It is a basic sine wave with an envelop with long decay.
The melody is played by a caverneous sounding synth passing through a reverb. Each note is randomly panned to add movement to the music.

## Useful commands

- Display audio devices: arecord -l
- Start the container: docker run -it --rm --platform linux/arm/v7 sonicpi

## Few noted bugs left...
If the bpm is too fast (more than 150), then Sonic Pi has a hard time following everything that it has to do and gives a runtime error.
