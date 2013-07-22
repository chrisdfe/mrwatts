require 'midilib'
require 'json'
require 'reggie_track'
require 'music_data'
require 'utilities'
require 'composer'

include MIDI
include MusicData
include Utilities
include Composer

class Mrwatts

	def initialize
		@song = MIDI::Sequence.new()
		@scales = MusicData.get_scales
		@note_lengths = Utilities.get_note_lengths
		@octaves = [16, 28, 40, 52, 64, 76, 88, 100, 112, 124]
	end

	# Options handling
	def set_scale(scale = nil)
		scale ||= "aeolian"
		scale = "aeolian" if scale == "minor"
		scale = "ionian" if scale == "major"
		@scales[scale]
	end

	def set_bpm(bpm)
		bpm ||= 120
		bpm = 150 if bpm == "fast"
		bpm = 120 if bpm == "medium"
		bpm = 90 if bpm == "slow"
		bpm
	end

	#Track writers
	def init_tracks
		@tracks.each do |index, track|
			track = ReggieTrack.new(@seq, @song)
			@seq.tracks << track
			track.instrument = GM_PATCH_NAMES[0]
			@tracks[index] = track
		end
	end

	def build_track(note_array, track, channel, chords = false, max_velocity = @velocity)

		note_array.each do |offset|
			note = offset["note"]
			length = offset["length"]
			mod = offset["mod"] || 0 #modulation: sharp or flat
			octave_index = offset["octave"] || 4
			velocity = offset["velocity"] || max_velocity

		  	fixed_note = fix_note({"note" => note, "oct" => octave_index})
		  	note = fixed_note["note"]
		  	oct = @octaves[fixed_note["oct"]]

		  	if chords then
				chord_notes = build_chord(note, octave_index, @scale)
				track.chord(chord_notes, length)
			else
	  			track.add_note(channel, oct, @scale, note, mod, velocity, length)
	  		end
		end
		
	end

	def set(options = {})
		@scale = set_scale(options["scale"])
		@bpm = set_bpm(options["bpm"]).to_i
		@velocity = options[:volume] || 127
		@song_name = "crab_cakes"
	end

	#compose!
	def compose(options = {})
		set(options)

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

		@melodyA = Composer.build_melody
		@melodyB = Composer.build_melody

		@basslineA = choose_bassline(get_basslines)
		@basslineB = choose_bassline(get_basslines)

		#fade_in_tracks
		fix_sequence_lengths

		write_melody
		write_bassline
		write_chords

		ending_note

		File.open("#{@song_name}.mid", 'wb') { |file| @seq.write(file) }

		puts "Song composed."
	end

end