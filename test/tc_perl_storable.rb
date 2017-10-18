$: << File.join(File.dirname(__FILE__), '../lib')

require 'test/unit'
require 'xmlsimple'
require 'fileutils'

# The test cases below are copied from the original Perl version,
# because I wanted to behave the Ruby version exactly as the Perl
# version. I left some comments, that maybe do not make a lot of
# sense in the current Ruby version just to make it easier to find
# changes between the current and future Perl versions of the
# module.
# Please note, that a major difference between the Perl and the Ruby
# version is, that the defaults of the options 'force_array' and
# 'key_attr' have changed.
class TC_Perl_Cache < Test::Unit::TestCase # :nodoc:
  # Wait until the current time is greater than the supplied value
  def pass_time(target)
    while Time::now.to_i <= target
      sleep 1
    end
  end
  
  def test_perl_test_cases
    src_file   = File.join(File.dirname(__FILE__), 'files', 'desertnet.src')
    xml_file   = File.join(File.dirname(__FILE__), 'files', 'desertnet.xml')
    cache_file = File.join(File.dirname(__FILE__), 'files', 'desertnet.stor')
    raise "Test data is missing!" unless File::exist?(src_file)

    # Make sure we can write to the filesystem and check it uses the same
    # clock as the machine we're running on.
    t0   = Time::now.to_i
    file = File.open(xml_file, "w")
    file.close
    t1   = File::mtime(xml_file).to_i
    t2   = Time::now.to_i
    raise "Time moved backwards!" if (t1 < t0) || (t2 < t1)

    # Initialise test data
    expected  = {
      'server' => {
        'sahara' => {
          'osversion' => '2.6',
          'osname'    => 'solaris',
          'address'   => [
            '10.0.0.101',
            '10.0.1.101'
          ]
        },
        'gobi' => {
          'osversion' => '6.5',
          'osname'    => 'irix',
          'address'   => '10.0.0.102'
        },
        'kalahari' => {
          'osversion' => '2.0.34',
          'osname'    => 'linux',
          'address'   => [
            '10.0.0.103',
            '10.0.1.103'
          ]
        }
      }
    }

    FileUtils.cp(src_file, xml_file)
    FileUtils.rm(cache_file) if File::exist?(cache_file)
    assert(!File::exist?(cache_file))

    opt = XmlSimple.xml_in(xml_file, { 'force_array' => false, 'key_attr' => %w(name key id) })
    assert_equal(expected, opt)
    assert(!File::exist?(cache_file)) # No cache file was created.
    pass_time(Time::now.to_i)

    opt = XmlSimple.xml_in(xml_file, { 'force_array' => false, 'key_attr' => %w(name key id), 'cache' => 'storable' })
    assert_equal(expected, opt)
    assert(File::exist?(cache_file)) # Cache file was created.
    t0 = File::mtime(cache_file)     # Remember cache timestamp
    pass_time(t0.to_i)

    opt = XmlSimple.xml_in(xml_file, { 'force_array' => false, 'key_attr' => %w(name key id), 'cache' => 'storable' })
    assert_equal(expected, opt)
    t1 = File::mtime(cache_file)
    assert_equal(t0, t1)

    pass_time(Time::now.to_i)
    t0 = Time::now
    File.open(xml_file, "a+") { |f| f.write("\n") } # Touch the XML file.
    opt = XmlSimple.xml_in(xml_file, { 'force_array' => false, 'key_attr' => %w(name key id), 'cache' => 'storable' })
    assert_equal(expected, opt)
    t2 = File::mtime(cache_file)
    assert(t1.to_i != t2.to_i)

    FileUtils.rm(xml_file)
    assert(!File::exist?(xml_file))
    file = File.open(xml_file, "w") # Re-create it (empty)
    file.close
    assert(File::exist?(xml_file))
    assert(File::size(xml_file) == 0)
    pass_time(File::mtime(xml_file).to_i) # But ensure cache file is newer
    FileUtils.rm(cache_file)               # Seems to be rqd for test on Win32
    File.open(cache_file, "w") { |f| f.write(Marshal.dump(expected, f)) }
    opt = XmlSimple.xml_in(xml_file, { 'force_array' => false, 'key_attr' => %w(name key id), 'cache' => 'storable' })
    assert_equal(expected, opt)
    t2 = File::mtime(cache_file)
    pass_time(t2.to_i)
    # Write some new data to the XML file
    File.open(xml_file, "w") { |f| f.write('<opt one="1" two="2"></opt>' + "\n") }

    # Parse with no caching
    opt = XmlSimple.xml_in(xml_file, { 'force_array' => false, 'key_attr' => %w(name key id) })
    assert_equal({ 'one' => '1', 'two' => '2' }, opt)
    t0 = File::mtime(cache_file)
    s0 = File::size(cache_file)
    assert_equal(t0, t2)

    # Parse again with caching enabled
    opt = XmlSimple.xml_in(xml_file, { 'force_array' => false, 'key_attr' => %w(name key id), 'cache' => 'storable' })
    assert_equal({ 'one' => '1', 'two' => '2' }, opt)
    t1 = File::mtime(cache_file)
    s1 = File::size(cache_file)
    assert((t0 != t1) || (s0 != s1)) # Content changes but date may not on Win32

    FileUtils.cp(src_file, xml_file)
    pass_time(t1.to_i)
    opt = XmlSimple.xml_in(xml_file, { 'force_array' => false, 'key_attr' => %w(name key id), 'cache' => 'storable' })
    assert_equal(expected, opt)

    # Clean up.
    FileUtils.rm(cache_file)
    FileUtils.rm(xml_file)
  end
end
