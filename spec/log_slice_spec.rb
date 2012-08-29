require File.expand_path('../lib/log_slice', File.dirname(__FILE__))
require 'helper'

describe LogSlice do

  it "finds the line" do
    log_slice = LogSlice.new(range_to_file 1..100)
    file = log_slice.find do |line|
      42 <=> line.to_i
    end
    file.readline.should == "42\n"
  end

  it "finds the first line when there are many matching lines" do
    log_slice = LogSlice.new(string_to_file (["1", "2"] + ["3"]*20).join("\n"))
    file = log_slice.find do |line|
      3 <=> line.to_i
    end
    file.pos.should == "1\n2\n".length
    file.readline.should == "3\n"
  end

  it "finds a matching line with log2(lines)+1 calls to comparison function" do
    [100, 10_000, 100_000].each do |total_lines|
      log_slice = LogSlice.new(range_to_file 1..total_lines)
      comparisons_count = 0
      log_slice.find do |line|
        comparisons_count = comparisons_count + 1
        42 <=> line.to_i
      end
      comparisons_count.should <= log2(total_lines).ceil + 1
    end
  end

  it "nil when no matching line is found (1)" do
    log_slice = LogSlice.new(range_to_file 1..100)
    file = log_slice.find do |line|
      1
    end
    file.should be_nil
  end

  it "nil when no matching line is found (2)" do
    log_slice = LogSlice.new(range_to_file 1..100)
    file = log_slice.find do |line|
      -1
    end
    file.should be_nil
  end

  it "nil when acting on an empty file" do
    log_slice = LogSlice.new(string_to_file "")
    file = log_slice.find do |line|
      42 <=> line.to_i
    end
    file.should be_nil
  end

  it "#each_line_reverse" do
    log_slice = LogSlice.new(range_to_file 1..10000)
    log_slice.instance_eval { @line_cursor = @size }
    lines = []
    file = log_slice.send(:each_line_reverse) do |line|
      lines << line.strip.to_i
    end
    lines.should == Array(1..10000).reverse
  end

  it "#each_line_reverse when file is empty" do
    log_slice = LogSlice.new(string_to_file "")
    log_slice.instance_eval { @line_cursor = @size }
    lines = []
    file = log_slice.send(:each_line_reverse) do |line|
      lines << line.strip.to_i
    end
    lines.should == []
  end

  it "#each_line_reverse when file has single newline char" do
    log_slice = LogSlice.new(string_to_file "\n")
    log_slice.instance_eval { @line_cursor = @size }
    lines = []
    file = log_slice.send(:each_line_reverse) do |line|
      lines << line.strip.to_i
    end
    lines.should == []
  end


end
