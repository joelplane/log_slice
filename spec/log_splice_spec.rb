require File.expand_path('../lib/log_slice', File.dirname(__FILE__))
require 'helper'

describe LogSlice do

  it "finds the line" do
    log_slice = LogSlice.new(range_to_file 1..1000)
    log_slice.find_line do |line|
      42 <=> line.to_i
    end.should == "42\n"
  end

  it "finds the lines byte offset" do
    log_slice = LogSlice.new(range_to_file 1..10)
    log_slice.find_offset do |line|
      3 <=> line.to_i
    end.should == "1\n2\n".length
  end

  it "finds the line in log2(lines) time" do
    pending
  end

  it "yields the line and all lines thereafter" do
    pending
  end

  it "yields all lines until a matching line is found" do
    pending
  end

  it "a slice of lines with a start condition and an end condition" do
    pending
  end

  it "yields nothing when start line is not found" do
    pending
  end

  it "handles end of file when looking for ending line" do
    pending
  end

  it "yields all lines when not given a start or end condition" do
    pending
  end

end
