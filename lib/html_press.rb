require "html_press/version"
require "html_press/html_entities"
require "html_press/html"

require 'multi_css'
require 'multi_js'

module HtmlPress
  def self.press(text, options = {})
    HtmlPress::Html.new(options).press text
  end

  # for backward compatibility
  def self.compress(text, options = {})
    HtmlPress::Html.new(options).press text
  end

  def self.js_compressor (text, options = nil)
    options ||= {}
    options[:output] ||= {}
    options[:output][:inline_script] = true
    MultiJs.compile(text, options).gsub(/;$/,'')
  end
end
