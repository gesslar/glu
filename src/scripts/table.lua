local TableClass = Glu.glass.register({
  name = "table",
  class_name = "TableClass",
  dependencies = {},
  setup = function(___, self)
    function self.n_cast(...)
      if type(...) == "table" and self.indexed(...) then
        return ...
      end

      return { ... }
    end

    self.assure_indexed = self.n_cast

    function self.map(t, fn, ...)
      ___.v.type(t, "table", 1, false)
      ___.v.type(fn, "function", 2, false)

      local result = {}
      for k, v in pairs(t) do
        result[k] = fn(k, v, ...)
      end
      return result
    end

    function self.values(t)
      ___.v.type(t, "table", 1, false)

      local result = {}
        for _, v in pairs(t) do
        result[#result + 1] = v
      end
      return result
    end

    function self.n_uniform(t, typ)
      ___.v.type(t, "table", 1, false)
      ___.v.indexed(t, 1, false)
      ___.v.type(typ, "string", 2, true)

      typ = typ or type(t[1])

      for _, v in pairs(t) do
        if type(v) ~= typ then
          return false
        end
      end

      return true
    end

    function self.n_distinct(t)
      ___.v.indexed(t, 1, false)

      local result, seen = {}, {}
      for _, v in ipairs(t) do
        if not seen[v] then
          seen[v] = true
          result[#result + 1] = v
        end
      end
      return result
    end

    function self.pop(t)
      ___.v.type(t, "table", 1, false)
      ___.v.indexed(t, 1, false)
      return table.remove(t, #t)
    end

    function self.push(t, v)
      ___.v.type(t, "table", 1, false)
      ___.v.type(v, "any", 2, false)
      ___.v.indexed(t, 1, false)
      table.insert(t, v)

      return #t
    end

    function self.unshift(t, v)
      ___.v.type(t, "table", 1, false)
      ___.v.type(v, "any", 2, false)
      ___.v.indexed(t, 1, false)
      table.insert(t, 1, v)

      return #t
    end

    function self.shift(t)
      ___.v.type(t, "table", 1, false)
      ___.v.indexed(t, 1, false)
      return table.remove(t, 1)
    end

    function self.allocate(source, spec)
      local spec_type = type(spec)
      ___.v.type(source, "table", 1, false)
      ___.v.not_empty(source, 1, false)
      ___.v.indexed(source, 1, false)
      if spec_type == ___.TYPE.TABLE then
        ___.v.indexed(spec, 2, false)
        assert(#source == #spec, "Expected source and spec to have the same number of elements")
      elseif spec_type == ___.TYPE.FUNCTION then
        ___.v.type(spec, "function", 2, false)
      end

      local result = {}

      if spec_type == ___.TYPE.TABLE then
        for i = 1, #spec do
          result[source[i]] = spec[i]
        end
      elseif spec_type == ___.TYPE.FUNCTION then
        for i = 1, #source do
          result[source[i]] = spec(i, source[i])
        end
      else
        for i = 1, #source do
          result[source[i]] = spec
        end
      end

      return result
    end

    function self.indexed(t)
      ___.v.type(t, "table", 1, false)

      local index = 1
      for k in pairs(t) do
        if k ~= index then
          return false
        end
        index = index + 1
      end
      return true
    end

    function self.associative(t)
      ___.v.type(t, "table", 1, false)

      for k, _ in pairs(t) do
        if type(k) ~= "number" or k % 1 ~= 0 or k <= 0 then
            return true
        end
      end
      return false
    end

    function self.reduce(t, fn, initial)
      ___.v.indexed(t, 1, false)
      ___.v.type(fn, "function", 2, false)
      ___.v.type(initial, "any", 3, false)

      local acc = initial
      for k, v in pairs(t) do
        acc = fn(acc, v, k)
      end
      return acc
    end

    function self.slice(t, start, stop)
      ___.v.indexed(t, 1, false)
      ___.v.type(start, "number", 2, false)
      ___.v.type(stop, "number", 3, true)
      ___.v.test(start >= 1, 2, false)
      ___.v.test(table.size(t) >= start, 2, false)
      ___.v.test(stop and stop >= start, 3, true)

      if not stop then
        stop = #t
      end

      local result = {}
      for i = start, stop do
        result[#result + 1] = t[i]
      end
      return result
    end

    function self.remove(t, start, stop)
      ___.v.indexed(t, 1, false)
      ___.v.type(start, "number", 2, false)
      ___.v.type(stop, "number", 3, true)
      ___.v.test(start >= 1, 2, false)
      ___.v.test(table.size(t) >= start, 2, false)
      ___.v.test(stop and stop >= start, 3, true)

      local snipped = {}
      if not stop then stop = start end
      local count = stop - start + 1
      for i = 1, count do
        table.insert(snipped, table.remove(t, start))
      end
      return t, snipped
    end

    function self.chunk(t, size)
      ___.v.indexed(t, 1, false)
      ___.v.type(size, "number", 2, false)

      local result = {}
      for i = 1, #t, size do
        result[#result + 1] = ___.slice(t, i, i + size - 1)
      end
      return result
    end

    function self.concat(tbl, ...)
      ___.v.indexed(tbl, 1, false)

      local args = { ... }

      for _, tbl_value in ipairs(args) do
        if type(tbl_value) == "table" then
          for _, value in ipairs(tbl_value) do
            table.insert(tbl, value)
          end
        else
          table.insert(tbl, tbl_value)
        end
      end

      return tbl
    end

    function self.drop(tbl, n)
      ___.v.indexed(tbl, 1, false)
      ___.v.type(n, "number", 2, false)
      ___.v.test(n >= 1, 2, false)
      return self.slice(___, tbl, n + 1)
    end

    function self.drop_right(tbl, n)
      ___.v.indexed(tbl, 1, false)
      ___.v.type(n, "number", 2, false)
      ___.v.test(n >= 1, 2, false)
      return self.slice(___, tbl, 1, #tbl - n)
    end

    function self.fill(tbl, value, start, stop)
      ___.v.indexed(tbl, 1, false)
      ___.v.type(value, "any", 2, false)
      ___.v.type(start, "number", 3, true)
      ___.v.type(stop, "number", 4, true)
      ___.v.test(start and start >= 1, value, 3, true)
      ___.v.test(stop and stop >= start, value, 4, true)

      for i = start or 1, stop or #tbl do
        tbl[i] = value
      end
      return tbl
    end

    function self.find(tbl, fn)
      ___.v.indexed(tbl, 1, false)
      ___.v.type(fn, "function", 2, false)

      for i = 1, #tbl do
        if fn(i, tbl[i]) then
          return i
        end
      end
      return nil
    end

    function self.find_last(tbl, fn)
      ___.v.indexed(tbl, 1, false)
      ___.v.type(fn, "function", 2, false)

      for i = #tbl, 1, -1 do
        if fn(i, tbl[i]) then
          return i
        end
      end
      return nil
    end

    function self.flatten(tbl)
      ___.v.indexed(tbl, 1, false)

      local result = {}
      for _, v in ipairs(tbl) do
        if type(v) == "table" then
          ___.concat(result, v)
        else
          table.insert(result, v)
        end
      end

      return result
    end

    function self.flatten_deeply(tbl)
      ___.v.indexed(tbl, 1, false)

      local result = {}
      for _, v in ipairs(tbl) do
        if type(v) == "table" then
          self.concat(result, self.flatten_deeply(v))
        else
          table.insert(result, v)
        end
      end

      return result
    end

    function self.initial(tbl)
      ___.v.indexed(tbl, 1, false)
      return self.slice(___, tbl, 1, #tbl - 1)
    end

    function self.pull(tbl, ...)
      ___.v.indexed(tbl, 1, false)

      local args = { ... }
      if #args == 0 then return tbl end

      local removeSet = {}
      for _, value in ipairs(args) do
        removeSet[value] = true
      end

      for i = #tbl, 1, -1 do
        if removeSet[tbl[i]] then
          table.remove(tbl, i)
        end
      end

      return tbl
    end

    function self.reverse(tbl)
      ___.v.indexed(tbl, 1, false)

      local len, midpoint = #tbl, math.floor(#tbl / 2)
      for i = 1, midpoint do
        tbl[i], tbl[len - i + 1] = tbl[len - i + 1], tbl[i]
      end
      return tbl
    end

    function self.uniq(tbl)
      ___.v.indexed(tbl, 1, false)

      local seen = {}
      local writeIndex = 1

      for readIndex = 1, #tbl do
        local value = tbl[readIndex]
        if not seen[value] then
          seen[value] = true
          tbl[writeIndex] = value
          writeIndex = writeIndex + 1
        end
      end

      -- Remove excess elements beyond writeIndex
      for i = #tbl, writeIndex, -1 do
        tbl[i] = nil
      end

      return tbl
    end

    function self.unzip(tbl)
      ___.v.indexed(tbl, 1, false)

      local size_of_table = #tbl
      -- Ensure that all sub-tables are of the same length
      local size_of_elements = #tbl[1]
      for _, t in ipairs(tbl) do ___.v.test(size_of_elements == #t, t, 1, false) end

      local num_new_sub_tables = size_of_elements -- yes, this is redundant, but it's more readable
      local new_sub_table_size = size_of_table -- this is the size of the sub-tables
      local result = {}

      for i = 1, num_new_sub_tables do
        result[i] = {}
      end

      for _, source_table in ipairs(tbl) do
        for i, value in ipairs(source_table) do
          table.insert(result[i], value)
        end
      end

      return result
    end

    function self.new_weak(opt)
      ___.v.test(rex.match(opt, "^(k?v?|v?k?)$"), opt, 1, true)

      opt = opt or "v"

      return setmetatable({}, { __mode = opt })
    end

    function self.weak(tbl)
      ___.v.type(tbl, "table", 1, false)
      return getmetatable(tbl) and getmetatable(tbl).__mode ~= nil
    end

    function self.zip(...)
      local tbls = { ... }
      local results = {}

      local size = #tbls[1]
      for _, t in ipairs(tbls) do ___.v.test(size == #t, t, 1, false) end

      for i = 1, size do
        results[i] = {}
        for _, t in ipairs(tbls) do
          table.insert(results[i], t[i])
        end
      end
      return results
    end

    function self.includes(tbl, value)
      ___.v.indexed(tbl, 1, false)
      ___.v.type(value, "any", 2, false)
      return table.index_of(tbl, value) ~= nil
    end

    local function collect_tables(tbl, extending)
      -- Check if the table is a valid object with a metatable and an __index field
      ___.v.object(tbl, 1, false)
      ___.v.type(extending, "boolean", 2, true)

      -- Set-like table to track visited tables
      local visited = {}
      local tables = {}

      local function add_table(t)
        if not visited[t] then
          table.insert(tables, t)
          visited[t] = true
        end
      end

      -- Start by adding the main table
      add_table(tbl)

      if extending then
        local mt = getmetatable(tbl)
        while mt and mt.__index do
          local extendingTbl = mt.__index
          if type(extendingTbl) == "table" then
            add_table(extendingTbl)
          end
          mt = getmetatable(extendingTbl)
        end
      end

      return tables
    end

    local function get_types(tbl, test)
      ___.v.type(tbl, "table", 1, false)
      ___.v.type(test, "function", 2, false)

      local keys = table.keys(tbl)
      keys = table.n_filter(keys, function(k) return test(tbl, k) end) or {}
      return keys
    end

    local function assemble_results(tables, test)
      local result = {}
      for _, t in ipairs(tables) do
        local keys = get_types(t, test) or {}
        for _, k in ipairs(keys) do
          if not ___.table.includes(result, k) then
            table.insert(result, k)
          end
        end
      end
      return result
    end

    function self.functions(tbl, extending)
      ___.v.object(tbl, 1, false)
      ___.v.type(extending, "boolean", 2, true)

      local tables = collect_tables(tbl, extending) or {}
      local test = function(t, k) return type(t[k]) == "function" end

      return assemble_results(tables, test)
    end
    -- Alias for functions
    self.methods = self.functions

    function self.properties(tbl, extending)
      ___.v.object(tbl, 1, false)
      ___.v.type(extending, "boolean", 2, true)

      local tables = collect_tables(tbl, extending) or {}
      local test = function(t, k) return type(t[k]) ~= "function" end

      return assemble_results(tables, test)
    end

    function self.object(tbl)
      ___.v.type(tbl, "table", 1, false)
      return tbl.object == true
    end

    function self.add(tbl, value)
      ___.v.associative(tbl, 1, false)
      ___.v.associative(value, 2, false)

      for k, v in pairs(value) do
        tbl[k] = v
      end

      return tbl
    end

    function self.n_add(tbl1, tbl2, index)
      ___.v.indexed(tbl1, 1, false)
      ___.v.indexed(tbl2, 2, false)
      ___.v.range(index, 1, #tbl1 + 1, 3, true)

      -- We are not adding +1 to the end index because we will be doing +1
      -- in the loop below
      index = index or #tbl1 + 1

      for i = 1, #tbl2 do
        table.insert(tbl1, index + i - 1, tbl2[i])
      end

      return tbl1
    end

    function self.walk(tbl)
      ___.v.indexed(tbl, 1, false)

      local i = 0
      return function()
        i = i + 1
        if tbl[i] then return i, tbl[i] end
      end
    end

    function self.element_of(list)
      ___.v.type(list, "table", 1, false)

      local max = #list
      return list[math.random(max)]
    end

    function self.element_of_weighted(list)
      ___.v.type(list, "table", 1, false)

      local total = 0
      for _, value in pairs(list) do
        total = total + value
      end

      local random = math.random(total)

      for key, value in pairs(list) do
        random = random - value
        if random <= 0 then
          return key
        end
      end
    end

    local assure_equality_function = function(condition)
      if type(condition) ~= "function" then
        condition = function(_, k) return k == condition end
      end
      return condition
    end

    function self.all(tbl, condition)
      ___.v.indexed(tbl, 1, false)
      ___.v.type(condition, "any", 2, false)

      local count = 0

      condition = assure_equality_function(condition)

      local result = table.n_filter(tbl, condition)
      if result then
        count = #result
      end

      return count == #tbl
    end

    function self.some(tbl, condition)
      ___.v.indexed(tbl, 1, false)
      ___.v.type(condition, "any", 2, false)

      condition = assure_equality_function(condition)

      return table.n_filter(tbl, condition) ~= nil
    end

    function self.none(tbl, condition)
      ___.v.indexed(tbl, 1, false)
      ___.v.type(condition, "any", 2, false)

      condition = assure_equality_function(condition)

      return table.n_filter(tbl, condition) == nil
    end

    function self.one(tbl, condition)
      ___.v.indexed(tbl, 1, false)
      ___.v.type(condition, "any", 2, false)

      condition = assure_equality_function(condition)

      return table.n_filter(tbl, condition) ~= nil and #table.n_filter(tbl, condition) == 1
    end

    function self.count(tbl, condition)
      ___.v.indexed(tbl, 1, false)
      ___.v.type(condition, "any", 2, false)

      condition = assure_equality_function(condition)

      return #table.n_filter(tbl, condition)
    end

    function self.natural_sort(tble)
      print("We here")
      ___.v.indexed(tble, 1, false)

      local sorted = {}
      for i = 1, #tble do
        sorted[i] = tble[i]
      end
      table.sort(sorted, ___.string.natural_compare)
      return sorted
    end

    function self.sort(tbl, arg)
      ___.v.indexed(tbl, 1, false)

      if type (arg) == "function" then
        table.sort(tbl, arg)
      else
        return self.natural_sort(tbl)
      end
    end

  end,
  valid = function(___, self)
    return {
      not_empty = function(value, argument_index, nil_allowed)
        assert(type(value) == "table", "Invalid type to argument " ..
          argument_index .. ". Expected table, got " .. type(value) .. " in\n" ..
          ___.get_last_traceback_line())
        if nil_allowed and value == nil then
          return
        end

        local last = ___.get_last_traceback_line()
        assert(not table.is_empty(value), "Invalid value to argument " ..
          argument_index .. ". Expected non-empty in\n" .. last)
      end,

      n_uniform = function(value, expected_type, argument_index, nil_allowed)
        if nil_allowed and value == nil then
          return
        end

        local last = ___.get_last_traceback_line()
        assert(self.n_uniform(value, expected_type),
          "Invalid type to argument " .. argument_index .. ". Expected an " ..
          "indexed table of " .. expected_type .. " in\n" .. last)
      end,
      indexed = function(value, argument_index, nil_allowed)
        if nil_allowed and value == nil then
          return
        end

        local last = ___.get_last_traceback_line()
        assert(self.indexed(value), "Invalid value to argument " ..
          argument_index .. ". Expected indexed table, got " .. type(value) ..
          " in\n" .. last)
      end,
      associative = function(value, argument_index, nil_allowed)
        if nil_allowed and value == nil then
          return
        end

        local last = ___.get_last_traceback_line()

        assert(self.associative(value),
          "Invalid value to argument " .. argument_index .. ". Expected " ..
          "associative table, got " .. type(value) .. " in\n" .. last)
      end,
      object = function(value, argument_index, nil_allowed)
        if nil_allowed and value == nil then
          return
        end

        local last = ___.get_last_traceback_line()
        assert(self.object(value), "Invalid value to argument " ..
          argument_index .. ". Expected object, got " .. type(value) ..
          " in\n" .. last)
      end,
      option = function(value, options, argument_index)
        ___.v.type(value, "any", argument_index, false)
        ___.v.indexed(options, argument_index, false)
        ___.v.type(argument_index, "number", 3, false)

        local last = ___.get_last_traceback_line()
        assert(table.index_of(options, value) ~= nil, "Invalid value to " ..
          "argument " .. argument_index .. ". Expected one of " ..
          table.concat(options, ", ") .. ", got " .. value .. " in\n" .. last)
      end
    }
  end,
})
