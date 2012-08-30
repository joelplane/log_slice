require 'tempfile'

RSpec.configure do |c|
  c.include(Module.new do

    def enumerable_to_file range
      file = Tempfile.new("test-#{range}")
      file.write(range.to_a.join("\n"))
      file.flush
      file.seek(0)
      file
    end

    def string_to_file string
      file = Tempfile.new("test-string")
      file.write(string)
      file.flush
      file.seek(0)
      file
    end

    def log2 n
      Math.log(n) / Math.log(2)
    end

  end)
end