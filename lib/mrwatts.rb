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
			"whole" => s.note_to_delta('whole'),
			"half" => s.note_to_delta('half'),
			"quarter" => s.note_to_delta('quarter'),
			"eighth" => s.note_to_delta('eighth'),
			"sixteenth" => s.note_to_delta('sixteenth')
		}

		puts "Hello, how you be"
	end

	def scale=(scale)
		@scale = @scales[scale]
	end

	def build_melody
		r = Random.new
		melody = []
		#length = 16
		roots = [1, 3, 5, 8] #the root notes for the phrases	

		roots.each { |root| 
			s = get_sequences
			sequences = s[r.rand(s.length)]
			sequences.each { |sequence|
				melody << {
					"note" => sequence["note"] + root - 1,
					"velocity" => sequence["velocity"],
					"length" => sequence["length"]
				}
			}
		}

		melody
	end

	def format_json(sequences)
		sequences.each do |sequence|
			sequence.each do |note|
				length = "#{note['length']}"
				note["length"] = @note_lengths[length]
			end
		end
	end

	def get_scales
		file = open("lib/data/scales.json")
		json = file.read
		scales = JSON.parse(json)
	end

	def get_sequences
		file = open("lib/data/sequences.json")
		json = file.read
		sequences = JSON.parse(json)
		sequences = format_json(sequences)
	end

	def build_bassline
		file = open("lib/data/basslines.json")
		json = file.read
		sequences = JSON.parse(json)
		sequences = format_json(sequences)

		sequences[Random.rand(sequences.length)]
	end

	def build_track(note_array, track, scale, chords = false, channel)

	  	default_scale = @scales[scale]

		note_array.each do |offset|
			note = offset["note"]
			length = offset["length"]
			mod = offset["mod"] || 0 #modulation: sharp or flat
			octave_index = offset["octave"] || 4
			velocity = offset["velocity"] || @velocity

			puts "note: #{note}, octave: #{octave_index}, length: #{length}"
		  	fixed_note = fix_note({"note" => note, "oct" => octave_index})
		  	puts "oct: #{@octaves[fixed_note["oct"]]}"
		  	note = fixed_note["note"]
		  	oct = @octaves[fixed_note["oct"]]

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
  		one = fix_note({"note" => note, "oct" => octave_index})
  		three = fix_note({"note" => note + 2, "oct" => octave_index})
  		five = fix_note({"note" => note + 4, "oct" => octave_index})
		[
			@octaves[one["oct"]] + default_scale[one["note"] - 1],
			@octaves[three["oct"]] + default_scale[three["note"] - 1],
			@octaves[five["oct"]] + default_scale[five["note"] - 1]
		]
	end

	def fix_note(params)
		note = params["note"]
		oct = params["oct"]

		while note > 7 do
			note -= 7
			oct += 1
		end

		{"note" => note, "oct" => oct}
	end

	def build(scale = "harmonic_minor")
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

		puts "building melody"
		@melody = build_melody

	 	#TODO:make this less awful
		build_track(@melody, melody_track, scale, 0)

		#bassline
		bassline_track = ReggieTrack.new(seq, @song)
		seq.tracks << bassline_track

		bassline_track.name = 'Bassline Track'
		bassline_track.instrument = GM_PATCH_NAMES[0]

		bassline_track.events << ProgramChange.new(1, 83, 1)

		@bassline = build_bassline
		puts "building bassline"
		build_track(@bassline, bassline_track, scale, 1)

		#chords
		puts "building chord track"
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