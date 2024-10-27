---@diagnostic disable-next-line: undefined-global
local mod = mod or {}
local script_name = "fd"
function mod.new(parent)
  local instance = { parent = parent }

  --- Splits a path into a directory and file.
  ---
  --- If the directory is required and does not exist, nil is returned.
  ---
  --- @example
  --- ```lua
  --- fd:dir_file("path/to/file.txt")
  --- -- "path/to", "file.txt"
  --- ```
  ---
  --- @param path string - The path to split.
  --- @param dir_required boolean - Whether the directory is required (Optional. Default is false).
  --- @return string|nil,string|nil - A table with the directory and file, or nil if the path is invalid.
  function instance:dir_file(path, dir_required)
    dir_required = dir_required or false

    local dir, file = rex.match(path, "^(.*)[\\\\\\/](.*)$")
    if #{dir, file} == 2 then
      return dir, file
    end

    if dir_required and dir then
      if not instance:dir_exists(dir) then
        return nil, nil
      end
    end

    return dir, file
  end

  --- Checks if a file exists.
  --- @param path string - The path to check.
  --- @return boolean - Whether the file exists.
  --- @example
  --- ```lua
  --- fd:file_exists("path/to/file.txt")
  --- -- true
  --- ```
  function instance:file_exists(path)
    if not path then return false end

    local attr, message, code = lfs.attributes(path)
    if not attr then return false end

    return attr.mode == "file"
  end

  --- Checks if a directory exists.
  --- @param path string - The path to check.
  --- @return boolean - Whether the directory exists.
  --- @example
  --- ```lua
  --- fd:dir_exists("path/to/directory")
  --- -- true
  --- ```
  function instance:dir_exists(path)
    if not path then return false end

    local attr, message, code = lfs.attributes(path)
    if not attr then return false end

    return attr.mode == "directory"
  end

  --- Reads a file.
  --- @param path string - The path to the file.
  --- @param binary boolean - Whether the file is binary (default false).
  --- @return ... any - The contents of the file.
  --- @example
  --- ```lua
  --- fd:read_file("path/to/file.txt")
  --- -- "contents of file"
  --- ```
  function instance:read_file(path, binary)
    local handle, error, code = io.open(path, "r" .. (binary and "b" or ""))
    if not handle then return nil, error, code end

    local data = handle:read("*a")
    handle:close()

    return data
  end

  --- Writes to a file.
  --- @param path string - The path to the file.
  --- @param data string - The data to write to the file.
  --- @param overwrite boolean - Whether to overwrite the file (default false).
  --- @param binary boolean - Whether the file is binary (default false).
  --- @return string|nil,string|nil,number|nil - The path to the file, the data written, and the error code.
  --- @example
  --- ```lua
  --- fd:write_file("path/to/file.txt", "contents of file")
  --- -- "path/to/file.txt", "contents of file", nil
  --- ```
  function instance:write_file(path, data, overwrite, binary)
    if not path then return end

    path = instance:fix_path(path)

    local flag = overwrite and "w" or "a"
    local mode = binary and "b" or ""
    local handle, error, code = io.open(path, flag .. mode)
    if not handle then return nil, error, code end

    handle:write(data)
    handle:flush()
    handle:close()

    return path, lfs.attributes(path)
  end

  --- Fix es a path.
  --- @param path string - The path to fix.
  --- @return string - The fixed path.
  --- @example
  --- ```lua
  --- fd:fix_path("path\\to\\file.txt")
  --- -- "path/to/file.txt"
  --- ```
  function instance:fix_path(path)
    return path:gsub("\\", "/")
  end

  instance.parent.valid = instance.parent.valid or setmetatable({}, {
    __index = function(_, k) return function(...) end end
  })

  return instance
end

-- Let Glu know we're here
raiseEvent("glu_module_loaded", script_name, mod)

return mod
