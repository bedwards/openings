-- for k,v in pairs(t) do print(k,v) end


-- c0_LuaChess.c0_get_next_moves() 

--   a2a3,a2a4,b2b3,b2b4,c2c3,c2c4,d2d3,d2d4,e2e3,e2e4,f2f3,f2f4,g2g3,g2g4,h2h3,h2h4,b1c3,b1a3,g1h3,g1f3,

-- for m in c0_LuaChess.c0_get_next_moves():gmatch("[a-h][1-8][a-h][1-8]") do 
--   print(m)
--   for n in m:gmatch("[a-h][1-8]") do 
--     print(n)
--   end
-- end

-- c0_LuaChess.c0_D_can_be_moved("e2", "e4") -> true
-- c0_LuaChess.c0_D_what_at("g1") -> "wN"


local json = require "json"
local c0_LuaChess = require "c0_chess"
local utils = require "utils"

local m = {}
m.ChessGame = {}
m.OpeningBook = {}

m.settingsPath = system.pathForFile("settings.json", system.DocumentsDirectory)

function m.OpeningBook.new()
  local book = {}
  setmetatable(book, {__tostring = utils.createToString("OpeningBook")})

  
  local settingsFile = io.open(m.settingsPath, "r")
  if settingsFile == nil then
    settingsFile = io.open(m.settingsPath, "w")
    settingsFile:write(json.encode({ book = { currentIndex = 1 } }))
    book.currentIndex = 1
  else
    local contents = settingsFile:read("*a")
    io.close(settingsFile)
    settingsFile = nil
    settings = json.decode(contents)
    book.currentIndex = settings.book.currentIndex
  end

  local path = system.pathForFile( "./openings.json" )
  local file = io.open(path, "r")
  local contents = file:read("*a")
  io.close(file)
  file = nil
  book.openings = json.decode(contents)

  function book.getCurrentOpening()
    return book.openings[book.currentIndex]
  end

  function book.getMySide()
    return book.getCurrentOpening()["turn"]
  end

  return book
end

m.book = m.OpeningBook:new()

local pieceImages = {
  bR = "black_rook.png", 
  bN = "black_knight.png", 
  bB = "black_bishop.png",
  bQ = "black_queen.png",
  bK = "black_king.png",
  bp = "black_pawn.png",
  wR = "white_rook.png", 
  wN = "white_knight.png", 
  wB = "white_bishop.png",
  wQ = "white_queen.png",
  wK = "white_king.png",
  wp = "white_pawn.png",
}

local files = {"a", "b", "c", "d", "e", "f", "g", "h"}
local squareNames = {}
local i = 1
for j, file in ipairs(files) do
  for rank = 8, 1, -1 do
    squareNames[i] = file .. rank
    i = i + 1
  end
end


function m.getMoves(pgn)
  local movesStr = c0_LuaChess.c0_get_moves_from_PGN(pgn)
  local moves = {}
  local movesIndex = 1
  for moveStr in movesStr:gmatch("[a-h][1-8][a-h][1-8]") do
    move = {}
    moveIndex = 1
    for squareName in moveStr:gmatch("[a-h][1-8]") do
      move[moveIndex] = squareName
      moveIndex = moveIndex + 1
    end
    moves[movesIndex] = move
    movesIndex = movesIndex + 1
  end
  return moves
end


function m.persistCurrentIndex(currentIndex)
  local settingsFile = io.open(m.settingsPath, "r")
  local contents = settingsFile:read("*a")
  io.close(settingsFile)
  local settings = json.decode(contents)
  settings.book.currentIndex = currentIndex
  settingsFile = io.open(m.settingsPath, "w")
  settingsFile:write(json.encode(settings))
  io.close(settingsFile)
end


