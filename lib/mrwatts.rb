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

	def get_json(filename)
		file = open("lib/data/#{filename}.json")
		json = file.read
		JSON.parse(json)
	end

	def get_scales
		scales = get_json("scales")
	end

	def get_sequences
		sequences = get_json("sequences")
		sequences = format_json(sequences)
	end

	def build_bassline
		sequences = get_json("basslines")
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

		  	fixed_note = fix_note({"note" => note, "oct" => octave_index})

		  	note = fixed_note["note"]
		  	oct = @octaves[fixed_note["oct"]]

		  	if chords then
				chord_notes = build_chord(note, octave_index, default_scale)
				track.chord(chord_notes, length)
			else
	  			#this seems like too many parameters
	  			track.add_note(channel, oct, default_scale, note, mod, velocity, length)
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

	def write_melody
		melody_track = ReggieTrack.new(@seq, @song)
		@seq.tracks << melody_track

		melody_track.name = 'Melody Track'
		melody_track.instrument = GM_PATCH_NAMES[0]

		melody_track.events << ProgramChange.new(0, 10, 0)

		@melodyA = build_melody
		@melodyB = build_melody

	 	2.times { build_track(@melodyA, melody_track, @scale, 0) }
	 	2.times { build_track(@melodyB, melody_track, @scale, 0) }
	end

	def write_bassline
		#bassline
		bassline_track = ReggieTrack.new(@seq, @song)
		@seq.tracks << bassline_track

		bassline_track.name = 'Bassline Track'
		bassline_track.instrument = GM_PATCH_NAMES[0]

		bassline_track.events << ProgramChange.new(1, 83, 1)

		@basslineA = build_bassline
		@basslineB = build_bassline

		2.times { build_track(@basslineA, bassline_track, @scale, 1) }
		2.times { build_track(@basslineB, bassline_track, @scale, 1) }
	end

	def write_chords
		#chords
		chord_track = ReggieTrack.new(@seq, @song)
		@seq.tracks << chord_track

		chord_track.name = 'Chord Track'
		chord_track.instrument = GM_PATCH_NAMES[0]

		chord_track.events << ProgramChange.new(1, 83, 1)
		2.times { build_track(@basslineA, chord_track, @scale, true, 2) }
		2.times { build_track(@basslineB, chord_track, @scale, true, 2) }
	end

	def compose(scale = "harmonic_minor")
		@scale = @sscale
		@velocity = 127

		@seq = Sequence.new()
		track = ReggieTrack.new(@seq, @song)
		@seq.tracks << track
		track.events << Tempo.new(Tempo.bpm_to_mpq(@bpm))
		track.events << MetaEvent.new(META_SEQ_NAME, @song_name)
		track.events << Controller.new(0, CC_VOLUME, @velocity)

		write_melody
		write_bassline
		write_chords

		File.open("#{@song_name}.mid", 'wb') { | file | @seq.write(file) }

		puts "Song composed."
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