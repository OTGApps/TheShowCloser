class Array
  # Credit where credit is due:
  # http://stackoverflow.com/questions/15737065/unique-permutations-for-large-sets/15737305#15737305
  def cartesian_power(n, max = 0)
    current = [0] * n
    last = [self.size - 1] * n
    result = []

    loop do
      result << current.reverse.collect { |i| self[i] }
      break if current == last || (max > 0 && result.count == max)

      (0...n).each do |index|
        current[index] += 1
        current[index] %= size

        break if current[index] > 0
      end
    end
    result
  end
end
