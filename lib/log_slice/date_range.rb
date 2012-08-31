require 'date'

class LogSlice
  class DateRange

    # @param file [File, String]
    # @param start_date [DateTime, String]
    # @param end_date [DateTime, String, nil]
    def initialize file, start_date, end_date=nil
      @file = file
      @start_date = start_date.is_a?(DateTime) ? start_date : DateTime.parse(start_date)
      @end_date = (end_date.is_a?(DateTime) || end_date.nil?) ? end_date : DateTime.parse(end_date)
    end

    def each
      file = LogSlice.new(@file).find do |line|
        date_compare @start_date, line
      end
      begin
        line = file.readline
        if @end_date.nil? || date_compare(@end_date, line) == 1
          yield line
        else
          break
        end
      end until file.eof?
    end

    private

    def date_compare date, line
      date_string = line.match(/\[([^\]]+)\]/)[1]
      date <=> DateTime.parse(date_string)
    end

  end
end
