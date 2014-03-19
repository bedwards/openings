-- for k,v in pairs(t) do print(k,v) end

local utils = require "utils"
local model = require "model"
local view = {}


-- Square ---------------------------------------------------------------------
-- parent, name, x, y, size, isWhite

view.Square = {}
view.Square.__index = view.Square
view.Square.__tostring = utils.createToString("view.Square")

function view.Square:new(o)
  setmetatable(o, view.Square)
  o:init()
  return o
end

function view.Square:init()
  self.rect = display.newRect(
    self.parent,
    self.x,
    self.y,
    self.size,
    self.size
  )
  if self.isWhite then
    self.rect:setFillColor(1, 1, .88)
  else
    self.rect:setFillColor(1, .87, .68)
  end
end


-- Piece ----------------------------------------------------------------------
-- manager, parent, square, filename
-- setSquare

view.Piece = {}
view.Piece.__index = view.Piece
view.Piece.__tostring = utils.createToString("view.Piece")

function view.Piece:new(o)
  setmetatable(o, view.Piece)
  o:init()
  return o
end

function view.Piece:init()
  self.image = display.newImage(
    self.parent,
    self.filename,
    system.ResourceDirectory,
    self.square.x,
    self.square.y,
    true
  )
  if self.isMine then
    self.image:addEventListener("tap", self)
  end
end

function view.Piece:removeSelf()
  self.image:removeEventListener("tap", self)
  self.image:removeSelf()
end

function view.Piece:tap()
  self.manager:addHighlightsFor(self)
end

function view.Piece:setSquare(square)
  self.square = square
  self.image.x = square.x
  self.image.y = square.y
end


-- Highlight ------------------------------------------------------------------
-- manager, parent, square, piece
-- removeSelf

view.Highlight = {}
view.Highlight.__index = view.Highlight
view.Highlight.__tostring = utils.createToString("view.Highlight")

function view.Highlight:new(o)
  setmetatable(o, view.Highlight)
  o:init()
  return o
end

function view.Highlight:init()
  self.rect = display.newRect(
    self.parent,
    self.square.x,
    self.square.y,
    self.square.size,
    self.square.size
  )
  self.rect:setFillColor(1, 1, .8)
  self.rect:setStrokeColor(.6, .6, .4)
  self.rect.strokeWidth = 2
  self.rect:addEventListener("tap", self)
end

function view.Highlight:removeSelf()
  self.rect:removeEventListener("tap", self)
  self.rect:removeSelf()
end

function view.Highlight:tap(event)
  self.manager:makeMove(self.piece.square.name, self.square.name)
end


-- HighlightManager -----------------------------------------------------------
-- manager, parent
-- addHighlightsFor, makeMove

view.HighlightManager = {}
view.HighlightManager.__index = view.HighlightManager
view.HighlightManager.__tostring = utils.createToString("view.HighlightManager")

function view.HighlightManager:new(o)
  setmetatable(o, view.HighlightManager)
  o:init()
  return o
end

function view.HighlightManager:init()
  self.highlights = {}
end

function view.HighlightManager:addHighlightsFor(piece)
  self:removeHighlights()
  local squareNames = self.game.getNextMovesForPieceAt(piece.square.name)
  self:addHighlightsAt(squareNames, piece)
end

function view.HighlightManager:addHighlightsAt(squareNames, piece)
  self:removeHighlights()
  for i, squareName in ipairs(squareNames) do
    local square = self.squares[squareName]
    local bounds = square.contentBounds
    self.highlights[i] = view.Highlight:new {
      manager = self,
      parent = self.parent,
      square = square,
      piece = piece,
    }
  end
end

function view.HighlightManager:removeHighlights()
  for i, highlight in ipairs(self.highlights) do
    highlight:removeSelf()
  end
  self.highlights = {}
end

function view.HighlightManager:makeMove(fromSquareName, toSquareName)
  self:removeHighlights()
  self.manager:makeMove(fromSquareName, toSquareName)
end


-- StatusText -----------------------------------------------------------------------
-- parent
-- show

view.StatusText = {}
view.StatusText.__index = view.StatusText
view.StatusText.__tostring = utils.createToString("view.StatusText")

function view.StatusText:new(o)
  setmetatable(o, view.StatusText)
  o:init()
  return o
end

function view.StatusText:init()
  self.parent.isVisible = false
  self.width = 125
  self.height = 24
  self.anchorX = .5
  self.anchorY = .5
  self.rect = display.newRect(
    self.parent,
    self.x,
    self.y,
    self.width,
    self.height
  )
  self.rect:setFillColor(1, 1, .8)
  self.rect:setStrokeColor(.6 , .6, .4)
  self.rect.strokeWidth = 2
  self.rect.anchorX = self.anchorX
  self.rect.anchorY = self.anchorY
  self.text = display.newText {
    parent = self.parent,
    text  = "no status",
    x = self.x,
    y = self.y,
    width = self.width,
    height = self.height,
    font = native.systemFont,
    fontSize = 18,
    align = "center",
  }
  self.text:setFillColor(.5, .5, .5)
  self.text.anchorX = self.anchorX
  self.text.anchorY = self.anchorY
