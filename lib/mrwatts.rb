require 'midilib'

class Mrwatts
	def sing
		puts "Space."
	end

	def initialize
		@song = MIDI::Sequence.new()
		puts "Hello, how you be"
	end

	def build_song

	end
end