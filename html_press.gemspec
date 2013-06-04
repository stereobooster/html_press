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
  s.license     = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
  
  s.add_dependency "multi_css", ">= 0.1.0"
  s.add_dependency "multi_js", ">= 0.1.0"
  s.add_dependency "htmlentities"
end
