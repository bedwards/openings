-- package.loaded.object = nil
-- for k,v in pairs(t) do print(k,v) end

local utils = {}

utils.copy = function(orig)
    local copy = {}
    for k, v in pairs(orig) do
        copy[k] = v
    end
    return copy
end

utils.createToString = function(className)
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

return utils
