Gem::Specification.new do |s|
  s.name        = 'log_slice'
  s.version     = '0.1'
  s.authors     = ["Joel Plane"]
  s.email       = ["joel.plane@gmail.com"]
  s.date        = '2012-08-29'
  s.summary     = "Find a line in a log file"
  s.description = "Find a line in a log file. Uses binary search to find the line quickly in a large log file. Can only search sorted data - which in the case of log file is the timestamp, and probably not much else."
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_development_dependency 'rspec'
end
