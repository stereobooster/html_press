require "html_press/version"
require "html_press/rainpress"
require "html_press/uglifier"
require "html_press/html"

module HtmlPress
    def self.compress(text)
      self::Html.new.compile text
    end
end
