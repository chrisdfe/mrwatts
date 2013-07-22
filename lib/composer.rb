require 'midilib'
require 'json'
require 'music_data'

include MusicData

module Composer

	def choose_bassline(sequences)
		sequences[Random.rand(sequences.length)]
	end

	#Phrase/melody building
	def build_melody
		r = Random.new
		melody = []
		starting_notes = []
		4.times { starting_notes << r.rand(7) }

		starting_notes.each do |note| 
			s = get_sequences
			sequences = get_sequences[r.rand(s.length)]
			sequences.each do |sequence|
				melody << {
					"note" => sequence["note"] + note - 1,
					"velocity" => sequence["velocity"],
					"length" => sequence["length"],
					"mod" => sequence["mod"]
				}
			end
		end

		melody
	end

	def build_chord(note, octave_index, scale)
  		one = fix_note({"note" => note, "oct" => octave_index})
  		three = fix_note({"note" => note + 2, "oct" => octave_index})
  		five = fix_note({"note" => note + 4, "oct" => octave_index})
  		
		[
			@octaves[one["oct"]] + scale[one["note"] - 1],
			@octaves[three["oct"]] + scale[three["note"] - 1],
			@octaves[five["oct"]] + scale[five["note"] - 1]
		]
	end

	#track snippet/manipulating methods
	def empty_measure
		[
			{"note"=> 0, "length"=> @note_lengths["whole"], "velocity"=> 0},
			{"note"=> 0, "length"=> @note_lengths["whole"], "velocity"=> 0},
			{"note"=> 0, "length"=> @note_lengths["whole"], "velocity"=> 0},
			{"note"=> 0, "length"=> @note_lengths["whole"], "velocity"=> 0}		
		]
	end

	def ending_note
		r = Random.new
		note = MusicData::ROOTS[r.rand(MusicData::ROOTS.length)]
		e = [{"note"=> note, "length"=> @note_lengths["whole"]}]
		build_track(e, @tracks["melody"], 0)
	end

	def ending_chord
		e = [{"note"=> 1, "octave" => 2, "length"=> @note_lengths["whole"]}]
		build_track(e, @tracks["chords"], 2, true)
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

	def write_melody
		@tracks["melody"].events << ProgramChange.new(0, 17, 0)
		2.times { build_track(empty_measure, @tracks["melody"], 0, false, 0) }
	 	2.times { build_track(@melodyA, @tracks["melody"], 0, false, 100) }
	 	2.times { build_track(@melodyB, @tracks["melody"], 0, false, 100) }
	 	ending_note
	end

	def write_bassline
		@tracks["bassline"].events << ProgramChange.new(1, 32, 1)
		4.times { build_track(@basslineA, @tracks["bassline"], 1) }
		2.times { build_track(@basslineB, @tracks["bassline"], 1) }
		2.times { build_track(@basslineA, @tracks["bassline"], 1) }
	end

	def write_chords
		@tracks["chords"].events << ProgramChange.new(2, 96, 1)
		4.times { build_track(@basslineA, @tracks["chords"], 2, true) }
		2.times { build_track(@basslineB, @tracks["chords"], 2, true) }
		2.times { build_track(@basslineA, @tracks["chords"], 2, true) }
		ending_chord
	end
end