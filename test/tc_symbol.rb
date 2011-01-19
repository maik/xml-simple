$: << File.join(File.dirname(__FILE__), '../lib')

require 'test/unit'
require 'xmlsimple'

# This test case will test the KeyToSymbol option
# added by Keith Veleba keith (at) veleba.net on 6/21/2006 
class TC_Symbol < Test::Unit::TestCase # :nodoc:
  def test_key_to_symbol
    symbol_file = File.join(File.dirname(__FILE__), 'files', 'symbol.xml')
    expected = {
                :x => ["Hello"],
                :y => ["World"],
                :z => [{
                       :inner => ["Inner"]
                      }]
               }
    xml = XmlSimple.xml_in(symbol_file, { 'KeyToSymbol' => true })
    assert_equal(expected, xml)
    xml = XmlSimple.xml_in(symbol_file, { 'key_to_symbol' => true })
    assert_equal(expected, xml)
  end
end
