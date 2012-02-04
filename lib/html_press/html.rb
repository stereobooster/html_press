module HtmlPress
  class Html

    def initialize (options = nil)
      @options = options
    end

    def log (text)
      if !@options.nil? && @options[:logger]
        @options[:logger].warn text
      end
    end

    def compile (html)

      out = html + ""

      @replacement_hash = 'MINIFYHTML' + Time.now.to_i.to_s
      @placeholders = []
      @strip_crlf = false

      # IE conditional comments
      out.gsub! /\s*(<!--\[[^\]]+\]>[\s\S]*?<!\[[^\]]+\]-->)\s*/ do |m|
        m.gsub!(/^\s+|\s+$/, '')
        comment = m.gsub(/\s*<!--\[[^\]]+\]>([\s\S]*?)<!\[[^\]]+\]-->\s*/, "\\1")
        comment_compressed = Html.new.compile(comment)
        m.gsub!(comment, comment_compressed)
        reserve m
      end

      # replace SCRIPTs (and minify) with placeholders
      out.gsub! /\s*(<script\b[^>]*?>[\s\S]*?<\/script>)\s*/i do |m|
        m.gsub!(/^\s+|\s+$/, '')
        js = m.gsub(/\s*<script\b[^>]*?>([\s\S]*?)<\/script>\s*/i , "\\1")
        begin
          js_compressed = HtmlPress.js_compressor js
          m.gsub!(js, js_compressed)
        rescue Exception => e
          log e.message
        end
        reserve m
      end

      # replace STYLEs (and minify) with placeholders
      out.gsub! /\s*(<style\b[^>]*?>[\s\S]*?<\/style>)\s*/i do |m|
        m.gsub!(/^\s+|\s+$/, '')
        css = m.gsub(/\s*<style\b[^>]*?>([\s\S]*?)<\/style>\s*/i, "\\1")
        begin
          css_compressed = HtmlPress.css_compressor css
          m.gsub!(css, css_compressed)
        rescue Exception => e
          log e.message
        end
        reserve m
      end

      # remove out comments (not containing IE conditional comments).
      out.gsub! /<!--([\s\S]*?)-->/ do |m|
        ''
      end

      # replace PREs with placeholders
      out.gsub! /\s*(<pre\b[^>]*?>[\s\S]*?<\/pre>)\s*/i do |m|
        pre = m.gsub(/\s*<pre\b[^>]*?>([\s\S]*?)<\/pre>\s*/i, "\\1")
        pre_compressed = pre.gsub(/\s+$/, '')
        m.gsub!(pre, pre_compressed)
        reserve m
      end

      # replace TEXTAREAs with placeholders
      out.gsub! /\s*(<textarea\b[^>]*?>[\s\S]*?<\/textarea>)\s*/i do |m|
        reserve m
      end

      # trim each line.
      # @todo take into account attribute values that span multiple lines.
      out.gsub!(/^\s+|\s+$/m, '')

      re = '\\s+(<\\/?(?:area|base(?:font)?|blockquote|body' +
        '|caption|center|cite|col(?:group)?|dd|dir|div|dl|dt|fieldset|form' +
        '|frame(?:set)?|h[1-6]|head|hr|html|legend|li|link|map|menu|meta' +
        '|ol|opt(?:group|ion)|p|param|t(?:able|body|head|d|h|r|foot|itle)' +
        '|ul)\\b[^>]*>)'

      re = Regexp.new(re)
      out.gsub!(re, '\\1')

      # remove ws outside of all elements
      out.gsub! />([^<]+)</ do |m|
        m.gsub(/^\s+|\s+$/, ' ')
      end

      # use newlines before 1st attribute in open tags (to limit line lengths)
      # out.gsub!(/(<[a-z\-:]+)\s+([^>]+>)/i, "\\1\n\\2")

      # match attributes
      out.gsub! /<[a-z\-:]+\s([^>]+)>/i do |m|
        reserve attrs(m, '[a-z\-:]+', true)
      end

      out.gsub!(/[\r\n]+/, @strip_crlf ? ' ' : "\n")

      out.gsub!(/\s+/, ' ')

      # fill placeholders
      re = Regexp.new('%' + @replacement_hash + '%(\d+)%')
      out.gsub! re do |m|
        m.gsub!(re, "\\1")
        @placeholders[m.to_i]
      end

      out
    end

    def reserve(content)
      @placeholders.push content
      '%' + @replacement_hash + '%' + (@placeholders.size - 1).to_s + '%'
    end

    def attrs (m, tag_name, r)
      re = "<(" + tag_name + ")(\s[^>]+)?>"
      re = Regexp.new(re, true)
      attributes = m.gsub(re, "\\2")
      if r
        tag = m.gsub(re, "\\1")
      else
        tag = tag_name
      end
      
      if attributes.size > 0
        attributes_compressed = attributes.gsub(/\s*([a-z\-_:]+(="[^"]*")?(='[^']*')?)\s*/i, " \\1")
  
        attributes_compressed.gsub! /([a-z\-_:]+="[^"]*")/i do |k|
          attr k, "\"", tag
        end
  
        attributes_compressed.gsub! /([a-z\-_:]+='[^']*')/i do |k|
          attr k, "'", tag
        end
  
        return m.gsub(attributes, attributes_compressed)
      end

      return m
    end

    def attr(attribute, delimiter, tag)
      re = "([a-z\\-_:]+)(=" + delimiter + "[^" + delimiter + "]*" + delimiter + ")?"
      re = Regexp.new re
      value = attribute.gsub(re, "\\2")

      if tag == "script"
        name = attribute.gsub(re, "\\1")
        if name == "type" || name == "language"
          return ""
        end
      end

      if value.size != 0

        name = attribute.gsub(re, "\\1")

        re = "^=" + delimiter + "|" + delimiter + "$"
        re = Regexp.new re
        value.gsub!(re, "")

        if name == "style"
          value = HtmlPress.css_compressor value
        end

        if name == "class"
          value.gsub!(/\s+/, " ")
          value.gsub!(/^\s+|\s+$/, "")
        end

        # if name == "onclick"
          # value = HtmlPress.js_compressor value
        # end

        attribute = name + "=" + delimiter + value + delimiter
      end

      attribute
    end

  end
end
