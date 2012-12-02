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

		puts "Hello, how you be"
	end

	def tell_joke
		puts "Space."
	end

	def build_melody
		r = Random.new
		melody = []
		length = 16
		#TODO: make this based on sequences rather than
		#single random notes.
		for i in 1 .. length
			melody << r.rand(8)
		end
		melody
	end

	def build_bassline
		[1, 5, 3, 4]
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
			:melodic_minor => [0, 2, 3, 5, 7, 9, 11, 12]
		}
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

	def random_sequence
		r = Random.new
		sequences = [
			[1, 2, 3],
			[1, 5, 3]
		]
		sequences[r.rand(sequences.length)]
	end

	def build_track(note_array, track, scale, note_length, pitch)
		note_array.collect! { |n| n + @octaves[pitch] }
		note_array.each do |offset|
		  off = (offset - 1) % 8
		  oct = offset - off
		  s = @scales[scale]
		  track.events << NoteOn.new(0, oct + s[off], @velocity, 0)
		  track.events << NoteOff.new(0, oct + s[off], @velocity, note_length)
		  
		  #track.chord([s[], s[o + 2]])
		end
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

		note_lengths = {
			:whole => seq.note_to_delta('whole'),
			:half => seq.note_to_delta('half'),
			:quarter => seq.note_to_delta('quarter'),
			:eighth => seq.note_to_delta('eighth')
		}
		
		#melody
		# Create a track to hold the notes. Add it to the sequence.
		melody_track = ReggieTrack.new(seq, @song)
		seq.tracks << melody_track

		# Give the track a name and an instrument name (optional).
		melody_track.name = 'Melody Track'
		melody_track.instrument = GM_PATCH_NAMES[0]

		melody_track.events << ProgramChange.new(0, 1, 0)
	 	@melody = build_melody

	 	#TODO:make this less awful
		build_track(@melody, melody_track, scale, note_lengths[:quarter], 4)

		#bassline
		bassline_track = ReggieTrack.new(seq, @song)
		seq.tracks << bassline_track
		bassline_track.events << ProgramChange.new(0, 1, 0)

		@bassline = build_bassline

		build_track(@bassline, bassline_track, scale, note_lengths[:whole], 2)

		# Calling recalc_times is not necessary, because that only sets the events'
		# start times, which are not written out to the MIDI file. The delta times are
		# what get written out.
		# track.recalc_times

		File.open("#{@song_name}.mid", 'wb') { | file |
			seq.write(file)
		}
		puts "built"
	end
end