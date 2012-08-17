#-*- encoding: utf-8 -*-

$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "splunkman/version"

Gem::Specification.new do |gem|
  gem.name        = "splunkman"
  gem.version     = SplunkMan::VERSION
  gem.authors     = ["Chris Tracey"]
  gem.email       = [""]
  gem.homepage    = "https://github.com/ctracey/splunkman"
  gem.summary     = %q{SplunkMan provides a simple API to execute saved searches on Splunk}

  # gem.description = %q{}
  # gem.rubyforge_project = "packbot"

  gem.files         = Dir.glob("**/*")
  gem.test_files    = Dir.glob("{spec}/**/*")
  gem.executables   = Dir.glob("{bin}/*").map{ |f| file.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "rake"
  gem.add_runtime_dependency "json"

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "webmock"
end


