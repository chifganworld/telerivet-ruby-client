Gem::Specification.new do |s|
  s.name        = 'telerivet'
  s.version     = '1.4.0'
  s.date        = '2018-06-12'
  s.summary     = "Telerivet REST API Client"
  s.description = "Ruby client library for Telerivet REST API"
  s.authors     = ["Jesse Young"]
  s.email       = 'support@telerivet.com'
  s.files       = ["lib/telerivet.rb", "lib/cacert.pem"] + Dir.glob("lib/telerivet/*")
  s.homepage    = 'http://telerivet.com'
  s.license     = 'MIT'
end