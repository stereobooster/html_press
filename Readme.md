#html_press

[![Build Status](https://secure.travis-ci.org/stereobooster/html_press.png?branch=master)](http://travis-ci.org/stereobooster/html_press)

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

## TODO

  - check if all utf-8 symbols, are smaller than html entities
  - ambigious ampersands
  - bin
  - Support other js/css minifiers (Closure, YUI compressor)
  - htmlTydi
  - add examples of usage with Sinatra and Rails
  - use parser ([鋸](https://github.com/tenderlove/nokogiri)) instead of regexp's

## Alternatives

  - [html-minifier](https://github.com/kangax/html-minifier) (js), [test suite](https://github.com/kangax/html-minifier/blob/gh-pages/tests/index.html), [ruby wrapper - html_minifier](https://github.com/stereobooster/html_minifier)
  - [htmlcompressor](http://code.google.com/p/htmlcompressor/) (java), [test suite](http://code.google.com/p/htmlcompressor/source/browse/#svn%2Ftrunk%2Fsrc%2Ftest%2Fresources%2Fhtml%253Fstate%253Dclosed)
  - PHPTal compress (php), [test suite](https://svn.motion-twin.com/phptal/trunk/tests/CompressTest.php)
  - [W3 total cache](http://wordpress.org/extend/plugins/w3-total-cache/) - WP plugin from smashingmagazine contains html minifier (php)

## Additional tools

  - https://github.com/gfranco/jeanny
  - https://github.com/aanand/deadweight
  - https://github.com/aberant/css-spriter
  - https://github.com/sstephenson/sprockets
  - https://github.com/documentcloud/jammit
  - https://github.com/cjohansen/juicer
  - https://github.com/alexdunae/w3c_validators
