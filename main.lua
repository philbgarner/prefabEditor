require "imgui"
require "imgui"
require "table_io"
require "prefabs_io"
anim8 = require "anim8"

--require os

assetlist = {}

 
box_x = 0
box_y = 0

sel_prop = 0
prop_val = nil
prop_key = nil
newprop = ""
newPropWindow = false

image_file = ""
img = nil
anim = nil

savePackWindow = false
savePackFilename = "assetpack"

sel_poly = 0

-- Save assets.list
function saveAssets()
  --table.save(assetlist , "assets/assets.list")
  writeAssetList()
end

-- Load assets.list
function loadAssets()
  --assetlist = table.load("assets/assets.list")  
  loadAssetList()
  image_file = ""
  sel_poly = 0
  sel_prop = 0
  prop_val = nil
  prop_key = nil
end

-- Export Pack by bunding images and assets.list from the assets subfolder into
-- a zip file.

function exportAssets(file)
  love.filesystem.remove(file)
  os.execute("7z a " .. file .. ".zip ./assets/*")
end

function addAsset(filename)
  if assetlist[filename] ~= nil then return end
  local im = love.graphics.newImage("assets/" .. filename)
  local w = im:getWidth()
  local h = im:getHeight()
  assetlist[filename] = {
      bound_poly = {}
      ,collision_settings = {
            cCat = 0
          ,cMask = 0
          ,cGroup = 0
          ,radius = 10
        }
      ,physical_properties = {
          mass = 0
          ,linear_d = 0
          ,angular_d = 0
          ,bodytype = 0
          ,bullet = false
          ,bodytype = 1
        }
      ,asset_properties = {
          animated = false
          ,animation_gridx = "1-1"
          ,animation_gridy = "1-1"
          ,animation_delay = 0.1
          ,animation_w = w
          ,animation_h = h
        }
    }
end
function removeAsset(filename)
  local al = {}
  for key, value in pairs(assetlist) do
    if key ~= filename then
      al[key] = value
    end
  end
  assetlist = al
end
function switchAsset(new_filename)
  
  if assetlist[new_filename] == nil then
    addAsset(new_filename)
  end
  
  local im = love.graphics.newImage("assets/" .. new_filename)
  
  -- Update globals that might need it
  sel_poly = 0
  sel_prop = 0
  prop_val = nil
  prop_key = nil
end

function newPoint(x, y)
  table.insert(assetlist[image_file].bound_poly, {x = x, y = y})
end

function removePoint(id)
  table.remove(assetlist[image_file].bound_poly, id)
end

function love.load()
  
  
end

function love.update(dt)
  
  if anim ~= nil then
    anim:update(dt)
  end
  
end

