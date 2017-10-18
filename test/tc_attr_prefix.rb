$: << File.join(File.dirname(__FILE__), '../lib')

require 'test/unit'
require 'xmlsimple'

class TC_AttrPrefix < Test::Unit::TestCase # :nodoc:
  def test_attr_prefix_option
    xml_str = <<-XML_STR
    <Customer id="12253">
      <first_name>Joe</first_name>
      <last_name>Joe</last_name>
      <Address type="home"> 
        <line1>211 Over There</line1>
        <city>Jacksonville</city>
        <state>FL</state>
        <zip_code>11234</zip_code>
      </Address>
      <Address type="postal"> 
        <line1>3535 Head Office</line1>
        <city>Jacksonville</city>
        <state>FL</state>
        <zip_code>11234</zip_code>
      </Address>
    </Customer>
    XML_STR

    c = XmlSimple.xml_in xml_str, { 'ForceArray' => false, 'AttrPrefix' => true }

    assert_equal(
    {
      "@id"=>"12253",
      "first_name"=>"Joe",
      "Address"=>
      [
        {
          "city"=>"Jacksonville",
          "line1"=>"211 Over There",
          "zip_code"=>"11234",
          "@type"=>"home",
          "state"=>"FL"
        },
        {
          "city"=>"Jacksonville",
          "line1"=>"3535 Head Office",
          "zip_code"=>"11234",
          "@type"=>"postal",
          "state"=>"FL"
        }
      ],
      "last_name"=>"Joe"
    },
    c)

    expected = REXML::Document.new <<-OUT
    <opt id="12253">
      <first_name>Joe</first_name>
      <last_name>Joe</last_name>
      <Address type="home">
      <line1>211 Over There</line1>
        <city>Jacksonville</city>
        <state>FL</state>
        <zip_code>11234</zip_code>
      </Address>
      <Address type="postal">
      <line1>3535 Head Office</line1>
        <city>Jacksonville</city>
        <state>FL</state>
        <zip_code>11234</zip_code>
      </Address>
    </opt>
    OUT
    e_root = expected.root
    o_root = expected.root
    assert_equal(e_root.elements.size, o_root.elements.size)
    assert_equal(e_root.name, o_root.name)
    assert_equal(e_root.attributes, o_root.attributes)
    assert_equal(e_root.elements['/opt/first_name'].texts, o_root.elements['/opt/first_name'].texts)
    assert_equal(e_root.elements['/opt/last_name'].texts, o_root.elements['/opt/last_name'].texts)
    %w(home postal).each do |addr_type|
      e_address = e_root.elements["/opt/Address[@type='#{addr_type}']"]
      o_address = o_root.elements["/opt/Address[@type='#{addr_type}']"]
      %w(line1 city state zip_code).each do |element|
        assert_equal(e_address.elements[element].text, o_address.elements[element].text)
      end
    end
  end
end

