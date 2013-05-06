#!/usr/bin/env ruby

require 'fileutils'

RAR='/usr/bin/rar'
UNZIP='/usr/bin/unzip'
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
check_command(UNZIP)
check_command(CONVERT)
if ARGV.length < 1 
  puts "Usage: #{__FILE__} file.[cbr|cbz]"
  exit 1
end
## Starting work
file = ARGV.shift
destfile = file.gsub(/cbr|cbz/, 'pdf')
tmpdir = "/tmp/#{file}.tmp"
puts "Converting #{file} to PDF."

print "Cleaning up temp directory #{tmpdir} ... "
FileUtils.rm_rf(tmpdir)
FileUtils.mkdir(tmpdir)
puts "cleaned!"

print "Unpacking file... "
if (File.extname(file) == '.cbr')
    run_system_command("#{RAR} x \"#{file}\" -w \"#{tmpdir}\" 1>/dev/null")
elsif (File.extname(file) == '.cbz')
    run_system_command("#{UNZIP} \"#{file}\" -d \"#{tmpdir}\" 1>/dev/null")
else 
  puts "Unknown file extension: #{File.extname(file)}"
  exit 1
end
puts "done!"

# TODO: handle pngs
print "Grouping jpg files... "
Dir.glob("#{tmpdir}/**/*.jpg").each { |item|
  FileUtils.mv(item, tmpdir) if File.dirname(item) != tmpdir
}
puts "done!"

# TODO: handle pngs
print "Creating PDF... "
run_system_command("#{CONVERT} \"#{tmpdir}/*.jpg\" \"#{destfile}\"")
puts " done!"

FileUtils.rm_rf(tmpdir)
puts "Output written: #{destfile}" if File.exists?(destfile)

