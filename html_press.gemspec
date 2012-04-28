# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "html_press/version"

Gem::Specification.new do |s|
  s.name        = "html_press"
  s.version     = HtmlPress::VERSION
  s.authors     = ["stereobooster"]
  s.email       = ["stereobooster@gmail.com"]
  s.homepage    = "https://github.com/stereobooster/html_press"
  s.summary     = %q{Compress html}
  s.description = %q{Ruby gem for compressing html}

  s.rubyforge_project = "html_press"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # s.add_dependency "nokogiri"

  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
  
  s.add_runtime_dependency "css_press", "0.3.1"
  s.add_runtime_dependency "uglifier"
  s.add_runtime_dependency "htmlentities"
end
