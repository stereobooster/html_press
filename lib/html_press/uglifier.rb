module HtmlPress
  begin
    require 'uglifier'
    def self.js_compressor (text)
      Uglifier.new.compile(text).gsub(/;$/,'')
    end
  rescue LoadError => e
    def self.js_compressor (text)
      text
    end
  end
end