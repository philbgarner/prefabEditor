require "imgui"

assetlist = {}

 
box_x = 0
box_y = 0

sel_prop = 0
prop_val = nil
prop_key = nil
newprop = ""
newPropWindow = false

sel_poly = 0
bound_poly = {}
collision_settings = {  
    cCat = 0
    ,cMask = 0
    ,cGroup = 0
  }
physical_properties = {
    mass = 0
    ,linear_d = 0
    ,angular_d = 0
    ,bodytype = 0
    ,bullet = false
    ,bodytype = 1
  }
asset_properties = {
  }

function addAsset(filename)
  if assetlist[filename] ~= nil then return end
  assetlist[filename] = {
      bound_poly = {}
      ,collision_settings = {
            cCat = 0
          ,cMask = 0
          ,cGroup = 0}
      ,physical_properties = {
          mass = 0
          ,linear_d = 0
          ,angular_d = 0
          ,bodytype = 0
          ,bullet = false
          ,bodytype = 1
        }
      ,asset_properties = {
      }
    }
end
function removeAsset(filename)
  local al = {}
  for key, value in #assetlist do
    if key ~= filename then
      al[key] = value
    end
  end
  assetlist = al
end
function switchAsset(old_filename, new_filename)
  if old_filename ~= nil and old_filename ~= "" and assetlist[old_filename] ~= nil then    
    assetlist[old_filename].bound_poly = bound_poly
    assetlist[old_filename].collision_settings = collision_settings
    assetlist[old_filename].physical_properties = physical_properties
    assetlist[old_filename].asset_properties = asset_properties
  end
  
  if assetlist[new_filename] == nil then
    addAsset(new_filename)
  end
  bound_poly = assetlist[new_filename].bound_poly
  collision_settings = assetlist[new_filename].collision_settings
  physical_properties = assetlist[new_filename].physical_properties
  asset_properties = assetlist[new_filename].asset_properties
  
  -- Update globals that might need it
  sel_poly = 0
  sel_prop = 0
  prop_val = nil
  prop_key = nil
end

function newPoint(x, y)
  table.insert(bound_poly, {x = x, y = y})
end

function removePoint(id)
  table.remove(bound_poly, id)
  if sel_poly > #bound_poly then
    sel_poly = #bound_poly
  end
end

image_file = ""
img = nil

function love.load()

end

function love.update(dt)
end

function love.draw()
  imgui.NewFrame()

  wndAssets(5, 5)
  wndImage(261, 5)  
  

  
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
  
  wndCollisions(5, 530)
  wndPhysics(1330, 5)
  wndProperties(1330, 275)
  
  if newPropWindow then
    imgui.SetNextWindowPos(love.graphics.getWidth() / 2 - 128, love.graphics.getHeight() / 2 - 64, "New Property")
    imgui.SetNextWindowSize(256, 128, "New Property")
    status, physicsWindow = imgui.Begin("New Property", true, {"NoCollapse", "TitleBar", "ShowBorders", "NoResize", "NoMove"})
    imgui.PushItemWidth(80)
    status, newprop = imgui.InputText("Property Name", newprop, 255)
    if imgui.Button("Ok") then
      newPropWindow = false
      if asset_properties[newprop] == nil then
        asset_properties[newprop] = ""
      end
    end
    imgui.End()
  end 
  
  imgui.Render();

end


function love.quit()
  imgui.ShutDown();
end

-- Save Function
-- Builds a .lua file from the points stored in the
-- bound_poly, physics_settings and asset_properties arrays.

function buildAssetsCatalog()

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
        switchAsset(image_file, file)
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

  status, collision_settings.cCat = imgui.InputInt("Category", collision_settings.cCat, 0, 16)
  status, collision_settings.cMask = imgui.InputInt("Mask", collision_settings.cMask, 0, 16)
  status, collision_settings.cGroup = imgui.InputInt("Group", collision_settings.cGroup, 0, 16)

  imgui.End()

end

function wndPhysics(x, y)
  
  imgui.SetNextWindowPos(x, y, "Physical Properties")
  imgui.SetNextWindowSize(512, 256, "Physical Properties")
  status, physicsWindow = imgui.Begin("Physical Properties", true, {"NoCollapse", "TitleBar", "ShowBorders", "NoResize", "AlwaysVerticalScrollbar"})
  status, physical_properties.bullet = imgui.Checkbox("'Bullet' Physics", physical_properties.bullet)
  status, physical_properties.mass = imgui.SliderFloat("Mass", physical_properties.mass, 0, 1000, "%.3f") 
  status, physical_properties.angular_d = imgui.SliderFloat("Angular Damping", physical_properties.angular_d, 0, 0.1, "%.3f") 
  status, physical_properties.linear_d = imgui.SliderFloat("Linear Damping", physical_properties.linear_d, 0, 0.1, "%.3f") 
  status, physical_properties.bodytype = imgui.Combo("Body Type", physical_properties.bodytype, {"Static", "Dynamic"}, 2)
  imgui.End()
  
end

function wndProperties(x, y)
  
  imgui.SetNextWindowPos(x, y, "Asset Properties")
  imgui.SetNextWindowSize(512, 256, "Asset Properties")
  status, physicsWindow = imgui.Begin("Asset Properties", true, {"NoCollapse", "TitleBar", "ShowBorders", "NoResize", "AlwaysVerticalScrollbar"})
  imgui.Text("Key / Value") imgui.SameLine()
  
  if imgui.Button("New Property") then
    newPropWindow = true
    newprop = ""
  end
  
  local i = 1
  for key, value in pairs(asset_properties) do
    imgui.Text(key .. " = ") imgui.SameLine()
    if sel_prop == i then
      prop_val = value
      prop_key = key
      status, prop_val = imgui.InputText("", prop_val, 255)
      imgui.SameLine()
      if status then
        asset_properties[prop_key] = prop_val
      end
      if imgui.Button("Remove") then
        asset_properties[prop_key] = nil
        prop_val = nil
        sel_prop = 0
      end
    else
      if imgui.Selectable(value)then
        sel_prop = i
      end
    end
    i = i + 1
  end
  imgui.End()
  
end

function wndImage(x, y)
  if img == nil then return end
  imgui.SetNextWindowPos(x, y, "Images")
  imgui.SetNextWindowSize(img:getWidth() + 15, img:getHeight() + 40, "Images")
  status, showAnotherWindow = imgui.Begin("Image: sunrise_rock1.png", false, { "NoCollapse", "TitleBar", "ShowBorders", "NoResize", "AlwaysVerticalScrollbar" })

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