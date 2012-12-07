#! /usr/bin/env ruby
#
# usage: from_scratch.rb
#
# This script shows you how to create a new sequence from scratch and save it
# to a MIDI file. It creates a file called 'from_scratch.mid'.

# Start looking for MIDI module classes in the directory above this one.
# This forces us to use the local copy, even if there is a previously
# installed version out there somewhere.

#$LOAD_PATH[0, 0] = File.join(File.dirname(__FILE__), '..', 'lib')