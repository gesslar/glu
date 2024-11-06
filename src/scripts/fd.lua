local script_name = "fd"
local class_name = script_name:title() .. "Class"
local deps = { "table", "valid" }

local FileSystemObjectClass = Glu.registerClass({
  class_name = "FileSystemObjectClass",
  script_name = "file_system_object",
  dependencies = {},
})

local FileClass = Glu.registerClass({
  class_name = "FileClass",
  script_name = "file",
  parent_class = FileSystemObjectClass,
  dependencies = {},
})

local DirectoryClass = Glu.registerClass({
  class_name = "DirectoryClass",
  script_name = "directory",
  parent_class = FileSystemObjectClass,
  dependencies = {},
})

local mod = Glu.registerClass({
  class_name = class_name,
  script_name = script_name,
  dependencies = {},
})

function mod.setup(___, self)
  --- Splits a path into a directory and file.
  ---
  --- If the directory is required and does not exist, nil is returned.
  ---
  --- @example
  --- ```lua
  --- fd.dir_file("path/to/file.txt")
  --- -- "path/to", "file.txt"
  --- ```
  ---
  --- @param path string - The path to split.
  --- @param dir_required boolean - Whether the directory is required (Optional. Default is false).
  --- @return string|nil,string|nil - A table with the directory and file, or nil if the path is invalid.
  function self.dir_file(path, dir_required)
    ___.valid.type(path, "string", 1, false)
    ___.valid.type(dir_required, "boolean", 2, true)

    dir_required = dir_required or false

    path, _ = self.fix_path(path)

    local dir, file = rex.match(path, "^(.*)/(.*)$")
    if #{dir, file} == 2 then
      return dir, file
    end

    if dir_required and dir then
      if not self.dir_exists(dir) then
        return nil, nil
      end
    end

    return dir, file
  end

  function self.root_dir_file(path)
    ___.valid.type(path, "string", 1, false)

    local root = self.determine_root(path)
    if not root then return nil, nil end

    local len = utf8.len(root)
    local dir, file = self.dir_file(path:sub(len + 1))
    if not dir then return nil, nil end

    return root, dir, file
  end

  --- Checks if a file exists.
  --- @param path string - The path to check.
  --- @return boolean - Whether the file exists.
  --- @example
  --- ```lua
  --- fd.file_exists("path/to/file.txt")
  --- -- true
  --- ```
  function self.file_exists(path)
    ___.valid.type(path, "string", 1, false)

    local attr, message, code = lfs.attributes(path)
    if not attr then return false end

    return attr.mode == "file"
  end

  --- Checks if a directory exists.
  --- @param path string - The path to check.
  --- @return boolean - Whether the directory exists.
  --- @example
  --- ```lua
  --- fd.dir_exists("path/to/directory")
  --- -- true
  --- ```
  function self.dir_exists(path)
    ___.valid.type(path, "string", 1, false)

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
  --- fd.read_file("path/to/file.txt")
  --- -- "contents of file"
  --- ```
  function self.read_file(path, binary)
    ___.valid.type(path, "string", 1, false)
    ___.valid.type(binary, "boolean", 2, true)

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
  --- fd.write_file("path/to/file.txt", "contents of file")
  --- -- "path/to/file.txt", "contents of file", nil
  --- ```
  function self.write_file(path, data, overwrite, binary)
    ___.valid.type(path, "string", 1, false)
    ___.valid.type(data, "string", 2, false)
    ___.valid.type(overwrite, "boolean", 3, true)
    ___.valid.type(binary, "boolean", 4, true)

    path = self.fix_path(path)

    local flag = overwrite and "w" or "a"
    local mode = binary and "b" or ""
    local handle, error, code = io.open(path, flag .. mode)
    if not handle then return nil, error, code end

    handle:write(data)
    handle:flush()
    handle:close()

    return path, lfs.attributes(path)
  end

  --- Fixes a path to use forward slashes.
  --- @param path string - The path to fix.
  --- @return string, number - The fixed path and the number of replacements made.
  --- @example
  --- ```lua
  --- fd.fix_path("path\\to\\file.txt")
  --- -- "path/to/file.txt"
  --- ```
  function self.fix_path(path)
    ___.valid.type(path, "string", 1, false)

    local result, num = rex.gsub(rex.gsub(path, "\\\\", "/"), "//", "/")
    if not result or num == 0 then return path, 0 end

    if result:sub(-1) == "/" then
      result = result:sub(1, -2) or ""
    end

    ---@diagnostic disable-next-line: return-type-mismatch
    return result, num
  end

  --- Ensures that a directory exists.
  --- @param path string - The path to the directory.
  --- @return table|nil, string|nil, number|nil - A table of created directories, the error message, and the error code.
  --- @example
  --- ```lua
  --- fd.assure_dir("path/to/directory")
  --- ```
  function self.assure_dir(path)
    ___.valid.type(path, "string", 1, false)

    path = self.fix_path(path)
    print(path)
    local root
    root, path, _ = self.root_dir_file(path)
    if path[1] == "/" then path = path:sub(2) end

    local dirs = path:split("/")
    local target = root
    dirs = table.n_filter(dirs, function(dir) return dir ~= "" end)

    local created = {}
    repeat
      local dir = table.remove(dirs, 1)
      target = target .. "/" .. dir

      if not self.dir_exists(target) then
        local ok, err, code = lfs.mkdir(target)
        if not ok then
          return nil, err, code
        end
        table.insert(created, target)
      end
    until #dirs == 0

    created = ___.table.map(created, function(_, dir) return self.fix_path(dir) end)
    return created, nil, nil
  end

  --- Determines the root of a path.
  --- @param path string - The path to determine the root of.
  --- @return string|nil - The root of the path, or nil if the path is invalid.
  --- @example
  --- ```lua
  --- fd.determine_root("c:\\test\\moo")
  --- -- "c:"
  --- ```
  function self.determine_root(path)
    ___.valid.type(path, "string", 1, false)

    path, _ = self.fix_path(path)

    local parts = {rex.match(path, "^([a-zA-Z]:(\\\\{1,2}|/{1,2})|/{1,2})(?:.*)$")}
    if not parts then return nil end

    local root, slash = parts[1], parts[2] or ""

    return root
  end

  function self.rmfile(path)
    ___.valid.file(path, 1)

    return lfs.remove(path)
  end

  function self.rmdir(path, recursive)
    ___.valid.dir(path, 1)
    ___.valid.type(recursive, "boolean", 2, true)

    recursive = recursive or false


  end

  --- Checks if a directory is empty.
  --- @param path string - The path to the directory.
  --- @return boolean - Whether the directory is empty.
  --- @example
  --- ```lua
  --- fd.dir_empty("/path/to/directory")
  --- -- true
  --- ```
  function self.dir_empty(path)
    return #self.get_dir(path, false) == 0
  end

  --- Gets the files in a directory.
  --- @param path string - The path to the directory.
  --- @param include_dots boolean - Whether to include the "." and ".." directories (default false).
  --- @return table - A table of files in the directory.
  --- @example
  --- ```lua
  --- fd.get_dir("/path/to/directory")
  --- -- {"file1", "file2", "file3"}
  --- ```
  function self.get_dir(path, include_dots)
    ___.valid.type(path, "string", 1, false)
    ___.valid.type(include_dots, "boolean", 2, true)

    include_dots = include_dots or false

    path, _ = self.fix_path(path)
    path = path or ""

    ___.valid.dir(path, 1)

    local result = {}

    for file in lfs.dir(path) do
      local attr = lfs.attributes(path .. "/" .. file)
      table.insert(result, file)
    end

    if not include_dots then
      result = table.n_filter(result, function(file) return file ~= "." and file ~= ".." end)
    end

    ---@diagnostic disable-next-line: return-type-mismatch
    return result
  end

  function self.tree(path)
    ___.valid.type(path, "string", 1, false)

    path, _ = self.fix_path(path)

    ___.valid.dir(path, 1)

    local tree = {}

    local root, dir, _ = unpack({self.root_dir_file(path)})
    if not root then return nil end

    local dirs = dir:split("/")
    dirs = table.n_filter(dirs, function(dir) return dir ~= "" end)

    for _, d in ___.table.walk(dirs) do
      local target = root .. "/" .. d
      if not self.dir_exists(target) then
        table.insert(tree, target)
      end
    end

    display(tree)
  end
end
