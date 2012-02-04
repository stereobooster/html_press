# encoding: UTF-8

require_relative "../lib/html_press"

class Lg
  attr_accessor :warns
  def initialize
    @warns = []
  end
  def warn text
    @warns.push text
  end
end

describe HtmlPress do
  before :each do
  end

  it "should leave only one whitespace between inline tags" do
    HtmlPress.compress("<p>lorem  <b>ipsum</b>  <i>dolor</i>  </p>").should eql "<p>lorem <b>ipsum</b> <i>dolor</i></p>"
  end

  it "should leave no whitespaces between block tags" do
    HtmlPress.compress("<div></div> \t\r\n  <div></div>").should eql "<div></div><div></div>"
    HtmlPress.compress("<div>  <div> \t\r\n  </div>  </div>").should eql "<div><div></div></div>"
  end

  it "should leave only one whitespace in text" do
    HtmlPress.compress("<p>a  a</p>").should eql "<p>a a</p>"
  end

  it "should leave newlines in pre tags and remove trailing spaces" do
    HtmlPress.compress("<pre>a \t </pre>").should eql "<pre>a</pre>"
    HtmlPress.compress("<pre>qwe   \nasd   </pre>").should eql "<pre>qwe\nasd</pre>"
  end

  it "should leave textareas as is" do
    text = "<textarea> \t </textarea>"
    HtmlPress.compress(text).should eql text
  end

  it "should compress js in script tags" do
    script = "  (function(undefined){ \t\n var long_name = '  '; }())  \n \r"
    compressed_script = "<script>" + HtmlPress.js_compressor(script) + "</script>"
    script = "  <script>" + script + "</script>  "
    HtmlPress.compress(script).should eql compressed_script
  end

  it "should compress css in style tags" do
    style = "  div { margin: 0px 0px; \n}  "
    compressed_style = "<style>" + HtmlPress.css_compressor(style) + "</style>"
    style = "  <style>" + style + "</style>  "
    HtmlPress.compress(style).should eql compressed_style
  end

  it "should remove html comments" do
    HtmlPress.compress("<p></p><!-- comment  --><p></p>").should eql "<p></p><p></p>"
  end

  it "should leave IE conditional comments" do
    text = "<!--[if IE]><html class=\"ie\"><![endif]--><div></div>"
    HtmlPress.compress(text).should eql text
  end

  it "should remove unnecessary whitespaces between attributes" do
    HtmlPress.compress("<p class=\"a\"   id=\"b\"></p>").should eql "<p class=\"a\" id=\"b\"></p>"
  end

  it "should leave whitespaces everywhere else" do
    text = "<a onclick=\"alert('     ')\" unknown_attr='   a  a'>a</a>"
    HtmlPress.compress(text).should eql text
  end

  it "should work with special utf-8 symbols" do
    HtmlPress.compress("✪<p></p>  <p></p>").should eql "✪<p></p><p></p>"
  end

  it "should work with tags in upper case" do
    HtmlPress.compress("<P>  </p>").should eql "<P></p>"
  end

  it "should remove whitespaces between IE conditional comments" do
    text = "<p></p>  <!--[if IE]><html class=\"ie\">      <![endif]--> <!--[if IE]><html class=\"ie1\"><![endif]-->"
    text2 = "<p></p><!--[if IE]><html class=\"ie\"><![endif]--><!--[if IE]><html class=\"ie1\"><![endif]-->"
    HtmlPress.compress(text).should eql text2
  end

  it "should treat text inside IE conditional comments as it was without comments" do
    text = "<div class=\"a\"   id=\"b\">    </div>    <p></p>"
    text2 = HtmlPress.compress(text)
    text = "<!--[if IE]>" + text + "<![endif]-->"
    text2 = "<!--[if IE]>" + text2 + "<![endif]-->"
    HtmlPress.compress(text).should eql text2
    text = "<script> (function(undefined){ var a;}()) </script>"
    text2 = HtmlPress.compress(text)
    text = "<!--[if IE]>" + text + "<![endif]-->"
    text2 = "<!--[if IE]>" + text2 + "<![endif]-->"
    HtmlPress.compress(text).should eql text2
  end

  it "should remove unnecessary whitespaces in html attributes (class)" do
    HtmlPress.compress("<p class=\"a  b\"></p>").should eql "<p class=\"a b\"></p>"
    HtmlPress.compress("<p class='a  b'></p>").should eql "<p class='a b'></p>"
  end

  it "should remove unnecessary whitespaces in html attributes (style)" do
    HtmlPress.compress("<p style=\"display: none;\"></p>").should eql "<p style=\"display:none;\"></p>"
  end

  it "should work with namespaces" do
    text = "<html xmlns:og=\"http://ogp.me/ns#\" class=\"a b\"><og:like>like</og:like></html>"
    HtmlPress.compress(text).should eql text
  end

  it "should not modify input value" do
    text = "<div> </div>"
    text1 = text + ""
    HtmlPress.compress(text)
    text.should eql text1
  end
  
  it "should not modify input value" do
    script_with_error = "<script>function(){</script>"
    l = Lg.new
    l.warns.size.should eql 0
    HtmlPress.compress(script_with_error, {:logger => l}).should eql script_with_error
    l.warns.size.should eql 1
  end
  # it "should remove unnecessary attributes" do
    # HtmlPress.compress("<script type=\"text/javascript\">var a;</script>").should eql "<script>var a;</script>"
  # end

end