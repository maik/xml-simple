$: << File.join(File.dirname(__FILE__), '../lib')

require 'test/unit'
require 'xmlsimple'

class NodeToTextTests < Test::Unit::TestCase
  def setup
    @xmlin = XmlSimple.new
    @element = REXML::Element.new("abc")
    @text = REXML::Text.new("<abc/>")
    @attribute = REXML::Attribute.new("name", "&lt;abc/&gt;")
    @element.add_attribute(@attribute)
    @element.add_text(@text)
  end

  def test_node_to_text_on_element
    assert_equal "<abc/>", @xmlin.send(:node_to_text, @element)
  end
  
  def test_node_to_text_on_text
    assert_equal "<abc/>", @xmlin.send(:node_to_text, @text)
  end
  
  def test_node_to_text_on_attribute
    assert_equal "<abc/>", @xmlin.send(:node_to_text, @attribute)
  end
  
  def test_node_to_text_on_doubly_normalized_attribute
    @attribute = REXML::Attribute.new("name", "&amp;lt;abc/&amp;gt;")
    assert_equal "&lt;abc/&gt;", @xmlin.send(:node_to_text, @attribute)
  end
  
  def test_node_to_text_on_nil
    assert_nil @xmlin.send(:node_to_text, nil)
  end
end
