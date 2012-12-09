require "./lib/mrwatts.rb"

describe Mrwatts do

	before do
		@rw = Mrwatts.new
	end

	after(:each) do
    	# @rw.compose
  	end

	describe "scales" do
		it "should use a default scale when given none" do
			@rw.set_scale.should be_a(Array)
		end
		it "should be able to use a specified mode" do
			@rw.set_scale("ionian").should be_a(Array)
			@rw.set_scale("dorian").should be_a(Array)
			@rw.set_scale("phrygian").should be_a(Array)
			@rw.set_scale("lydian").should be_a(Array)
			@rw.set_scale("mixolydian").should be_a(Array)
			@rw.set_scale("aeolian").should be_a(Array)
			@rw.set_scale("locrian").should be_a(Array)
		end
		it "should accept 'major' or 'minor' as the scale" do
			@rw.set_scale("major").should be_a(Array)
			@rw.set_scale("minor").should be_a(Array)
		end
	end

	describe "tempo" do
		describe "string values" do
			it "should accept 'slow' as a tempo" do
				@rw.set_bpm("slow").should be_a(Integer)
			end
			it "should accept 'medium' as a tempo" do
				@rw.set_bpm("medium").should be_a(Integer)
			end
			it "should accept 'fast' as a tempo" do
				@rw.set_bpm("fast").should be_a(Integer)
			end
		end

		it "should be able to compose a song with a specified tempo" do
			@rw.set_bpm(115).should eq(115)
			@rw.set_bpm(90).should eq(90)
			@rw.set_bpm(166).should eq(166)
		end
	end

	it "should give the song a random name if you want it to" do
		pending
	end

	it "should produce chord progressions, melodies, and basslines that are the same length" do
		pending
	end

	it "should tell a joke if you want it to" do
		@rw.tell_joke
	end

end