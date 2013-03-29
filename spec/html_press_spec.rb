# encoding: UTF-8

require File.expand_path("../lib/html_press", File.dirname(__FILE__))

class LoggerStub
  attr_accessor :errors
  def initialize
    @errors = []
  end
  def error text
    @errors.push text
  end
end

describe HtmlPress do
  before :each do
  end

  it "should leave only one whitespace between inline tags" do
    HtmlPress.press("<p>lorem  <b>ipsum</b>  <i>dolor</i>  </p>").should eql "<p>lorem <b>ipsum</b> <i>dolor</i></p>"
  end

  it "should leave no whitespaces between block tags" do
    HtmlPress.press("<div></div> \t\r\n  <div></div>").should eql "<div></div><div></div>"
    HtmlPress.press("<div>  <div> \t\r\n  </div>  </div>").should eql "<div><div></div></div>"
  end

  it "should leave only one whitespace in text" do
    HtmlPress.press("<p>a  a</p>").should eql "<p>a a</p>"
  end

  it "should leave newlines in pre tags and remove trailing spaces" do
    HtmlPress.press("<pre>a \t </pre>").should eql "<pre>a</pre>"
    HtmlPress.press("<pre>qwe   \r\nasd   </pre>").should eql "<pre>qwe\nasd</pre>"
    HtmlPress.press("<pre>   qwe   \n\r\n   asd   </pre>").should eql "<pre>   qwe\n\n   asd</pre>"
  end

  it "should leave textareas as is" do
    text = "<textarea> \t </textarea>"
    HtmlPress.press(text).should eql text
  end

  it "should compress js in script tags" do
    script = "  (function(undefined){ \t\n var long_name = '  '; }())  \n \r"
    pressed_script = "<script>" + HtmlPress.js_compressor(script) + "</script>"
    script = "  <script>" + script + "</script>  "
    HtmlPress.press(script).should eql pressed_script

    script = %q{<script>window.jQuery||document.write('<script src="/components/jquery/jquery.js"><\/script>')</script>}
    HtmlPress.press(script).should eql script
  end

  it "should compress css in style tags" do
    style = "  div { margin: 0px 0px; \n}  "
    pressed_style = "<style>" + MultiCss.min(style) + "</style>"
    style = "  <style>" + style + "</style>  "
    HtmlPress.press(style).should eql pressed_style
  end

  it "should remove html comments" do
    HtmlPress.press("<p></p><!-- comment  --><p></p>").should eql "<p></p><p></p>"
  end

  it "should leave IE conditional comments" do
    text = "<!--[if IE]><html class=\"ie\"><![endif]--><div></div>"
    HtmlPress.press(text).should eql text
  end

  it "should work with special utf-8 symbols" do
    HtmlPress.press("✪<p></p>  <p></p>").should eql "✪<p></p><p></p>"
  end

  it "should work with tags in upper case" do
    HtmlPress.press("<P>  </p>").should eql "<P></p>"
  end

  it "should remove whitespaces between IE conditional comments" do
    text = "<p></p>  <!--[if IE]><html class=\"ie\">      <![endif]--> <!--[if IE]><html class=\"ie1\"><![endif]-->"
    text2 = "<p></p> <!--[if IE]><html class=\"ie\"><![endif]--><!--[if IE]><html class=\"ie1\"><![endif]-->"
    # TODO          ↑ remove this whitespace
    HtmlPress.press(text).should eql text2
  end

  it "should remove whitespaces between script tags" do
    text = "<p></p>  <script>var a</script> \t <script>var b</script>"
    text2 = "<p></p> <script>var a</script><script>var b</script>"
    HtmlPress.press(text).should eql text2
  end

  it "should concatenate adjacent script tags" do
    pending "Not implemented yet" do
      text = "<p></p>  <script>var a</script> \t <script>function b(){}</script>"
      text2 = "<p></p> <script>var a;function b(){}</script>"
      HtmlPress.press(text).should eql text2
    end
  end

  it "should treat text inside IE conditional comments as it was without comments" do
    text = "<div class=\"a\"   id=\"b\">    </div>    <p></p>"
    text2 = HtmlPress.press(text)
    text = "<!--[if IE]>" + text + "<![endif]-->"
    text2 = "<!--[if IE]>" + text2 + "<![endif]-->"
    HtmlPress.press(text).should eql text2
    text = "<script> (function(undefined){ var a;}()) </script>"
    text2 = HtmlPress.press(text)
    text = "<!--[if IE]>" + text + "<![endif]-->"
    text2 = "<!--[if IE]>" + text2 + "<![endif]-->"
    HtmlPress.press(text).should eql text2
  end

  it "should remove unnecessary whitespaces inside tag" do
    HtmlPress.press("<p class=\"a\"   id=\"b\"></p>").should eql "<p class=\"a\" id=\"b\"></p>"
    HtmlPress.press("<p class=\"a\" ></p>").should eql "<p class=\"a\"></p>"
    HtmlPress.press("<img src=\"\" />").should eql "<img src=\"\"/>"
    HtmlPress.press("<br />").should eql "<br/>"
  end

  it "should work with 'badly' formatted attributes" do
    HtmlPress.press("<p class='a'   id='b'></p>").should eql "<p class='a' id='b'></p>"
    # HtmlPress.press("<p class = 'a'></p>").should eql "<p class='a'></p>"
    # HtmlPress.press("<p class = a></p>").should eql "<p class=a></p>"
  end

  it "should work with different case attributes" do
    text = '<embed allowFullScreen="true" allowScriptAccess="always"/>'
    HtmlPress.press(text).should eql text
  end

  it "should optimize attributes" do
    HtmlPress.press("<p class=\"a  b\"></p>").should eql "<p class=\"a b\"></p>"
    # TODO http(s):// to //
  end

  it "should compress css in style attributes" do
    HtmlPress.press("<p style=\"display: none;\"></p>").should eql "<p style=\"display:none\"></p>"
    HtmlPress.press("<p style=\"\"></p>").should eql "<p style=\"\"></p>"
    #FIX those tests can be broken if algorithm of css_press will be changed
    HtmlPress.press("<p style=\"font-family:Arial ,'Helvetica Neue'\"></p>").should eql "<p style=\"font-family:Arial ,'Helvetica Neue'\"></p>"
    HtmlPress.press("<p style='font-family:Arial ,\"Helvetica Neue\"'></p>").should eql "<p style='font-family:Arial ,\"Helvetica Neue\"'></p>"
  end

  it "should work with namespaces" do
    text = "<html xmlns:og=\"http://ogp.me/ns#\" class=\"a b\"><og:like>like</og:like></html>"
    HtmlPress.press(text).should eql text
  end

  it "should compress namespaces" do
    pending "Not implemented yet" do
      text = "<html xmlns:og=\"http://ogp.me/ns#\" class=\"a b\"><og:like>like</og:like></html>"
      text1 = "<html xmlns:a=\"http://ogp.me/ns#\" class=\"a b\"><a:like>like</a:like></html>"
      HtmlPress.press(text).should eql text1
    end
  end

  it "should not modify input value" do
    text = "<div>   </div>"
    text1 = text.dup
    HtmlPress.press(text).should_not eql text
    text.should eql text1
  end

  it "should leave whitespaces inside other attributes" do
    text = "<a onclick=\"alert('     ')\" unknown_attr='   a  a'>a</a>"
    HtmlPress.press(text).should eql text
  end

  it "should report javascript errors" do
    ["<script>function(){</script>", "<a onclick=\"return false\"></a>"].each do |script_with_error|
      log = LoggerStub.new
      HtmlPress.press(script_with_error, {:logger => log}).should eql script_with_error
      log.errors.size.should eql 1
    end
  end

  it "should report css errors" do
    ["<style>.clas{margin:</style>", "<a style=\"#asd\">link</a>"].each do |style_with_error|
      log = LoggerStub.new
      HtmlPress.press(style_with_error, {:logger => log}).should eql style_with_error
      log.errors.size.should eql 1
    end
  end

  it "should remove values of boolean attributes" do
    HtmlPress.press("<option selected=\"selected\">a</option>").should eql "<option selected>a</option>"
    HtmlPress.press("<input type=\"checkbox\" checked=\"checked\"/>").should eql "<input type=\"checkbox\" checked/>"
    HtmlPress.press("<input type=\"radio\" checked=\"checked\"/>").should eql "<input type=\"radio\" checked/>"
    # disabled            (input, textarea, button, select, option, optgroup)
    HtmlPress.press("<input disabled=\"disabled\"/>").should eql "<input disabled/>"
    # readonly            (input type=text/password, textarea)
    HtmlPress.press("<input readonly=\"readonly\"/>").should eql "<input readonly/>"
    pending "Not implemented yet" do
      HtmlPress.press("<script src=\"example.com\" async=\"async\"></script>").should eql "<script src=\"example.com\" async></script>"
      HtmlPress.press("<script src=\"example.com\" defer=\"defer\"></script>").should eql "<script src=\"example.com\" defer></script>"
      HtmlPress.press("<select multiple=\"multiple\"/>").should eql "<select multiple/>"
      # ismap     isMap     (img, input type=image)
      # declare             (object; never used)
      # noresize  noResize  (frame)
      # nowrap    noWrap    (td, th; deprecated)
      # noshade   noShade   (hr; deprecated)
      # compact             (ul, ol, dl, menu, dir; deprecated)
    end
  end

  it "should remove attributes with default values" do
    HtmlPress.press("<script type=\"text/javascript\" language=\"JavaScript\">var a</script>").should eql "<script>var a</script>"
    HtmlPress.press("<script type=\"text/javascript\" src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js\"> </script>").
      should eql "<script src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js\"></script>"
    HtmlPress.press("<style type=\"text/stylesheet\"></style>").should eql "<style></style>"
    HtmlPress.press("<link type=\"text/stylesheet\"/>").should eql "<link/>"
    HtmlPress.press("<link rel=\"alternate\" type=\"application/rss+xml\"/>").should eql "<link rel=\"alternate\" type=\"application/rss+xml\"/>"
    HtmlPress.press("<form method=\"get\"></form>").should eql "<form></form>"
    HtmlPress.press("<input type=\"text\"/>").should eql "<input/>"
    # input value "" ?
  end

  it "should convert html entities to utf-8 symbols" do
    HtmlPress.press("&lt; &#60; &gt; &#62; &amp; &#38;").should eql "&lt; &#60; &gt; &#62; &amp; &#38;"
    HtmlPress.press("&eacute;lan").should eql "élan"
    %W{textarea pre}.each do |t|
      HtmlPress.press("<#{t}>&#39;</#{t}>").should eql "<#{t}>'</#{t}>"
    end
  end

  it "should remove unnecessary quotes for attribute values" do
    HtmlPress.press("<img src=\"\">", {:unquoted_attributes => true}).should eql "<img src=\"\">"
    HtmlPress.press("<p id=\"a\"></p>", {:unquoted_attributes => true}).should eql "<p id=a></p>"
    text = "<p id=\"a b\"></p>"
    HtmlPress.press(text, {:unquoted_attributes => true}).should eql text
    text = "<p id=\"a=\"></p>"
    HtmlPress.press(text, {:unquoted_attributes => true}).should eql text
    text = "<p id=\"a'\"></p>"
    HtmlPress.press(text, {:unquoted_attributes => true}).should eql text
    text = "<p id=\"a`\"></p>"
    HtmlPress.press(text, {:unquoted_attributes => true}).should eql text
    text = "<p id='a\"'></p>"
    HtmlPress.press(text, {:unquoted_attributes => true}).should eql text
    text = "<p id=\"a\t\"></p>"
    HtmlPress.press(text, {:unquoted_attributes => true}).should eql text
  end

  it "should remove empty attribute values" do
    HtmlPress.press("<img src=\"\">", {:drop_empty_values => true}).should eql "<img src>"
  end

  it "should compress javascript in event attributes" do
    %w[onfocus onblur onselect onchange onclick
      ondblclick onmousedown onmouseup onmouseover onmousemove
      onmouseout onkeypress onkeydown onkeyup
    ].each do |evt|
      HtmlPress.press("<a #{evt}=\"javacript: alert('  ');\"></a>").should eql "<a #{evt}=\"alert('  ')\"></a>"
      HtmlPress.press("<a #{evt}=\"\"></a>").should eql "<a #{evt}=\"\"></a>"
    end
  end

  it "should concatenate adjecent style tags" do
    pending "Not implemented yet"
    # all stylle tags can be collected, concatneated and placed in header
  end
end