# AUTOFI
This project was made for the course COM-418: Computers and Music. The goal is to create Lo-Fi music that is endlessly generated by a computer, and is accessible on a website: similarly to web radios one can find online. The user can personnalize the music to change different parameters: the background, the speed, and generally the mood.

## About LOFI
Lofi/LoFi/Lo-Fi (hip-hop in particular) is a popular genre of music mostly used to study or relax. It usually doesn't have any lyrics, is quite repetitive and where distortion, hum or background noise are often present. Recreating the repetitivness is easy, however creating music that is not too repetitive is harder.

## Tools we used
We used principaly the software Sonic Pi by Sam Aaron, in Ruby, as it enabled users to code music live, which is exactly what we needed.

## Overview

### Files structure

- `sonic_pi_buffers`: Contains the source files for SonicPi, the music code. File `main.rb` is the starting point, the other files are modules that define functions and parameters.
- `static`: assets for the website (CSS/JS/images).
- `templates`: HTML views.
- `sonic-pi`: SonicPi software (compiled and slightly modified for our purpose).
- `app.py`: Flask webapp.
- `icecast.xml`, `ices.xml`: config files for audio streaming server. 

### User interface

The interface is basically split in two collumns. The left side have three different setting buttons. The highest is the play/pause button which is clickable. The second controls the BPM of the music. The most important one, we call it : "The mood control panel", is a XY controller, with each axis divided 6 values. and you can move the cursor the pannel to control the mood of the song.
The right collumn controls all possible background effects or ambiances that you want. By clicking on them you can have obtain a sound from a particular weather or place in the background of the music. The background image always matches the selected place and weather.

### Overall structure

Hopefully you know a little bit about music!
We decided to have song-like structures, to try to simulate the radio effect, where songs change one after the other. A song is made different stages: a beginning, a "normal" middle part (`NOR1`), a bridge, another "normal" middle part(`NOR2`), and an end. In pop music, the normal middle part is usually the verse and chorus. A counter counts each beat, and signals when a change is made between each stage, and also when the song ends (the counter has reached the end stage). The stages have a randomized duration, to get the songs to last between 3 and 6 minutes no matter the tempo.

Inside a stage, the structure is in loop of 2 measures (meaning 8 beats).

### Rhythm

The rhythm is dependent of one user parameters: the intensity which ranges from 0 to 5. At 0, there is no rhythm, at 1 a bit more and etc. until 5. To be able to code the different rhythms, one can imagine that the 2 measures form a grid of semi-quavers (so 32 in total), and we place the different rhythms that we want to play on this grid. To make it a bit more entertaining, there is a lot of different randomization: many sounds have a randomized amplitude, some instruments are added or removed according to the song (to have a difference between two songs). 
Effects are also added to the rhythms according to the stage we are at: at the end of a song, the global rhythm amplitude decays, and comes back at the beginning of the next song. During the bridge, a low pass filter was added for some songs, to give a muffled sound. 

### Chord Progressions

The chords are grouped in themes, which are always made of 4 chords. The themes are created manually but can be transposed in any key (see <em>chords_list.rb</em>). The theme selection depends on the mood control panel. To match the desired mood, several modes (scales) are used. The modes used are (from happiest to saddest) : "mixolydian", "lydian", "major", "minor", "dorian", "harmonic major". The themes are generated at the following song section changes : at the beginning of the song, when passing from the normal part to the bridge, and inversely. Once the theme is generated, it is repeated until the end of the section. To ensure a smooth transition from a theme to another, a cadence is placed between them, which is computed according to the key and the mode of each theme. 
The next theme is generated from the previous with 3 possible modulations:
- Moving to a relative mode. the tonic is moved randomly to match a mode relative to the previous one, i.e. that uses the same notes.
- Changing the mode. The tonic does not change and the next mode is selected randomly, thus changing the scale.
- Moving to the fourth degree. The tonic is moved a fourth up. A new scale is built, starting from the new tonic and using the mode of the previous theme. The fourth degree is called a neighbour tone, as a scale tranposed a fourth higher still the contains the majority of the notes of the first scale, which ease the modulation.
The cadences are built according to selected modulation, generally following a harmonic sequence, 4-5-1 or 5-1 pattern.

