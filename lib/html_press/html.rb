module HtmlPress
  class Html

    DEFAULTS = {
      :logger => false,
      :unquoted_attributes => false,
      :drop_empty_values => false 
    }

    def initialize (options = {})
      @options = DEFAULTS.merge(options)
      if @options.keys.include? :dump_empty_values
        @options[:drop_empty_values] = @options.delete(:dump_empty_values)
        warn "dump_empty_values deprecated use drop_empty_values"
      end
    end

    def log (text)
      if @options[:logger] && @options[:logger].respond_to?(:call)
        @options[:logger].call text
      end
    end

    def press (html)

      out = html.respond_to?(:read) ? html.read : html.dup

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
        m.gsub! /<[a-z\-:]+\s([^>]+)>/i do |m|
          attrs(m, '[a-z\-:]+', true)
        end
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
        m.gsub! /<[a-z\-:]+\s([^>]+)>/i do |m|
          attrs(m, '[a-z\-:]+', true)
        end
        css = m.gsub(/\s*<style\b[^>]*?>([\s\S]*?)<\/style>\s*/i, "\\1")
        begin
          css_compressed = HtmlPress.style_compressor css
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

      # replace entities
      out.gsub! /&lt;|&#60;|&gt;|&#62;|&amp;|&#38;/ do |m|
        reserve m
      end

      out = HtmlPress.entities_compressor out

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
  
        attributes_compressed = " " + attributes_compressed.strip

        if attributes_compressed == " /"
          attributes_compressed = "/"
        elsif attributes_compressed == " "
          attributes_compressed = ""
        end
        m.gsub(attributes, attributes_compressed)
      else
        m
      end
    end

    def attr(attribute, delimiter, tag)
      re = "([a-z\\-_:]+)(=" + delimiter + "[^" + delimiter + "]*" + delimiter + ")?"
      re = Regexp.new re
      value_original = attribute.gsub(re, "\\2")
      value = value_original.downcase
      name_original = attribute.gsub(re, "\\1")
      name = name_original.downcase
      tag_name = tag.downcase

      if value.size > 0
        re = "^=" + delimiter + "|" + delimiter + "$"
        re = Regexp.new re
        value_original.gsub!(re, "")
      end

      case tag_name
      when "script"
        p name
        p value_original
        if (name == "type" && value_original == "text/javascript") || (name == "language" && value_original == "JavaScript")
          return ""
        elsif name == "async" || name == "defer"
          return name_original
        end
      when "form"
        if name == "method" && value_original == "get"
          return ""
        end
      when /link|style/
        if name == "type" && value_original == "text/stylesheet"
          return ""
        end
      when /input|textarea|button|select|option|optgroup/
        if name == "disabled"
          return name_original
        end
        if (tag_name == "input" || tag_name == "textarea") && name == "readonly"
          return name_original
        end
        if tag_name == "option" && name == "selected"
          return name_original
        end
        if tag_name == "input"
          if name == "type" && (value == "=\"text\"" || value == "='text'")
            return ""
          end
          if name == "checked"
            return name_original
          end
          # if name == "value" && (value == "=\"\"" || value == "=''")
            # return ''
          # end
        end
      end

      if value.size > 0

        if name == "style"
          begin
            value_original = HtmlPress.css_compressor value_original
            # TODO what about escaped attribute values?
            if delimiter == "\""
              value_original.gsub!("\"", "'")
            else
              value_original.gsub!("'", "\"")
            end
          rescue Exception => e
            log e.message
          end
        end

        if name == "class"
          value_original.gsub!(/\s+/, " ")
          value_original.gsub!(/^\s+|\s+$/, "")
        end

        events = %w[onfocus onblur onselect onchange onclick
          ondblclick onmousedown onmouseup onmouseover onmousemove
          onmouseout onkeypress onkeydown onkeyup]

        if events.include? name
          value_original.gsub! /^javascript:\s+|;$/, ''
          begin
            value_original = HtmlPress.js_compressor value_original
            # TODO what about escaped attribute values?
            if delimiter == "\""
              value_original.gsub! "\"", "'"
            end
          rescue Exception => e
            log e.message
          end
        end

        if value_original.size == 0
          #attribute without value may be dropped by IE7
          if @options[:drop_empty_values]
            attribute = name_original
          else
            attribute = name_original + "=" + delimiter + delimiter
          end
        elsif @options[:unquoted_attributes] && !(value_original =~ /[ \t\r\n\f"'`=<>]/)
          attribute = name_original + "=" + value_original
        else
          attribute = name_original + "=" + delimiter + value_original + delimiter
        end

      end

      attribute
    end

    # for backward compatibility
    alias :compile :press

  end
end
