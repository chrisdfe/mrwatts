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

	def get_basslines
		sequences = get_json("basslines")
		sequences = format_json(sequences)
	end

	def choose_bassline(sequences)
		sequences[Random.rand(sequences.length)]
	end

	def build_melody
		r = Random.new
		melody = []
		roots = [1, 3, 5, 7]
		starting_notes = []
		4.times { starting_notes << roots[r.rand(roots.length)] }

		starting_notes.each do |note| 
			s = get_sequences
			sequences = get_sequences[r.rand(s.length)]
			sequences.each do |sequence|
				melody << {
					"note" => sequence["note"] + note - 1,
					"velocity" => sequence["velocity"],
					"length" => sequence["length"]
				}
			end
		end

		melody
	end

	def build_track(note_array, track, scale, channel, chords = false)

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

	# Makes sure the note fits into a 7-note scale,
	# adjusts the octave if it is above 7 notes
	def fix_note(params)
		note = params["note"]
		oct = params["oct"]

		while note > 7 do
			note -= 7
			oct += 1
		end

		{"note" => note, "oct" => oct}
	end

	def init_tracks
		@tracks.each do |index, track|
			track = ReggieTrack.new(@seq, @song)
			@seq.tracks << track
			track.instrument = GM_PATCH_NAMES[0]
			@tracks[index] = track
		end
		@tracks
	end

	def write_melody
		@tracks["melody"].events << ProgramChange.new(0, 10, 0)
	 	2.times { build_track(@melodyA, @tracks["melody"], @scale, 0) }
	 	2.times { build_track(@melodyB, @tracks["melody"], @scale, 0) }
	end

	def write_bassline
		@tracks["bassline"].events << ProgramChange.new(1, 83, 1)
		2.times { build_track(@basslineA, @tracks["bassline"], @scale, 1) }
		2.times { build_track(@basslineB, @tracks["bassline"], @scale, 1) }
	end

	def write_chords
		@tracks["chords"].events << ProgramChange.new(1, 86, 1)
		2.times { build_track(@basslineA, @tracks["chords"], @scale, 2, true) }
		2.times { build_track(@basslineB, @tracks["chords"], @scale, 2, true) }
	end

	def calculate_length(sequence)
		length = 0
		sequence.each do |note|
			length += note["length"]
		end
		length
	end

	def fade_in_tracks
		build_track(empty_measure, @tracks["melody"], @scale, 0)
	end

	def fix_sequence_lengths
		if (calculate_length(@basslineA) < calculate_length(@basslineB))
			aLength = calculate_length(@basslineA)
			bLength = calculate_length(@basslineB)
			diff = bLength - aLength
			#note: messy
			if diff == (aLength)
				temp = @basslineA.dup
				@basslineA.each do |note|
					temp.push(note)
				end
				@basslineA = temp.dup
			end
		end
	end

	def compose(scale = "harmonic_minor", bpm = 120)
		@scale = scale
		@bpm = bpm || 120
		@velocity = 127

		#required master tracks
		@seq = Sequence.new()
		track = ReggieTrack.new(@seq, @song)
		@seq.tracks << track
		track.events << Tempo.new(Tempo.bpm_to_mpq(@bpm))
		track.events << MetaEvent.new(META_SEQ_NAME, @song_name)
		track.events << Controller.new(0, CC_VOLUME, @velocity)

		#instrumental tracks
		@tracks = {"bassline" => nil, "chords" => nil, "melody" => nil}
		init_tracks

		@melodyA = build_melody
		@melodyB = build_melody

		@basslineA = get_basslines[0]
		@basslineB = choose_bassline(get_basslines)

		fade_in_tracks
		fix_sequence_lengths

		write_melody
		write_bassline
		write_chords

		File.open("#{@song_name}.mid", 'wb') { |file| @seq.write(file) }

		puts "Song composed."
	end

	def empty_measure 
		[{"note"=> 0, "length"=> "whole", "velocity"=> 0}]
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