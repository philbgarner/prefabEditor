require "imgui"

mass = 0
linear_d = 0
angular_d = 0
bodytype = false
bullet = 0
bodytype = 1
 
box_x = 0
box_y = 0

sel_poly = 0
bound_poly = {}

function newPoint(x, y)
  table.insert(bound_poly, {x = x, y = y})
end

function removePoint(id)
  table.remove(bound_poly, id)
  if sel_poly > #bound_poly then
    sel_poly = #bound_poly
  end
end

cCat = 0
cMask = 0
cGroup = 0

image_file = ""
img = nil

function love.load()
  love.window.setMode(1920, 1200, {resizable=true, minwidth=1920, minheight=1200})


end

function love.update(dt)
end

function love.draw()
  imgui.NewFrame()

  wndAssets(5, 5)
  wndImage(261, 5)  
  wndCollisions(5, 530)
  wndPhysics(261, 815)

  imgui.Render();
  
  if #bound_poly > 2 then
    love.graphics.setLineWidth(2)
    love.graphics.setColor(0, 0, 0)
    --love.graphics.rectangle("line", 262 + 8 + dx, 33 + dy, dw, dh)
    local pol = {}
    for i=1, #bound_poly do
      table.insert(pol, (bound_poly[i].x * img:getWidth()) + 262 + 8 )
      table.insert(pol, (bound_poly[i].y * img:getHeight()) + 33 )
    end
    love.graphics.polygon("line", pol)
    love.graphics.setColor(255, 255, 255)
    love.graphics.push()
      love.graphics.translate(1, 1)
      love.graphics.polygon("line", pol)
    --love.graphics.rectangle("line", 261 + 8 + dx, 32 + dy, dw, dh)
    love.graphics.pop()
    love.graphics.setLineWidth(1)
  end

end


function love.quit()
  imgui.ShutDown();
end

-- Editor Window Definitions

function wndAssets(x, y)
  imgui.SetNextWindowPos(x, y, "Images")
  imgui.SetNextWindowSize(256, 512, "Images")
  status, showAnotherWindow = imgui.Begin("Select Image", true, { "NoCollapse", "TitleBar", "ShowBorders", "NoResize", "AlwaysVerticalScrollbar" })

  local files = love.filesystem.getDirectoryItems("assets/")

  for k, file in ipairs(files) do
    if file:match("^.+(%..+)$") == ".png" then
      if image_file == "" then image_file = file end
      local s = false
      if file == image_file then s = true end
      if imgui.Selectable(file, s) then
        image_file = file
        img = love.graphics.newImage("assets/" .. image_file)
      end
    end
  end

  imgui.End()
end

function wndCollisions(x, y)
  imgui.SetNextWindowPos(x, y, "Images")
  imgui.SetNextWindowSize(256, 400, "Images")
  status, showAnotherWindow = imgui.Begin("Collision Settings", true, { "NoCollapse", "TitleBar", "ShowBorders", "NoResize", "AlwaysVerticalScrollbar" })

  imgui.Text("Points:")
  
  if imgui.Button("Add Point") then
    newPoint(0.5, 0.5)
  end
  if imgui.Button("Remove Point") then
    removePoint(sel_poly)
  end
    
  for i=1, #bound_poly do
    local s = false
    if i == sel_poly then
      s = true
    end
    if imgui.Selectable("#" .. i .. " (" .. string.format("%.3f", bound_poly[i].x) .. ", " .. string.format("%.3f", bound_poly[i].y) .. ")", s) then
      box_x = bound_poly[i].x
      box_y = bound_poly[i].y
      sel_poly = i
    end
  end
  
  imgui.Separator()

  status, box_x = imgui.SliderFloat("x", box_x, 0, 1, "%.3f", 1) 
  status, box_y = imgui.SliderFloat("y", box_y, 0, 1, "%.3f", 1)

  if sel_poly > 0 then
    bound_poly[sel_poly].x = box_x
    bound_poly[sel_poly].y = box_y
  end
  
  imgui.Separator()

  imgui.Text("Collision Groups")

  status, cCat = imgui.InputInt("Category", cCat, 0, 16)
  status, cMask = imgui.InputInt("Mask", cMask, 0, 16)
  status, cGroup = imgui.InputInt("Group", cGroup, 0, 16)

  imgui.End()

end

function wndPhysics(x, y)
  
  imgui.SetNextWindowPos(x, y, "Physical Properties")
  imgui.SetNextWindowSize(512, 256, "Physical Properties")
  status, physicsWindow = imgui.Begin("Physical Properties", true, {"NoCollapse", "TitleBar", "ShowBorders", "NoResize", "AlwaysVerticalScrollbar"})
  status, bullet = imgui.Checkbox("'Bullet' Physics", bullet)
  status, mass = imgui.SliderFloat("Mass", mass, 0, 1000, "%.3f") 
  status, angular_d = imgui.SliderFloat("Angular Damping", angular_d, 0, 0.1, "%.3f") 
  status, linear_d = imgui.SliderFloat("Linear Damping", linear_d, 0, 0.1, "%.3f") 
  status, bodytype = imgui.Combo("Body Type", bodytype, {"Static", "Dynamic"}, 2)
  imgui.End()
  
end

function wndImage(x, y)
  if img == nil then return end
  imgui.SetNextWindowPos(x, y, "Images")
  imgui.SetNextWindowSize(img:getWidth() + 15, img:getHeight() + 40, "Images")
  status, showAnotherWindow = imgui.Begin("Image: sunrise_rock1.png", true, { "NoCollapse", "TitleBar", "ShowBorders", "NoResize", "AlwaysVerticalScrollbar" })

  imgui.Image(img, img:getWidth(), img:getHeight())

  imgui.End()
end
--
-- User inputs
--
function love.textinput(t)
  imgui.TextInput(t)
  if not imgui.GetWantCaptureKeyboard() then
    -- Pass event to the game
  end
end

function love.keypressed(key)
  imgui.KeyPressed(key)
  if not imgui.GetWantCaptureKeyboard() then
    -- Pass event to the game
  end
end

function love.keyreleased(key)
  imgui.KeyReleased(key)
  if not imgui.GetWantCaptureKeyboard() then
    -- Pass event to the game
  end
end

function love.mousemoved(x, y)
  imgui.MouseMoved(x, y)
  if not imgui.GetWantCaptureMouse() then
    -- Pass event to the game
  end
end

function love.mousepressed(x, y, button)
  imgui.MousePressed(button)
  if not imgui.GetWantCaptureMouse() then
    -- Pass event to the game
  end
end

function love.mousereleased(x, y, button)
  imgui.MouseReleased(button)
  if not imgui.GetWantCaptureMouse() then
    -- Pass event to the game
  end
end

function love.wheelmoved(x, y)
  imgui.WheelMoved(y)
  if not imgui.GetWantCaptureMouse() then
    -- Pass event to the game
  end
end