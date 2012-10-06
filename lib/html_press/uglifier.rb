module HtmlPress
  begin
    require 'uglifier'
    # Available options https://github.com/lautis/uglifier#options
    def self.js_compressor (text, options = nil)
      options ||= {}
      options[:inline_script] = true
      Uglifier.new(options).compile(text).gsub(/;$/,'')
    end
  rescue LoadError => e
    def self.js_compressor (text, options = nil)
      text
    end
  end
end