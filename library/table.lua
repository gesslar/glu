---@meta TableClass

------------------------------------------------------------------------------
-- TableClass
------------------------------------------------------------------------------

if false then -- ensure that functions do not get defined

  ---@class TableClass

  ---Adds a second associative table to a first associative table, merging the
  ---second table into the first.
  ---
  ---@example
  ---```lua
  ---table.add({ a = 1 }, { b = 2 })
  ----- { a = 1, b = 2 }
  ---
  ---table.add({ a = 1, b = 2 }, { b = 3, c = 4 })
  ----- { a = 1, b = 3, c = 4 }
  ---```
  ---
  ---@name add
  ---@param table1 table - The table to add the value to.
  ---@param table2 table - The table to add to the first table.
  ---@return table # The first table with the second table added.
  function table.add(table1, table2) end

  ---Allocates a new table with given an initial indexed table and a
  ---specification for the new table.
  ---
  ---The specification can be:
  ---* another indexed table, in which case the new table will be created with
  ---  the same values as the source table, but with the values in the spec table
  ---  applied to each corresponding value in the source table. The second table
  ---  must have the same number of elements as the source table.
  ---* a function, in which case the function will be applied to each value in
  ---  the source table to produce the values in the new table.
  ---* a single type, in which case all values in the new table will be of
  ---  that type
  ---
  ---@example
  ---```lua
  ---table.allocate({"a", "b", "c"}, "x")
  ----- {a = "x", b = "x", c = "x"}
  ---
  ---table.allocate({"a","b","c"}, {1, 2, 3})
  ----- {a = 1, b = 2, c = 3}
  ---
  ---table.allocate({ "a", "b", "c" }, function(k, v)
  ---  return string.byte(v)
  ---end)
  ----- {a = 97, b = 98, c = 99}
  ---```
  ---@name allocate
  ---@param source table - The table to copy.
  ---@param spec table - The specification for the new table.
  ---@return table # The new table.
  function table.allocate(source, spec) end

  ---Returns true if the table is associative, false otherwise.
  ---
  ---@example
  ---```lua
  ---table.associative({ a = 1, b = 2 })
  ----- true
  ---
  ---table.associative({ 1, 2, 3 })
  ----- false
  ---```
  ---
  ---@name associative
  ---@param t table - The table to check.
  ---@return boolean # True if the table is associative, false otherwise.
  function table.associative(t) end

  ---Returns a table of tables, each containing a slice of the original table
  ---of specified size. If there are not enough elements to fill the last
  ---chunk, the last chunk will contain the remaining elements.
  ---
  ---@example
  ---```lua
  ---table.chunk({1, 2, 3, 4, 5}, 2)
  ----- {{1, 2}, {3, 4}, {5}}
  ---```
  ---
  ---@name chunk
  ---@param t table - The table to chunk.
  ---@param size number - The size of each chunk.
  ---@return table # A table of tables, each containing a slice of the original table.
  function table.chunk(t, size) end

  ---Creates a new table by concatenating the original table with any
  ---additional arrays and/or values. If the arguments contains tables, they
  ---will be concatenated with the original table. Otherwise, the values will
  ---be added to the end of the original table.
  ---@example
  ---```lua
  ---table.concat({1}, 2, {3}, {{4}})
  ----- {1, 2, 3, {4}}
  ---```
  ---
  ---@name concat
  ---@param tbl table - The first table to concatenate.
  ---@param ... any - Additional tables and/or values to concatenate.
  ---@return table # A new table containing the concatenated tables.
  function table.concat(tbl, ...) end

  ---Drops the first n elements from an indexed table.
  ---
  ---@name drop
  ---@param tbl table - The table to drop elements from.
  ---@param n number - The number of elements to drop.
  ---@return table # A new table with the first n elements removed.
  function table.drop(tbl, n) end

  ---Drops the last n elements from an indexed table.
  ---
  ---@name drop_right
  ---@param tbl table - The table to drop elements from.
  ---@param n number - The number of elements to drop.
  ---@return table # A new table with the last n elements removed.
  function table.drop_right(tbl, n) end

  ---Returns a random element from the keys of a table, with each value
  ---representing a weight.
  ---
  ---@example
  ---```lua
  ---table.element_of_weighted({ [1] = 10, [2] = 20, [3] = 70 })
  ----- 3
  ---```
  ---
  ---@name element_of_weighted
  ---@param list table - The table to choose an element from.
  ---@return any # A random element from the table.
  function table.element_of_weighted(list) end

  ---Returns a random element from an indexed table.
  ---
  ---@example
  ---```lua
  ---table.element_of({1, 2, 3})
  ----- 2
  ---```
  ---
  ---@name element_of
  ---@param list table - The table to choose an element from.
  ---@return any # A random element from the table.
  function table.element_of(list) end

  ---Fills an indexed table with a value.
  ---
  ---If the start index is not provided, it will fill from the beginning of the
  ---table. If the stop index is not provided, it will fill to the end of the
  ---table.
  ---
  ---@example
  ---```lua
  ---table.fill({1, 2, 3, 4, 5}, "x")
  ----- {"x", "x", "x", "x", "x"}
  ---
  ---table.fill({1, 2, 3, 4, 5}, "x", 2)
  ----- {1, "x", "x", 4, 5}
  ---
  ---table.fill({1, 2, 3, 4, 5}, "x", 2, 4)
  ----- {1, "x", "x", "x", 5}
  ---```
  ---
  ---@name fill
  ---@param tbl table - The table to fill.
  ---@param value any - The value to fill the table with.
  ---@param start number? - The start index to fill.
  ---@param stop number? - The stop index to fill.
  ---@return table # The filled table.
  function table.fill(tbl, value, start, stop) end

  ---Returns the index of the first element in a table that satisfies a
  ---predicate function.
  ---
  ---@example
  ---```lua
  ---table.find({1, 2, 3, 4, 5}, function(v) return v > 3 end)
  ----- 4
  ---```
  ---
  ---@name find
  ---@param tbl table - The table to find the index of the first element in.
  ---@param fn function - The predicate function to satisfy.
  ---@return number|nil # The index of the first element that satisfies the predicate function, or nil if no element satisfies the predicate.
  function table.find(tbl, fn) end


  ---Returns the index of the last element in a table that satisfies a
  ---predicate function.
  ---
  ---@example
  ---```lua
  ---table.find_last({1, 2, 3, 4, 5}, function(v) return v > 3 end)
  ----- 4
  ---```
  ---
  ---@name find_last
  ---@param tbl table - The table to find the index of the last element in.
  ---@param fn function - The predicate function to satisfy.
  ---@return number? # The index of the last element that satisfies the predicate function, or nil if no element satisfies the predicate.
  function table.find_last(tbl, fn) end

  ---Flattens a table of tables into a single table recursively.
  ---
  ---@example
  ---```lua
  ---table.flatten_deeply({1, {2, {3, {4}}, 5}})
  ----- {1, 2, 3, 4, 5}
  ---```
  ---
  ---@name flatten_deeply
  ---@param tbl table - The table to flatten recursively.
  ---@return table # A new table containing the flattened table.
  function table.flatten_deeply(tbl) end

  ---Flattens a table of tables into a single table.
  ---
  ---@example
  ---```lua
  ---table.flatten({1, {2, {3, {4}}, 5}})
  ----- {1, 2, 3, 4, 5}
  ---```
  ---
  ---@name flatten
  ---@param tbl table - The table to flatten.
  ---@return table # A new table containing the flattened table.
  function table.flatten(tbl) end

  ---Returns a table of the functions in a table.
  ---
  ---@example
  ---```lua
  ---table.functions({a = 1, b = 2, c = end})
  ----- {c = function()}
  ---```
  ---
  ---@name functions
  ---@param tbl table - The table to get the functions from.
  ---@param inherited boolean? - Whether to include inherited functions.
  ---@return table # A table of the functions in the table.
  function table.functions(tbl, inherited) end

  ---Returns true if an indexed table includes a value, false otherwise.
  ---
  ---@example
  ---```lua
  ---table.includes({1, 2, 3}, 2)
  ----- true
  ---```
  ---
  ---@name includes
  ---@param tbl table - The table to check.
  ---@param value any - The value to check for.
  ---@return boolean # True if the table includes the value, false otherwise.
  function table.includes(tbl, value) end

  ---Returns true if a table is indexed, false otherwise.
  ---
  ---@example
  ---```lua
  ---table.indexed({1, 2, 3})
  ----- true
  ---
  ---table.indexed({ a = 1, b = 2 })
  ----- false
  ---```
  ---
  ---@name indexed
  ---@param t table - The table to check.
  ---@return boolean # True if the table is indexed, false otherwise.
  function table.indexed(t) end

  ---Returns an indexed table with the last element removed from the original
  ---indexed table.
  ---
  ---@example
  ---```lua
  ---table.initial({1, 2, 3, 4, 5})
  ----- {1, 2, 3, 4}
  ---```
  ---
  ---@name initial
  ---@param tbl table - The table to remove the last element from.
  ---@return table # A new table with the last element removed.
  function table.initial(tbl) end

  ---Returns true if a table is an object, false otherwise.
  ---
  ---@example
  ---```lua
  ---local object1 = {1,2,3}
  ---local object2 = {}
  ---setmetatable(object2, { __index = object1 })
  ---
  ---table.object(object1)
  ----- false
  ---table.object(object2)
  ----- true
  ---```
  ---
  ---@name object
  ---@param tbl table - The table to check.
  ---@return boolean # True if the table is an object, false otherwise.
  function table.object(tbl) end

  ---Returns a new table with a function applied to each element of the original
  ---table, transforming each element into a new value.
  ---
  ---@example
  ---```lua
  ---table.map({1, 2, 3}, function(v) return v * 2 end)
  ----- {2, 4, 6}
  ---```
  ---
  ---@name map
  ---@param t table - The table to map over.
  ---@param fn function - The function to map over the table.
  ---@param ... any - Additional arguments to pass to the function.
  ---@return table # A new table with the function applied to each element.
  function table.map(t, fn, ...) end

  ---Appends or inserts a second indexed table into a first indexed table at
  ---a specified index.
  ---
  ---If the index is not provided, the second table is appended to the end of
  ---the first table. If the index is provided, the second table is inserted into
  ---the first table at the specified index.
  ---
  ---@example
  ---```lua
  ---table.n_add({1, 2, 3}, {4, 5, 6})
  ----- {1, 2, 3, 4, 5, 6}
  ---
  ---table.n_add({1, 2, 3}, {4, 5, 6}, 2)
  ----- { 1, 4, 5, 6, 2, 3 }
  ---```
  ---
  ---@name n_add
  ---@param tbl1 table - The first table to add the value to.
  ---@param tbl2 table - The second table to add to the first table.
  ---@param index number? - The index to add the second table to.
  ---@return table # The first table with the second table added.
  function table.n_add(tbl1, tbl2, index) end

  ---Casts a value to an indexed table if it is not already one.
  ---
  ---@example
  ---```lua
  ---table.n_cast(1)
  ----- {1}
  ---
  ---table.n_cast({1, 2, 3})
  ----- {1, 2, 3}
  ---```
  ---
  ---@name n_cast
  ---@param ... any - The value to cast.
  ---@return table # A new indexed table with the value or the value itself if it is already indexed.
  function table.n_cast(...) end

  ---Returns a new table with the distinct elements of an indexed table.
  ---
  ---@example
  ---```lua
  ---table.n_distinct({1, 2, 3, 2, 1})
  ----- {1, 2, 3}
  ---```
  ---
  ---@name n_distinct
  ---@param t table - The table to get the distinct elements from.
  ---@return table # A new table with the distinct elements.
  function table.n_distinct(t) end

  ---Returns true or false if all elements in an indexed table are of the same
  ---type. If a type is not provided, it will check if all elements are of the
  ---same type as the first element in the table.
  ---
  ---@example
  ---```lua
  ---table.n_uniform({1, 2, 3}, "number")
  ----- true
  ---```
  ---
  ---@name n_uniform
  ---@param t table - The table to check.
  ---@param typ string? - The type to check for.
  ---@return boolean # True if all elements are of the same type, false otherwise.
  function table.n_uniform(t, typ) end

  ---Creates a new table with weak references. Valid options are "v" for
  ---weak values, "k" for weak keys, and "kv" or "vk" for weak keys and
  ---values.
  ---
  ---@example
  ---```lua
  ---table.new_weak("v")
  ----- A table with weak value references
  ---```
  ---
  ---@name new_weak
  ---@param opt s
  ---@tring? - The reference type.
  ---@return table # A new table with weak references.
  function table.new_weak(opt) end

  ---Removes and returns the last element of an indexed table.
  ---
  ---@example
  ---```lua
  ---local sample = {1, 2, 3}
  ---table.pop(sample)
  ----- 3
  ----- sample = {1, 2}
  ---```
  ---
  ---@name pop
  ---@param t table - The table to remove the last element from.
  ---@return any # The last element of the table.
  function table.pop(t) end

  ---Returns a table of the properties of a table. This function only returns
  ---the properties of the table itself, not the properties of any metatables,
  ---and no functions.
  ---
  ---If the inherited parameter is true, it will include the properties of any
  ---metatables.
  ---
  ---@example
  ---```lua
  ---table.properties({a = 1, b = 2})
  ----- {a = 1, b = 2}
  ---```
  ---
  ---@name properties
  ---@param tbl table - The table to get the properties from.
  ---@param inherited boolean? - Whether to include inherited properties.
  ---@return table # A table of the properties of the table.
  function table.properties(tbl, inherited) end

  ---Adds a value to the end of an indexed table, returning the new length of
  ---the table.
  ---
  ---@example
  ---```lua
  ---table.push({1, 2, 3}, 4)
  ----- 4
  ---```
  ---
  ---@name push
  ---@param t table - The table to append the value to.
  ---@param v any - The value to append to the table.
  ---@return number # The new length of the table.
  function table.push(t, v) end

  ---Reduces an indexed table to a single value using a reducer function.
  ---
  ---@example
  ---```lua
  ---table.reduce({1, 2, 3}, function(acc, v) return acc + v end, 0)
  ----- 6
  ---```
  ---
  ---@name reduce
  ---@param t table - The table to reduce.
  ---@param fn function - The reducer function.
  ---@param initial any? - The initial value.
  ---@return any # The reduced value.
  function table.reduce(t, fn, initial) end

  ---Removes and returns a slice of a table from the start index to the stop
  ---index. If the stop index is not provided, it will only remove the element
  ---at the start index. A second return value is also provided containing the
  ---removed slice.
  ---
  ---@example
  ---```lua
  ---table.remove({1, 2, 3, 4, 5}, 2, 4)
  ----- {1, 5}
  ----- {2, 3, 4}
  ---
  ---table.remove({1, 2, 3, 4, 5}, 2)
  ----- {1, 3, 4, 5}
  ----- {2}
  ---```
  ---
  ---@name remove
  ---@param t table - The table to remove the slice from.
  ---@param start number - The start index of the slice.
  ---@param stop number? - The stop index of the slice.
  ---@return table # A new table containing the removed slice.
  function table.remove(t, start, stop) end

  ---Reverses an indexed table.
  ---
  ---@example
  ---```lua
  ---table.reverse({1, 2, 3})
  ----- {3, 2, 1}
  ---```
  ---
  ---@name reverse
  ---@param tbl table - The table to reverse.
  ---@return table # A new reversed table.
  function table.reverse(tbl) end

  ---Removes and returns the first element of an indexed table.
  ---
  ---@example
  ---```lua
  ---table.shift({1, 2, 3})
  ----- 1
  ---```
  ---
  ---@name shift
  ---@param t table - The table to remove the first element from.
  ---@return any # The first element of the table.
  function table.shift(t) end

  ---Returns a slice of an indexed table.
  ---
  ---@example
  ---```lua
  ---table.slice({1, 2, 3, 4, 5}, 2, 4)
  ----- {2, 3, 4}
  ---```
  ---
  ---@name slice
  ---@param t table - The table to slice.
  ---@param start number? - The start index.
  ---@param stop number? - The stop index.
  ---@return table # A new table with the slice.
  function table.slice(t, start, stop) end

  ---Returns a new table with the unique elements of an indexed table.
  ---
  ---@example
  ---```lua
  ---table.uniq({1, 2, 3, 2, 1})
  ----- {1, 2, 3}
  ---```
  ---
  ---@name uniq
  ---@param tbl table - The table to get the unique elements from.
  ---@return table # A new table with the unique elements.
  function table.uniq(tbl) end

  ---Adds a value to the beginning of an indexed table.
  ---
  ---@example
  ---```lua
  ---table.unshift({1, 2, 3}, 4)
  ----- 4
  ---```
  ---
  ---@name unshift
  ---@param t table - The table to add the value to.
  ---@param v any - The value to add to the table.
  ---@return number # The new length of the table.
  function table.unshift(t, v) end

  ---Unzips a table of tables into a table of tables. The index of the new
  ---sub-tables will be the same as the index of the sub-tables in the original
  ---table.
  ---
  ---@example
  ---```lua
  ---local combined = {{"John", 25}, {"Jane", 30}, {"Jim", 35}}
  ---local names, ages = unpack(table.unzip(combined))
  ----- names = {"John", "Jane", "Jim"}
  ----- ages = {25, 30, 35}
  ---```
  ---
  ---@name unzip
  ---@param tbl table - The table to unzip.
  ---@return table # A table of tables.
  function table.unzip(tbl) end

  ---Returns an indexed table with the values of an associative table.
  ---
  ---@example
  ---```lua
  ---table.values({a = 1, b = 2})
  ----- {1, 2}
  ---```
  ---
  ---@name values
  ---@param t table - The table to get the values from.
  ---@return table # An indexed table with the values.
  function table.values(t) end

  ---Returns an iterator function that can be used to walk over an indexed
  ---table.
  ---
  ---@example
  ---```lua
  ---table.walk({1, 2, 3}, function(v) print(v) end)
  ----- 1
  ----- 2
  ----- 3
  ---```
  ---
  ---@name walk
  ---@param tbl table - The table to walk over.
  ---@return function # An iterator function.
  function table.walk(tbl) end

  ---Returns a new table with weak references. Valid options are "v" for
  ---weak values, "k" for weak keys, and "kv" or "vk" for weak keys and
  ---values.
  ---
  ---@example
  ---```lua
  ---table.weak("v")
  ----- A table with weak value references
  ---```
  ---
  ---@name weak
  ---@param opt string? - The reference type.
  ---@return table # A new table with weak references.
  function table.weak(opt) end

  ---Zips multiple tables together. The tables must all be of the same length.
  ---
  ------ @example
  ---```lua
  ---local names = {"John", "Jane", "Jim"}
  ---local ages = {25, 30, 35}
  ---
  ---table.zip(names, ages)
  ----- {{"John", 25}, {"Jane", 30}, {"Jim", 35}}
  ---```
  ---
  ---@name zip
  ---@param ... table - The tables to zip together.
  ---@return table # A new table containing the zipped tables.
  function table.zip(...) end

end
