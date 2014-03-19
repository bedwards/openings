-- package.loaded.qicktest = nil
-- for k,v in pairs(t) do print(k,v) end

require "deepcopy"

quicktest = {}

quicktest.createToString = function(className)
  return function(obj)
    local s = className .. "{"
    local sep = ""
    for k, v in pairs(obj) do
      if k:sub(1, 2) ~= "__" then
        if type(v) ~= "function" then
          s = s .. sep .. k .. "=" .. v
          sep = ", "
        elseif k:sub(1, 3) == "get" then
          s = s .. sep .. k:sub(4, k:len()):lower() .. "=" .. v()
          sep = ", "
        elseif k:sub(1, 2) == "is" then
          s = s .. sep .. k:sub(3, k:len()):lower() .. "=" .. v()
          sep = ", "
        end
      end
    end
    return s .. "}"
  end
end

quicktest.Object = { __className = "Object" }
quicktest.Object.__index = quicktest.Object

function quicktest.Object:__extend(className)
  c = { __className = className }
  c.__index = c
  mt = table.deepcopy(self)
  setmetatable(c, mt)
  return c
end

function quicktest.Object:new(params)
  if params == nil then
    o = {}
  else
    o = params:deepcopy()
  end
  mt = table.deepcopy(self)
  mt.__tostring = quicktest.createToString(self.__className)
  setmetatable(o, mt)
  o:init()
  return o
end

function quicktest.Object:init()
end

quicktest.MyThing = quicktest.Object:__extend("MyThing")

return quicktest
