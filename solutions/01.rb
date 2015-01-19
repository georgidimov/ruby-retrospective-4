def fibonacci(nth_member)
  return 1 if nth_member == 1 or nth_member == 2

  fibonacci(nth_member - 1) + fibonacci(nth_member - 2)
end

def lucas(nth_member)
  return 2 if nth_member == 1
  return 1 if nth_member == 2

  lucas(nth_member - 1) + lucas(nth_member - 2)
end

def summed(nth_member)
  fibonacci(nth_member) + lucas(nth_member)
end

def series(series_name, nth_member)
  case series_name
    when 'fibonacci' then fibonacci(nth_member)
    when 'lucas'     then lucas(nth_member)
    when 'summed'    then summed(nth_member)
  end
end

