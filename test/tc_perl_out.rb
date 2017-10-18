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
class TC_Perl_Out < Test::Unit::TestCase # :nodoc:
  def test_perl_test_cases
    # Try encoding a scalar value
    xml = XmlSimple.xml_out("scalar", { 'key_attr' => %w(name key id) });
    assert_equal('<opt>scalar</opt>', xml.strip)
    assert_equal('scalar', XmlSimple.xml_in(xml))

    # Next try encoding a hash
    hashref1 = { 'one' => 1, 'two' => 'II', 'three' => '...' }
    hashref2 = { 'one' => 1, 'two' => 'II', 'three' => '...' }

    xml = XmlSimple.xml_out(hashref1)
    parts = xml.strip.split(' ').sort
    assert_equal(['/>', '<opt', 'one="1"', 'three="..."', 'two="II"'], parts)
    assert_equal({ 'one' => '1', 'two' => 'II', 'three' => '...' }, XmlSimple.xml_in(xml))

    # Now try encoding a hash with a nested array
    ref = { 'array' => %w(one two three) }

    # Expect:
    # <opt>
    #   <array>one</array>
    #   <array>two</array>
    #   <array>three</array>
    # </opt>
    xml = XmlSimple.xml_out(ref, { 'key_attr' => %w(name key id) })
    assert(
      xml =~ %r!<array>one</array>\s*
         <array>two</array>\s*
         <array>three</array>!sx)
    assert_equal(ref, XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(name key id) }))

    # Now try encoding a nested hash
    ref = {
      'value' => '555 1234',
      'hash1' => { 'one' => 1 },
      'hash2' => { 'two' => 2 }
    }

    # Expect:
    # <opt value="555 1234">
    #   <hash1 one="1" />
    #   <hash2 two="2" />
    # </opt>
    xml = XmlSimple.xml_out(ref, { 'key_attr' => %w(name key id) })
    assert_equal({
      'hash1' => { 'one' => '1' },
      'hash2' => { 'two' => '2' },
      'value' => '555 1234'
    }, XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(name key id) }))
    assert(xml =~ %r!<hash1 one="1" />\s*!s)
    assert(xml =~ %r!<hash2 two="2" />\s*!s)

    # Now try encoding an anonymous array
    ref = %w(1 two III)
    
    # Expect:
    # <opt>
    #   <anon>1</anon>
    #   <anon>two</anon>
    #   <anon>III</anon>
    # </opt>
    xml = XmlSimple.xml_out(ref, { 'key_attr' => %w(name key id) })
    assert_equal(ref, XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(name key id) }))
    assert(xml =~ %r{
      ^<(\w+)\s*>
      \s*<anon>1</anon>
      \s*<anon>two</anon>
      \s*<anon>III</anon>
      \s*</\1>\s*$}sx)

    # Now try encoding a nested anonymous array
    ref = [ %w(1.1 1.2), %w(2.1 2.2) ]

    # Expect:
    # <opt>
    #   <anon>
    #     <anon>1.1</anon>
    #     <anon>1.2</anon>
    #   </anon>
    #   <anon>
    #     <anon>2.1</anon>
    #     <anon>2.2</anon>
    #   </anon>
    # </opt>
    xml = XmlSimple.xml_out(ref, { 'key_attr' => %w(name key id) })
    assert_equal(ref, XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(name key id) }))
    assert(xml =~ %r{
      <(\w+)\s*>
      \s*<anon\s*>
      \s*<anon\s*>1\.1</anon\s*>
      \s*<anon\s*>1\.2</anon\s*>
      \s*</anon\s*>
      \s*<anon\s*>
      \s*<anon\s*>2\.1</anon\s*>
      \s*<anon\s*>2\.2</anon\s*>
      \s*</anon\s*>
      \s*</\1\s*>}sx)

    # Now try encoding a hash of hashes with key folding disabled
    ref = {
      'country' => {
        'England' => { 'capital' => 'London' },
        'France'  => { 'capital' => 'Paris' },
        'Turkey'  => { 'capital' => 'Istanbul' }
      }
    }

    # Expect:
    # <opt>
    #   <country>
    #     <England capital="London" />
    #     <France capital="Paris" />
    #     <Turkey capital="Istanbul" />
    #   </country>
    # </opt>
    xml = XmlSimple.xml_out(ref, { 'key_attr' => [] })
    assert_equal(ref, XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(name key id) }))
    e_doc = REXML::Document.new(xml)
    assert_equal(e_doc.root.name, 'opt')
    [%w(England London), %w(France Paris), %w(Turkey Istanbul)].each do |country, capital|
      assert_equal(e_doc.root.elements["/opt/country/#{country}/@capital"].value, capital)
    end

    # Try encoding same again with key folding set to non-standard value
    # Expect:
    # <opt>
    #   <country fullname="England" capital="London" />
    #   <country fullname="France" capital="Paris" />
    #   <country fullname="Turkey" capital="Istanbul" />
    # </opt>
    xml = XmlSimple.xml_out(ref, { 'key_attr' => ['fullname'] })
    xml_save = xml.dup
    assert_equal(ref, XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(fullname) }))
    assert(!xml.sub!(%r!\s*fullname="England"!s, 'uk').nil?)
    assert(!xml.sub!(%r!\s*capital="London"!s, 'uk').nil?)
    assert(!xml.sub!(%r!\s*fullname="France"!s, 'fr').nil?)
    assert(!xml.sub!(%r!\s*capital="Paris"!s, 'fr').nil?)
    assert(!xml.sub!(%r!\s*fullname="Turkey"!s, 'tk').nil?)
    assert(!xml.sub!(%r!\s*capital="Istanbul"!s, 'tk').nil?)
    assert(!xml.sub!(%r!<countryukuk\s*/>\s*!s, '').nil?)
    assert(!xml.sub!(%r!<countryfrfr\s*/>\s*!s, '').nil?)
    assert(!xml.sub!(%r!<countrytktk\s*/>\s*!s, '').nil?)
    assert(!xml.sub!(%r!^<(\w+)\s*>\s*</\1>$!s, '').nil?)

    # Same again but specify name as scalar rather than array
    xml = XmlSimple.xml_out(ref, { 'key_attr' => 'fullname' })
    assert_equal(xml_save, xml)

    # Same again but specify keyattr as hash rather than array
    xml = XmlSimple.xml_out(ref, { 'key_attr' => { 'country' => 'fullname' }})
    assert_equal(xml_save, xml)

    # Same again but add leading '+'
    xml = XmlSimple.xml_out(ref, { 'key_attr' => { 'country' => '+fullname' }})
    assert_equal(xml_save, xml)

    # and leading '-'
    xml = XmlSimple.xml_out(ref, { 'key_attr' => { 'country' => '-fullname' }})
    assert_equal(xml_save, xml)

    # One more time but with default key folding values

    # Expect:
    # <opt>
    #   <country name="England" capital="London" />
    #   <country name="France" capital="Paris" />
    #   <country name="Turkey" capital="Istanbul" />
    # </opt>
    xml = XmlSimple.xml_out(ref, { 'key_attr' => %w(name key id) })
    assert_equal(ref, XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(name key id) }))
    assert(!xml.sub!(%r!\s*name="England"!s, 'uk').nil?)
    assert(!xml.sub!(%r!\s*capital="London"!s, 'uk').nil?)
    assert(!xml.sub!(%r!\s*name="France"!s, 'fr').nil?)
    assert(!xml.sub!(%r!\s*capital="Paris"!s, 'fr').nil?)
    assert(!xml.sub!(%r!\s*name="Turkey"!s, 'tk').nil?)
    assert(!xml.sub!(%r!\s*capital="Istanbul"!s, 'tk').nil?)
    assert(!xml.sub!(%r!<countryukuk\s*/>\s*!s, '').nil?)
    assert(!xml.sub!(%r!<countryfrfr\s*/>\s*!s, '').nil?)
    assert(!xml.sub!(%r!<countrytktk\s*/>\s*!s, '').nil?)
    assert(!xml.sub!(%r!^<(\w+)\s*>\s*</\1>$!s, '').nil?)

    # Finally, confirm folding still works with only one nested hash

    # Expect:
    # <opt>
    #   <country name="England" capital="London" />
    # </opt>
    ref = { 'country' => { 'England' => { 'capital' => 'London' } } }
    xml = XmlSimple.xml_out(ref, { 'key_attr' => %w(name key id) })
    assert_equal(ref, XmlSimple.xml_in(xml, { 'key_attr' => %w(name key id) }))
    assert(!xml.sub!(%r!\s*name="England"!s, 'uk').nil?)
    assert(!xml.sub!(%r!\s*capital="London"!s, 'uk').nil?)
    assert(!xml.sub!(%r!<countryukuk\s*/>\s*!s, '').nil?)
    assert(!xml.sub!(%r!^<(\w+)\s*>\s*</\1>$!s, '').nil?)

    # Check that default XML declaration works
    #
    # Expect:
    # <?xml version='1.0' standalone='yes'?>
    # <opt one="1" />
    ref = { 'one' => 1 }
    xml = XmlSimple.xml_out(ref, { 'xml_declaration' => true, 'key_attr' => %w(name key id) })
    assert_equal({ 'one' => '1' }, XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(name key id) }))
    assert(!xml.sub!(%r!<\?xml version='1.0' standalone='yes'\?>!s, '').nil?)
    assert(xml =~ /^\s*<opt\s+one="1"\s*\/>/s)

    # Check that custom XML declaration works
    #
    # Expect:
    # <?xml version='1.0' standalone='yes'?>
    # <opt one="1" />
    xml = XmlSimple.xml_out(ref, { 'xml_declaration' => "<?xml version='1.0' standalone='yes'?>", 'key_attr' => %w(name key id)})
    assert_equal({ 'one' => '1' }, XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(name key id) }))
    assert(!xml.sub!(%r!<\?xml version='1.0' standalone='yes'\?>!s, '').nil?)
    assert(xml =~ /^\s*<opt\s+one="1"\s*\/>/s)

    # Check that special characters do get escaped
    ref = { 'a' => '<A>', 'b' => '"B"', 'c' => '&C&', 'd' => "'D'" }
    xml = XmlSimple.xml_out(ref, { 'key_attr' => %w(name key id) })
    assert_equal(ref, XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(name key id) }))
    assert(!xml.sub!(%r!a="&lt;A&gt;"!s, '').nil?)
    assert(!xml.sub!(%r!b="&quot;B&quot;"!s, '').nil?)
    assert(!xml.sub!(%r!c="&amp;C&amp;"!s, '').nil?)
    assert(!xml.sub!(%r!d="&apos;D&apos;"!s, '').nil?)
    assert(!xml.sub!(%r!^<(\w+)\s*/>$!s, '').nil?)

    # unless we turn escaping off
    xml = XmlSimple.xml_out(ref, { 'key_attr' => %w(name key id), 'no_escape' => true })
    assert(!xml.sub!(%r!a="<A>"!s, '').nil?)
    assert(!xml.sub!(%r!b=""B""!s, '').nil?)
    assert(!xml.sub!(%r!c="&C&"!s, '').nil?)
    assert(!xml.sub!(%r!d="'D'"!s, '').nil?)
    assert(!xml.sub!(%r!^<(\w+)\s*/>$!s, '').nil?)

    # Try encoding a circular data structure and confirm that it fails
    ref = { 'a' => '1' }
    ref['b'] = ref
    assert_raises(ArgumentError) { XmlSimple.xml_out(ref, { 'key_attr' => %w(name key id) }) }

    # Try encoding a repetitive (but non-circular) data structure and confirm that 
    # it does not fail
    a   = { 'alpha' => '1' }
    ref = { 'a' => a, 'b' => a }
    xml = XmlSimple.xml_out(ref, { 'key_attr' => %w(name key id) })
    assert(xml =~ %r!^
      <opt>
      \s*<a\s+alpha="1"\s*/>
      \s*<b\s+alpha="1"\s*/>
      \s*</opt>!xs)

    # Perl comment: "Try encoding a blessed reference and
    #                confirm that it fails".
    # That isn't true for the Ruby version, because every
    # object has a to_s method.
    ref = Time::now
    xml = XmlSimple.xml_out(ref, { 'key_attr' => %w(name key id) })
    assert_equal(xml, "<opt>#{ref}</opt>\n")

    # Repeat some of the above tests with named root element

    # Try encoding a scalar value
    xml = XmlSimple.xml_out("scalar", { 'root_name' => 'TOM', 'key_attr' => %w(name key id) });
    assert_equal('scalar', XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(name key id) }))
    assert(xml =~ %r/^\s*<TOM>scalar<\/TOM>\s*$/si)

    # Next try encoding a hash

    # Expect:
    # <DICK one="1" two="II" three="..." />
    xml = XmlSimple.xml_out(hashref1, { 'root_name' => 'DICK', 'key_attr' => %w(name key id) })
    assert_equal({
      'one' => '1',
      'two' => 'II',
      'three' => '...'
    }, XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(name key id) }))

    assert(!xml.sub!(%r/one="1"/s, '').nil?)
    assert(!xml.sub!(%r/two="II"/s, '').nil?)
    assert(!xml.sub!(%r/three="..."/s, '').nil?)
    assert(!xml.sub!(%r/^<DICK\s+\/>/s, '').nil?)

    # Now try encoding a hash with a nested array
    ref = { 'array' => %w(one two three) }

    # Expect:
    # <LARRY>
    #   <array>one</array>
    #   <array>two</array>
    #   <array>three</array>
    # </LARRY>
    xml = XmlSimple.xml_out(ref, { 'root_name' => 'LARRY', 'key_attr' => %w(name key id) })
    assert_equal(ref, XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(name key id) }))
    assert(!xml.sub!(%r!
      <array>one</array>\s*
      <array>two</array>\s*
      <array>three</array>!sx, '').nil?)
    assert(!xml.sub!(%r/^<(LARRY)\s*>\s*<\/\1>\s*$/s, '').nil?)

    # Now try encoding a nested hash
    ref = {
      'value' => '555 1234',
      'hash1' => { 'one' => '1' },
      'hash2' => { 'two' => '2' }
    }

    # Expect:
    # <CURLY value="555 1234">
    #   <hash1 one="1" />
    #   <hash2 two="2" />
    # </CURLY>
    xml = XmlSimple.xml_out(ref, { 'root_name' => 'CURLY', 'key_attr' => %w(name key id) })
    assert_equal(ref, XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(name key id) }))
    assert(!xml.sub!(%r!<hash1 one="1" />\s*!s, '').nil?)
    assert(!xml.sub!(%r!<hash2 two="2" />\s*!s, '').nil?)
    assert(!xml.sub!(%r!^<(CURLY)\s+value="555 1234"\s*>\s*</\1>\s*$!s, '').nil?)

    # Now try encoding an anonymous array
    ref = %w(1 two III)

    # Expect:
    # <MOE>
    #   <anon>1</anon>
    #   <anon>two</anon>
    #   <anon>III</anon>
    # </MOE>
    xml = XmlSimple.xml_out(ref, { 'root_name' => 'MOE', 'key_attr' => %w(name key id) })
    assert_equal(ref, XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(name key id) }))
    assert(!xml.sub!(%r!
      ^<(MOE)\s*>
      \s*<anon>1</anon>
      \s*<anon>two</anon>
      \s*<anon>III</anon>
      \s*</\1>\s*$!sx, '').nil?)

    # Test again, this time with no root element

    # Try encoding a scalar value
    xml = XmlSimple.xml_out("scalar", { 'root_name' => '', 'key_attr' => %w(name key id) });
    assert(xml =~ /scalar\s+/s)
    xml = XmlSimple.xml_out("scalar", { 'root_name' => nil, 'key_attr' => %w(name key id) });
    assert(xml =~ /scalar\s+/s)

    # Next try encoding a hash

    # Expect:
    #   <one>1</one>
    #   <two>II</two>
    #   <three>...</three>
    xml = XmlSimple.xml_out(hashref1, { 'root_name' => '', 'key_attr' => %w(name key id) })
    assert_equal({
      'one' => '1',
      'two' => 'II',
      'three' => '...'
    }, XmlSimple.xml_in("<opt>" + xml + "</opt>", { 'force_array' => false, 'key_attr' => %w(name key id) }))
    assert(!xml.sub!(%r/<one>1<\/one>/, '').nil?)
    assert(!xml.sub!(%r/<two>II<\/two>/, '').nil?)
    assert(!xml.sub!(%r/<three>...<\/three>/, '').nil?)
    assert(!xml.sub!(%r/^\s*$/, '').nil?)

    # Now try encoding a nested hash
    ref = {
      'value' => '555 1234',
      'hash1' => { 'one' => '1' },
      'hash2' => { 'two' => '2' }
    }

    # Expect:
    #   <value>555 1234</value>
    #   <hash1 one="1" />
    #   <hash2 two="2" />
    xml = XmlSimple.xml_out(ref, { 'root_name' => '', 'key_attr' => %w(name key id) })
    assert_equal(ref, XmlSimple.xml_in("<opt>" + xml + "</opt>", { 'force_array' => false, 'key_attr' => %w(name key id) }))
    assert(!xml.sub!(%r!<value>555 1234<\/value>\s*!s, '').nil?)
    assert(!xml.sub!(%r!<hash1 one="1" />\s*!s, '').nil?)
    assert(!xml.sub!(%r!<hash2 two="2" />\s*!s, '').nil?)
    assert(!xml.sub!(%r!^\s*$!s, '').nil?)

    # Now try encoding an anonymous array
    ref = %w(1 two III)

    # Expect:
    #   <anon>1</anon>
    #   <anon>two</anon>
    #   <anon>III</anon>
    xml = XmlSimple.xml_out(ref, { 'root_name' => '', 'key_attr' => %w(name key id) })
    assert_equal(ref, XmlSimple.xml_in("<opt>" + xml + "</opt>", { 'force_array' => false, 'key_attr' => %w(name key id) }))
    assert(!xml.sub!(%r!
      ^\s*<anon>1</anon>
      \s*<anon>two</anon>
      \s*<anon>III</anon>
      \s*$!sx, '').nil?)

    # Test option error handling
    assert_raises(ArgumentError) { XmlSimple.xml_out(hashref1, { 'search_path' => [] })} # only valid for XmlSimple.xml_in()
    assert_raises(ArgumentError) { XmlSimple.xml_out(hashref1, 'bogus') }

    # Test output to file
    test_file = 'testoutput.xml'
    File.delete(test_file) if File.exist?(test_file)
    assert(!File.exist?(test_file))

    xml = XmlSimple.xml_out(hashref1)
    XmlSimple.xml_out(hashref1, { 'output_file' => test_file })
    assert(File.exist?(test_file))
    assert_equal(xml, IO::read(test_file))
    File.delete(test_file)

    # Test output to an IO handle
    assert(!File.exist?(test_file))
    fh = File.open(test_file, "w")
    XmlSimple.xml_out(hashref1, { 'output_file' => fh })
    fh.close()
    assert(File.exist?(test_file))
    assert_equal(xml, IO::read(test_file))
    File.delete(test_file)

    # After all that, confirm that the original hashref we supplied has not
    # been corrupted.
    assert_equal(hashref1, hashref2)

    # Confirm that hash keys with leading '-' are skipped
    ref = {
      'a'  => 'one',
      '-b' => 'two',
      '-c' => {
        'one' => '1',
        'two' => '2'
      }
    }
    xml = XmlSimple.xml_out(ref, { 'root_name' => 'opt', 'key_attr' => %w(name key id) })
    assert(!xml.sub!(%r!^\s*<opt\s+a="one"\s*/>\s*$!s, '').nil?)

    # Try a more complex unfolding with key attributes named in a hash
    ref = {
      'car' => {
        'LW1804' => {
          'option' => {
            '9926543-1167' => {
              'key'  => '1',
              'desc' => 'Steering Wheel'
            }
          },
          'id'   => '2',
          'make' => 'GM'
        },
        'SH6673' => {
          'option' => {
            '6389733317-12' => {
              'key'  => '2', 
              'desc' => 'Electric Windows'
            },
            '3735498158-01' => {
              'key'  => '3',
              'desc' => 'Leather Seats'
            },
            '5776155953-25' => {
              'key'  => '4',
              'desc' => 'Sun Roof'
            }
          },
          'id'   => '1',
          'make' => 'Ford'
        }
      }
    }

    # Expect:
    # <opt>
    #   <car license="LW1804" id="2" make="GM">
    #     <option key="1" pn="9926543-1167" desc="Steering Wheel" />
    #   </car>
    #   <car license="SH6673" id="1" make="Ford">
    #     <option key="2" pn="6389733317-12" desc="Electric Windows" />
    #     <option key="3" pn="3735498158-01" desc="Leather Seats" />
    #     <option key="4" pn="5776155953-25" desc="Sun Roof" />
    #   </car>
    # </opt>
    xml = XmlSimple.xml_out(ref, { 'key_attr' => { 'car' => 'license', 'option' => 'pn' }})
    assert_equal(ref, XmlSimple.xml_in(xml, { 'key_attr' =>  { 'car' => 'license', 'option' => 'pn' }}))
    assert(!xml.sub!(%r!\s*make="GM"!s, 'gm').nil?)
    assert(!xml.sub!(%r!\s*id="2"!s, 'gm').nil?)
    assert(!xml.sub!(%r!\s*license="LW1804"!s, 'gm').nil?)
    assert(!xml.sub!(%r!\s*desc="Steering Wheel"!s, 'opt').nil?)
    assert(!xml.sub!(%r!\s*pn="9926543-1167"!s, 'opt').nil?)
    assert(!xml.sub!(%r!\s*key="1"!s, 'opt').nil?)
    assert(!xml.sub!(%r!\s*<cargmgmgm>\s*<optionoptoptopt\s*/>\s*</car>!s, 'CAR').nil?)
    assert(!xml.sub!(%r!\s*make="Ford"!s, 'ford').nil?)
    assert(!xml.sub!(%r!\s*id="1"!s, 'ford').nil?)
    assert(!xml.sub!(%r!\s*license="SH6673"!s, 'ford').nil?)
    assert(!xml.sub!(%r!\s*desc="Electric Windows"!s, '1').nil?)
    assert(!xml.sub!(%r!\s*pn="6389733317-12"!s, '1').nil?)
    assert(!xml.sub!(%r!\s*key="2"!s, '1').nil?)
    assert(!xml.sub!(%r!\s*<option111!s, '<option').nil?)
    assert(!xml.sub!(%r!\s*desc="Leather Seats"!s, '2').nil?)
    assert(!xml.sub!(%r!\s*pn="3735498158-01"!s, '2').nil?)
    assert(!xml.sub!(%r!\s*key="3"!s, '2').nil?)
    assert(!xml.sub!(%r!\s*<option222!s, '<option').nil?)
    assert(!xml.sub!(%r!\s*desc="Sun Roof"!s, '3').nil?)
    assert(!xml.sub!(%r!\s*pn="5776155953-25"!s, '3').nil?)
    assert(!xml.sub!(%r!\s*key="4"!s, '3').nil?)
    assert(!xml.sub!(%r!\s*<option333!s, '<option').nil?)
    assert(!xml.sub!(%r!\s*<carfordfordford>\s*(<option\s*/>\s*){3}</car>!s, 'CAR').nil?)
    assert(!xml.sub!(%r!^<(\w+)\s*>\s*CAR\s*CAR\s*</\1>$!s, '').nil?)

    # Check that empty hashes translate to empty tags
    ref = {
      'one' => {
        'attr1' => 'avalue1',
        'nest1' => [ 'nvalue1' ],
        'nest2' => {}
      },
      'two' => {}
    }

    xml = XmlSimple.xml_out(ref, { 'key_attr' => %w(name key id) })
    assert(!xml.sub!(%r!<nest2\s*></nest2\s*>\s*!, '<NNN>').nil?)
    assert(!xml.sub!(%r!<nest1\s*>nvalue1</nest1\s*>\s*!, '<NNN>').nil?)
    assert(!xml.sub!(%r!<one\s*attr1\s*=\s*"avalue1">\s*!, '<one>').nil?)
    assert(!xml.sub!(%r!<one\s*>\s*<NNN>\s*<NNN>\s*</one>!, '<nnn>').nil?)
    assert(!xml.sub!(%r!<two\s*></two\s*>\s*!, '<nnn>').nil?)
    assert(!xml.sub!(%r!^\s*<(\w+)\s*>\s*<nnn>\s*<nnn>\s*</\1\s*>\s*$!, '').nil?)

    # Check undefined values generate warnings 
    ref = { 'tag' => nil }
    assert_raises(ArgumentError) { XmlSimple.xml_out(ref) }

    # Unless undef is mapped to empty elements
    ref = { 'tag' => nil }
    xml = XmlSimple.xml_out(ref, { 'suppress_empty' => nil, 'key_attr' => %w(name key id) })
    assert(!xml.sub!(%r!^\s*<(\w*)\s*>\s*<tag\s*></tag\s*>\s*</\1\s*>\s*$!s, '').nil?)

    # Test the keeproot option
    ref = {
      'seq' => {
        'name' => 'alpha',
        'alpha' => [ 1, 2, 3 ]
      }
    }
    xml1 = XmlSimple.xml_out(ref, { 'root_name' => 'sequence', 'key_attr' => %w(name key id) })
    xml2 = XmlSimple.xml_out({ 'sequence' => ref }, { 'keep_root' => true, 'key_attr' => %w(name key id) })
    assert_equal(xml1, xml2)

    # Test that items with text content are output correctly
    # Expect: <opt one="1">text</opt>
    ref = { 'one' => '1', 'content' => 'text' }
    xml = XmlSimple.xml_out(ref, { 'key_attr' => %w(name key id) })
    assert(!xml.sub!(%r!^\s*<opt\s+one="1">text</opt>\s*$!s, '').nil?)

    # Even if we change the default value for the 'contentkey' option
    ref = { 'one' => '1', 'text_content' => 'text' };
    xml = XmlSimple.xml_out(ref, { 'content_key' => 'text_content', 'key_attr' => %w(name key id) })
    assert(!xml.sub!(%r!^\s*<opt\s+one="1">text</opt>\s*$!s, '').nil?)

    # and also if we add the '-' prefix
    xml = XmlSimple.xml_out(ref, { 'content_key' => '-text_content', 'key_attr' => %w(name key id) })
    assert(!xml.sub!(%r!^\s*<opt\s+one="1">text</opt>\s*$!s, '').nil?)

    # Check 'noattr' option
    ref = {
      'attr1'  => 'value1',
      'attr2'  => 'value2',
      'nest'   => %w(one two three)
    }

    # Expect:
    #
    # <opt>
    #   <attr1>value1</attr1>
    #   <attr2>value2</attr2>
    #   <nest>one</nest>
    #   <nest>two</nest>
    #   <nest>three</nest>
    # </opt>
    #
    xml = XmlSimple.xml_out(ref, { 'no_attr' => true, 'key_attr' => %w(name key id) })
    assert(xml !~ /=/s)
    assert_equal(ref, XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(name key id) }))
    assert(!xml.sub!(%r!\s*<(attr1)>value1</\1>\s*!s, 'NEST').nil?)
    assert(!xml.sub!(%r!\s*<(attr2)>value2</\1>\s*!s, 'NEST').nil?)
    assert(!xml.sub!(%r!\s*<(nest)>one</\1>\s*<\1>two</\1>\s*<\1>three</\1>!s, 'NEST').nil?)
    assert(!xml.sub!(%r!^<(\w+)\s*>(NEST\s*){3}</\1>$!s, '').nil?)

    # Check noattr doesn't screw up keyattr
    ref = {
      'number' => {
        'twenty one' => {
          'dec' => '21',
          'hex' => '0x15'
        },
        'thirty two' => {
          'dec' => '32',
          'hex' => '0x20'
        }
      }
    }

    # Expect:
    #
    # <opt>
    #   <number>
    #     <dec>21</dec>
    #     <word>twenty one</word>
    #     <hex>0x15</hex>
    #   </number>
    #   <number>
    #     <dec>32</dec>
    #     <word>thirty two</word>
    #     <hex>0x20</hex>
    #   </number>
    # </opt>
    #
    xml = XmlSimple.xml_out(ref, { 'no_attr' => true, 'key_attr' => [ 'word' ] })
    assert(xml !~ /=/s)
    assert_equal(ref, XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(word) }))
    assert(!xml.sub!(%r!\s*<(dec)>21</\1>\s*!s, '21').nil?)
    assert(!xml.sub!(%r!\s*<(hex)>0x15</\1>\s*!s, '21').nil?)
    assert(!xml.sub!(%r!\s*<(word)>twenty one</\1>\s*!s, '21').nil?)
    assert(!xml.sub!(%r!\s*<(number)>212121</\1>\s*!s, 'NUM').nil?)
    assert(!xml.sub!(%r!\s*<(dec)>32</\1>\s*!s, '32').nil?)
    assert(!xml.sub!(%r!\s*<(hex)>0x20</\1>\s*!s, '32').nil?)
    assert(!xml.sub!(%r!\s*<(word)>thirty two</\1>\s*!s, '32').nil?)
    assert(!xml.sub!(%r!\s*<(number)>323232</\1>\s*!s, 'NUM').nil?)
    assert(!xml.sub!(%r!^<(\w+)\s*>NUMNUM</\1>$!, '').nil?)

    # Check grouped tags get ungrouped correctly
    ref = {
      'prefix' => 'before',
      'dirs'   => [ '/usr/bin', '/usr/local/bin' ],
      'suffix' => 'after'
    }

    # Expect:
    #
    # <opt>
    #   <prefix>before</prefix>
    #   <dirs>
    #     <dir>/usr/bin</dir>
    #     <dir>/usr/local/bin</dir>
    #   </dirs>
    #   <suffix>after</suffix>
    # </opt>
    #
    xml = XmlSimple.xml_out(ref, {
      'key_attr'    => %w(name key id),
      'no_attr'     => true,
      'group_tags'  => { 'dirs' => 'dir' }
    })
    assert(!xml.sub!(%r!\s*<(prefix)>before</\1>\s*!s, 'ELEM').nil?)
    assert(!xml.sub!(%r!\s*<(suffix)>after</\1>\s*!s, 'ELEM').nil?)
    assert(!xml.sub!(%r!\s*<dir>/usr/bin</dir>\s*<dir>/usr/local/bin</dir>\s*!s, 'LIST').nil?)
    assert(!xml.sub!(%r!\s*<dirs>LIST</dirs>\s*!s, 'ELEM').nil?)
    assert(!xml.sub!(%r!^<(\w+)\s*>ELEMELEMELEM</\1>$!, '').nil?)

    # Try again with multiple groupings
    ref = {
      'dirs'  => [ '/usr/bin', '/usr/local/bin' ],
      'terms' => [ 'vt100', 'xterm' ]
    }

    # Expect:
    #
    # <opt>
    #   <dirs>
    #     <dir>/usr/bin</dir>
    #     <dir>/usr/local/bin</dir>
    #   </dirs>
    #   <terms>
    #     <term>vt100</term>
    #     <term>xterm</term>
    #   </terms>
    # </opt>
    #
    xml = XmlSimple.xml_out(ref, {
      'key_attr'    => %w(name key id),
      'no_attr'     => true,
      'group_tags'  => { 'dirs' => 'dir', 'terms' => 'term' }
    })

    assert(!xml.sub!(%r!\s*<dir>/usr/bin</dir>\s*<dir>/usr/local/bin</dir>\s*!s, 'LIST').nil?)
    assert(!xml.sub!(%r!\s*<dirs>LIST</dirs>\s*!s, 'ELEM').nil?)
    assert(!xml.sub!(%r!\s*<term>vt100</term>\s*<term>xterm</term>\s*!s, 'LIST').nil?)
    assert(!xml.sub!(%r!\s*<terms>LIST</terms>\s*!s, 'ELEM').nil?)
    assert(!xml.sub!(%r!^<(\w+)\s*>ELEMELEM</\1>$!, '').nil?)

    # Confirm unfolding and grouping work together
    ref = {
      'dirs'   => {
        'first'   => { 'content' => '/usr/bin'       }, 
        'second'  => { 'content' => '/usr/local/bin' }
      }
    }

    # Expect:
    #
    # <opt>
    #   <dirs>
    #     <dir name="first">/usr/bin</dir>
    #     <dir name="second">/usr/local/bin</dir>
    #   </dirs>
    # </opt>
    #
    xml = XmlSimple.xml_out(ref, {
      'key_attr'    => { 'dir' => 'name'},
      'group_tags'  => { 'dirs' => 'dir' }
    })
    assert(!xml.sub!(%r!\s*<dir\s+name="first">/usr/bin</dir>\s*!s, 'ITEM').nil?)
    assert(!xml.sub!(%r!\s*<dir\s+name="second">/usr/local/bin</dir>\s*!s, 'ITEM').nil?)
    assert(!xml.sub!(%r!\s*<dirs>ITEMITEM</dirs>\s*!s, 'GROUP').nil?)
    assert(!xml.sub!(%r!^<(\w+)\s*>GROUP</\1>$!, '').nil?)

    # Combine unfolding, grouping and stripped content - watch it fail :-(
    ref = {
      'dirs'   => {
        'first'   => '/usr/bin',
        'second'  => '/usr/local/bin'
      }
    }

    # Expect:
    #
    # <opt>
    #   <dirs first="/usr/bin" second="/usr/local/bin" />
    # </opt>
    #
    xml = XmlSimple.xml_out(ref, {
      'key_attr'    => { 'dir' => 'name'},
      'group_tags'  => { 'dirs' => 'dir' },
      'content_key' => '-content'
    })
    assert(!xml.sub!(%r!
      ^<(\w+)>\s*
        <dirs>\s*
          <dir
            (?:
              \s+first="/usr/bin"
             |\s+second="/usr/local/bin"
            ){2}\s*
          />\s*
        </dirs>\s*
      </\1>$!x, '').nil?)

    # Check 'NoIndent' option
    ref = { 'nest' => %w(one two three) }

    # Expect:
    #
    # <opt><nest>one</nest><nest>two</nest><nest>three</nest></opt>
    #
    xml = XmlSimple.xml_out(ref, {
      'key_attr'  => %w(name key id),
      'no_indent' => true
    })

    assert_equal(ref, XmlSimple.xml_in(xml, { 'force_array' => false, 'key_attr' => %w(name key id) }))
    assert_equal('<opt><nest>one</nest><nest>two</nest><nest>three</nest></opt>', xml)

    # 'Stress test' with a data structure that maps to several thousand elements.
    # Unfold elements with XmlSimple.xml_out() and fold them up again with XmlSimple.xml_in()
    opt1 =  { 'TypeA' => {}, 'TypeB' => {}}
    for i in 1 .. 40
      for j in 1 .. i
        opt1['TypeA'][i.to_s] = { 'Record' => {}}
        opt1['TypeB'][i.to_s] = { 'Record' => {}}
        opt1['TypeA'][i.to_s]['Record'][j.to_s] = { 'Hex' => sprintf("0x%04X", j) }
        opt1['TypeB'][i.to_s]['Record'][j.to_s] = { 'Oct' => sprintf("%04o", j) }
      end
    end

    xml = XmlSimple.xml_out(opt1, { 'key_attr' => { 'TypeA' => 'alpha', 'TypeB' => 'beta', 'Record' => 'id' }})
    opt2 = XmlSimple.xml_in(xml, { 'key_attr' => { 'TypeA' => 'alpha', 'TypeB' => 'beta', 'Record' => 'id' } })
    assert_equal(opt1, opt2)
  end
end

