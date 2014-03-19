local composer = require "composer"
local scene = composer.newScene()
local view = require "view"
local v = view.View:new {
  composer = composer,
  sceneName = "scene2",
  otherSceneName = "scene1",
}

function scene:create(event)
end

function scene:show(event)
  local phase = event.phase
  if phase == "will" then
    v:willShow()
  elseif phase == "did" then
  end
end

function scene:hide(event)
  local phase = event.phase
  if event.phase == "will" then
  elseif phase == "did" then
    v:didHide()
  end
end

function scene:destroy(event)
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
