require File.expand_path("log_slice/search_boundary", File.dirname(__FILE__))
require File.expand_path("log_slice/date_range", File.dirname(__FILE__))

class LogSlice

  NEWLINE = "\n"
  NEWLINE_CHAR = "\n"[0]

  # @param log_file [File, String]
  # @param options [Hash] :exact_match default false
  def initialize log_file, options={}
    @file = log_file.respond_to?(:seek) ? log_file : File.open(log_file, 'r')
    @exact_match = options[:exact_match] || false
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
    reset_progress_check
    @search_boundary.reset
    line = find_next_newline
    while making_progress?
      comp_value = compare.call(line)
      if comp_value == 0 # found matching line
        backtrack_to_first_line_match compare
        return @file
      else
        @search_boundary.send(comp_value < 0 ? :cursor_back : :cursor_forward)
        line = find_next_newline
      end
    end
    if @exact_match
      nil
    else
      backtrack_to_gap compare
      return @file.eof? ? nil : @file
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


  # once the line has been found, we must check the lines above it -
  # if a line above also matches, we should seek to it.
  # (this make search on some files O(n/2) instead of O(log2(n))) )
  # @param compare [Proc] comparison function
  def backtrack_to_first_line_match compare
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

  # if no match was found, we're sitting at too-high.
  # backtrack up to the first too-high
  def backtrack_to_gap compare
    @line_cursor = @file.pos
    previous_cursor_position = @line_cursor
    each_line_reverse do |line|
      if compare.call(line) == 1
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
    cursor = @line_cursor
    left_over = ""
    loop do
      if chunk_size > cursor
        chunk_size = cursor
        cursor = 0
      else
        cursor -= chunk_size
      end
      break if chunk_size == 0
      @file.seek(cursor)
      chunk = @file.read(chunk_size) + left_over
      lines = chunk.split(NEWLINE)
      while lines.length > 1
        line = lines.pop || ""
        @line_cursor -= (line.length + NEWLINE.length)
        yield(line)
      end
      left_over = lines[0] || ""
      lines = []
    end
    @line_cursor -= (left_over.length + NEWLINE.length)
    yield left_over unless left_over == ''
  end

  # After the search is moved by cursor search_boundary.cursor_*, it's position
  # is probably not at the start of a line, but somewhere within a line.
  # find_next_newline advances the cursor until we're at the start of the
  # next line.
  def find_next_newline
    @line_cursor = @search_boundary.cursor
    @file.seek(@line_cursor)
    while (current_char = @file.getc) != NEWLINE_CHAR && !current_char.nil?
      @line_cursor += 1
    end
    if @file.eof?
      ""
    else
      @line_cursor += 1
      @file.seek(@line_cursor)
      @file.readline
    end
  end


end