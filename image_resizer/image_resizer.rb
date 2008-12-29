#!/usr/bin/env ruby

require 'optparse'
require 'date'
require 'ftools'
require 'rubygems'
require 'image_science'

class ImageResizer
  VERSION = '0.1'
  SUPPORTED_FILES = %w(.JPG .GIF)

  attr_reader :arguments, :files, :percent
  
  def initialize(arguments)
    @arguments = arguments
    @files = nil
    @percent = nil
  end

  def run
    if options_parsed? && arguments_valid? then
      print "\nImageResizer start at #{DateTime.now}\n"
      if @files.size > 0 then
        puts "I've got #{@files.size} image files to process\n\n"
        process_files
      else
        puts "No images to process\n"
      end
    else 
      output_usage
    end
  end
  
  private
  def arguments_valid? 
    return @arguments.length >= 4
  end

  def options_parsed?
    opts = OptionParser.new
    opts.on('-v', '--version', 'Display application version') { output_version; exit 0 }
    opts.on('-d [DIR]', String, 'Directory of files to resize') do |dir|
      @files = Dir.new(dir).find_all {|f| f.to_s != ".." && f.to_s != "."}
      @files.collect! {|f| File.new(File.join(dir, f.to_s))}
    end
    opts.on('-p [PERCENT]', Integer, 'Percentage size of output files') do |p|
      @percent = p.to_i
    end
    opts.on('-o [OUTPUT_DIR]', String, 'Output directory') do |dir|
      File.makedirs(dir) unless File.exist?(dir)
      @output_dir = Dir.new(dir)
    end
    
    begin
      opts.parse(@arguments)
    rescue
      return false
    end

    return true
  end

  def process_files
    @files.each do |f|
      next unless SUPPORTED_FILES.include? File.extname(f.path).upcase
      puts "Processing: #{File.basename(f.path)}\n"
      ImageScience.with_image(f.path) do |img|
        out_height = (img.height.to_i * @percent) / 100
        out_width = (img.width.to_i * @percent) / 100
        
        f_extname = File.extname(f.path)
        f_basename = File.basename(f.path, f_extname)
        
        if @output_dir.nil? then
          f_dir = File.dirname(f.path)
          f_suffix = '_resized'
        else
          f_dir = @output_dir.path
          f_suffix = ''
        end

        f_out = File.join(f_dir, f_basename + f_suffix + f_extname)
        
        puts"\tOriginal: size: W:#{img.width}, H:#{img.height}\n"
        puts"\tOutput: size: W:#{out_width}, H:#{out_height}\n"
        img.resize(out_width, out_height) do |resized_img|
          resized_img.save(f_out)
          puts "\tSaved to: #{f_out}\n"
        end

      end
    end
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
