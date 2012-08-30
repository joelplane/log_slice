class LogSlice
  class SearchBoundary

    attr_reader :cursor

    def initialize file_size
      @file_size = file_size
    end

    # reset the search boundary to cover the entire file
    def reset
      @lower = 0
      @upper = @file_size
      @cursor = 0
      self
    end

    # Move cursor forward.
    # The cursor is moved half way between it's start location and the upper boundary.
    def cursor_forward
      @lower = @cursor
      @cursor = @cursor + (@upper - @cursor) / 2
    end

    # Move cursor backward.
    # The cursor is moved half way between it's start location and the lower boundary.
    def cursor_back
      @upper = @cursor
      @cursor = @cursor - (@cursor - @lower) / 2
    end

  end
end
