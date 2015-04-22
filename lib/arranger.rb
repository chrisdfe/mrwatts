require 'midilib'
require 'json'

require_relative 'composer'

class Arranger

  def initialize(scale, sequence, tracks)
    @scale    = scale
    @sequence = sequence
    @tracks   = tracks
  end

  def write_song!
    @bassline_a = Composer.compose_bassline
    @bassline_b = Composer.compose_bassline

    # TODO here: different song structures
    SongData.scale = @scale
    write_melody! @tracks["melody"]
    write_bassline! @tracks["bassline"]
    write_chords! @tracks["chords"]  
  end

  def write_melody!(track)
    track.events << ProgramChange.new(0, 17, 0)

    melodyA = Composer.compose_melody
    melodyB = Composer.compose_melody

    2.times { empty_measure!(track) }
    2.times { build_track!(melodyA, track, 0, false, 100) }
    2.times { build_track!(melodyB, track, 0, false, 100) }
    ending_note!(track)

    track
  end

  def write_bassline!(track)
    track.events << ProgramChange.new(1, 32, 1)

    4.times { build_track!(@bassline_a, track, 1) }
    2.times { build_track!(@bassline_b, track, 1) }
    2.times { build_track!(@bassline_a, track, 1) }

    track
  end

  def write_chords!(track)
    track.events << ProgramChange.new(2, 96, 1)

    Utilities.fix_sequence_lengths!(@bassline_a, @bassline_b)

    4.times { build_track!(@bassline_a, track, 2, true) }
    2.times { build_track!(@bassline_b, track, 2, true) }
    2.times { build_track!(@bassline_a, track, 2, true) }
    ending_chord!(track)

    track
  end

  def build_track!(melody, track, channel, chords = false, max_velocity = 127)
    melody.each do |offset|
      note         = offset["note"]
      length       = offset["length"]
      mod          = offset["mod"] || 0 # modulation: sharp or flat
      octave_index = offset["octave"] || 4
      velocity     = offset["velocity"] || max_velocity

      fixed_note = Utilities.fix_note({"note" => note, "oct" => octave_index})
      note = fixed_note["note"]
      oct = MusicData::OCTAVES[fixed_note["oct"]]

      if chords
        chord_notes = Composer.build_chord(note, octave_index)
        track.chord(chord_notes, length)
      else
        track.add_note(channel, oct, SongData.scale, note, mod, velocity, length)
      end
    end

  end

  def empty_measure!(track)
    build_track!(Composer.empty_measure, track, 0)
  end

  def ending_note!(track)
    build_track!(Composer.ending_note, track, 0)
  end

  def ending_chord!(track)
    build_track!(Composer.ending_chord, track, 2, true)
  end

end