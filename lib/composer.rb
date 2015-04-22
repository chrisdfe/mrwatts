require 'midilib'
require 'json'

require_relative 'music_data'
require_relative 'utilities'

module Composer

  def self.compose_melody
    r = Random.new
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

    melody
  end

  def self.compose_bassline
    basslines = MusicData.get_basslines
    basslines[Random.rand(basslines.length)]
  end

  # Right now limited to a 1st inversion triad
  def self.build_chord(note, octave_index)
    one   = Utilities.fix_note({"note" => note, "oct" => octave_index})
    three = Utilities.fix_note({"note" => note + 2, "oct" => octave_index})
    five  = Utilities.fix_note({"note" => note + 4, "oct" => octave_index})

    [
      MusicData::OCTAVES[one["oct"]] + SongData.scale[one["note"] - 1],
      MusicData::OCTAVES[three["oct"]] + SongData.scale[three["note"] - 1],
      MusicData::OCTAVES[five["oct"]] + SongData.scale[five["note"] - 1]
    ]
  end

  def self.empty_measure
    [
      {"note"=> 0, "length"=> MusicData.note_lengths["whole"], "velocity"=> 0},
      {"note"=> 0, "length"=> MusicData.note_lengths["whole"], "velocity"=> 0},
      {"note"=> 0, "length"=> MusicData.note_lengths["whole"], "velocity"=> 0},
      {"note"=> 0, "length"=> MusicData.note_lengths["whole"], "velocity"=> 0}    
    ]
  end

  def self.ending_note
    r = Random.new
    note = MusicData::ROOTS[r.rand(MusicData::ROOTS.length)]
    [{"note"=> note, "length"=> MusicData.note_lengths["whole"]}]
  end

  def self.ending_chord
    [{"note"=> 1, "octave" => 2, "length" => MusicData.note_lengths["whole"]}]  
  end

end