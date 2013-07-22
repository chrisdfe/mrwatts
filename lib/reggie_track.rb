class ReggieTrack < MIDI::Track
  @@channel_counter = 0

  def initialize(number, song)
    super(number)
    @sequence = song
    @time = 0
    @channel = @@channel_counter
    @@channel_counter += 1
  end

  # Add one or more notes to sound simultaneously. Increments the per-track
  # timer so that subsequent notes will sound after this one finishes.
  def chord(notes, duration)
    notes.each do |note|
      event(MIDI::NoteOnEvent.new(@channel, note, 127))
    end

    @time += duration

    notes.each do |note|
      event(MIDI::NoteOffEvent.new(@channel, note, 127))
    end

    recalc_delta_from_times
  end

  def add_note(channel, oct, scale, note, mod, velocity, length)
    events << NoteOn.new(channel, oct + scale[note - 1] + mod, velocity, 0)
    events << NoteOff.new(channel, oct + scale[note - 1] + mod, velocity, length)
  end

  private

  def event(event)
		@events << event
		event.time_from_start = @time
  end
end