One the modulation scheme is chosen, the mode is selected randomly in a set that varies depending on the mood and on the section of the song.

### Melody

The melody follow the harmonic progressioin. When a theme is played, one of its chords is randomly selected and a melodic phrase is played on it. The melodic phrase can be built in 3 different ways:
- create an arpeggio from 4 notes taken randomly in the chord
- create a rising or a falling sequence from a degree selected randomly in the scale. The sequence constist of 3 neighbour notes in the scale
- create an enclosure of a degree selected randomly in the scale, i.e. playing a note upper, a note lower and then the target note (here the scale degree selected at random).

Once the musical phrase is built, its notes are played with a probability relative the intensity set by the user in the mood control panel. If the intensity is high, almost all notes of the phrase are played, and vice versa.

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

### Instruments and Effects 

The chords are played by 3 instruments : synth keys, pads and bass.
- The synth keys sweep through each chord. The duration of the sweep is set randomly for each chord. the chords are placed randomly on the down and up beats. The instrument is built as a sine wave going through a light distortion, a formant filter and finally a reverb. it imitates the sound of a gloomy glockenspiel or a Rhodes.
- the pads play all notes of one chord at the same time but transpose one octave higher, the chords are played at regular interval. The instrument is built as an ambiant pad synth going through a distortion and a high-pass filter. It is used to fill the space and the high-passed distortion add a <em>lofi grain</em> to the sound.
- the bass plays only the first note of each chord tranposed 2 octaves lower. It is a basic sine wave passing trhough an envelop with long decay.
The melody is played by a caverneous sounding synth passing through a reverb. Each note is randomly panned to add movement to the music.

## Deployment

SonicPi is a great tool to play with music, but the distribution of the outcome is another story. The final product should be a website, from which a user can stream personalized lo-fi music in real-time. This implies to have the following pipeline on a server:
- A SonicPi instance running the code and producing the music based on parameters
- A audio streaming server (e.g Icecast)
- A webserver serving the user interface and exposing an API to talk with SonicPi

The main challenge is to deal with SonicPi, which was not designed for such purpose. Therefore, we have not reached the final goal yet. As of today, we can run a headless (without GUI) SonicPi server and control it via OSC requests. OSC stands for Open Sound Control and is a protocol for audio networking. OSC is well supported by SonicPi, which can be exclusively controlled via OSC requests (e.g run code or stop the music, update parameters, etc). The current website is fully working, but instead of playing music from a stream, it is a remote for SonicPi, i.e. it controls what SonicPi outputs.

### Installation

We only tested the setup on Intel Macbook Pro running Mac OS 10.15 (SonicPi was compiled for this plateform).

Requirements:
- Ruby 2.7+
- Python 3.6+
- Flask 2.0+

To run the SonicPi server, go to the folder `sonic-pi/app/server/ruby/bin` and run `ruby sonic-pi-server.rb`. You should see the message `Sonic Pi Server successfully booted.`.

To run the webserver, in the root folder run `flask run`. You should see the message `Running on http://127.0.0.1:5000/`.

If both servers successfully booted, you should be able to use the web interface at `http://127.0.0.1:5000` and play with the music. Be aware that changing a parameter may not be reflected directly and can take up to a few minutes. If you want to see the effect directly, press pause and play again to restart.

When the SonicPi server is stopped, a process might stay alive and block the port 4560, which prevents the restart. Run `lsof -nP -i:4560` to display the PID of the process and `kill -9 $PID` to stop it.

## Few noted bugs left...

If the bpm is too fast (more than 150), then Sonic Pi has a hard time following everything that it has to do and gives a runtime error. Thus, the bpm is limited between 1 and 140 on the web interface.

## To improve
The themes always contain 4 chords, which is monotone. Modulating the number of chords per theme would add more variation and allow the song to breath more a certain moments. The melody is generated every time a theme is played, thus no pattern is repeated. Locking one or more patterns at a certain moment, and alternate between them would add a feel of constrution to the melodic and something that is rememberable. The instruments are constantly playing, their volume could be adjusted depending on the section of the song. At the moment there is only one theme per mode, but this can be increased to obain more diversity across the songs. Each mode was originally supposed to be a <em>theme bank</em>.
