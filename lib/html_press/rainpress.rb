module HtmlPress
  begin
    require 'rainpress'
    def self.css_compressor (text)
      Rainpress.compress(text).gsub(/^\s+/m, '')
    end
  rescue LoadError => e
    def self.css_compressor (text)
      text
    end
  end
end