function m.ChessGame.new(params)
  local game = {}
  setmetatable(game, {__tostring = utils.createToString("ChessGame")})

  game.opening = params.opening
  game.moves = m.getMoves(params.opening.pgn)

  if params.opening.turn == "b" then
    game.movesIndex = 1
  else
    game.movesIndex = 2
  end

  game.border = {
    x = params.x - params.border,
    y = params.y - params.border,
    size = params.size + params.border * 2
  }

  game.squareSize = params.size / 8

  game.squares = {}
  local n = 1
  for i = 1, 8 do
    for j = 1, 8 do
      local index = n
      if params.opening.turn == "b" then
        index = #squareNames - n + 1
      end
      game.squares[squareNames[index]] = {
        x = params.x + (i - 1) * game.squareSize,
        y = params.y + (j - 1) * game.squareSize,
        isWhite = (i + j) % 2 == 0,
        squareName = squareNames[index]
      }
      n = n + 1
    end
  end

  function game.makeOpponentMove()
    move = game.moves[game.movesIndex]
    game.movesIndex = game.movesIndex + 2
    c0_LuaChess.c0_move_to(move[1], move[2])
    -- print(move[1], move[2], c0_LuaChess.c0_get_FEN())
    c0_LuaChess.c0_sidemoves = -c0_LuaChess.c0_sidemoves
    local oppMoveInfo = {
        x = game.squares[move[2]].x,
        y = game.squares[move[2]].y,
        oldSquareName = move[1],
        newSquareName = move[2]
    }

    return oppMoveInfo
  end


  -- if params.opening.turn == "b" then
  --   c0_LuaChess.c0_side = -1
  -- else
  --   c0_LuaChess.c0_side = 1
  -- end
  
  c0_LuaChess.c0_set_start_position("")

  if params.opening.turn == "b" then
    game.makeOpponentMove()
  end

  game.pieces = {}
  n = 1
  for i, squareName in ipairs(squareNames) do
    local piece = c0_LuaChess.c0_D_what_at(squareName)
    if piece ~= "" then
      game.pieces[n] = {
        x = game.squares[squareName].x,
        y = game.squares[squareName].y,
        filename = pieceImages[piece],
        squareName = squareName,
        isMine = params.opening.turn == piece:sub(1, 1),
      }
      n = n + 1
    end
  end

  function game.getNextMovesForPieceAt(squareName)
    -- a2a3,a2a4,b2b3,b2b4,c2c3,c2c4,d2d3,d2d4,e2e3,e2e4,f2f3,f2f4,g2g3,g2g4,h2h3,h2h4,b1c3,b1a3,g1h3,g1f3,
    nextMoveSquareNames = {}
    local z = 1
    for nextMove in c0_LuaChess.c0_get_next_moves():gmatch("[a-h][1-8][a-h][1-8]") do
      local t = {}
      local i = 1
      for n in nextMove:gmatch("[a-h][1-8]") do 
        t[i] = n
        i = i + 1
      end
      if t[1] == squareName then
        nextMoveSquareNames[z] = t[2]
        z = z + 1
      end
    end
    return nextMoveSquareNames
  end

  function game.makeMove(fromSquareName, toSquareName)
    c0_LuaChess.c0_move_to(fromSquareName, toSquareName)
    local rawPgn = c0_LuaChess.c0_put_to_PGN("")
    c0_LuaChess.c0_sidemoves = -c0_LuaChess.c0_sidemoves
    local pgn
    for s in rawPgn:gmatch("1%. N?[a-h][1-8][^0]*") do
      pgn = s:sub(1, #s-2)
    end
    -- |1. e4 e5|
    -- |1. e4 e5 2. d4|
    -- |1. e4 e5 2. d4 d5|
    -- |1. e4 e5 2. d4 d5 3. Nc3|
    expected = game.opening.pgn
    if pgn == expected then
      if m.book.currentIndex == #m.book.openings then
        m.book.currentIndex = 1
        m.persistCurrentIndex(m.book.currentIndex)
        return { status = "Game over" }
      end
      m.book.currentIndex = m.book.currentIndex + 1
      m.persistCurrentIndex(m.book.currentIndex)
      return { status = "Complete" }
    end
    if pgn == expected:sub(1, #pgn) then
      return { status = "Correct" }
    end
    if m.book.currentIndex > 1 then
      m.book.currentIndex = m.book.currentIndex - 1
      m.persistCurrentIndex(m.book.currentIndex)
    end
    local expectedMoves = c0_LuaChess.c0_get_moves_from_PGN(expected)
    -- print("game.moves")
    -- for k,v in pairs(game.moves) do print(k,v[1],v[2]) end
    -- print("move at", game.movesIndex - 1, game.moves[game.movesIndex - 1][1], game.moves[game.movesIndex - 1][2])
    -- print("expectedMoves", expectedMoves)
    -- print("c0_LuaChess.c0_moveslist", c0_LuaChess.c0_moveslist)
    -- expectedMoves = expectedMoves:sub(1, #c0_LuaChess.c0_moveslist)
    return { status = "Incorrect", move = game.moves[game.movesIndex - 1] }
  end

  return game
end

return m