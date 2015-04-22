require 'midilib'
require 'json'

require_relative 'reggie_track'

module Utilities

	# Makes sure the note fits into a 7-note scale,
	# adjusts the octave if it is above 7 notes
	def self.fix_note(params)
		note = params["note"]
		oct = params["oct"]

		while note > 7 do
			note -= 7
			oct += 1
		end

		{"note" => note, "oct" => oct}
	end

	def self.calculate_length(sequence)
		#note: smelly
		length = 0
		sequence.each do |note|
			length += note["length"]
		end
		length
	end

	#
	def self.fix_sequence_lengths!(sequenceA, sequenceB)
		aLength = self.calculate_length(sequenceA)
		bLength = self.calculate_length(sequenceB)
				
		if (aLength < bLength)
			diff = bLength - aLength

			if diff == (aLength)
				temp = sequenceA.dup
				sequenceA.each { |note| temp.push(note) } 
				sequenceA = temp.dup
			end
		end
	end

end