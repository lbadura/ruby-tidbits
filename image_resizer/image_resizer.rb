#!/usr/bin/env ruby

require 'optparse'
require 'date'

class ImageResizer
  VERSION = '0.1'

  attr_reader :arguments, :files, :percent
  
  def initialize(arguments)
    @arguments = arguments
    @files = nil
    @percent = nil
  end

  def run
    if options_parsed? && arguments_valid? then
      print "\nImageResizer start at #{DateTime.now}\n"
      print "I've got #{@files.size} image files to process\n"
    else 
      output_usage
    end
  end
  
  private
  def arguments_valid? 
    return @arguments.length == 4
  end

  def options_parsed?
    opts = OptionParser.new
    opts.on('-v', '--version', 'Display application version') { output_version; exit 0 }
    opts.on('-d [DIR]', String, 'Directory of files to resize') do |dir|
      @files = Dir.new(dir).find_all {|f| f.to_s != ".." && f.to_s != "."}
    end
    opts.on('-p [PERCENT]', Integer, 'Percentage size of output files') do |p|
      @percent = p
    end
    
    begin
      opts.parse(@arguments)
    rescue
      return false
    end

    return true
  end

  def output_version
    print "Ruby Image Resizer v#{VERSION}\n"
  end

  def output_usage
    print "usage:\n./resize.rb -d [directory] -p [percent]\n"
  end
end

# create app instance and run it
app = ImageResizer.new(ARGV)
app.run
