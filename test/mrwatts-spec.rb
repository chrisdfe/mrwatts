require "./lib/mrwatts.rb"

describe Mrwatts do

	before do
		@rw = Mrwatts.new
	end

	it "should be able to build a song without a specified scale" do
		@rw.build
	end

	it "should be able to build a song using a specified scale" do
		@rw.build("lydian")
	end

	it "should be able to build a song with a slow, medium, or fast tempo" do
		pending
	end

	it "should be able to build a song with a specific bpm" do
		pending
	end

	it "should give the song a random name if you want it to" do
		pending
	end

	it "should tell a joke if you want it to" do
		@rw.tell_joke
	end
end