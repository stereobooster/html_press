require 'htmlentities'

module HtmlPress
  class Entities
    def initialize
      @replacement_hash = 'MINIFYENTITY' + Time.now.to_i.to_s
      @placeholders = []
    end

    def reserve(content)
      @placeholders.push content
      '%' + @replacement_hash + '%' + (@placeholders.size - 1).to_s + '%'
    end

    def minify text
      out = text.dup

      out.gsub! /&lt;|&#60;|&gt;|&#62;|&amp;|&#38;/ do |m|
        reserve m
      end

      out = HTMLEntities.new.decode(out)

      re = Regexp.new('%' + @replacement_hash + '%(\d+)%')
      out.gsub! re do |m|
        m.gsub!(re, "\\1")
        @placeholders[m.to_i]
      end

      out
    end
  end

  def self.entities_compressor (text)
    Entities.new.minify(text)
  end
end