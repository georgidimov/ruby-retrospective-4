def n_member(first, second, n)
  #reduce n, because first and second members are already calculated
  (n - 1).times { second, first = first + second, second }

  first
end

def fibonacci(n)
  n_member 1, 1, n
end

def lucas(n)
  n_member 2, 1, n
end

def series(sequence, n)
  case sequence
    when 'fibonacci' then fibonacci n
    when 'lucas' then lucas n
    when 'summed' then (fibonacci n) + (lucas n)
  end
end
