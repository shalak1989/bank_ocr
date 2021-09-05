module PolicyOcr
  class Processor
    # This sets how many columns wide each number is
    NUM_COL = 3
    # This sets how many rows a number spans
    NUM_ROW = 3
    # This sets the number of spaces/newlines between rows of numbers
    SPACE_AFTER_ROW = 1
    # This sets how many total columns each number set takes up.
    TOTAL_COLUMNS = 27
    # This maps the string underscore/pipe symbols to the string representation of their number
    NUMBER_MAP = {
      ' _ | ||_|' => '0',
      '     |  |' => '1',
      ' _  _||_ ' => '2',
      ' _  _| _|' => '3',
      '   |_|  |' => '4',
      ' _ |_  _|' => '5',
      ' _ |_ |_|' => '6',
      ' _   |  |' => '7',
      ' _ |_||_|' => '8',
      ' _ |_| _|' => '9'
    }

    def self.process
      file = File.open('spec/fixtures/sample.txt')
      file_data = file.readlines.map(&:chomp)
      numbers = parse_into_numbers(file_data)
      print_number_report(numbers)
    ensure
      file.close
    end

    # With more time I would refactor this into more methods, this is too cluttered
    def self.parse_into_numbers(data)
      numbers = []
      current_row = 0
      current_col = 0
      while current_row < data.count
        number = ""
        while current_col < TOTAL_COLUMNS
          current_col = column_number(current_col)
          number_symbol = calculate_number_symbol(current_row, current_col, data)
          number += calculate_actual_number(number_symbol)
        end
        numbers.push(number)
        # set row
        current_row += NUM_ROW + SPACE_AFTER_ROW
        # set starting column back to 0
        current_col = 0
      end
      numbers
    end

    def self.calculate_number_symbol(current_row, current_col, data)
      data[current_row][current_col - NUM_COL, NUM_COL] +
        data[current_row + 1][current_col - NUM_COL, NUM_COL] +
        data[current_row + 2][current_col - NUM_COL, NUM_COL]
    end

    def self.column_number(current_column_number)
      current_column_number == TOTAL_COLUMNS ? 0 : current_column_number + NUM_COL
    end

    def self.calculate_actual_number(number_symbol)
      NUMBER_MAP[number_symbol] || '?'
    end

    def self.checksum_passed?(number)
      sum = 0
      # d9 is at the first position of a digit in an array so we start at 9
      digit_multiplier = 9
      number.split('').each do |n|
        sum += n.to_i * digit_multiplier
        digit_multiplier -= 1
      end
      (sum % 11).zero?
    end

    def self.print_number_report(numbers)
      final_numbers = []
      numbers.each { |n| final_numbers.push(validate_number(n)) }
      puts final_numbers
    end

    def self.validate_number(number)
      return "#{number} ERR" if number.include?('?')
      return number if checksum_passed?(number)

      # final condition is an illegitimate number
      "#{number} ILL"
    end
  end
end
