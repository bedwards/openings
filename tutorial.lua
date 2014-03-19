-- > package.loaded.tutorial = nil
-- > require('tutorial')
-- > a1 = tutorial.Account:new{balance = 500.00}
-- > s1 = tutorial.SpecialAccount:new{balance = 200.00, limit = 175.00}                     > a1:withdraw(50.00)
-- > print(a1.balance)                                                                     450
-- > s1:withdraw(125.00)
-- ./tutorial.lua:29: insufficient funds
-- stack traceback:
--   [C]: in function 'error'
--   ./tutorial.lua:29: in function 'withdraw'
--   stdin:1: in main chunk
--   [C]: ?

tutorial = {}

tutorial.Account = {
  balance = 0
}

function tutorial.Account:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function tutorial.Account:deposit (v)
  self.balance = self.balance + v
end

function tutorial.Account:withdraw (v)
  if v > self.balance then error"insufficient funds" end
  self.balance = self.balance - v
end

tutorial.SpecialAccount = tutorial.Account:new()

function tutorial.SpecialAccount:withdraw (v)
  if self.balance - v < self:getLimit() then
    error"insufficient funds"
  end
  self.balance = self.balance - v
end

function tutorial.SpecialAccount:getLimit ()
  return self.limit or 0
end

function tutorial.newAccount (initialBalance)
  local self = {
    balance = initialBalance
  }

  local withdraw = function (v)
    self.balance = self.balance - v
  end

  local deposit = function (v)
    self.balance = self.balance + v
  end

  local getBalance = function ()
    return self.balance
  end

  return {
    withdraw = withdraw,
    deposit = deposit,
    getBalance = getBalance
  }
end

return tutorial
