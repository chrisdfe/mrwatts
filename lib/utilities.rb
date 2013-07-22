require 'midilib'
require 'json'
require 'reggie_track'

module Utilities

	def get_note_lengths
	 	s = Sequence.new()
		{
			"whole" => s.note_to_delta('whole'),
			"half" => s.note_to_delta('half'),
			"quarter" => s.note_to_delta('quarter'),
			"eighth" => s.note_to_delta('eighth'),
			"sixteenth" => s.note_to_delta('sixteenth'),
			"half triplet" => s.note_to_delta('half triplet'),
			"quarter triplet" => s.note_to_delta('quarter triplet'),
			"eighth triplet" => s.note_to_delta('eighth triplet')
		}
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

	def calculate_length(sequence)
		#note: smelly
		length = 0
		sequence.each do |note|
			length += note["length"]
		end
		length
	end

end