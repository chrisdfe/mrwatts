require "music_data"

module SongData
  @@scale = "aeolian"

  def self.scale
    @@scale
  end

  def self.scale=(scale)
    @@scale = MusicData.get_scales[scale]
  end


end