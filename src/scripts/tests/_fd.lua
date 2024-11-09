---@diagnostic disable-next-line: lowercase-global
function run_fd_tests()
  -- This is a test for the fd module.
  local tester_name = "__PKGNAME__"
  local g = Glu(tester_name, nil)
  local testing = g.fd
  local test = g.test

  local test_dir = getMudletHomeDir()
  local test_name = function() return "test_file_" .. math.random(os.time()) .. ".txt" end
  local test_file_content = "expected content of the file"
  local files, dirs = {}, {}

  local function rm_test_file(file)
    local full_path = test_dir .. "/" .. file
    if testing.file_exists(full_path) then
      testing.rmfile(full_path)
      files[file] = nil
    end
  end

  local function write_test_file(content)
    local file = test_name()
    local path = test_dir .. "/" .. file
    local file_path, result = testing.write_file(path, content, true)
    if not file_path then error("Failed to write test file: " .. result.error) end

    files[file] = file_path
    return file, file_path
  end

  local function rm_test_dir(dir)
    local full_path = test_dir .. "/" .. dir
    if testing.dir_exists(full_path) then
      testing.rmdir(full_path)
      dirs[dir] = nil
    end
  end

  local function write_test_dir()
    local dir = test_name()
    local full_path = test_dir .. "/" .. dir
    local result, err = lfs.mkdir(full_path)
    if not result then error("Failed to write test directory: " .. err) end

    dirs[dir] = full_path
    return dir, full_path
  end

  local function dir_file_valid(cond)
    local file, path = write_test_file(test_file_content)

    return cond.is_deeply(
      { testing.dir_file(path) },
      { test_dir, file },
      "dir_file('" .. path .. "') should return '" .. test_dir .. "' and '" .. file .. "'"
    )
  end

  local function dir_file_invalid(cond)
    local file = test_name()
    local path = test_dir .. "/" .. file

    return cond.is_deeply(
      { testing.dir_file(file, true) },
      { nil, nil },
      "dir_file('" .. file .. "', true) should return nil, nil when directory is required"
    )
  end

  local function file_exists_true(cond)
    local file, path = write_test_file(test_file_content)

    return cond.is_eq(
      testing.file_exists(path),
      true,
      "file_exists('" .. path .. "') should return true"
    )
  end

  local function file_exists_false(cond)
    local file = test_name()
    local path = test_dir .. "/" .. file

    return cond.is_eq(
      testing.file_exists(path),
      false,
      "file_exists('" .. path .. "') should return false"
    )
  end

  local function dir_exists_true(cond)
    return cond.is_eq(
      testing.dir_exists(test_dir),
      true,
      "dir_exists('" .. test_dir .. "') should return true"
    )
  end

  local function dir_exists_false(cond)
    local dir = test_dir .. "/" .. test_name()

    return cond.is_eq(
      testing.dir_exists(dir),
      false,
      "dir_exists('" .. dir .. "') should return false"
    )
  end

  local function read_file(cond)
    local file, path = write_test_file(test_file_content)
    local content = testing.read_file(path)

    return cond.is_eq(
      content,
      test_file_content,
      "read_file('" .. path .. "') should return '" .. test_file_content .. "'"
    )
  end

  local function write_file(cond)
    local file, path = write_test_file(test_file_content)

    return cond.is_not_nil(
      path,
      "write_file should return '" .. path .. "'"
    )
  end

  local function fix_path(cond, runner, test)
    local bad_file = "//path\\\\to\\file"
    local good_file = "/path/to/file"

    return cond.is_eq(
      testing.fix_path(bad_file),
      good_file,
      "fix_path('" .. bad_file .. "') should return '" .. good_file .. "'"
    )
  end

  -- Run the tests
  local runner = test.runner({
    name = testing.class_name,
    tests = {
      { name = "fd.dir_file_valid", func = dir_file_valid },
      { name = "fd.dir_file_invalid", func = dir_file_invalid },
      { name = "fd.file_exists_true", func = file_exists_true },
      { name = "fd.file_exists_false", func = file_exists_false },
      { name = "fd.dir_exists_true", func = dir_exists_true },
      { name = "fd.dir_exists_false", func = dir_exists_false },
      { name = "fd.read_file", func = read_file },
      { name = "fd.write_file", func = write_file },
      { name = "fd.fix_path", func = fix_path }
    }
  })
  .execute(true)
  .wipe()

  for file in pairs(files) do rm_test_file(file) end
  for dir in pairs(dirs) do rm_test_dir(dir) end
end
