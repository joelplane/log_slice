require File.expand_path('../lib/log_slice', File.dirname(__FILE__))
require 'helper'

describe LogSlice::DateRange do

  let(:file_contents) {
    %{
[2012-08-31 17:19:45] test 1
[2012-08-31 17:19:57] test 2
[2012-08-31 17:19:57] test 3
[2012-08-31 17:20:12] test 4
[2012-08-31 17:20:24] test 5
[2012-08-31 17:20:35] test 6
[2012-08-31 17:21:02] test 7
[2012-08-31 17:21:09] test 8
    }.strip
  }

  it "works" do
    start_date = '2012-08-31 17:20:00'
    end_date = '2012-08-31 17:21:00'
    lines = []
    LogSlice::DateRange.new(string_to_file(file_contents), start_date, end_date).each do |line|
      lines << line.strip
    end
    lines.should == [
      "[2012-08-31 17:20:12] test 4",
      "[2012-08-31 17:20:24] test 5",
      "[2012-08-31 17:20:35] test 6"
    ]
  end

  it "works without an end date" do
    start_date = '2012-08-31 17:20:00'
    lines = []
    LogSlice::DateRange.new(string_to_file(file_contents), start_date, nil).each do |line|
      lines << line.strip
    end
    lines.should == [
      "[2012-08-31 17:20:12] test 4",
      "[2012-08-31 17:20:24] test 5",
      "[2012-08-31 17:20:35] test 6",
      "[2012-08-31 17:21:02] test 7",
      "[2012-08-31 17:21:09] test 8"
    ]
  end

end
