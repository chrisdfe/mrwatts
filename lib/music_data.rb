require 'midilib'
require 'json'
require 'utilities'

module MusicData
  ROOTS   = [1, 3, 5, 7]
  OCTAVES = [16, 28, 40, 52, 64, 76, 88, 100, 112, 124]

  #JSON
  def self.format_json(sequences)
    sequences.each do |sequence|
      sequence.each do |note|
        length = "#{note['length']}"
        note["length"] = self.note_lengths[length]
      end
    end
  end

  def self.get_scales
    self.get_json("scales")
  end

  def self.get_json(filename)
    file = open("#{File.expand_path('../../', __FILE__)}/lib/data/#{filename}.json")
    json = file.read
    JSON.parse(json)
  end

  def self.get_sequences
    sequences = get_json("sequences")
    sequences = format_json(sequences)
  end

  def self.get_basslines
    sequences = get_json("basslines")
    sequences = format_json(sequences)
  end


  def self.note_lengths
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

end