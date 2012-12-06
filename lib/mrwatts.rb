require 'midilib'
require 'reggie_track'
include MIDI

class Mrwatts

	def initialize(song_name = "crab_cakes")
		@song = MIDI::Sequence.new()
		@song_name = song_name
		@scales = get_scales
		@bpm = 120

		@octaves = [16, 28, 40, 52, 64, 76, 88, 100, 112, 124]

	 	s = Sequence.new()

		@note_lengths = {
			:whole => s.note_to_delta('whole'),
			:half => s.note_to_delta('half'),
			:quarter => s.note_to_delta('quarter'),
			:eighth => s.note_to_delta('eighth')
		}

		puts "Hello, how you be"
	end

	def build_melody
		r = Random.new
		melody = []
		#length = 16
		offsets = [1, 2, 3, 4]
		offsets.each { |offset| 
			s = random_sequence
			sequences = s[r.rand(s.length)]
			sequences.each { |chunk|
				melody << {:note => chunk[:note] + offset - 1, :length => chunk[:length]}
			}
		}

		melody
	end

	def build_bassline
		[
		{:note => 1, :length => @note_lengths[:whole]},
		{:note => 5, :mod => -1, :length => @note_lengths[:half]},
		{:note => 5, :length => @note_lengths[:half]},
		{:note => 3, :length => @note_lengths[:whole]},
		{:note => 4, :length => @note_lengths[:whole]}
		]
	end

	def get_scales
		{
			:ionian => [0, 2, 4, 5, 7, 9, 11, 12],
			:dorian => [0, 2, 3, 5, 7, 9, 10, 12],
			:phrygian => [0, 1, 3, 5, 7, 8, 10, 12],
			:lydian => [0, 2, 4, 6, 7, 9, 11, 12],
			:mixolydian => [0, 2, 4, 5, 7, 9, 10, 12],
			:aeolian => [0, 2, 3, 5, 7, 8, 10, 12],
			:locrian => [0, 1, 3, 5, 6, 8, 10, 12],
			:harmonic_minor => [0, 2, 3, 5, 7, 8, 11, 12],
			:melodic_minor => [0, 2, 3, 5, 7, 9, 11, 12],
			:chromatic => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
		}
	end

	def random_sequence
		#r = Random.new
		#Idea: this data could be stored in as json.
		#TODO: 1. add octave field: by default 0, if it goes over the 'fix'
		#method will figure out what it should be instead
		# 2. Link chords, bassline, and sequences together
		# 2 and a half. Support for a single sequence being in a different mode, to do things like
		# switch to dorian for the IV chord
		sequences = [
			[
				{:note => 1, :length => @note_lengths[:quarter]},
				{:note => 2, :length => @note_lengths[:quarter]}, 
				{:note => 3, :length => @note_lengths[:half]}
			],
			[
				{:note => 1, :length => @note_lengths[:half]},
				{:note => 2, :length => @note_lengths[:quarter]},
				{:note => 3, :length => @note_lengths[:quarter]}
			],
			[
				{:note => 1, :length => @note_lengths[:quarter]},
				{:note => 3, :length => @note_lengths[:quarter]},
				{:note => 5, :length => @note_lengths[:quarter]},
				{:note => 3, :length => @note_lengths[:quarter]}				
			]
		]
		#sequences[r.rand(sequences.length)]
	end

	def build_track(note_array, track, scale, pitch, chords = false, channel)
	  	default_scale = @scales[scale]
		note_array.each do |offset|
			note = offset[:note]
			length = offset[:length]
			mod = offset[:mod] || 0

		  	off = (note - 1) % 8
		  	oct = @octaves[pitch]

			if chords then
			  	chord_notes = [default_scale[fix(off)], default_scale[fix(off + 2)], default_scale[fix(off + 4)]]
			  	track.chord(chord_notes)
		  	else
		  		track.events << NoteOn.new(channel, oct + default_scale[off] + mod, @velocity, 0)
		  		track.events << NoteOff.new(channel, oct + default_scale[off] + mod, @velocity, length)
			end
		end
	end


	def fix(num)
		if num > 8 then num -= 8 end
		num
	end

	def build(scale)

		seq = Sequence.new()
		track = ReggieTrack.new(seq, @song)
		seq.tracks << track
		track.events << Tempo.new(Tempo.bpm_to_mpq(@bpm))
		track.events << MetaEvent.new(META_SEQ_NAME, @song_name)

		@velocity = 127
		# Add a volume controller event (optional).
		track.events << Controller.new(0, CC_VOLUME, @velocity)

		# Add events to the track: a major scale. Arguments for note on and note off
		# constructors are channel, note, velocity, and delta_time. Channel numbers
		# start at zero. We use the new Sequence#note_to_delta method to get the
		# delta time length of a single quarter note.
		
		#melody
		# Create a track to hold the notes. Add it to the sequence.
		melody_track = ReggieTrack.new(seq, @song)
		seq.tracks << melody_track

		# Give the track a name and an instrument name (optional).
		melody_track.name = 'Melody Track'
		melody_track.instrument = GM_PATCH_NAMES[0]

		melody_track.events << ProgramChange.new(0, 10, 0)

		@melody = build_melody

	 	#TODO:make this less awful
		build_track(@melody, melody_track, scale, 4, 0)

		#bassline
		bassline_track = ReggieTrack.new(seq, @song)
		seq.tracks << bassline_track

		bassline_track.name = 'Bassline Track'
		bassline_track.instrument = GM_PATCH_NAMES[0]

		bassline_track.events << ProgramChange.new(1, 83, 1)

		@bassline = build_bassline

		build_track(@bassline, bassline_track, scale, 2, 1)

		File.open("#{@song_name}.mid", 'wb') { | file | seq.write(file) }

		puts "Built."
	end

	def tell_joke
		puts "What sound does a squirrel make?"
	end

	def random_name
		r = Random.new
		names = [
			"Sugar's got it going on",
			"Squirrel",
			"Get your shoes on!",
			"Humans",
			"High Time"
		]
		names[r.rand(names.length)]
	end

end