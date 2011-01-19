$: << File.join(File.dirname(__FILE__), '../lib')

require 'test/unit'
require 'xmlsimple'

# This test case checks if a bug regarding markup encoding
# reported by Yan Zhang (Yan.Zhang (at) fedexkinkos.com)
# has been fixed.
class TC_Markup < Test::Unit::TestCase # :nodoc:
  def test_markup
    doc = <<-DOC
    <businessCustNames>
      <businessCustName>The&#39;s Heating &amp; Air</businessCustName>
    </businessCustNames>
    DOC
    expected = { 'businessCustName' => ["The's Heating & Air"] }
    xml = XmlSimple.xml_in(doc)
    assert_equal(expected, xml)
  end
end

