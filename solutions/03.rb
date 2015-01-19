class String
  def to_b
    case self
      when 'true'  then true
      when 'false' then false
    end
  end
end

module RBFS
  class File
    attr_accessor :data
    attr_reader   :data_type

    def initialize(passed_value = nil)
      self.data = passed_value
      @data_type
    end

    def data=(passed_value)
      @data      = passed_value
      @data_type = define_data_type(passed_value)
    end

    def define_data_type(data)
      return :string  if data.is_a? String
      return :symbol  if data.is_a? Symbol
      return :number  if data.is_a? Integer   or data.is_a? Float
      return :boolean if data.is_a? TrueClass or data.is_a? FalseClass
      :nil
    end

    def serialize()
      "#{@data_type}:#{@data}"
    end

    def self.parse(serialized_string)
      serialized_data_type, serialized_data = serialized_string.split(':', 2)

      parsed_data = parse_data(serialized_data, serialized_data_type)
      parsed_file = File.new(parsed_data)
    end

    def self.parse_data(serialized_data, serialized_data_type)
      case serialized_data_type
        when 'string'  then serialized_data.to_s
        when 'symbol'  then serialized_data.to_sym
        when 'number'  then parse_number(serialized_data)
        when 'boolean' then serialized_data.to_b
        else nil
      end
    end

    def self.parse_number(serialized_data)
      if serialized_data.include? '.'
        serialized_data.to_f
      else
        serialized_data.to_i
      end
    end

    private :define_data_type
  end

  class Directory
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

    def serialize_hash(hash)
      serialized_files = hash.size.to_s + ':'

      hash.each do |name, file|
        current_file = name.to_s                  + ':' +
                       file.serialize.length.to_s + ':' +
                       file.serialize

        serialized_files.concat(current_file)
      end

      serialized_files
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

    def self.parse_hash(serialized_string, &add_object_to_directory)
      objects_count, serialized_string = serialized_string.split(':', 2)
      objects_count = objects_count.to_i

      objects_count.times do
        object_name, object_length, serialized_string = serialized_string.split(':', 3)
        object_content = serialized_string.slice!(0, object_length.to_i)

        add_object_to_directory.(object_name, object_content)
      end

      serialized_string
    end

  private :serialize_hash
  end
end