function love.draw()
  imgui.NewFrame()

    -- Menu
    if imgui.BeginMainMenuBar() then
        if imgui.BeginMenu("File") then
            if imgui.MenuItem("Save assets.list") then
              saveAssets()
            end
            if imgui.MenuItem("Load assets.list") then 
              loadAssets()
            end
            if imgui.MenuItem("Export") then
              saveAssets()
              savePackWindow = true
            end
            if imgui.MenuItem("Exit") then love.quit() end
            imgui.EndMenu()
        end
        imgui.EndMainMenuBar()
    end
    
  wndAssets(5, 25)
  wndImage(261, 25)  
  
  wndCollisions(5, 530)
  wndPhysics(1330, 25)
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
  
  if savePackWindow then
    imgui.SetNextWindowPos(love.graphics.getWidth() / 2 - 128, love.graphics.getHeight() / 2 - 64, "New Property")
    imgui.SetNextWindowSize(256, 128, "Export Pack")
    status, exportWindow = imgui.Begin("Export Pack", true, {"NoCollapse", "TitleBar", "ShowBorders", "NoResize", "NoMove"})
    imgui.PushItemWidth(80)
    status, savePackFilename = imgui.InputText("Filename", savePackFilename, 255)
    if imgui.Button("Ok") then
      exportAssets(savePackFilename)
      
      savePackWindow = false
    end
    imgui.End()
  end 
  
  imgui.Render();
  if assetlist[image_file] == nil then return end
  if anim ~= nil then anim:draw(img, 270, 50) end

  if #assetlist[image_file].bound_poly > 2 or (assetlist[image_file].physical_properties.bodytype == 2 and #assetlist[image_file].bound_poly == 1) then
    love.graphics.setLineWidth(2)
    love.graphics.setColor(0, 0, 0)
    
    anim_w = tonumber(assetlist[image_file].asset_properties.animation_w)
    anim_h = tonumber(assetlist[image_file].asset_properties.animation_h)
    
    if anim_w == nil then anim_w = 0 end
    if anim_h == nil then anim_h = 0 end
    
    if assetlist[image_file].physical_properties.bodytype == 1 then -- Static body.
      local pol = {}
      for i=1, #assetlist[image_file].bound_poly do
        table.insert(pol, (assetlist[image_file].bound_poly[i].x * img:getWidth()) + 270 )
        table.insert(pol, (assetlist[image_file].bound_poly[i].y * img:getHeight()) + 50)
      end
      love.graphics.line(pol)
      love.graphics.setColor(255, 255, 255)
      love.graphics.push()
        love.graphics.translate(1, 1)
        love.graphics.line(pol)
      --love.graphics.rectangle("line", 261 + 8 + dx, 32 + dy, dw, dh)
      love.graphics.pop()
      if sel_poly ~= nil and assetlist[image_file].bound_poly[sel_poly] ~= nil then 
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("line", (assetlist[image_file].bound_poly[sel_poly].x * anim_w) + 270 , (assetlist[image_file].bound_poly[sel_poly].y * anim_h) + 50, 4)
        love.graphics.setColor(255, 255, 255)
        love.graphics.push()
          love.graphics.translate(1, 1)
          love.graphics.line(pol)
          love.graphics.setColor(255, 255, 0)
          love.graphics.circle("line", (assetlist[image_file].bound_poly[sel_poly].x * anim_w) + 270 , (assetlist[image_file].bound_poly[sel_poly].y * anim_h) + 50, 4)
        love.graphics.pop()
      end
      love.graphics.setColor(255, 255, 255)
    elseif assetlist[image_file].physical_properties.bodytype == 2 then  -- Dynamic Body
      love.graphics.setColor(255, 255, 255)
      love.graphics.circle("line", (assetlist[image_file].bound_poly[1].x * anim_w) + 270, (assetlist[image_file].bound_poly[1].y * anim_h) + 50, assetlist[image_file].collision_settings.radius)
      love.graphics.push()
        love.graphics.translate(1, 1)
        love.graphics.circle("line", (assetlist[image_file].bound_poly[1].x * anim_w) + 270, (assetlist[image_file].bound_poly[1].y * anim_h) + 50, assetlist[image_file].collision_settings.radius)
      love.graphics.pop()
    end
    love.graphics.setLineWidth(1)
  end
  
end


function love.quit()
  imgui.ShutDown();
end

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
        switchAsset(file)
        img = love.graphics.newImage("assets/" .. image_file)
        --print(assetlist, image_file, assetlist[image_file])
        local g = anim8.newGrid(tonumber(assetlist[image_file].asset_properties.animation_w), tonumber(assetlist[image_file].asset_properties.animation_h), img:getWidth(), img:getHeight())
        anim = anim8.newAnimation(g(assetlist[image_file].asset_properties.animation_gridx, assetlist[image_file].asset_properties.animation_gridy), tonumber(assetlist[image_file].asset_properties.animation_delay))
      end
    end
  end

  imgui.End()
end

