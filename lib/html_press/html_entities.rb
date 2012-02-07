module HtmlPress
  begin
    require 'htmlentities'
    def self.entities_compressor (text)
      HTMLEntities.new.decode(text)
    end
  rescue LoadError => e
    def self.entities_compressor (text)
      text
    end
  end
end