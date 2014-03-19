-- package.loaded.account = nil
-- for k,v in pairs(t) do print(k,v) end

local object = require "object"

local m = {}
m.Account = {}

function m.Account.new(balance)
  local o = {}
  setmetatable(o, {__tostring = object.toString "Account"})

  o.balance = balance or 0

  function o.withdraw(v)
    o.balance = o.balance - v
  end

  function o.deposit(v)
    o.balance = o.balance + v
  end

  function o.getBalance()
    return o.balance
  end
  
  return o
end

return m
