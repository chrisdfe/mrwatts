require 'midilib'
require 'json'
require 'composer'

module Arranger

  def self.write_melody!(track)
    track.events << ProgramChange.new(0, 17, 0)

    melodyA = Composer.compose_melody
    melodyB = Composer.compose_melody

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

    basslineA = Composer.compose_bassline
    basslineB = Composer.compose_bassline
    Utilities.fix_sequence_lengths!(basslineA, basslineB)

    4.times { self.build_track!(basslineA, track, 2, true) }
    2.times { self.build_track!(basslineB, track, 2, true) }
    2.times { self.build_track!(basslineA, track, 2, true) }
    self.ending_chord!(track)
    track
  end

  def self.build_track!(melody, track, channel, chords = false, max_velocity = 127)
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

  def self.empty_measure!(track)
    self.build_track!(Composer.empty_measure, track, 0)
  end

  def self.ending_note!(track)
    self.build_track!(Composer.ending_note, track, 0)
  end

  def self.ending_chord!(track)
    self.build_track!(Composer.ending_chord, track, 2, true)
  end

end