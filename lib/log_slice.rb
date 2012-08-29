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
  # @return [File] file after seeking to start of line
  def find &compare
    direction = :forward
    line_cursor = nil
    loop do
      line = next_line direction
      if line_cursor == @line_cursor
        return nil
      end
      line_cursor = @line_cursor
      case compare.call(line)
        when 0 # found
          walk_up_to_first_match compare
          return @file
        when -1
          direction = :back
        when 1
          direction = :forward
        else
          raise ArgumentError
      end
    end
  end

  private

  # @param direction [Symbol] direction in file to move, :forward or :back
  # @return [String] line
  def next_line direction
    move_char_cursor direction
    find_next_newline
  end

  # once the line has been found, we must check the lines above it -
  # if a line above also matches, we should seek to it.
  # (this make search on some files O(n/2) instead of O(log2(n))) )
  def walk_up_to_first_match compare
    move_to_previous_line compare
    @file.seek(@line_cursor)
  end

  def move_to_previous_line compare
    last_cursor_position = @line_cursor
    each_line_reverse do |line|
      if compare.call(line) != 0
        @line_cursor = last_cursor_position
        break
      end
      last_cursor_position = @line_cursor
    end
  end

  def each_line_reverse
    chunk_size = 512
    left_over = ""
    cursor = @line_cursor
    loop do
      cursor = cursor - chunk_size
      if cursor < 0
        chunk_size = chunk_size + cursor
        cursor = 0
      end
      break if chunk_size == 0
      #puts "seeking to #{cursor}, chunk size #{chunk_size}, left over #{left_over.length}"
      @file.seek(cursor)
      chunk = @file.read(chunk_size) + left_over
      lines = chunk.split("\n")
      while lines.length > 1
        line = lines.pop || ""
        @line_cursor = @line_cursor - (line.length + 1)
        yield(line)
      end
      left_over = lines[0] || ""
      lines = []
    end
    yield left_over unless left_over == ''
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
        distance = (@char_cursor - @lower) / 2
        old_cursor = @char_cursor
        @char_cursor = @char_cursor - distance
        @upper = old_cursor
      end
    else
      @char_cursor = @size / 2
    end
  end

end