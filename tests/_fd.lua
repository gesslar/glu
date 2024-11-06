-- This is a test for the fd module.
local test_script = "test"
local target_script = "fd"
local tester_name = "__PKGNAME__"
local g = Glu.new(tester_name, nil)
local mod = g[target_script]
local test = g[test_script]

local function dir_file_valid(t)
  return t.is_deeply(
    { mod.dir_file("path/to/file.txt") },
    { "path/to", "file.txt" },
    "dir_file('path/to/file.txt') should return 'path/to' and 'file.txt'"
  )
end

local function dir_file_invalid(t)
  return t.is_deeply(
    { mod.dir_file("file.txt", true) },
    { nil, nil },
    "dir_file('file.txt', true) should return nil, nil when directory is required"
  )
end

local function file_exists_true(t)
  return t.is_eq(
    mod.file_exists("path/to/existing_file.txt"),
    true,
    "file_exists('path/to/existing_file.txt') should return true"
  )
end

local function file_exists_false(t)
  return t.is_eq(
    mod.file_exists("path/to/non_existing_file.txt"),
    false,
    "file_exists('path/to/non_existing_file.txt') should return false"
  )
end

local function dir_exists_true(t)
  return t.is_eq(
    mod.dir_exists("path/to/existing_directory"),
    true,
    "dir_exists('path/to/existing_directory') should return true"
  )
end

local function dir_exists_false(t)
  return t.is_eq(
    mod.dir_exists("path/to/non_existing_directory"),
    false,
    "dir_exists('path/to/non_existing_directory') should return false"
  )
end

local function read_file(t)
  local content = mod.read_file("path/to/existing_file.txt")
  return t.is_eq(
    content,
    "expected content of the file",
    "read_file('path/to/existing_file.txt') should return the correct content"
  )
end

local function write_file(t)
  local path, written_data, error_code = mod.write_file("path/to/new_file.txt", "new content", true)
  return t.is_deeply(
    { path, written_data, error_code },
    { "path/to/new_file.txt", "new content", nil },
    "write_file should return the correct path, data written, and no error"
  )
end

local function fix_path(t)
  return t.is_eq(
    mod.fix_path("path\\to\\file.txt"),
    "path/to/file.txt",
    "fix_path('path\\to\\file.txt') should return 'path/to/file.txt'"
  )
end

-- Run the tests

---@diagnostic disable-next-line: lowercase-global
function run_fd_tests()
  ---@diagnostic disable-next-line: undefined-global
  local runner = test.new({})
    .add("fd.dir_file_valid", dir_file_valid)
    .add("fd.dir_file_invalid", dir_file_invalid)
    .add("fd.file_exists_true", file_exists_true)
    .add("fd.file_exists_false", file_exists_false)
    .add("fd.dir_exists_true", dir_exists_true)
    .add("fd.dir_exists_false", dir_exists_false)
    .add("fd.read_file", read_file)
    .add("fd.write_file", write_file)
    .add("fd.fix_path", fix_path)
    .execute(true)
    .wipe()
end
