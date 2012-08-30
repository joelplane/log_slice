LogSlice
========

Uses binary search to find a line quickly in a large log file. O(log2(n))

Can only search sorted data, which means it's probably only useful for searching by timestamp.

## Example

something-interesting.log:

    [2012-08-29 18:41:12] (9640) 1  something something something else 1
    [2012-08-29 18:41:14] (9640) 2  something something something else 2
    [2012-08-29 18:41:14] (9640) 3  something something something else 3
    [2012-08-29 18:41:14] (9640) 4  something something something else 4
    [2012-08-29 18:42:18] (9640) 5  something something something else 5
    [2012-08-29 18:42:18] (9640) 6  something something something else 6
    [2012-08-29 18:42:18] (9640) 7  something something something else 7
    [2012-08-29 18:42:20] (9640) 8  something something something else 8
    [2012-08-29 18:42:20] (9640) 9  something something something else 9
    [2012-08-29 18:42:20] (9640) 10 something something something else 10

extract everything that happened at or after 18:42:18:
```ruby
find_date = DateTime.parse("2012-08-29 18:42:18")
file = LogSlice.new("something-interesting.log").find do |line|
    date_string = line.match(/^\[([^\]]+)\]/)[1]
    find_date <=> DateTime.parse(date_string)
end

# this will yield an instance of File
# the position in the file is the first byte of the found line

file.readline
#=> "[2012-08-29 18:42:18] (9640) 5  something something something else 5"

# Once you found the line you were after,
# you can continue to read subsequent lines:

file.readline
#=> "[2012-08-29 18:42:18] (9640) 6  something something something else 6"
```

LogSlice.new takes a File or file path, and a comparison function, passed as a block.
When passed a line, the block must return -1 if the value represented by the line
is too high, 1 if it's too low, or 0 if it's just right.

```ruby
LogSlice.new(file_or_file_path).find(&comparison_function) #=> File or nil
```

## Limitations

* Can only search sorted data. At the moment, if the data isn't sorted, it will most likely not find anything
  (ie return nil). In very rare cases it may find value the anyway by chance, so it's not guaranteed that unsorted
  input will yield nil.
* Can only search for a known value. For example, searching for 18:42:19 in the example above will yield nothing.
  This severely limits usefulness, and should be addressed.

## Disclaimer

Use this at your own risk. Better yet, don't use it, it probably doesn't work.
