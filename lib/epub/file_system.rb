require 'fileutils'

module Epub
  class FileSystem
    include Logger

    def initialize(basepath)
      @basepath = basepath
    end


    def open(filepath)
      path = abs_filepath(filepath)
      FileUtils.open(path, "r") do |file|
        yield(file)
      end
    end


    def mkdir(path)
      path = abs_filepath(path)
      begin
        FileUtils.mkdir(path)
      rescue
      end
    end


    def write(filepath, data=nil)
      path = abs_filepath(filepath)

      ::File.open(path, "w") do |file|
        if block_given?
          yield(file)
        else
          file.puts data
        end
      end
    end


    def rm(filepath)
      path = abs_filepath(filepath)
      FileUtils.rm(path)
    end


    def mv(old_fn,new_fn)
      old_fn = abs_filepath(old_fn)
      new_fn = abs_filepath(new_fn)

      log "mv #{old_fn} #{new_fn}"
      FileUtils.mv(old_fn, new_fn)
    end


    def each(force_type=nil)
      Dir["#{@basepath}/**/*"].each do |f|
        type = entry.file? ? :file : :directory

        case force_type
        when :file
          yield(entry) if type == :file
        when :directory
          yield(entry) if type == :directory
        else
          yield(entry)
        end
      end
    end


    # TODO: Add omit option here
    def clean_empty_dirs!
      Dir["#{@basepath}/**/*"].each do |f|
        if f.directory? && Dir(f).entries < 1
          FileUtils.rm(f)
        end
      end
    end


    # Read a file from the epub
    def read(path)
      path = abs_filepath(path)
      ::File.read(path)
    end


    # Read an xml file from the epub and parses with Nokogiri
    def read_xml(filepath)
      data = read(filepath)
      Nokogiri::XML data
    end


    private

      def abs_filepath(filepath)
        ::File.join(@basepath, filepath)
      end
  end
end