LogSlice
========

Uses binary search to find a line quickly in a large log file. O(log2(n))

Can only search sorted data, which means it's probably only useful for searching by timestamp.

## Example

something-interesting.log:

    [2012-08-29 18:41:12] (9640) something something something else 1
    [2012-08-29 18:41:14] (9640) something something something else 2
    [2012-08-29 18:41:14] (9640) something something something else 3
    [2012-08-29 18:41:14] (9640) something something something else 4
    [2012-08-29 18:42:18] (9640) something something something else 5
    [2012-08-29 18:42:18] (9640) something something something else 6
    [2012-08-29 18:42:18] (9640) something something something else 7
    [2012-08-29 18:42:20] (9640) something something something else 8
    [2012-08-29 18:42:20] (9640) something something something else 9
    [2012-08-29 18:42:20] (9640) something something something else 10

extract everything that happened at or after 18:42:18:
```ruby
find_date = DateTime.parse("2012-08-29 18:42:18")
file = LogSlice.new("something-interesting.log").find do |line|
    date_string = line.match(/^\[([^\]]+)\]/)[1]
    find_date <=> DateTime.parse(date_string)
end

# this will yield an instance of File
# the position is the file is the first byte of the found line

file.readline
#=> "[2012-08-29 18:42:18] (9640) something something something else 5"

file.readline
#=> "[2012-08-29 18:42:18] (9640) something something something else 6"
```

LogSlice.new takes a File or file path, and a block. When passed a line,
the block must return -1 if the value represented by the line is too high,
1 if it's too low, or 0 if it's just right.

## Limitations

* Can only search sorted data. At the moment, if the data isn't sorted, it won't detect it and it will loop forever.
* Can only search for a known value. For example, searching for 18:42:19 in the example above will yield nothing.

## Disclaimer

Use this at your own risk. Better yet, don't use it, it probably doesn't work.
