-- package.loaded.qicktest = nil
-- for k,v in pairs(t) do print(k,v) end

quicktest = {}

quicktest.copy = function(orig)
    local copy = {}
    for k, v in pairs(orig) do
        copy[k] = v
    end
    return copy
end

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

quicktest.MyThing = {}
quicktest.MyThing.__index = quicktest.MyThing
quicktest.MyThing.__tostring = quicktest.createToString("MyThing")

function quicktest.MyThing:new(params)
  if params == nil then o = {} else o = quicktest.copy(params) end
  setmetatable(o, quicktest.MyThing)
  o:init()
  return o
end

function quicktest.MyThing:init()
end

return quicktest























