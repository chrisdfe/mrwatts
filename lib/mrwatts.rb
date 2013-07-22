require 'midilib'
require 'json'

require 'reggie_track'
require 'music_data'
require 'song_data'
require 'utilities'
require 'composer'
require 'arranger'

include MIDI

class Mrwatts

  def initialize
    @song = MIDI::Sequence.new()
  end

  # Options handling
  def set_scale!(scale = nil)
    scale ||= "aeolian"
    scale = "aeolian" if scale == "minor"
    scale = "ionian" if scale == "major"
    @scale = scale
    return if MusicData.get_scales[scale] != nil

    puts "Mr Watts doesn't know that scale."
    @scale = "aeolian"    
  end

  def set_bpm!(bpm)
    bpm ||= 120
    bpm = 150 if bpm == "fast"
    bpm = 120 if bpm == "medium"
    bpm = 90 if bpm == "slow"
    @bpm = bpm.to_i
  end

  #Track writers
  def init_tracks
    @tracks = {"bassline" => nil, "chords" => nil, "melody" => nil}

    @tracks.each do |index, track|
      track = ReggieTrack.new(@seq, @song)
      @seq.tracks << track
      track.instrument = GM_PATCH_NAMES[0]
      @tracks[index] = track
    end
  end

  def set(options = {})
    set_scale!(options["scale"])
    set_bpm!(options["bpm"])
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

    init_tracks

    SongData.scale = @scale
    Arranger.write_melody! @tracks["melody"]
    # @tracks["bassline"] = Composer.write_bassline
    Arranger.write_chords! @tracks["chords"]

    File.open("#{@song_name}.mid", 'wb') { |file| @seq.write(file) }

    puts "Song composed."
  end

end