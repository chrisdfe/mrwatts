require 'midilib'
require 'json'
require 'utilities'

include Utilities

module MusicData
	ROOTS = [1, 3, 5, 7]
	#JSON
	def format_json(sequences)
		sequences.each do |sequence|
			sequence.each do |note|
				length = "#{note['length']}"
				note["length"] = Utilities.get_note_lengths[length]
			end
		end
	end

	def get_json(filename)
		file = open("#{File.expand_path('../../', __FILE__)}/lib/data/#{filename}.json")
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

end