require "bundler"
Bundler.setup

require 'ruby-prof'
require 'html_press'

file_path = File.expand_path("../index.html", __FILE__)
html = File.open(file_path, "r:UTF-8").read

# require 'open-uri'
# html = open('http://www.amazon.com/') {|f| f.read }

before = html.bytesize
html.force_encoding "UTF-8" if html.respond_to?(:force_encoding)

RubyProf.start
  html = HtmlPress.press html
result = RubyProf.stop

after = html.bytesize
puts "Economy: " + ((before - after).to_f/1024).round(2).to_s + "kb (" +
  (100*(before - after).to_f/before).round(2).to_s + "%)"

report_path = File.expand_path("../reports", __FILE__)
FileUtils.rm_rf(report_path)
Dir.mkdir(report_path) unless File.exist?(report_path)
printer = RubyProf::MultiPrinter.new(result)
printer.print(:path => report_path, :profile => "profile")
