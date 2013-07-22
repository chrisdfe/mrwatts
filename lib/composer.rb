require 'midilib'
require 'json'
require 'music_data'
require 'utilities'

module Composer

	def self.choose_bassline(sequences)
		sequences[Random.rand(sequences.length)]
	end

	def self.build_melody(options = {})
		r = Random.new
		options["scale"] ||= "aeolian"
		melody = []
		starting_notes = []

		4.times { starting_notes << r.rand(7) }

		starting_notes.each do |note| 
			s = MusicData.get_sequences
			sequences = s[r.rand(s.length)]
			sequences.each do |sequence|
				melody << {
					"note" => sequence["note"] + note - 1,
					"velocity" => sequence["velocity"],
					"length" => sequence["length"],
					"mod" => sequence["mod"]
				}
			end
		end

		{"scale" => options["scale"], "melody" => melody}
	end

	def self.build_bassline(options)
		scale = options["scale"] || "aeolian"
		bassline = self.choose_bassline(MusicData.get_basslines)
		{"scale" => scale, "melody" => bassline}
	end

	# Right now limited to a 1st inversion triad
	def self.build_chord(note, octave_index, scale)
  		one   = Utilities.fix_note({"note" => note, "oct" => octave_index})
  		three = Utilities.fix_note({"note" => note + 2, "oct" => octave_index})
  		five  = Utilities.fix_note({"note" => note + 4, "oct" => octave_index})
  		
		[
			MusicData::OCTAVES[one["oct"]] + scale[one["note"] - 1],
			MusicData::OCTAVES[three["oct"]] + scale[three["note"] - 1],
			MusicData::OCTAVES[five["oct"]] + scale[five["note"] - 1]
		]
	end

	def self.build_track!(melody_data, track, channel, chords = false, max_velocity = 127)
		puts melody_data["scale"]
		scale = MusicData::scales[melody_data["scale"]]
		
		melody_data["melody"].each do |offset|
			note         = offset["note"]
			length       = offset["length"]
			mod          = offset["mod"] || 0 #modulation: sharp or flat
			octave_index = offset["octave"] || 4
			velocity     = offset["velocity"] || max_velocity

		  	fixed_note = Utilities.fix_note({"note" => note, "oct" => octave_index})
		  	note = fixed_note["note"]
		  	oct = MusicData::OCTAVES[fixed_note["oct"]]

		  	if chords
				chord_notes = build_chord(note, octave_index, scale)
				track.chord(chord_notes, length)
			else
	  			track.add_note(channel, oct, scale, note, mod, velocity, length)
	  		end
		end
		
	end

	def self.empty_measure
		{
			"scale" => "aeolian",
			"melody" => [
				{"note"=> 0, "length"=> MusicData.note_lengths["whole"], "velocity"=> 0},
				{"note"=> 0, "length"=> MusicData.note_lengths["whole"], "velocity"=> 0},
				{"note"=> 0, "length"=> MusicData.note_lengths["whole"], "velocity"=> 0},
				{"note"=> 0, "length"=> MusicData.note_lengths["whole"], "velocity"=> 0}		
			]
		}
	end

	def self.empty_measure!(track)
		self.build_track!(self.empty_measure, track, 0)
	end

	def self.ending_note!(track)
		r = Random.new
		note = MusicData::ROOTS[r.rand(MusicData::ROOTS.length)]
		e = {
			"scale" => "aeolian",
			"melody" => [
				{"note"=> note, "length"=> MusicData.note_lengths["whole"]}
			]
		}
		self.build_track!(e, track, 0)
	end

	def self.ending_chord!(track)
		e = {
			"scale" => "aeolian",
			"melody" => [
				{"note"=> 1, "octave" => 2, "length" => MusicData.note_lengths["whole"]}
			]
		}
		self.build_track!(e, track, 2, true)
	end

	def self.write_melody!(track)
		track.events << ProgramChange.new(0, 17, 0)

		options = ({"scale" => "aeolian"})

		melodyA = self.build_melody(options)
		melodyB = self.build_melody(options)

		2.times { self.empty_measure!(track) }
	 	2.times { self.build_track!(melodyA, track, 0, false, 100) }
	 	2.times { self.build_track!(melodyB, track, 0, false, 100) }
	 	self.ending_note!(track)
	 	track
	end

	def self.write_bassline!(track)
		track.events << ProgramChange.new(1, 32, 1)

		4.times { self.build_track!(basslineA, track, 1) }
		2.times { self.build_track!(basslineB, track, 1) }
		2.times { self.build_track!(basslineA, track, 1) }
		track
	end

	def self.write_chords!(track)
		track.events << ProgramChange.new(2, 96, 1)

		options = ({"scale" => "aeolian"})

		basslineA = self.build_bassline(options)
		basslineB = self.build_bassline(options)
		Utilities.fix_sequence_lengths!(basslineA["melody"], basslineB["melody"])

		4.times { self.build_track!(basslineA, track, 2, true) }
		2.times { self.build_track!(basslineB, track, 2, true) }
		2.times { self.build_track!(basslineA, track, 2, true) }
		self.ending_chord!(track)
		track
	end

end