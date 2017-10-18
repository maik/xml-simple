$: << File.join(File.dirname(__FILE__), '../lib')

require 'test/unit'
require 'xmlsimple'

# The test cases below are copied from the original Perl version,
# because I wanted to behave the Ruby version exactly as the Perl
# version. I left some comments, that maybe do not make a lot of
# sense in the current Ruby version just to make it easier to find
# changes between the current and future Perl versions of the
# module.
# Please note, that a major difference between the Perl and the Ruby
# version is, that the defaults of the options 'force_array' and
# 'key_attr' have changed.
class TC_Perl_In < Test::Unit::TestCase # :nodoc:
  def test_perl_test_cases
    opt = XmlSimple.xml_in(%q(<opt name1="value1" name2="value2"></opt>), {
      'force_array' => false,
      'key_attr'    => %w(name, key, id)
    })
    expected = {
      'name1' => 'value1',
      'name2' => 'value2'
    }
    assert_equal(expected, opt)

    # Now try a slightly more complex one that returns the same value
    opt = XmlSimple.xml_in(%q(
      <opt> 
        <name1>value1</name1>
        <name2>value2</name2>
      </opt>
    ), { 'force_array' => false, 'key_attr' => %w(name key id) })
    assert_equal(expected, opt)

    # And something else that returns the same
    opt = XmlSimple.xml_in(%q(<opt name1="value1"
    name2="value2" />), { 'force_array' => false, 'key_attr' => %w(name key id) })
    assert_equal(expected, opt)

    # Try something with two lists of nested values 
    opt = XmlSimple.xml_in(%q(
      <opt> 
        <name1>value1.1</name1>
        <name1>value1.2</name1>
        <name1>value1.3</name1>
        <name2>value2.1</name2>
        <name2>value2.2</name2>
        <name2>value2.3</name2>
    </opt>), { 'force_array' => false, 'key_attr' => %w(name key id) })
    assert_equal({
      'name1' => [ 'value1.1', 'value1.2', 'value1.3' ],
      'name2' => [ 'value2.1', 'value2.2', 'value2.3' ]
    }, opt)

    # Now a simple nested hash
    opt = XmlSimple.xml_in(%q(
      <opt> 
        <item name1="value1" name2="value2" />
      </opt>), { 'force_array' => false, 'key_attr' => %w(name key id) })
    assert_equal({
      'item' => {
        'name1' => 'value1',
        'name2' => 'value2'
      }
    }, opt)

    # Now a list of nested hashes
    opt = XmlSimple.xml_in(%q(
      <opt> 
        <item name1="value1" name2="value2" />
        <item name1="value3" name2="value4" />
      </opt>), { 'force_array' => false, 'key_attr' => %w(name key id) })
    assert_equal({
      'item' => [
        { 
          'name1' => 'value1',
          'name2' => 'value2'
        },
        {
          'name1' => 'value3',
          'name2' => 'value4'
        }
	  ]
    }, opt)

    # Now a list of nested hashes transformed into a hash using former
    # default key names.
    string = %q(
      <opt> 
        <item name="item1" attr1="value1" attr2="value2" />
        <item name="item2" attr1="value3" attr2="value4" />
      </opt>
    )
    target = {
      'item' => {
        'item1' => {
          'attr1' => 'value1',
          'attr2' => 'value2'
        },
        'item2' => {
          'attr1' => 'value3',
          'attr2' => 'value4'
        }
      }
    }
    opt = XmlSimple.xml_in(string, { 'force_array' => false, 'key_attr' => %w(name key id) })
    assert_equal(target, opt)

    # Same thing left as an array by suppressing former default key names.
    target = {
      'item' => [
        {
          'name'  => 'item1',
          'attr1' => 'value1',
          'attr2' => 'value2'
        },
        {
          'name'  => 'item2',
          'attr1' => 'value3',
          'attr2' => 'value4'
        }
      ]
    }
    opt = XmlSimple.xml_in(string, { 'force_array' => false })
    assert_equal(target, opt)

    # Same again with alternative key suppression
    opt = XmlSimple.xml_in(string, { 'key_attr' => {} })
    assert_equal(target, opt)

    # Try the other two "default" key attribute names (they are no
    # default values in the Ruby version.)
    opt = XmlSimple.xml_in(%q(
      <opt> 
        <item key="item1" attr1="value1" attr2="value2" />
        <item key="item2" attr1="value3" attr2="value4" />
      </opt>
    ), { 'force_array' => false, 'key_attr' => %w(name key id) })
    assert_equal({
      'item' => {
        'item1' => {
          'attr1' => 'value1',
          'attr2' => 'value2'
        },
        'item2' => {
          'attr1' => 'value3',
          'attr2' => 'value4'
        }
      }
    }, opt)

    opt = XmlSimple.xml_in(%q(
      <opt> 
        <item id="item1" attr1="value1" attr2="value2" />
        <item id="item2" attr1="value3" attr2="value4" />
      </opt>
    ), { 'force_array' => false, 'key_attr' => %w(name key id) })
    assert_equal({
      'item' => {
        'item1' => {
          'attr1' => 'value1',
          'attr2' => 'value2'
        },
        'item2' => {
          'attr1' => 'value3',
          'attr2' => 'value4'
        }
      }
    }, opt)

    # Similar thing using non-standard key names
    xml = %q(
      <opt> 
        <item xname="item1" attr1="value1" attr2="value2" />
        <item xname="item2" attr1="value3" attr2="value4" />
      </opt>)

    target = {
      'item' => {
        'item1' => {
          'attr1' => 'value1',
          'attr2' => 'value2'
        },
        'item2' => {
          'attr1' => 'value3',
          'attr2' => 'value4'
        }
      }
    }

    opt = XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(xname) })
    assert_equal(target, opt)

    # And with precise element/key specification
    opt = XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => { 'item' => 'xname' } })
    assert_equal(target, opt)

    # Same again but with key field further down the list
    opt = XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(wibble xname) })
    assert_equal(target, opt)

    # Same again but with key field supplied as scalar
    opt = XmlSimple.xml_in(xml, { 'force_array' => false, 'keyattr' => %w(xname) })
    assert_equal(target, opt)

    # Same again but with mixed-case option name
    opt = XmlSimple.xml_in(xml, { 'force_array' => false, 'KeyAttr' => %w(xname) })
    assert_equal(target, opt)

    # Same again but with underscores in option name
    opt = XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(xname) })
    assert_equal(target, opt)

    # Weird variation, not exactly what we wanted but it is what we expected 
    # given the current implementation and we don't want to break it accidently
    xml = %q(
     <opt>
       <item id="one" value="1" name="a" />
       <item id="two" value="2" />
       <item id="three" value="3" />
     </opt>)

    target = {
      'item' => {
        'three' => {
          'value' => '3'
        },
        'a' => {
          'value' => '1',
          'id'    => 'one'
        },
        'two' => { 
          'value' => '2'
        }
      }
    }
       
    opt = XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(name key id) })
    assert_equal(target, opt)

    # Or somewhat more as one might expect
    target = {
      'item' => {
        'one' => {
          'value' => '1',
          'name'  => 'a' 
        },
        'two' => {
          'value' => '2'
        },
        'three' => {
          'value' => '3'
        }
      }
    }
       
    opt = XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => { 'item' => 'id' } })
    assert_equal(target, opt)

    # Now a somewhat more complex test of targetting folding
    xml = %q(
      <opt>
        <car license="SH6673" make="Ford" id="1">
          <option key="1" pn="6389733317-12" desc="Electric Windows"/>
          <option key="2" pn="3735498158-01" desc="Leather Seats"/>
          <option key="3" pn="5776155953-25" desc="Sun Roof"/>
        </car>
        <car license="LW1804" make="GM"   id="2">
          <option key="1" pn="9926543-1167" desc="Steering Wheel"/>
        </car>
      </opt>)

    target = {
      'car' => {
        'LW1804' => {
          'id'     => '2',
          'make'   => 'GM',
          'option' => {
            '9926543-1167' => {
              'key'  => '1',
              'desc' => 'Steering Wheel'
            }
          }
        },
        'SH6673' => {
          'id'     => '1',
          'make'   => 'Ford',
          'option' => {
            '6389733317-12' => {
              'key'  => '1', 
              'desc' => 'Electric Windows'
            },
            '3735498158-01' => {
              'key'  => '2',
              'desc' => 'Leather Seats'
            },
            '5776155953-25' => {
              'key'  => '3',
              'desc' => 'Sun Roof'
            }
          }
        }
      }
    }
    
    opt = XmlSimple.xml_in(xml, { 'key_attr' => { 'car' => 'license', 'option' => 'pn' }});
    assert_equal(target, opt)

    # Now try leaving the keys in place
    target = {
      'car' => {
        'LW1804' => {
          'id'     => '2',
          'make'   => 'GM',
          'option' => {
            '9926543-1167' => {
              'key'  => '1',
              'desc' => 'Steering Wheel',
              '-pn'  => '9926543-1167'
            }
          },
          'license' => 'LW1804'
        },
        'SH6673' => {
          'id'     => '1',
          'make'   => 'Ford',
          'option' => {
            '6389733317-12' => {
              'key'  => '1',
              'desc' => 'Electric Windows',
              '-pn'  => '6389733317-12'
            },
            '3735498158-01' => {
              'key'  => '2',
              'desc' => 'Leather Seats',
              '-pn'  => '3735498158-01'
            },
            '5776155953-25' => {
              'key'  => '3',
              'desc' => 'Sun Roof',
              '-pn'  => '5776155953-25'
            }
          },
          'license' => 'SH6673'
        }
      }
    }
    
    opt = XmlSimple.xml_in(xml, { 'key_attr' => { 'car' => '+license', 'option' => '-pn' }})
    assert_equal(target, opt)

    # Confirm the stringifying references bug is fixed
    xml = %q(
      <opt>
        <item>
          <name><firstname>Bob</firstname></name>
          <age>21</age>
        </item>
        <item>
          <name><firstname>Kate</firstname></name>
          <age>22</age>
        </item>
      </opt>)
      
    target = {
      'item' => [
        {
          'age'  => '21',
          'name' => {
            'firstname' => 'Bob'
          }
        },
        {
          'age'  => '22',
          'name' => {
            'firstname' => 'Kate'
          }
        },
      ]
    }
      
    opt = XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(name key id) })
    assert_equal(target, opt)

    opt = XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => { 'item' => 'name' }})
    assert_equal(target, opt)

    # Make sure that the root element name is preserved if we ask for it
    target = XmlSimple.xml_in("<opt>#{xml}</opt>", {
      'key_attr' => { 'car' => '+license', 'option' => '-pn' }
    })
    opt = XmlSimple.xml_in(xml, {
      'keep_root' => true,
      'key_attr'  => { 'car' => '+license', 'option' => '-pn' }
    })
    assert_equal(target, opt)

    # confirm that CDATA sections parse correctly
    xml = %q{<opt><cdata><![CDATA[<greeting>Hello, world!</greeting>]]></cdata></opt>};
    opt = XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(name key id) });
    assert_equal({ 'cdata' => '<greeting>Hello, world!</greeting>' }, opt)

    xml = %q{<opt><x><![CDATA[<y>one</y>]]><![CDATA[<y>two</y>]]></x></opt>};
    opt = XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(name key id) });
    assert_equal({ 'x' => '<y>one</y><y>two</y>' }, opt)

    # Try parsing a named external file
    opt = XmlSimple.xml_in(File.join(File.dirname(__FILE__), 'files', 'test1.xml'), { 'force_array' => false, 'key_attr' => %w(name key id) })
    assert_equal({ 'location' => 'files/test1.xml' }, opt)

    # Try parsing default external file (scriptname.xml in script directory)
    # I have disabled this test for now, because I did not have time to make
    # it work. The problem is that the environment of the test runner is
    # completely different from the environment of the actual test case.
    # opt = XmlSimple.xml_in(nil, { 'force_array' => false, 'key_attr' => %w(name key id) })
    # assert_equal({ 'location' => 'tc_perl_in.xml' }, opt)

    # Try parsing named file in a directory in the searchpath
    opt = XmlSimple.xml_in('test2.xml', {
      'force_array' => false,
      'key_attr'    => %w(name key id),
      'search_path' => ['dir1', 'dir2', File.join(File.dirname(__FILE__), 'files', 'subdir')]
    })
    assert_equal({ 'location' => 'files/subdir/test2.xml' }, opt)

    # Ensure we get expected result if file does not exist
    assert_raises(ArgumentError) {
      XmlSimple.xml_in('bogusfile.xml', { 'searchpath' => %w(. ./files) } )
    }

    # Try parsing from an IO::Handle 
    fh = File.new(File.join(File.dirname(__FILE__), 'files', '1_xml_in.xml'))
    opt = XmlSimple.xml_in(fh, { 'force_array' => false, 'key_attr' => %w(name key id) })
    assert_equal('files/1_xml_in.xml', opt['location'])

    # Try parsing from STDIN
    $stdin.reopen(File.new(File.join(File.dirname(__FILE__), 'files', '1_xml_in.xml')))
    opt = XmlSimple.xml_in('-', { 'force_array' => false, 'key_attr' => %w(name key id) })
    assert_equal('files/1_xml_in.xml', opt['location'])

    # Confirm anonymous array handling works in general
    opt = XmlSimple.xml_in(%q(
      <opt>
        <row>
          <anon>0.0</anon><anon>0.1</anon><anon>0.2</anon>
        </row>
        <row>
          <anon>1.0</anon><anon>1.1</anon><anon>1.2</anon>
        </row>
        <row>
          <anon>2.0</anon><anon>2.1</anon><anon>2.2</anon>
        </row>
      </opt>), { 'force_array' => false, 'key_attr' => %w(name key id) })
    assert_equal({
      'row' => [
	     [ '0.0', '0.1', '0.2' ],
	     [ '1.0', '1.1', '1.2' ],
	     [ '2.0', '2.1', '2.2' ]
      ]
    }, opt)

    # Confirm anonymous array handling works in special top level case
    opt = XmlSimple.xml_in(%q(
      <opt>
        <anon>one</anon>
        <anon>two</anon>
        <anon>three</anon>
      </opt>), { 'force_array' => false, 'key_attr' => %w(name key id) })
    assert_equal(%w(one two three), opt)

    opt = XmlSimple.xml_in(%q(
      <opt>
        <anon>1</anon>
        <anon>
          <anon>2.1</anon>
          <anon>
	        <anon>2.2.1</anon>
	        <anon>2.2.2</anon>
          </anon>
        </anon>
      </opt>), { 'force_array' => false, 'key_attr' => %w(name key id) })
    assert_equal([
      '1',
      [
        '2.1', [
          '2.2.1', '2.2.2'
        ]
      ]
    ], opt)

    # Check for the dreaded 'content' attribute
    xml = %q(
      <opt>
        <item attr="value">text</item>
      </opt>)

    opt = XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(name key id) });
    assert_equal({
      'item' => {
        'content' => 'text',
        'attr'    => 'value'
      }
    }, opt)

    # And check that we can change its name if required
    opt = XmlSimple.xml_in(xml, {
      'force_array' => false,
      'key_attr'    => %w(name key id),
      'content_key' => 'text_content'
    })
    assert_equal({
      'item' => {
        'text_content' => 'text',
        'attr'         => 'value'
      }
    }, opt)

    # Check that it doesn't get screwed up by force_array option
    xml = %q(<opt attr="value">text content</opt>)
    opt = XmlSimple.xml_in(xml, { 'key_attr' => %w(name key id) })
    assert_equal({
      'attr'    => 'value',
      'content' => 'text content'
    }, opt)

    # Test that we can force all text content to parse to hash values
    xml = %q(<opt><x>text1</x><y a="2">text2</y></opt>)
    opt = XmlSimple.xml_in(xml, {
      'force_content' => true,
      'force_array'   => false,
      'key_attr'      => %w(name key id)
    })
    assert_equal({
      'x' => {
        'content' => 'text1'
      },
      'y' => {
        'a'       => '2',
        'content' => 'text2'
      }
    }, opt)

    # And that this is compatible with changing the key name
    opt = XmlSimple.xml_in(xml, {
      'force_content' => true,
      'content_key'   => '0',
      'force_array'   => false,
      'key_attr'      => %w(name key id)
    })
    assert_equal({
      'x' => {
        '0' => 'text1'
      },
      'y' => {
        'a' => '2',
        '0' => 'text2'
      }
    }, opt)

    # Confirm that spurious 'content' key are *not* eliminated
    # after array folding.
    xml = %q(<opt><x y="one">First</x><x y="two">Second</x></opt>)
    opt = XmlSimple.xml_in(xml, {
      'force_array' => [ 'x' ],
      'key_attr'    => { 'x' => 'y' }
    })
    assert_equal({
      'x' => {
        'one' => { 'content' => 'First' },
        'two' => { 'content' => 'Second' }
      }
    }, opt)

    # unless we ask nicely
    xml = %q(<opt><x y="one">First</x><x y="two">Second</x></opt>)
    opt = XmlSimple.xml_in(xml, {
      'force_array' => [ 'x' ],
      'key_attr'    => { 'x' => 'y' },
      'content_key' => '-content'
    })
    assert_equal({
      'x' => {
        'one' => 'First',
        'two' => 'Second'
      }
    }, opt)
    
    # Check that mixed content parses in the weird way we expect
    xml = %q(<p class="mixed">Text with a <b>bold</b> word</p>)
    expected = {
      'class'   => 'mixed',
      'content' => [ 'Text with a ', ' word' ],
      'b'       => 'bold'
    }
    assert_equal(expected, XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(name key id) }))

    expected = {
      'class'   => 'mixed',
      'content' => [ 'Text with a ', ' word' ],
      'b'       => ['bold']
    }
    assert_equal(expected, XmlSimple.xml_in(xml, { 'key_attr' => %w(name key id) }))

    xml = %q(<p class="mixed">Text without a <b>bold</b></p>)
    expected = {
      'class'   => 'mixed',
      'content' => 'Text without a ',
      'b'       => 'bold'
    }
    assert_equal(expected, XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(name key id) }))

    expected = {
      'class'   => 'mixed',
      'content' => 'Text without a ',
      'b'       => ['bold']
    }
    assert_equal(expected, XmlSimple.xml_in(xml, { 'key_attr' => %w(name key id) }))

    # Confirm single nested element rolls up into a scalar attribute value
    string = %q(
      <opt>
        <name>value</name>
      </opt>)
    opt = XmlSimple.xml_in(string, { 'force_array' => false, 'key_attr' => %w(name key id) })
    assert_equal({ 'name' => 'value'}, opt)

    # Unless 'forcearray' option is specified
    opt = XmlSimple.xml_in(string, { 'key_attr' => %w(name key id) })
    assert_equal({ 'name' => [ 'value' ] }, opt)

    # Confirm array folding of single nested hash
    string = %q(
      <opt>
        <inner name="one" value="1" />
      </opt>)
    opt = XmlSimple.xml_in(string, { 'key_attr' => %w(name key id) })
    assert_equal({ 'inner' => { 'one' => { 'value' => '1' } } }, opt)

    # But not without forcearray option specified
    opt = XmlSimple.xml_in(string, { 'force_array' => false, 'key_attr' => %w(name key id) })
    assert_equal({'inner' => { 'name' => 'one', 'value' => '1' } }, opt)

    # Test advanced features of forcearray
    xml = %q(
      <opt zero="0">
        <one>i</one>
        <two>ii</two>
        <three>iii</three>
        <three>3</three>
        <three>c</three>
      </opt>)
    opt = XmlSimple.xml_in(xml, {
      'force_array' => [ 'two' ],
      'key_attr'    => %w(name key id)
    })
    assert_equal({
      'zero'  => '0',
      'one'   => 'i',
      'two'   => [ 'ii' ],
      'three' => [ 'iii', '3', 'c' ]
    }, opt)

    # Test force_array regexes
    xml = %q(
      <opt zero="0">
        <one>i</one>
        <two>ii</two>
        <three>iii</three>
        <four>iv</four>
        <five>v</five>
      </opt>
    )
    opt = XmlSimple.xml_in(xml, {
      'key_attr'    => %w(name key id),
      'force_array' => [ %r(^f), 'two', %r(n) ],
      'content_key' => '-content'
    })
    assert_equal({
      'zero'  => '0',
      'one'   => [ 'i' ],
      'two'   => [ 'ii' ],
      'three' => 'iii',
      'four'  => [ 'iv' ],
      'five'  => [ 'v' ]
    }, opt)
    
    # Same again but a single regexp rather than in an arrayref
    opt = XmlSimple.xml_in(xml, {
      'key_attr'    => %w(name key id),
      'force_array' => /^f|e$/,
      'content_key' => '-content'
    })
    assert_equal({
      'zero'  => '0',
      'one'   => [ 'i' ],
      'two'   => 'ii',
      'three' => [ 'iii' ],
      'four'  => [ 'iv' ],
      'five'  => [ 'v' ]
    }, opt)

    # Test 'noattr' option
    xml = %q(
      <opt name="user" password="foobar">
        <nest attr="value">text</nest>
      </opt>)
    opt = XmlSimple.xml_in(xml, {
      'no_attr'     => true,
      'force_array' => false,
      'key_attr'    => %w(name key id)
    })
    assert_equal({ 'nest' => 'text' }, opt)

    # And make sure it doesn't screw up array folding 
    xml = %q{
      <opt>
        <item><key>a</key><value>alpha</value></item>
        <item><key>b</key><value>beta</value></item>
        <item><key>g</key><value>gamma</value></item>
      </opt>}
    opt = XmlSimple.xml_in(xml, {
      'no_attr'     => true,
      'force_array' => false,
      'key_attr'    => %w(name key id)
    })
    assert_equal({
      'item' => {
        'a' => { 'value' => 'alpha' },
        'b' => { 'value' => 'beta' },
        'g' => { 'value' => 'gamma' }
      }
    }, opt)

    # Confirm empty elements parse to empty hashrefs
    xml = %q(
      <body>
        <name>bob</name>
        <outer attr="value">
          <inner1 />
          <inner2></inner2>
        </outer>
      </body>)
    opt = XmlSimple.xml_in(xml, {
      'no_attr'     => true,
      'force_array' => false,
      'key_attr'    => %w(name key id)
    })
    assert_equal({
      'name' => 'bob',
      'outer' => {
        'inner1' => {},
        'inner2' => {}
      }
    }, opt)

    # Unless 'suppressempty' is enabled
    opt = XmlSimple.xml_in(xml, {
      'no_attr'        => true,
      'suppress_empty' => true,
      'force_array'    => false,
      'key_attr'       => %w(name key id)
    })
    assert_equal({ 'name' => 'bob', }, opt)

    # Check behaviour when 'suppressempty' is set to nil
    opt = XmlSimple.xml_in(xml, {
      'no_attr'        => true,
      'suppress_empty' => nil,
      'force_array'    => false,
      'key_attr'       => %w(name key id)
    })
    assert_equal({
       'name' => 'bob',
      'outer' => {
          'inner1' => nil,
        'inner2' => nil
        }
       }, opt)

    # Check behaviour when 'suppressempty' is set to to empty string;
    opt = XmlSimple.xml_in(xml, {
      'no_attr'        => true,
      'suppress_empty' => '',
      'force_array'    => false,
      'key_attr'       => %w(name key id)
    })
    assert_equal({
      'name' => 'bob',
      'outer' => {
        'inner1' => '',
        'inner2' => ''
      }
    }, opt)

    # Confirm completely empty XML parses to undef with 'suppressempty'
    xml = %q(
      <body>
        <outer attr="value">
          <inner1 />
          <inner2></inner2>
        </outer>
      </body>)
    opt = XmlSimple.xml_in(xml, {
      'no_attr'        => true,
      'suppress_empty' => true,
      'force_array'    => false,
      'key_attr'       => %w(name key id)
    })
    assert_equal(nil, opt)

    # Confirm nothing magical happens with grouped elements
    xml = %q(
      <opt>
        <prefix>before</prefix>
        <dirs>
          <dir>/usr/bin</dir>
          <dir>/usr/local/bin</dir>
        </dirs>
        <suffix>after</suffix>
      </opt>)
    opt = XmlSimple.xml_in(xml, {
      'force_array' => false,
      'key_attr'    => %w(name key id)
    })
    assert_equal({
      'prefix' => 'before',
      'dirs'   => {
        'dir' => [ '/usr/bin', '/usr/local/bin' ]
      },
      'suffix' => 'after'
    }, opt)
    
    # unless we specify how the grouping works
    xml = %q(
      <opt>
        <prefix>before</prefix>
        <dirs>
          <dir>/usr/bin</dir>
          <dir>/usr/local/bin</dir>
        </dirs>
        <suffix>after</suffix>
      </opt>)
    opt = XmlSimple.xml_in(xml, {
      'force_array' => false,
      'key_attr'    => %w(name key id),
      'grouptags'   => { 'dirs' => 'dir' }
    })
    assert_equal({
      'prefix' => 'before',
      'dirs'   => [ '/usr/bin', '/usr/local/bin' ],
      'suffix' => 'after'
    }, opt)

    # Try again with multiple groupings
    xml = %q(
      <opt>
        <prefix>before</prefix>
        <dirs>
          <dir>/usr/bin</dir>
          <dir>/usr/local/bin</dir>
        </dirs>
        <infix>between</infix>
        <terms>
          <term>vt100</term>
          <term>xterm</term>
        </terms>
        <suffix>after</suffix>
      </opt>)
    opt = XmlSimple.xml_in(xml, {
      'force_array' => false,
      'key_attr'    => %w(name key id),
      'grouptags'   => { 'dirs' => 'dir', 'terms' => 'term' }
    })
    assert_equal({
      'prefix' => 'before',
      'dirs'   => [ '/usr/bin', '/usr/local/bin' ],
      'infix'  => 'between',
      'terms'  => [ 'vt100', 'xterm' ],
      'suffix' => 'after'
    }, opt)

    # confirm folding and ungrouping work together
    xml = %q(
      <opt>
        <prefix>before</prefix>
        <dirs>
          <dir name="first">/usr/bin</dir>
          <dir name="second">/usr/local/bin</dir>
        </dirs>
        <suffix>after</suffix>
      </opt>)
    opt = XmlSimple.xml_in(xml, {
      'force_array' => false,
      'key_attr'    => { 'dir' => 'name' },
      'grouptags'   => { 'dirs' => 'dir' }
    })
    assert_equal({
      'prefix' => 'before',
      'dirs'   => {
        'first'  => { 'content' => '/usr/bin' },
        'second' => { 'content' => '/usr/local/bin' }
      },
      'suffix' => 'after'
    }, opt)

    # confirm folding, ungrouping and content stripping work together
    xml = %q(
      <opt>
        <prefix>before</prefix>
        <dirs>
          <dir name="first">/usr/bin</dir>
          <dir name="second">/usr/local/bin</dir>
        </dirs>
        <suffix>after</suffix>
      </opt>)
    opt = XmlSimple.xml_in(xml, {
      'content_key' => '-text',
      'force_array' => false,
      'key_attr'    => { 'dir' => 'name' },
      'grouptags'   => { 'dirs' => 'dir' }
    })
    assert_equal({
      'prefix' => 'before',
      'dirs'   => {
        'first'  => '/usr/bin',
        'second' => '/usr/local/bin'
      },
      'suffix' => 'after'
    }, opt)

    # confirm folding fails as expected even with ungrouping
    # but (no forcearray)
    xml = %q(
      <opt>
        <prefix>before</prefix>
        <dirs>
          <dir name="first">/usr/bin</dir>
        </dirs>
        <suffix>after</suffix>
      </opt>)
    opt = XmlSimple.xml_in(xml, {
      'content_key' => '-text',
      'force_array' => false,
      'key_attr'    => { 'dir' => 'name' },
      'grouptags'   => { 'dirs' => 'dir' }
    })
    assert_equal({
      'prefix' => 'before',
      'dirs'   => {
        'name'  => 'first',
        'text' => '/usr/bin'
      },
      'suffix' => 'after'
    }, opt)

    # but works with force_array enabled
    xml = %q(
      <opt>
        <prefix>before</prefix>
        <dirs>
          <dir name="first">/usr/bin</dir>
        </dirs>
        <suffix>after</suffix>
      </opt>)
    opt = XmlSimple.xml_in(xml, {
      'content_key' => '-text',
      'force_array' => [ 'dir' ],
      'key_attr'    => { 'dir' => 'name' },
      'grouptags'   => { 'dirs' => 'dir' }
    })
    assert_equal({
      'prefix' => 'before',
      'dirs'   => { 'first' => '/usr/bin' },
      'suffix' => 'after'
    }, opt)

    # Test variable expansion - when no variables are defined
    xml = %q(
      <opt>
        <file name="config_file">${conf_dir}/appname.conf</file>
        <file name="log_file">${log_dir}/appname.log</file>
        <file name="debug_file">${log_dir}/appname.dbg</file>
      </opt>)
    opt = XmlSimple.xml_in(xml, {
      'content_key' => '-content',
      'force_array' => false,
      'key_attr'    => %w(name key id)
    })
    assert_equal({
      'file' => {
        'config_file' => '${conf_dir}/appname.conf',
        'log_file'    => '${log_dir}/appname.log',
        'debug_file'  => '${log_dir}/appname.dbg'
      }
    }, opt)

    # try again but with variables defined in advance
    opt = XmlSimple.xml_in(xml, {
      'content_key' => '-content',
      'force_array' => false,
      'key_attr'    => %w(name key id),
      'variables'   => { 'conf_dir' => '/etc', 'log_dir' => '/var/log' }
    })
    assert_equal({
      'file' => {
        'config_file' => '/etc/appname.conf',
        'log_file'    => '/var/log/appname.log',
        'debug_file'  => '/var/log/appname.dbg'
      }
    }, opt)

    # now try defining them in the XML
    xml = %q(
      <opt>
        <dir xsvar="conf_dir">/etc</dir>
        <dir xsvar="log_dir">/var/log</dir>
        <file name="config_file">${conf_dir}/appname.conf</file>
        <file name="log_file">${log_dir}/appname.log</file>
        <file name="debug_file">${log_dir}/appname.dbg</file>
      </opt>)
    opt = XmlSimple.xml_in(xml, {
      'content_key' => '-content',
      'force_array' => false,
      'key_attr'    => %w(name key id),
      'varattr'     => 'xsvar'
    })
    assert_equal({
      'file' => {
        'config_file' => '/etc/appname.conf',
        'log_file'    => '/var/log/appname.log',
        'debug_file'  => '/var/log/appname.dbg'
      },
      'dir'  => [
        { 'xsvar' => 'conf_dir', 'content' => '/etc' },
        { 'xsvar' => 'log_dir',  'content' => '/var/log' }
      ]
    }, opt)

    # confirm that variables in XML are merged with pre-defined ones
    xml = %q(
      <opt>
        <dir xsvar="log_dir">/var/log</dir>
        <file name="config_file">${conf_dir}/appname.conf</file>
        <file name="log_file">${log_dir}/appname.log</file>
        <file name="debug_file">${log_dir}/appname.dbg</file>
      </opt>)
    opt = XmlSimple.xml_in(xml, {
      'content_key' => '-content',
      'force_array' => false,
      'key_attr'    => %w(name key id),
      'varattr'     => 'xsvar',
      'variables'   => { 'conf_dir' => '/etc', 'log_dir' => '/tmp' }
    })
    assert_equal({
      'file' => {
        'config_file' => '/etc/appname.conf',
        'log_file'    => '/var/log/appname.log',
        'debug_file'  => '/var/log/appname.dbg'
      },
      'dir' => { 'xsvar' => 'log_dir',  'content' => '/var/log' }
    }, opt)

    # confirm that variables are expanded in variable definitions
    xml = %q(
      <opt>
        <dirs>
          <dir name="prefix">/usr/local/apache</dir>
          <dir name="exec_prefix">${prefix}</dir>
          <dir name="bin_dir">${exec_prefix}/bin</dir>
        </dirs>
      </opt>)
    opt = XmlSimple.xml_in(xml, {
      'content_key' => '-content',
      'force_array' => false,
      'key_attr'    => %w(name key id),
      'varattr'     => 'name',
      'grouptags'   => { 'dirs' => 'dir' }
    })
    assert_equal({
      'dirs' => {
        'prefix'      => '/usr/local/apache',
        'exec_prefix' => '/usr/local/apache',
        'bin_dir'     => '/usr/local/apache/bin'
      }
    }, opt)

    # Test option error handling
    assert_raises(ArgumentError) {
      XmlSimple.xml_in('<x y="z" />', { 'root_name' => 'fred' })
    }

    # Test the NormaliseSpace option
    xml = %q(
      <opt>
        <user name="  Joe
        Bloggs  " id="  one  two "/>
        <user>
          <name>  Jane
          Doe </name>
          <id>
          three
          four
          </id>
        </user>
      </opt>)
    opt = XmlSimple.xml_in(xml, {
      'force_array'    => false,
      'key_attr'       => %w(name),
      'NormaliseSpace' => 1
    })
    assert(opt['user'].instance_of?(Hash))
    assert(opt['user'].has_key?('Joe Bloggs'))
    assert(opt['user'].has_key?('Jane Doe'))
    assert(opt['user']['Jane Doe']['id'] =~ /^\s\s+three\s\s+four\s\s+$/s)

    opt = XmlSimple.xml_in(xml, {
      'force_array'    => false,
      'key_attr'       => %w(name),
      'NormaliseSpace' => 2
    })
    assert(opt['user'].instance_of?(Hash))
    assert(opt['user'].has_key?('Joe Bloggs'))
    assert(opt['user']['Joe Bloggs']['id'] =~ /^one\stwo$$/s)
    assert(opt['user'].has_key?('Jane Doe'))
    assert(opt['user']['Jane Doe']['id'] =~ /^three\sfour$/s)

    # confirm NormaliseSpace works in anonymous arrays too
    xml = %q(
      <opt>
        <anon>  one  two </anon><anon> three
        four  five </anon><anon> six </anon><anon> seveneightnine </anon>
      </opt>)
    opt = XmlSimple.xml_in(xml, {
      'force_array'    => false,
      'key_attr'       => %w(name key id),
      'NormaliseSpace' => 2
    })
    assert_equal([
      'one two', 'three four five', 'six', 'seveneightnine'
    ], opt)

    # Check that American speeling works too
    opt = XmlSimple.xml_in(xml, {
      'force_array'    => false,
      'key_attr'       => %w(name key id),
      'NormalizeSpace' => 2
    })
    assert_equal([
      'one two', 'three four five', 'six', 'seveneightnine'
    ], opt)

    # Now for a 'real world' test, try slurping in an SRT config file
    opt = XmlSimple.xml_in(File.join(File.dirname(__FILE__), 'files', 'srt.xml'), { 'key_attr' => %w(name key id) })
    target = {
      'global' => [
        {
          'proxypswd' => 'bar',
          'proxyuser' => 'foo',
          'exclude' => [
            '/_vt',
            '/save\\b',
            '\\.bak$',
            '\\.\\$\\$\\$$'
          ],
          'httpproxy' => 'http://10.1.1.5:8080/',
          'tempdir' => 'C:/Temp'
        }
      ],
      'pubpath' => {
        'test1' => {
          'source' => [
            {
              'label' => 'web_source',
              'root' => 'C:/webshare/web_source'
            }
          ],
          'title' => 'web_source -> web_target1',
          'package' => {
            'images' => { 'dir' => 'wwwroot/images' }
          },
          'target' => [
            {
              'label' => 'web_target1',
              'root' => 'C:/webshare/web_target1',
              'temp' => 'C:/webshare/web_target1/temp'
            }
          ],
          'dir' => [ 'wwwroot' ]
        },
        'test2' => {
          'source' => [
            {
              'label' => 'web_source',
              'root' => 'C:/webshare/web_source'
            }
          ],
          'title' => 'web_source -> web_target1 & web_target2',
          'package' => {
            'bios' => { 'dir' => 'wwwroot/staff/bios' },
            'images' => { 'dir' => 'wwwroot/images' },
            'templates' => { 'dir' => 'wwwroot/templates' }
          },
          'target' => [
            {
              'label' => 'web_target1',
              'root' => 'C:/webshare/web_target1',
              'temp' => 'C:/webshare/web_target1/temp'
            },
            {
              'label' => 'web_target2',
              'root' => 'C:/webshare/web_target2',
              'temp' => 'C:/webshare/web_target2/temp'
            }
          ],
          'dir' => [ 'wwwroot' ]
        },
        'test3' => {
          'source' => [
            {
              'label' => 'web_source',
              'root' => 'C:/webshare/web_source'
            }
          ],
          'title' => 'web_source -> web_target1 via HTTP',
          'addexclude' => [ '\\.pdf$' ],
          'target' => [
            {
              'label' => 'web_target1',
              'root' => 'http://127.0.0.1/cgi-bin/srt_slave.plx',
              'noproxy' => '1'
            }
          ],
          'dir' => [ 'wwwroot' ]
        }
      }
    }
    assert_equal(target, opt)

  end
end

