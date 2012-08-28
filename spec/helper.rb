require 'tempfile'

RSpec.configure do |c|
  c.include(Module.new do
    def range_to_file range
      file = Tempfile.new("test-#{range}")
      file.write(range.to_a.join("\n"))
      file.flush
      file.seek(0)
      file
    end
  end)
end