Gem::Specification.new do |s|
  s.name        = 'mrwatts'
  s.version     = '0.1.3'
  s.date        = '2010-04-28'
  s.summary     = "An improvisational midi making music gem"
  s.description = "Named after the inspiring Reggie Watts"
  s.authors     = ["Christopher Ferris"]
  s.email       = 'christopher.d.ferris@gmail.com'
  s.executables << "mrwatts"
  s.files       = [
  	"README.md",
  	"TODO.md",
  	"Rakefile",
  	"Travis.yml",
  	"lib/mrwatts.rb",
  	"lib/reggie_track.rb",
  	"lib/data/basslines.json",
  	"lib/data/scales.json",
  	"lib/data/sequences.json",
  	"bin/mrwatts",
  	"test/mrwatts-spec.rb"
  ]
  s.homepage    = 'http://rubygems.org/gems/mrwatts'
end