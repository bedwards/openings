-- package.loaded.object = nil
-- for k,v in pairs(t) do print(k,v) end

local utils = {}

function utils.copy(orig)
    local copy = {}
    for k, v in pairs(orig) do
        copy[k] = v
    end
    return copy
end

function utils.createToString(className)
  return function(obj)
    local s = className .. "{"
    local sep = ""
    for k, v in pairs(obj) do
      if k:sub(1, 2) ~= "__" then
        if type(v) ~= "table" then
          if type(v) ~= "function" then
            s = s .. sep .. k .. "=" .. tostring(v)
            sep = ", "
          elseif k:sub(1, 3) == "get" then
            s = s .. sep .. k:sub(4, k:len()):lower() .. "=" .. tostring(v())
            sep = ", "
          elseif k:sub(1, 2) == "is" then
            s = s .. sep .. k:sub(3, k:len()):lower() .. "=" .. tostring(v())
            sep = ", "
          end
        end
      end
    end
    return s .. "}"
  end
end

function utils.doesFileExist(fname, path)
    local results = false
    local filePath = system.pathForFile(fname, path)
    --filePath will be 'nil' if file doesn't exist and the path is 'system.ResourceDirectory'
    if (filePath) then
        filePath = io.open(filePath, "r")
    end
    if (filePath) then
        print("File found: " .. fname)
        --clean up file handles
        filePath:close()
        results = true
    else
        print("File does not exist: " .. fname)
    end
    return results
end

-- check for file in 'system.DocumentsDirectory'
-- local results = utils.doesFileExist("images/cat.png", system.DocumentsDirectory)
-- check for file in 'system.ResourceDirectory'
-- local results = utils.doesFileExist("images/cat.png")

function utils.copyFile(srcName, srcPath, dstName, dstPath, overwrite)
    local results = false
    local srcPath = utils.doesFileExist(srcName, srcPath)
    if srcPath == false then
        return nil  -- nil = source file not found
    end
    --check to see if destination file already exists
    if not overwrite then
        if utils.doesFileExist(dstName, dstPath) then
            return 1  -- 1 = file already exists (don't overwrite)
        end
    end
    --copy the source file to the destination file
    local rfilePath = system.pathForFile(srcName, srcPath)
    local wfilePath = system.pathForFile(dstName, dstPath)
    local rfh = io.open(rfilePath, "rb")
    local wfh = io.open(wfilePath, "wb")

    if not wfh then
        print("writeFileName open error!")
        return false
    else
        --read the file from 'system.ResourceDirectory' and write to the destination directory
        local data = rfh:read("*a")
        if not data then
            print("read error!")
            return false
        else
            if not wfh:write(data) then
                print("write error!")
                return false
            end
        end
    end

    results = 2  -- 2 = file copied successfully!

    --clean up file handles
    rfh:close()
    wfh:close()

    return results
end

-- copy 'readme.txt' from the 'system.ResourceDirectory' to 'system.DocumentsDirectory'.
-- utils.copyFile("readme.txt", nil, "readme.txt", system.DocumentsDirectory, true)
-- utils.copyFile("cat.png.txt", nil, "cat.png", system.DocumentsDirectory, true)
-- local catImage = display.newImage("cat.png", system.DocumentsDirectory, 0, 100)


return utils
