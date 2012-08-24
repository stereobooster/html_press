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

### Ruby
```ruby
require 'html_press'
compressed_html = HtmlPress.press html
```

### Jekyll
see [jekyll_press](https://github.com/stereobooster/jekyll_press)

## TODO
  - use parser ([鋸](https://github.com/tenderlove/nokogiri)) instead of regexp's
    - add option to convert relative urls to absolute urls
  - [ambigious ampersands](http://mathiasbynens.be/notes/ambiguous-ampersands) for compression?
  - cli
  - Support other js/css minifiers (Closure, YUI compressor)
  - htmlTydi
  - add examples of usage with Sinatra and Rails
  - Rack plugin

## Alternatives
  - [html-minifier](https://github.com/kangax/html-minifier) (js), [test suite](https://github.com/kangax/html-minifier/blob/gh-pages/tests/index.html), [ruby wrapper - html_minifier](https://github.com/stereobooster/html_minifier)
  - [htmlcompressor](http://code.google.com/p/htmlcompressor/) (java), [test suite](http://code.google.com/p/htmlcompressor/source/browse/#svn%2Ftrunk%2Fsrc%2Ftest%2Fresources%2Fhtml%253Fstate%253Dclosed)
  - PHPTal compress (php), [test suite](https://svn.motion-twin.com/phptal/trunk/tests/CompressTest.php)
  - [W3 total cache](http://wordpress.org/extend/plugins/w3-total-cache/) - WP plugin from smashingmagazine contains html minifier (php)

## Additional tools
  - https://github.com/gfranco/jeanny
  - https://github.com/aanand/deadweight
  - https://github.com/aberant/css-spriter
  - https://github.com/jakesgordon/sprite-factory/
  - https://github.com/grosser/smusher
  - https://github.com/sstephenson/sprockets
  - https://github.com/documentcloud/jammit
  - https://github.com/alexdunae/w3c_validators

## Resources
  - http://perfectionkills.com/experimenting-with-html-minifier
  - http://perfectionkills.com/optimizing-html
  - https://developers.google.com/speed/articles/optimizing-html
