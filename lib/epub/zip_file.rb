module Epub
  class ZipFile
    include Logger

    def initialize(filepath)
      @filepath = filepath
    end


    def open(filepath)
      zip_open do |zip|
        zip.file.open(filepath, "r") do |file|
          yield(file)
        end
      end
    end


    def mkdir(path)
      zip_open do |zip|
        begin
          zip.mkdir(path)
        rescue
        end
      end
    end


    def write(filepath, data=nil)
      zip_open do |zip|
        zip.get_output_stream(filepath) do |file|
          if block_given?
            yield(file)
          else
            file.puts data
          end
        end
      end
    end


    def rm(filepath)
      zip_open do |zip|
        zip.remove(filepath)
      end
    end


    def mv(old_fn,new_fn)
      log "mv #{old_fn} #{new_fn}"
      data = read(old_fn)

      rm(old_fn)
      write(new_fn, data)
    end


    def each(force_type=nil)
      Zip::ZipFile.foreach(@filepath) do |entry|
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
      Zip::ZipFile.foreach(@filepath) do |entry|
        if entry.directory?
          zip_open do |zip|
            is_empty = false
            zip.dir.open(entry.to_s) do |d|
              is_empty = true if d.entries.size < 1
            end

            if is_empty
              zip.remove(entry.to_s)
            end
          end
        end
      end
    end


    # Read a file from the epub
    def read(filepath)
      data = nil
      open(filepath) do |file|
        data = file.read.clone
      end
      data
    end


    # TODO: Should this be in here???
    # Read an xml file from the epub and parses with Nokogiri
    def read_xml(filepath, namespace=nil)
      data = read(filepath)
      Nokogiri::XML data
    end


    private

      def zip_open
        Zip::ZipFile.open(@filepath) do |zip|
          yield(zip)
        end
      end

  end
end