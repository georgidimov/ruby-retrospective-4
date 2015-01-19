class NumberSet
  include Enumerable

  def initialize(existing_set = [])
    @set = existing_set
  end

  def each(&block)
    @set.each(&block)
  end

  def <<(new_number)
    @set << new_number unless @set.include? new_number
  end

  def [](filter)
    NumberSet.new(@set.select { |number| filter.pass? number })
  end

  def size
    @set.size
  end

  def empty?
    @set.empty?
  end
end

class Filter
  def initialize(&block)
    @condition = block
  end

  def pass?(number)
    @condition.call(number)
  end

  def &(other_filter)
    Filter.new { |number| pass? number and other_filter.pass? number }
  end

  def |(other_filter)
    Filter.new { |number| pass? number or other_filter.pass? number }
  end
end

class TypeFilter < Filter
  def initialize(type)
    case type
      when :integer then super() { |number| number.is_a? Integer }
      when :real    then super() { |number| number.is_a? Float or
                                            number.is_a? Rational }
      when :complex then super() { |number| number.is_a? Complex }
    end
  end
end

class SignFilter < Filter
  def initialize(sign)
    case sign
      when :positive     then super() { |number| number > 0 }
      when :non_positive then super() { |number| number <= 0 }
      when :negative     then super() { |number| number < 0 }
      when :non_negative then super() { |number| number >= 0 }
    end
  end
end