function wndCollisions(x, y)
  if assetlist[image_file] == nil then return end
  
  anim_w = tonumber(assetlist[image_file].asset_properties.animation_w)
  anim_h = tonumber(assetlist[image_file].asset_properties.animation_h)
  
  if anim_w == nil then anim_w = 0 end
  if anim_h == nil then anim_h = 0 end
  
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
  for i=1, #assetlist[image_file].bound_poly do
    local s = false
    if i == sel_poly then
      s = true
    end
    if imgui.Selectable("#" .. i .. " (" .. string.format("%.3f", assetlist[image_file].bound_poly[i].x) .. ", " .. string.format("%.3f", assetlist[image_file].bound_poly[i].y) .. ")", s) then
      box_x = assetlist[image_file].bound_poly[i].x
      box_y = assetlist[image_file].bound_poly[i].y
      sel_poly = i
    end
  end
  
  imgui.Separator()

  status, box_x = imgui.SliderFloat("x", box_x, 0, 1, "%.3f", 1) 
  status, box_y = imgui.SliderFloat("y", box_y, 0, 1, "%.3f", 1)
  if assetlist[image_file].physical_properties.bodytype == 2 then
    status, assetlist[image_file].collision_settings.radius = imgui.SliderFloat("radius", tonumber(assetlist[image_file].collision_settings.radius), 0, anim_w, "%.3f", 1)
  end

  if sel_poly > 0 and sel_poly <= #assetlist[image_file].bound_poly then
    assetlist[image_file].bound_poly[sel_poly].x = box_x
    assetlist[image_file].bound_poly[sel_poly].y = box_y
  end
  
  imgui.Separator()

  imgui.Text("Collision Groups")

  status, assetlist[image_file].collision_settings.cCat = imgui.InputInt("Category", assetlist[image_file].collision_settings.cCat, 0, 16)
  status, assetlist[image_file].collision_settings.cMask = imgui.InputInt("Mask", assetlist[image_file].collision_settings.cMask, 0, 16)
  status, assetlist[image_file].collision_settings.cGroup = imgui.InputInt("Group", assetlist[image_file].collision_settings.cGroup, 0, 16)

  imgui.End()

end

function wndPhysics(x, y)
  if assetlist[image_file] == nil then return end
  
  imgui.SetNextWindowPos(x, y, "Physical Properties")
  imgui.SetNextWindowSize(512, 256, "Physical Properties")
  status, physicsWindow = imgui.Begin("Physical Properties", true, {"NoCollapse", "TitleBar", "ShowBorders", "NoResize", "AlwaysVerticalScrollbar"})
  status, assetlist[image_file].physical_properties.bullet = imgui.Checkbox("'Bullet' Physics", assetlist[image_file].physical_properties.bullet)
  status, assetlist[image_file].physical_properties.mass = imgui.SliderFloat("Mass", assetlist[image_file].physical_properties.mass, 0, 1000, "%.3f") 
  status, assetlist[image_file].physical_properties.angular_d = imgui.SliderFloat("Angular Damping", assetlist[image_file].physical_properties.angular_d, 0, 0.1, "%.3f") 
  status, assetlist[image_file].physical_properties.linear_d = imgui.SliderFloat("Linear Damping", assetlist[image_file].physical_properties.linear_d, 0, 0.1, "%.3f") 
  status, assetlist[image_file].physical_properties.bodytype = imgui.Combo("Body Type", assetlist[image_file].physical_properties.bodytype, {"Static", "Dynamic"}, 2)
  imgui.End()
  
end

function wndProperties(x, y)
  if assetlist[image_file] == nil then return end
  
  imgui.SetNextWindowPos(x, y, "Asset Properties")
  imgui.SetNextWindowSize(512, 256, "Asset Properties")
  status, physicsWindow = imgui.Begin("Asset Properties", true, {"NoCollapse", "TitleBar", "ShowBorders", "NoResize", "AlwaysVerticalScrollbar", "AlwaysHorizontalScrollbar"})
  imgui.Text("Key / Value") imgui.SameLine()
  
  if imgui.Button("New Property") then
    newPropWindow = true
    newprop = ""
  end
  
  local i = 1
  for key, value in pairs(assetlist[image_file].asset_properties) do
    imgui.Text(key .. " = ") imgui.SameLine()
    if sel_prop == i then
      prop_val = value
      prop_key = key
      status, prop_val = imgui.InputText("", tostring(prop_val), 255)
      imgui.SameLine()
      if status then
        assetlist[image_file].asset_properties[prop_key] = tostring(prop_val)
      end
      if imgui.Button("Remove") then
        assetlist[image_file].asset_properties[prop_key] = nil
        prop_val = nil
        sel_prop = 0
      end
    else
      if imgui.Selectable(tostring(value)) then
        sel_prop = i
      end
    end
    i = i + 1
  end
  imgui.Separator()
  imgui.End()
  
end

function wndImage(x, y)
  if img == nil then return end
  imgui.SetNextWindowPos(x, y, "Images")
  imgui.SetNextWindowSize(img:getWidth() + 15, img:getHeight() + 40, "Images")
  status, showAnotherWindow = imgui.Begin("Image: sunrise_rock1.png", false, { "NoCollapse", "TitleBar", "ShowBorders", "NoResize", "AlwaysVerticalScrollbar" })

--  imgui.Image(img, img:getWidth(), img:getHeight())

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