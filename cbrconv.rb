#!/usr/bin/env ruby

require 'fileutils'

RAR='/usr/bin/rar'
CONVERT='/usr/bin/convert'

def check_command(command)
  if !File.exists?(command)
    puts "Error: #{command} not found"
    exit 1
  end
end

def run_system_command(command)
  system command
  if $? != 0
    puts "Command failed: #{command}"
    exit 1
  end
end

## Sanity check
check_command(RAR)
check_command(CONVERT)
if ARGV.length < 1 
  puts "Usage: #{__FILE__} file.cbr"
  exit 1
end
## Starting work
file = ARGV.shift
destfile = file.gsub(/cbr/, 'pdf')
tmpdir = "/tmp/#{file}.tmp"
puts "Converting #{file} to PDF."

print "Cleaning up temp directory #{tmpdir} ... "
FileUtils.rm_rf(tmpdir)
FileUtils.mkdir(tmpdir)
puts "cleaned!"

print "Unpacking file... "
run_system_command("#{RAR} x \"#{file}\" -w \"#{tmpdir}\" 1>/dev/null")
puts "done!"

print "Grouping jpg files... "
Dir.glob("#{tmpdir}/**/*.jpg").each { |item|
  FileUtils.mv(item, tmpdir) if File.dirname(item) != tmpdir
}
puts "done!"

print "Creating PDF... "
run_system_command("#{CONVERT} \"#{tmpdir}/*.jpg\" \"#{destfile}\"")
puts " done!"

FileUtils.rm_rf(tmpdir)
puts "Output written: #{destfile}" if File.exists?(destfile)

