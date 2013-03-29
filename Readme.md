# HtmlPress ![Gem Version](https://fury-badge.herokuapp.com/rb/html_press.png) [![Build Status](https://travis-ci.org/stereobooster/html_press.png?branch=master)](https://travis-ci.org/stereobooster/html_press) [![Dependency Status](https://gemnasium.com/stereobooster/html_press.png?travis)](https://gemnasium.com/stereobooster/html_press) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/stereobooster/html_press)

## How it works

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

### Rails
TODO :exclamation:

### Sinatra
TODO :exclamation:

### Command line
TODO :exclamation:

## TODO
  - use parser ([鋸](https://github.com/tenderlove/nokogiri)) instead of regexp's
    - add option to convert relative urls to absolute urls (for SEO)
  - [ambigious ampersands](http://mathiasbynens.be/notes/ambiguous-ampersands) for compression?
  - Support other js/css minifiers (Closure, YUI compressor)
  - htmlTydi
  - Rack plugin
  - add script to benchmark real projects like amazon or stackoverflow
  - support html5 tags
  - add more options
  - Optimization: make substring replace based on substring length and its position in initial string

## Alternatives
  - [html-minifier](https://github.com/kangax/html-minifier) (js), [test suite](https://github.com/kangax/html-minifier/blob/gh-pages/tests/index.html), ruby wrapper - [html_minifier](https://github.com/stereobooster/html_minifier)
  - [htmlcompressor](http://code.google.com/p/htmlcompressor/) (java), [test suite](http://code.google.com/p/htmlcompressor/source/browse/#svn%2Ftrunk%2Fsrc%2Ftest%2Fresources%2Fhtml%253Fstate%253Dclosed)
  - PHPTal compress (php), [test suite](https://svn.motion-twin.com/phptal/trunk/tests/CompressTest.php)
  - [W3 total cache](http://wordpress.org/extend/plugins/w3-total-cache/) - WP plugin from smashingmagazine contains html minifier (php)

## Additional tools
  - [jeanny](https://github.com/gfranco/jeanny) - rename css classes and ids in css and html files
    - make shorter pathes for images in css
  - [deadweight](https://github.com/aanand/deadweight) - remove unused css rules from css files
  - [csscss](http://zmoazeni.github.com/csscss/) will parse any CSS files you give it and let you know which rulesets have duplicated declarations.
  - [css-spriter](https://github.com/aberant/css-spriter), [sprite-factory](https://github.com/jakesgordon/sprite-factory) - combine images in sprites
  - resize images by size defined in html and vice versa embed size of images in html
  - [#1](http://habrahabr.ru/post/90761/), [#2](http://ap-project.org/English/Article/View/53/) - inline small images in css
  - [smusher](https://github.com/grosser/smusher), jpegtran, optipng - losslessly minify images
  - [sprockets](https://github.com/sstephenson/sprockets), [jammit](https://github.com/documentcloud/jammit) - asset bundlers
  - [w3c_validators](https://github.com/alexdunae/w3c_validators)
  - [reduce](https://github.com/grosser/reduce)

## Resources

### Minimize HTML
  - http://perfectionkills.com/experimenting-with-html-minifier
  - http://perfectionkills.com/optimizing-html
  - https://developers.google.com/speed/articles/optimizing-html

### Front-end optimization
  - https://developers.google.com/speed/docs/insights/rules
  - http://developer.yahoo.com/performance/rules.html
