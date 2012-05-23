module HtmlPress
  begin
    require 'css_press'
    def self.css_compressor (text)
      text = "a{#{text}}"
      text = CssPress.press text
      text.gsub(/^a\{/, '').gsub(/\}$/, '')
    end
    def self.style_compressor (text)
      CssPress.press text
    end
  rescue LoadError => e
    def self.css_compressor (text)
      text
    end
    def self.style_compressor (text)
      text
    end
  end

end