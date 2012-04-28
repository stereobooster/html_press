require "html_press/version"
require "html_press/css_press"
require "html_press/uglifier"
require "html_press/html_entities"
require "html_press/html"

module HtmlPress
  def self.press(text, options = {})
    HtmlPress::Html.new(options).press text
  end

  # for backward compatibility
  def self.compress(text, options = {})
    HtmlPress::Html.new(options).press text
  end

end
