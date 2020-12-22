$: << File.join(File.dirname(__FILE__), '../lib')

require 'test/unit'
require 'xmlsimple'

class TC_Out < Test::Unit::TestCase # :nodoc:
  def test_simple_structure
    hash = {
      'opt' => [
        {
          'x' => [ { 'content'=> 'text1'} ],
          'y' => [ { 'content'=> 'text2'} ]
        }
      ]
    }
    expected = <<"END_OF_XML"
<opt>
  <opt>
    <x>text1</x>
    <y>text2</y>
  </opt>
</opt>
END_OF_XML

    assert_equal(expected, XmlSimple.xml_out(hash))
  end

  def test_keep_root
    hash = {
      'opt' => [
        {
          'x' => [ { 'content'=> 'text1'} ],
          'y' => [ { 'content'=> 'text2'} ]
        }
      ]
    }
    expected = <<"END_OF_XML"
<opt>
  <x>text1</x>
  <y>text2</y>
</opt>
END_OF_XML

    assert_equal(expected, XmlSimple.xml_out(hash, { 'keep_root' => true }))
  end

  def test_original
    hash = {
      'logdir'        => '/var/log/foo/',
      'debugfile'     => '/tmp/foo.debug',

      'server'        => {
        'sahara'        => {
          'osversion'     => '2.6',
          'osname'        => 'solaris',
          'address'       => [ '10.0.0.101', '10.0.1.101' ]
        },

        'gobi'          => {
          'osversion'     => '6.5',
          'osname'        => 'irix',
          'address'       => '10.0.0.102'
        },

        'kalahari'      => {
          'osversion'     => '2.0.34',
          'osname'        => 'linux',
          'address'       => [ '10.0.0.103', '10.0.1.103' ]
        }
      }
    }

    expected = <<"END_OF_XML"
<opt logdir="/var/log/foo/" debugfile="/tmp/foo.debug">
  <server>
    <sahara osversion="2.6" osname="solaris">
      <address>10.0.0.101</address>
      <address>10.0.1.101</address>
    </sahara>
    <gobi osversion="6.5" osname="irix" address="10.0.0.102" />
    <kalahari osversion="2.0.34" osname="linux">
      <address>10.0.0.103</address>
      <address>10.0.1.103</address>
    </kalahari>
  </server>
</opt>
END_OF_XML
    assert_equal(expected, XmlSimple.xml_out(hash))
  end

  def test_xyz
    hash = {
      'abc' => [
        {
          'z' => ['ZZZ', {}, {}]
        }
      ],
      'b'   => [
        {
          'c' => ['Eins', 'Eins', 'Zwei']
        },
        {
          'c' => [
            'Drei',
            'Zwei',
            { 'd' => [ 'yo' ] }
          ]
        }
      ],
      'xyz'  => [ 'Hallo' ],
      'att'  => [ { 'test' => '42' } ],
      'att2' => [ { 'test' => '4711', 'content' => 'CONTENT' } ],
      'element' => [
        {
          'att'     => '1',
          'content' => 'one'
        },
        {
          'att'     => '2',
          'content' => 'two'
        },
        {
          'att'     => '3',
          'content' => 'three'
        },
      ],
    }
    expected = <<"END_OF_XML"
<opt>
  <abc>
    <z>ZZZ</z>
    <z></z>
    <z></z>
  </abc>
  <b>
    <c>Eins</c>
    <c>Eins</c>
    <c>Zwei</c>
  </b>
  <b>
    <c>Drei</c>
    <c>Zwei</c>
    <c>
      <d>yo</d>
    </c>
  </b>
  <xyz>Hallo</xyz>
  <att test="42" />
  <att2 test="4711">CONTENT</att2>
  <element att="1">one</element>
  <element att="2">two</element>
  <element att="3">three</element>
</opt>
END_OF_XML

    assert_equal(expected, XmlSimple.xml_out(hash))
  end

  def test_selfclose
    hash = {
      'root' => [
        {
          'empty' => ['text', {}, {}]
        }
      ]
    }
    expected = <<"END_OF_XML"
<opt>
  <root>
    <empty>text</empty>
    <empty />
    <empty />
  </root>
</opt>
END_OF_XML

    assert_equal(expected, XmlSimple.xml_out(hash, 'selfclose' => true))
  end

  def test_output_with_symbols
    test1 = { :foo => 'abc' }
    expected = "<opt foo=\"abc\" />\n"
    output = XmlSimple.xml_out(test1)
    assert_equal(output, expected)
  end
end
