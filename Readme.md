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
    begin
      require 'html_press'
      def render(context)
        text = super
        HtmlPress.compress text
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

## Alternatives

###Ruby

  - https://github.com/completelynovel/html_compressor
  - https://github.com/MadRabbit/frontcompiler

###Other

  - http://code.google.com/p/htmlcompressor/
  - smarty `strip` tag
  - W3 total cache (WP plugin from smashingmagazine contains html minifier)

## TODO

  - bin
  - Support other minifiers (Closure, YUI compressor)
  - htmlTydi
