require 'midilib'
require 'json'
require 'reggie_track'

include MIDI

class Mrwatts

	def initialize
		@song = MIDI::Sequence.new()
		@song_name = format_title_for_file("Crab Cakes")
		@scales = get_scales
		@bpm = 120

		@octaves = [16, 28, 40, 52, 64, 76, 88, 100, 112, 124]

	 	s = Sequence.new()

		@note_lengths = {
			:whole => s.note_to_delta('whole'),
			:half => s.note_to_delta('half'),
			:quarter => s.note_to_delta('quarter'),
			:eighth => s.note_to_delta('eighth'),
			:sixteenth => s.note_to_delta('sixteenth')
		}

		puts "Hello, how you be"
	end

	def set_scale(scale)
		@scale = @scales[scale]
	end

	def build_melody
		r = Random.new
		melody = []
		#length = 16
		roots = [1, 3, 5, 8] #the root notes for the phrases	

		roots.each { |root| 
			s = random_sequence
			sequences = s[r.rand(s.length)]
			sequences.each { |sequence|
				melody << {:note => sequence[:note] + root - 1, :velocity => sequence[:velocity], :length => sequence[:length]}
			}
		}

		melody
	end

	def build_bassline
		file = open("../lib/sequences/basslines.json")
		json = file.read
		sequences = JSON.parse(json)

		sequences.each do |sequence|
			counter = 0
			sequence.each do |note|
				note["note"] = note["note"].to_i
				note["octave"] = note["octave"].to_i
				length = "#{note['length']}".to_sym
				note["length"] = @note_lengths[length]
			end
		end

		puts sequences[0]
		[
		{:note => 1, :octave => 2, :length => @note_lengths[:whole]},
		{:note => 3, :octave => 2, :length => @note_lengths[:half]},
		{:note => 4, :octave => 2, :length => @note_lengths[:half]},
		{:note => 1, :octave => 2, :length => @note_lengths[:whole]},
		{:note => 3, :octave => 2, :length => @note_lengths[:half]},
		{:note => 4, :octave => 2, :length => @note_lengths[:half]},
		]
	end

	def get_scales
		{
			:ionian => [0, 2, 4, 5, 7, 9, 11],
			:dorian => [0, 2, 3, 5, 7, 9, 10],
			:phrygian => [0, 1, 3, 5, 7, 8, 10],
			:lydian => [0, 2, 4, 6, 7, 9, 11],
			:mixolydian => [0, 2, 4, 5, 7, 9, 10],
			:aeolian => [0, 2, 3, 5, 7, 8, 10],
			:locrian => [0, 1, 3, 5, 6, 8, 10],
			:harmonic_minor => [0, 2, 3, 5, 7, 8, 11],
			:melodic_minor => [0, 2, 3, 5, 7, 9, 11],
			:chromatic => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
		}
	end

	def random_sequence
		sequences = [
			[
				{:note => 1, :length => @note_lengths[:quarter]},
				{:note => 6, :length => @note_lengths[:quarter]}, 
				{:note => 5, :length => @note_lengths[:half]}
			],
			[
				{:note => 1, :length => @note_lengths[:half]},
				{:note => 2, :velocity => 0, :length => @note_lengths[:quarter]},
				{:note => 3, :length => @note_lengths[:eighth]},
				{:note => 5, :length => @note_lengths[:eighth]},
			],
			[
				{:note => 1, :length => @note_lengths[:quarter]},
				{:note => 3, :length => @note_lengths[:quarter]},
				{:note => 0, :velocity => 0, :length => @note_lengths[:quarter]},
				{:note => 3, :length => @note_lengths[:quarter]}				
			]
		]

	end

	def build_track(note_array, track, scale, chords = false, channel)

	  	default_scale = @scales[scale]

		note_array.each do |offset|
			note = offset[:note]
			length = offset[:length]
			mod = offset[:mod] || 0 #modulation: sharp or flat
			octave_index = offset[:octave] || 4
			velocity = offset[:velocity] || @velocity

			puts "note: #{note}, octave: #{octave_index}"
		  	fixed_note = fix_note({:note => note, :oct => octave_index})

		  	note = fixed_note[:note]
		  	oct = @octaves[fixed_note[:oct]]

		  	if chords then
				chord_notes = build_chord(note, octave_index, default_scale)
				track.chord(chord_notes, length)
			else
	  			track.events << NoteOn.new(channel, oct + default_scale[note - 1] + mod, velocity, 0)
	  			track.events << NoteOff.new(channel, oct + default_scale[note - 1] + mod, velocity, length)
	  		end
		end

	end

	def build_chord(note, octave_index, default_scale)
  		one = fix_note({:note => note, :oct => octave_index})
  		three = fix_note({:note => note + 2, :oct => octave_index})
  		five = fix_note({:note => note + 4, :oct => octave_index})
		[
			@octaves[one[:oct]] + default_scale[one[:note] - 1],
			@octaves[three[:oct]] + default_scale[three[:note] - 1],
			@octaves[five[:oct]] + default_scale[five[:note] - 1]
		]
	end

	def fix_note(params)
		note = params[:note]
		oct = params[:oct]

		while note > 7 do
			note -= 7
			oct += 1
		end

		{:note => note, :oct => oct}
	end

	def build(scale = :harmonic_minor)
		@scale = @scales[scale]

		seq = Sequence.new()
		track = ReggieTrack.new(seq, @song)
		seq.tracks << track
		track.events << Tempo.new(Tempo.bpm_to_mpq(@bpm))
		track.events << MetaEvent.new(META_SEQ_NAME, @song_name)

		@velocity = 127
		# Add a volume controller event (optional).
		track.events << Controller.new(0, CC_VOLUME, @velocity)

		#melody
		melody_track = ReggieTrack.new(seq, @song)
		seq.tracks << melody_track

		melody_track.name = 'Melody Track'
		melody_track.instrument = GM_PATCH_NAMES[0]

		melody_track.events << ProgramChange.new(0, 10, 0)

		@melody = build_melody

	 	#TODO:make this less awful
		build_track(@melody, melody_track, scale, 0)

		#bassline
		bassline_track = ReggieTrack.new(seq, @song)
		#seq.tracks << bassline_track

		bassline_track.name = 'Bassline Track'
		bassline_track.instrument = GM_PATCH_NAMES[0]

		bassline_track.events << ProgramChange.new(1, 83, 1)

		@bassline = build_bassline

		build_track(@bassline, bassline_track, scale, 1)

		#chords
		chord_track = ReggieTrack.new(seq, @song)
		seq.tracks << chord_track

		chord_track.name = 'Chord Track'
		chord_track.instrument = GM_PATCH_NAMES[0]

		chord_track.events << ProgramChange.new(1, 83, 1)
		build_track(@bassline, chord_track, scale, true, 2)

		File.open("#{@song_name}.mid", 'wb') { | file | seq.write(file) }

		puts "Built."
	end

	def tell_joke
		puts "What sound does a squirrel make?"
	end

	def format_title_for_file(name)
		"crab_cakes"
	end

	def random_name
		r = Random.new
		names = [
			"Sugar's got it going on",
			"Squirrel",
			"Get your shoes on!",
			"Humans",
			"High Time",
			"Crab Cakes"
		]
		names[r.rand(names.length)]
	end

end