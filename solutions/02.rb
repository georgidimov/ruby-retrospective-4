module FilterOperators
  def call(number)
    @predicate.call(number)
  end

  def &(the_other_filter)
    combined_filter = self.class.new(nil)

    combined_filter.predicate = Proc.new do |number|
      call(number) and the_other_filter.call(number)
    end

    combined_filter
  end

  def |(the_other_filter)
    combined_filter = self.class.new(nil)

    combined_filter.predicate = Proc.new do |number|
      call(number) or the_other_filter.call(number)
    end

    combined_filter
  end

  def to_s
    "#@predicate"
  end
end

class NumberSet
  include Enumerable
  attr_reader :container

  def initialize
    @container = []
  end

  def each
    @container.each { |member| yield member }
  end

  def <<(new_member)
    @container << new_member if @container.find_index(new_member) == nil
  end

  def size
    @container.size
  end

  def empty?
    @container.empty?
  end

  def [](filter)
    filtered_number_set = NumberSet.new

    @container.each do |member|
      filtered_number_set << member if filter.call(member)
    end

    filtered_number_set
  end

  def to_s
    "#@container"
  end
end

class Filter
  include FilterOperators
  attr_accessor :predicate

  def initialize(&block)
    @predicate = block
  end
end

class TypeFilter
  include FilterOperators
  attr_accessor :predicate

  def initialize(numbers_type)
    case
       when numbers_type == :integer
         @predicate = Proc.new { |number|  number.is_a?(Integer) }
       when numbers_type == :real
         @predicate = Proc.new do |number| number.is_a?(Float) or
                                           number.is_a?(Rational)
         end
       when numbers_type == :complex
         @predicate = Proc.new { |number|  number.is_a?(Complex) }
     end
  end
end

class SignFilter
  include FilterOperators
  attr_accessor :predicate

  def initialize(numbers_limitation)
    @predicate = case numbers_limitation
                   when :positive     then Proc.new { |number| number > 0 }
                   when :non_positive then Proc.new { |number| number <= 0 }
                   when :negative     then Proc.new { |number| number < 0 }
                   when :non_negative then Proc.new { |number| number >= 0 }
                 end
  end
end
