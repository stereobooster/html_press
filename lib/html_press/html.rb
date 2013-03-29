module HtmlPress
  class Html

    DEFAULTS = {
      :logger => false,
      :unquoted_attributes => false,
      :drop_empty_values => false,
      :strip_crlf => false,
      :js_minifier_options => false
    }

    def initialize (options = {})
      @options = DEFAULTS.merge(options)
      if @options.keys.include? :dump_empty_values
        @options[:drop_empty_values] = @options.delete(:dump_empty_values)
        warn "dump_empty_values deprecated use drop_empty_values"
      end
      if @options[:logger] && !@options[:logger].respond_to?(:error)
        raise ArgumentError, 'Logger has no error method'
      end
    end

    def press (html)
      out = html.respond_to?(:read) ? html.read : html.dup

      @replacement_hash = 'MINIFYHTML' + Time.now.to_i.to_s
      @placeholders = []

      out = process_ie_conditional_comments out
      out = process_scripts out
      out = process_styles out
      out = process_html_comments out
      out = process_pres out

      out = HtmlPress.entities_compressor out

      out = trim_lines out
      out = process_block_elements out
      out = process_textareas out

      # use newlines before 1st attribute in open tags (to limit line lengths)
      # out.gsub!(/(<[a-z\-:]+)\s+([^>]+>)/i, "\\1\n\\2")

      out = process_attributes out
      out = process_whitespaces out
      out = fill_placeholders out

      out
    end

    # for backward compatibility
    alias :compile :press

    protected

    # IE conditional comments
    def process_ie_conditional_comments (out)
      out.gsub /(<!--\[[^\]]+\]>([\s\S]*?)<!\[[^\]]+\]-->)\s*/ do
        m = $1
        comment = $2
        comment_compressed = Html.new.press(comment)
        m.gsub!(comment, comment_compressed)
        reserve m
      end
    end

    # replace SCRIPTs (and minify) with placeholders
    def process_scripts (out)
      out.gsub /(<script\b[^>]*?>([\s\S]*?)<\/script>)\s*/i do
        js = $2
        m = $1.gsub /^<script\s([^>]+)>/i do |m|
          attrs(m, 'script', true)
        end
        begin
          js_compressed = HtmlPress.js_compressor js, @options[:js_minifier_options]
          m.gsub!(">#{js}<\/script>", ">#{js_compressed}<\/script>")
        rescue MultiJs::ParseError => e
          log e.message
        end
        reserve m
      end
    end

    # replace STYLEs (and minify) with placeholders
    def process_styles (out)
      out.gsub /(<style\b[^>]*?>([\s\S]*?)<\/style>)\s*/i do
        css = $2
        m = $1.gsub /^<style\s([^>]+)>/i do |m|
          attrs(m, 'style', true)
        end
        begin
          css_compressed = MultiCss.min css
          m.gsub!(css, css_compressed)
        rescue Exception => e
          log e.message
        end
        reserve m
      end
    end

    # remove html comments (not IE conditional comments)
    def process_html_comments (out)
      out.gsub /<!--([\s\S]*?)-->/, ''
    end

    # replace PREs with placeholders
    def process_pres (out)
      out.gsub /(<pre\b[^>]*?>([\s\S]*?)<\/pre>)\s*/i do
        pre = $2
        m = $1
        pre_compressed = pre.lines.map{ |l| l.gsub(/\s+$/, '') }.join("\n")
        pre_compressed = HtmlPress.entities_compressor pre_compressed
        m.gsub!(pre, pre_compressed)
        reserve m
      end
    end

    # trim each line
    def trim_lines (out)
      out.gsub(/^\s+|\s+$/m, '')
    end

    # remove whitespaces outside of block elements
    def process_block_elements (out)
      re = '\\s+(<\\/?(?:area|base(?:font)?|blockquote|body' +
        '|caption|center|cite|col(?:group)?|dd|dir|div|dl|dt|fieldset|form' +
        '|frame(?:set)?|h[1-6]|head|hr|html|legend|li|link|map|menu|meta' +
        '|ol|opt(?:group|ion)|p|param|t(?:able|body|head|d|h|r|foot|itle)' +
        '|ul)\\b[^>]*>)'

      re = Regexp.new(re)
      out.gsub!(re, '\\1')

      # remove whitespaces outside of all elements
      out.gsub! />([^<]+)</ do |m|
        m.gsub(/^\s+|\s+$/, ' ')
      end

      out
    end

    # replace TEXTAREAs with placeholders
    def process_textareas (out)
      out.gsub /(<textarea\b[^>]*?>[\s\S]*?<\/textarea>)\s*/i do |m|
        reserve m
      end
    end

    # attributes
    def process_attributes (out)
      out.gsub /<[a-z\-:]+\s([^>]+)>/i do |m|
        reserve attrs(m, '[a-z\-:]+', true)
      end
    end

    # replace two or more whitespaces with one
    def process_whitespaces (out)
      out.gsub!(/[\r\n]+/, @options[:strip_crlf] ? ' ' : "\n")
      out.gsub!(/\s+/, ' ')
      out
    end

    # fill placeholders
    def fill_placeholders (out)
      re = Regexp.new('%' + @replacement_hash + '%(\d+)%')
      out.gsub re do |m|
        m.gsub!(re, "\\1")
        @placeholders[m.to_i]
      end
    end

    def log (text)
      @options[:logger].error text if @options[:logger]
    end

    def reserve (content)
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
        attributes_compressed = attributes.gsub(/([a-z\-_:]+(="[^"]*")?(='[^']*')?)\s*/i, " \\1")
  
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
      re = Regexp.new re, true
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
          if name == "type" && value_original == "text"
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
            value_original = MultiCss.min_attr value_original
            # TODO what about escaped attribute values?
            if delimiter == "\""
              value_original.gsub!("\"", "'")
            else
              value_original.gsub!("'", "\"")
            end
          rescue MultiCss::ParseError => e
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
            value_original = HtmlPress.js_compressor value_original, @options[:js_minifier_options]
            # TODO what about escaped attribute values?
            if delimiter == "\""
              value_original.gsub! "\"", "'"
            end
          rescue MultiJs::ParseError => e
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

  end
end
