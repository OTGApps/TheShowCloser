class Array
  # Credit where credit is due: http://stackoverflow.com/questions/15737065/unique-permutations-for-large-sets/15737305#15737305
  def cartesian_power(n)
    current = [0] * n
    last = [size - 1] * n

    loop do
      yield current.reverse.collect { |i| self[i] }
      break if current == last

      (0...n).each do |index|
        current[index] += 1
        current[index] %= size

        break if current[index] > 0
      end
    end
  end
end