end

function view.StatusText:show(status)
  self.text.text = status
  self.parent.isVisible = true
  timer.performWithDelay(1000, function()
    self.parent.isVisible = false
  end)
end


-- View -----------------------------------------------------------------------
-- viewName, otherViewName

view.View = {}
view.View.__index = view.View
view.View.__tostring = utils.createToString("view.View")

function view.View:new(o)
  setmetatable(o, view.View)
  o:init()
  return o
end

function view.View:init()

  -- parents
  self.parents = {
    background = display.newGroup(),
    squares = display.newGroup(),
    highlights = display.newGroup(),
    pieces = display.newGroup(),
    statusText = display.newGroup(),
  }

  -- background
  local background = display.newRect(
    self.parents.background,
    0,
    0,
    display.contentWidth,
    display.contentHeight
  )
  background:setFillColor(.13, .55, .13)

  -- model (game)
  self:newGame()

  -- border
  self.border = display.newRect(
    self.parents.background,
    self.game.border.x,
    self.game.border.y,
    self.game.border.size,
    self.game.border.size
  )
  self.border:setFillColor(.55, .27, .07)

  -- status text
  self.statusText = view.StatusText:new {
    parent = self.parents.statusText,
    x = (self.border.x + self.border.contentBounds.xMax ) / 2,
    y = (self.border.y + self.border.contentBounds.yMax ) / 2,
  }

  self.pieces = {}

end

function view.View:newGame()
  local padding = 8
  self.game = model.ChessGame.new {
    x = padding,
    y = display.statusBarHeight + padding,
    size = display.contentWidth - padding * 2,
    border = 4,
    opening = model.book.getCurrentOpening()
  }
end

function view.View:willShow()

  self:newGame()

  for k, group in pairs(self.parents) do
    if k ~= "statusText" then
      group.isVisible = true
    end
  end

  -- squares
  self.squares = {}
  for i, modelSquare in pairs(self.game.squares) do
    self.squares[modelSquare.squareName] = view.Square:new {
      parent = self.parents.squares,
      name = modelSquare.squareName,
      x = modelSquare.x,
      y = modelSquare.y,
      size = self.game.squareSize,
      isWhite = modelSquare.isWhite,
    }
  end

  -- hightlights
  self.highlightManager = view.HighlightManager:new {
    manager = self,
    parent = self.parents.highlights,
    game = self.game,
    squares = self.squares,
  }

  -- pieces
  for i, modelPiece in ipairs(self.game.pieces) do
    self.pieces[modelPiece.squareName] = view.Piece:new {
      manager = self.highlightManager,
      parent = self.parents.pieces,
      square = self.squares[modelPiece.squareName],
      filename = modelPiece.filename,
      isMine = modelPiece.isMine,
    }
  end

end

function view.View:makeMove(fromSquareName, toSquareName)
  if self.pieces[toSquareName] ~= nil then
    self.pieces[toSquareName]:removeSelf()
  end
  self.pieces[toSquareName] = self.pieces[fromSquareName]
  self.pieces[fromSquareName] = nil
  self.pieces[toSquareName]:setSquare(self.squares[toSquareName])
  local result = self.game.makeMove(fromSquareName, toSquareName)
  self.statusText:show(result.status)
  if result.status == "Correct" then
    timer.performWithDelay(1000, function()
      local move = self.game.makeOpponentMove()
      self.pieces[move.newSquareName] = self.pieces[move.oldSquareName]
      self.pieces[move.oldSquareName] = nil
      self.pieces[move.newSquareName]:setSquare(self.squares[move.newSquareName])
    end)
  elseif result.status == "Incorrect" then
    self.highlightManager:addHighlightsAt(result.move)
    timer.performWithDelay(1000, function()
      self.composer:gotoScene(self.otherSceneName)
      self.composer:removeScene(self.sceneName, true)
    end)
  elseif result.status == "Complete" then
    timer.performWithDelay(1000, function()
      self.composer:gotoScene(self.otherSceneName)
      self.composer:removeScene(self.sceneName, true)
    end)
  end
end

function view.View:didHide()
  self.highlightManager:removeHighlights()
  for k, piece in pairs(self.pieces) do
    piece:removeSelf()
  end
  self.pieces = {}
  for k, group in pairs(self.parents) do
    group.isVisible = false
  end

end

return view
