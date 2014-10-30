begin
  require 'rexml/document'
  require 'rexml/xpath'
rescue Exception => ex
  $stderr.print "\nYou have to install REXML to use xml-simple.\n\n"
end
