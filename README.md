##Mt Watts
This gem is for those who love the sweet sonds of MIDI music but lack the resources or talent to make any for themselves.  It is a command line tool that creates proceedurally generated music customized to the user's tastes.

##Dependencies
This gem has two important dependencies: Midilib and JSON.  You can install these using bundle install or manually.

##How to use

Install Mrwatts
>	gem install Mrwatts

Get Mrwatts to compose using default settings
>	Mrwatts

Or, specify how you want your song to sound
>	Mrwatts --scale melodic_minor --bpm 180

<p>Your song will be saved as a file named crab_cakes.mid in your current directory.</p>

###Scales
<p>Here is a complete list of available scales:</p>
<ul>
	<li>Major</li>
	<li>Minor</li>
	<li>Ionian -- same as "major".</li>
	<li>Dorian -- minor scale; somewhat mysterious sounding.</li>
	<li>Phrygian -- minor scale; used often in metal.</li>
	<li>Lydian -- major scale; somewhat mysterious sounding.</li>
	<li>Mixolydian -- major scale; used often in blues.</li>
	<li>Aeolian -- same as "minor".</li>
	<li>Locrian -- minor/diminished scale; also used in metal.</li>
	<li>Harmonic_minor -- minor scale; used alternative to aeolian that gives more satisfying resolutions.</li>
	<li>Melodic_minor -- minor scale; used often in jazz and classical music.</li>
	<li>Chromatic -- contains every note; sounds very eerie and atonal when Mr Watts uses it.</li>
</ul>

###BPM
The default BPM (beats per minute) is 120.  A higher number makes the song faster and a lower number makes the song slower.

##Disclaimer
This gem is still a work in progress, and many of the planned features have not yet been implemented.  A lot of the songs you generate may sound terrible.

##Known Bugs
<ol>
	<li>Some scale/progression/melody combinations sound really terrible.</li>
</ol>
##TODO:
<ol>
	<li>Support for a single sequence being in a different mode, to do things like switch to dorian for the IV chord</li>
	<li>Percussion</li>
	<li>Motifs/themes -- snippets that are reused to make a coherent melody</li>
	<li>Sequence categorization -- sequences that go only at the beginning of a phrase, at the end, or both</li>
	<li>Add support for progressions intended only for major keys, or minor keys, or both.</li>
	<li>Combine the basslines and chords data into the same json file to give them greater independence from each other while still being connected</li>
	<li>If the phrase ends before the measure, add an appropriate amount of silence to fill the rest of the measure up</li>
	<li>Support for different instruments</li>
	<li>Some major refactoring/separating into multiple files</li>
</ol>

