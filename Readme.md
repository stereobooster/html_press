#html_press

## how it works

Remove all whitespace junk. Leave only HTML

```
1.               ┌――――――――――――――――――╖        2.         ┌――――――――――――――――――╖
  ●――――――――――――――├―╢ <html> ws junk ║          ●――――――――├―――――――――╢ <html> ║
                 └――――――――――――――――――╜                   └――――――――――――――――――╜
```

## Usage

### Jekyll

Gemfile

```ruby
gem "jekyll"
gem "html_press"
```

_plugins/strip_tag.rb

```ruby
module Jekyll
  class StripTag < Liquid::Block
    @total_economy = 0
    class << self 
      attr_accessor :total_economy
    end 

    begin
      require 'html_press'
      def render(context)
        text = super
        before = text.bytesize
        text = HtmlPress.press text
        after = text.bytesize

        self.class.total_economy += before - after
        economy = (self.class.total_economy.to_f / 1024).round(2)
        p 'totally saved: ' + economy.to_s + ' Kb'
        text
      end
    rescue LoadError => e
      p "Unable to load 'html_press'"
    end
  end
end

Liquid::Template.register_tag('strip', Jekyll::StripTag)
```

In templates

```liquid
{% strip %}
here goes text...
{% endstrip %}
```

Run

```
bundle install
bundle exec jekyll
```

## Additional tools

  - https://github.com/aberant/css-spriter
  - https://github.com/sstephenson/sprockets
  - https://github.com/documentcloud/jammit
  - https://github.com/cjohansen/juicer
  - https://github.com/alexdunae/w3c_validators

## TODO

  - check if all utf-8 symbols, are smaller than html entities
  - ambigious ampersands
  - bin
  - Support other minifiers (Closure, YUI compressor)
  - htmlTydi
  - add examples of usage with Sinatra and Rails
  - https://github.com/gfranco/jeanny
  - https://github.com/aanand/deadweight

## Alternatives

###Ruby

  - https://github.com/completelynovel/html_compressor
  - https://github.com/MadRabbit/frontcompiler

###Other

  - http://code.google.com/p/htmlcompressor/
  - smarty `strip` tag
  - W3 total cache (WP plugin from smashingmagazine contains html minifier)
