$: << File.join(File.dirname(__FILE__), '../lib')

require 'test/unit'
require 'xmlsimple'

class TC_String_In < Test::Unit::TestCase # :nodoc:
  def test_simple_strings
    simple = XmlSimple.new
    expected = { 'username' => 'testuser', 'password' => 'frodo' }
    xml_string = '<opt username="testuser" password="frodo"></opt>'
    assert_equal(expected, simple.xml_in(xml_string))

    xml_string = '<opt username="testuser" password="frodo" />'
    assert_equal(expected, simple.xml_in(xml_string))

    assert_equal(expected, XmlSimple.xml_in(xml_string))
  end

  def test_repeated_nested_elements
    simple = XmlSimple.new
    xml_string = <<-'END_OF_XML'
    <opt>
      <person firstname="Joe" lastname="Smith">
        <email>joe@smith.com</email>
        <email>jsmith@yahoo.com</email>
      </person>
      <person firstname="Bob" lastname="Smith">
        <email>bob@smith.com</email>
      </person>
    </opt>
    END_OF_XML
    expected = {
      'person' => [
        {
          'email'     => ['joe@smith.com', 'jsmith@yahoo.com'],
          'firstname' => 'Joe',
          'lastname'  => 'Smith'
        },
        {
          'email'     => ['bob@smith.com'],
          'firstname' => 'Bob',
          'lastname'  => 'Smith'
        }
      ]
    }
    assert_equal(expected, simple.xml_in(xml_string))

    expected = {
      'person' => [
        {
          'email'     => ['joe@smith.com', 'jsmith@yahoo.com'],
          'firstname' => 'Joe',
          'lastname'  => 'Smith'
        },
        {
          'email'     => 'bob@smith.com',
          'firstname' => 'Bob',
          'lastname'  => 'Smith'
        }
      ]
    }
    assert_equal(expected, simple.xml_in(xml_string, { 'force_array' => false }))
  end

  def test_keyattr_folding
    simple = XmlSimple.new
    xml_string = <<-'END_OF_XML'
    <opt>
      <person key="jsmith"  firstname="Joe" lastname="Smith" />
      <person key="tsmith"  firstname="Tom" lastname="Smith" />
      <person key="jbloggs" firstname="Joe" lastname="Bloggs" />
    </opt>
    END_OF_XML
    expected = {
      'person' => {
        'jbloggs' => {
          'firstname' => 'Joe',
          'lastname'  => 'Bloggs'
        },
        'tsmith' => {
          'firstname' => 'Tom',
          'lastname'  => 'Smith'
        },
        'jsmith' => {
          'firstname' => 'Joe',
          'lastname'  => 'Smith'
        }
      }
    }
    assert_equal(expected, simple.xml_in(xml_string, { 'key_attr' => %w(key) }))
  end

  def test_text_and_attributes
    simple = XmlSimple.new
    xml_string = <<-'END_OF_XML'
    <opt>
      <one>first</one>
      <two attr="value">second</two>
    </opt>
    END_OF_XML
    expected = {
      'one' => [ 'first' ],
      'two' => [ { 'attr' => 'value', 'content' => 'second' } ]
    }
    assert_equal(expected, simple.xml_in(xml_string))

    expected = {
      'one' => 'first',
      'two' => { 'attr' => 'value', 'content' => 'second' }
    }
    assert_equal(expected, simple.xml_in(xml_string, { 'force_array' => false }))
  end

  def test_anonymous_arrays
    simple = XmlSimple.new
    xml_string = <<-'END_OF_XML'
    <opt>
      <head><anon>Col 1</anon><anon>Col 2</anon><anon>Col 3</anon></head>
      <data><anon>R1C1</anon><anon>R1C2</anon><anon>R1C3</anon></data>
      <data><anon>R2C1</anon><anon>R2C2</anon><anon>R2C3</anon></data>
      <data><anon>R3C1</anon><anon>R3C2</anon><anon>R3C3</anon></data>
    </opt>
    END_OF_XML
    expected = {
      'head' => [
        [ 'Col 1', 'Col 2', 'Col 3' ]
      ],
      'data' => [
        [ 'R1C1', 'R1C2', 'R1C3' ],
        [ 'R2C1', 'R2C2', 'R2C3' ],
        [ 'R3C1', 'R3C2', 'R3C3' ]
      ]
    }
    assert_equal(expected, simple.xml_in(xml_string))

    xml_string = <<-'END_OF_XML'
    <opt>
      <head><silly>Col 1</silly><silly>Col 2</silly><silly>Col 3</silly></head>
      <data><silly>R1C1</silly><silly>R1C2</silly><silly>R1C3</silly></data>
      <data><silly>R2C1</silly><silly>R2C2</silly><silly>R2C3</silly></data>
      <data><silly>R3C1</silly><silly>R3C2</silly><silly>R3C3</silly></data>
    </opt>
    END_OF_XML
    expected = {
      'head' => [
        [ 'Col 1', 'Col 2', 'Col 3' ]
      ],
      'data' => [
        [ 'R1C1', 'R1C2', 'R1C3' ],
        [ 'R2C1', 'R2C2', 'R2C3' ],
        [ 'R3C1', 'R3C2', 'R3C3' ]
      ]
    }
    assert_equal(expected, simple.xml_in(xml_string, { 'anonymous_tag' => 'silly' }))

    xml_string = <<-'END_OF_XML'
    <opt>
      <anon><anon>Col 1</anon><anon>Col 2</anon></anon>
      <anon><anon>R1C1</anon><anon>R1C2</anon></anon>
      <anon><anon>R2C1</anon><anon>R2C2</anon></anon>
    </opt>
    END_OF_XML
    expected = [
        [ 'Col 1', 'Col 2' ],
        [ 'R1C1', 'R1C2' ],
        [ 'R2C1', 'R2C2' ]
    ]
    assert_equal(expected, simple.xml_in(xml_string))

    xml_string = <<-'END_OF_XML'
    <opt>
      <silly><silly>Col 1</silly><silly>Col 2</silly></silly>
      <silly><silly>R1C1</silly><silly>R1C2</silly></silly>
      <silly><silly>R2C1</silly><silly>R2C2</silly></silly>
    </opt>
    END_OF_XML
    expected = [
        [ 'Col 1', 'Col 2' ],
        [ 'R1C1', 'R1C2' ],
        [ 'R2C1', 'R2C2' ]
    ]
    assert_equal(expected, simple.xml_in(xml_string, { 'anonymous_tag' => 'silly' }))
  end

  def test_collapse_again
    simple = XmlSimple.new
    xml_string = '<opt><item name="one">First</item><item name="two">Second</item></opt>'
    expected = {
      'item' => {
        'one' => 'First',
        'two' => 'Second'
      }
    }
    assert_equal(expected, simple.xml_in(xml_string, {
      'KeyAttr'    => { 'item' => 'name' },
      'ForceArray' => [ 'item' ],
      'ContentKey' => '-content'
    }))

    expected = {
      'item' => {
        'one' => { 'content' => 'First'  },
        'two' => { 'content' => 'Second' }
      }
    }
    assert_equal(expected, simple.xml_in(xml_string, {
      'KeyAttr'    => { 'item' => 'name' },
      'ForceArray' => [ 'item' ],
      'ContentKey' => 'content'
    }))
  end

  def test_force_array_regex
    simple = XmlSimple.new
    xml_string = '<opt><item name="one">First</item><item name="two">Second</item></opt>'
    expected = {
      'item' => {
        'one' => { 'content' => 'First'  },
        'two' => { 'content' => 'Second' }
      }
    }
    assert_equal(expected, simple.xml_in(xml_string, {
      'KeyAttr'    => { 'item' => 'name' },
      'ForceArray' => [ /item/ ]
    }))
    assert_equal(expected, simple.xml_in(xml_string, {
      'KeyAttr'    => { 'item' => 'name' },
      'ForceArray' => [ /it/ ]
    }))
  end

  def test_group_tags
    simple = XmlSimple.new
    xml_string = <<-'END_OF_XML'
    <opt>
      <searchpath>
        <dir>/usr/bin</dir>
        <dir>/usr/local/bin</dir>
        <dir>/usr/X11/bin</dir>
      </searchpath>
    </opt>
    END_OF_XML
    
    expected = {
      'searchpath' => {
        'dir' => [ '/usr/bin', '/usr/local/bin', '/usr/X11/bin' ]
      }
    }
    assert_equal(expected, simple.xml_in(xml_string, {
      'ForceArray' => false,
      'KeyAttr'    => %w(name key id)
    }))

    expected = {
      'searchpath' => [ '/usr/bin', '/usr/local/bin', '/usr/X11/bin' ]
    }
    assert_equal(expected, simple.xml_in(xml_string, {
      'ForceArray' => false,
      'KeyAttr'    => %w(name key id),
      'GroupTags'  => { 'searchpath' => 'dir' }
    }))
  end

  def test_normalise_space
    simple = XmlSimple.new
    xml_string = <<-'END_OF_XML'
    <opt>
      <searchpath>
        <dir>  /usr/bin</dir>
        <dir>/usr/local/bin  </dir>
        <dir>  /usr   /X11/bin  </dir>
      </searchpath>
    </opt>
    END_OF_XML
    
    expected = {
      'searchpath' => {
        'dir' => [ '  /usr/bin', '/usr/local/bin  ', '  /usr   /X11/bin  ' ]
      }
    }
    assert_equal(expected, simple.xml_in(xml_string, {
      'ForceArray'     => false,
      'KeyAttr'        => %w(name key id),
      'NormaliseSpace' => 0
    }))

    expected = {
      'searchpath' => {
        'dir' => [ '/usr/bin', '/usr/local/bin', '/usr /X11/bin' ]
      }
    }
    assert_equal(expected, simple.xml_in(xml_string, {
      'ForceArray'     => false,
      'KeyAttr'        => %w(name key id),
      'NormaliseSpace' => 2
    }))
  end

  def test_var_attr
    simple = XmlSimple.new
    xml_string = <<-'END_OF_XML'
    <opt>
      <dir name="prefix">/usr/local/apache</dir>
      <dir name="exec_prefix">${prefix}</dir>
      <dir name="bindir">${exec_prefix}/bin</dir>
    </opt>
    END_OF_XML
    
    expected = {
      'dir' => {
        'prefix'      => '/usr/local/apache',
        'exec_prefix' => '/usr/local/apache',
        'bindir'      => '/usr/local/apache/bin'
      }
    }
    assert_equal(expected, simple.xml_in(xml_string, {
      'ForceArray' => false,
      'KeyAttr'    => %w(name key id),
      'VarAttr'    => 'name',
      'ContentKey' => '-content'
    }))
  end
end

