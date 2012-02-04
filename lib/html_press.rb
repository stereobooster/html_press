require "html_press/version"
require "html_press/rainpress"
require "html_press/uglifier"
require "html_press/html"

module HtmlPress
    def self.compress(text, options = nil)
      self::Html.new(options).compile text
    end
end
