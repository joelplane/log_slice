require File.expand_path("log_slice/search_boundary", File.dirname(__FILE__))

class LogSlice

  # @param log_file [File, String]
  def initialize log_file
    @file = log_file.respond_to?(:seek) ? log_file : File.open(log_file, 'r')
    @search_boundary = SearchBoundary.new(@file.stat.size)
    @line_cursor = nil
  end

  # Find line in the file using the comparison function.
  # Depends on lines being sorted.
  # The comparison function will be passed lines from the file. It must
  # return -1 if the line is later than the one it's looking for, 1 if
  # the line is earlier than the one it's looking for, and 0 if it is
  # the line it's looking for.
  # @param compare [Proc] comparison function
  # @return [File, nil] file after seeking to start of line or nil if line not found
  def find &compare
    @search_boundary.reset
    direction = :forward
    reset_progress_check
    loop do
      line = next_line direction
      return nil unless making_progress?
      comp_value = compare.call(line)
      if comp_value == 0 # found matching line
        move_line_cursor_to_first_match compare
        return @file
      else
        direction = comp_value < 0 ? :back : :forward
      end
    end
  end

  private

  # whether the cursor has moved since previous call
  def making_progress?
    return false if @previous_cursor_position == @line_cursor
    @previous_cursor_position = @line_cursor
    true
  end

  def reset_progress_check
    @previous_cursor_position = nil
  end

  # @param direction [Symbol] direction in file to move, :forward or :back
  # @return [String] line
  def next_line direction
    move_search_cursor direction
    find_next_newline
  end

  # once the line has been found, we must check the lines above it -
  # if a line above also matches, we should seek to it.
  # (this make search on some files O(n/2) instead of O(log2(n))) )
  # @param compare [Proc] comparison function
  def move_line_cursor_to_first_match compare
    previous_cursor_position = @line_cursor
    each_line_reverse do |line|
      if compare.call(line) != 0
        # we've found a non-matching line,
        # so we set @line_cursor back to the previous matching line
        @line_cursor = previous_cursor_position
        break
      end
      previous_cursor_position = @line_cursor
    end
    @file.seek(@line_cursor)
  end

  # iterate over each line from the current cursor position, in reverse.
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

  # After the search is moved by cursor move_search_cursor, it's position
  # is probably not at the start of a line, but somewhere within a line.
  # find_next_newline advances the cursor until we're at the start of the
  # next line.
  def find_next_newline
    newline_char = "\n"[0]
    @line_cursor = @search_boundary.cursor
    @file.seek(@line_cursor)
    current_char = nil
    while (current_char = @file.getc) != newline_char && !current_char.nil?
      @line_cursor = @line_cursor + 1
    end
    if current_char.nil?
      "" # eof
    else
      @line_cursor = @line_cursor + 1
      @file.seek(@line_cursor)
      @file.readline
    end
  end

  # Move cursor in the direction specified. The cursor is moved
  # half way between it's start location and the search boundary.
  # @param direction [Symbol] direction in file to move the cursor, :forward or :back
  def move_search_cursor direction
    if direction == :forward
      @search_boundary.cursor_forward
    else
      @search_boundary.cursor_back
    end
  end

end