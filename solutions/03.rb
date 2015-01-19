module RBFS
  class File
    attr_accessor :data

    def initialize(passed_value = nil)
      self.data = passed_value
    end

    def data=(passed_value)
      @data = passed_value
    end

    def data_type
      case @data
        when String                then :string
        when Symbol                then :symbol
        when Integer,   Float      then :number
        when TrueClass, FalseClass then :boolean
        when NilClass              then :nil
      end
    end

    def serialize()
      "#{data_type}:#{@data}"
    end

    def self.parse(serialized_string)
      serialized_data_type, serialized_data = serialized_string.split(':', 2)

      serialized_data = case serialized_data_type
                          when 'string'  then serialized_data.to_s
                          when 'symbol'  then serialized_data.to_sym
                          when 'number'  then serialized_data.to_f
                          when 'boolean' then serialized_data == 'true'
                          else nil
                        end

      File.new(serialized_data)
    end
  end

  module HashSerializer
    def serialize_hash(hash)
      serialized_files = "#{hash.size}:"

      hash.each do |name, file|
        serialized_files.concat("#{name}:#{file.serialize.length}:#{file.serialize}")
      end

      serialized_files
    end
  end

  module HashParser
    def parse_hash(serialized_string, &add_object_to_directory)
      objects_count, serialized_string = serialized_string.split(':', 2)
      objects_count = objects_count.to_i

      objects_count.times do
        object_name, object_length, serialized_string = serialized_string.split(':', 3)
        object_content = serialized_string.slice!(0, object_length.to_i)

        add_object_to_directory.call(object_name, object_content)
      end

      serialized_string
    end
  end

  class Directory
    include HashSerializer
    extend  HashParser

    attr_reader :files, :directories

    def initialize()
      @files       = Hash.new
      @directories = Hash.new
    end

    def add_file(name, file)
      @files[name] = file
    end

    def add_directory(name, directory = nil)
      directory          = Directory.new if directory.nil?
      @directories[name] = directory
    end

    def [](name)
      return @directories[name] unless @directories[name].nil?
      return @files[name]       unless @files[name].nil?
      nil
    end

    def serialize()
      serialize_hash(@files) + serialize_hash(@directories)
    end

    def self.parse(serialized_string)
      new_directory = Directory.new()

      add_file = lambda do |file_name, file_content|
                   new_directory.add_file(file_name, File.parse(file_content))
                 end
      serialized_string = parse_hash(serialized_string, &add_file)

      add_directory = lambda do |dir_name, dir_content|
                       new_directory.add_directory(dir_name, Directory.parse(dir_content))
                      end
      parse_hash(serialized_string, &add_directory)

      new_directory
    end

    private :serialize_hash
  end
end
