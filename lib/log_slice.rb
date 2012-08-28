class LogSlice

  # @param log_file [File, String]
  def initialize log_file
    @file = log_file.respond_to?(:seek) ? log_file : File.open(log_file, 'r')
    @size = @file.stat.size
    @lower = 0
    @upper = @size
    @char_cursor = nil
    @line_cursor = nil
  end

  # Depends on lines being sorted
  # @return [Fixnum] file byte offset
  def find_offset &compare
    direction = :forward
    line_cursor = nil
    loop do
      line = next_line direction
      if line_cursor == @line_cursor
        return nil
      end
      line_cursor = @line_cursor
      case compare.call(line)
        when 0
          return @line_cursor
          # found
        when -1
          direction = :back
        when 1
          direction = :forward
        else
          raise ArgumentError
      end
    end
  end

  # @return [Fixnum] file byte offset
  def find_line &compare
    offset = find_offset &compare
    @file.seek(offset)
    @file.readline
  end

  private

  # @param direction [Symbol] direction in file to move, :forward or :back
  # @return [String] line
  def next_line direction
    move_char_cursor direction
    find_next_newline
  end

  def find_next_newline
    newline_char = "\n"[0]
    @line_cursor = @char_cursor
    @file.seek(@line_cursor)
    current_char = nil
    while (current_char = @file.getc) != newline_char && !current_char.nil?
      @line_cursor = @line_cursor + 1
    end
    if current_char.nil?
      # eof
      ""
    else
      @line_cursor = @line_cursor + 1
      @file.seek(@line_cursor)
      @file.readline
    end
  end

  # @param direction [Symbol] direction in file to move the cursor, :forward or :back
  def move_char_cursor direction
    if @char_cursor
      if direction == :forward
        distance = (@upper - @char_cursor) / 2
        old_cursor = @char_cursor
        @char_cursor = @char_cursor + distance
        @lower = old_cursor
      else
        distance = @char_cursor - @lower / 2
        old_cursor = @char_cursor
        @char_cursor = @char_cursor - distance
        @upper = old_cursor
      end
    else
      @char_cursor = @size / 2
    end
  end

end