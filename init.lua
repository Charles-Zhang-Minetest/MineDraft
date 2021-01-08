-- Read the file
function ProcessDraftFile(path, origin, direction)
  -- Create some variables
  local blockTypes = {}
  local z = 0 -- Row as z
  -- Book Keeping
  local keeped = 0
  local removed = 0
  local updated = 0
  -- Start parsing
  for line in io.lines(path) do
    -- Check if it's a definition line
    if line:sub(0,2) == "--" then
      local _,_,key,value = line:find("^%-%-(%S+)%s+(%S+)%s*$")
      blockTypes[key] = value
    -- Handle normal lines
    else 
      local x = 0 -- Column as x
      for letter in line:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        local loc = {x=origin.x+x*direction.x, y=origin.y, z=origin.z+z*direction.z*(-1)}
        -- Debug Print
        print("Letter: "..letter..", Block: "..blockTypes[letter])
        -- Update node
        if blockTypes[letter] == "keep" then
          keeped = keeped + 1
        elseif blockTypes[letter] == "remove" then
          minetest.remove_node(loc)
          removed = removed + 1
        else
          minetest.set_node(loc, {name=blockTypes[letter]})
          updated = updated + 1
        end
        -- Increment x
        x = x + 1
      end
    end
    -- Increment z
    z = z + 1
  end
end

minetest.register_chatcommand("draft", {
    func = function(name, params)
      -- Handle missing parameter
      if params == nil or params:len() == 0 then
        print("/draft dx dz vx vz draftName: Draft a given draftName (without filename suffix) with offset dx and dz; Direction (of vx and vz) must be either 1 or -1.")
        return
      end
      
      -- Get player location
      local pos = minetest.get_player_by_name(name):getpos()
      pos.y = math.floor(pos.y)
      -- Parse parameters
      local basePath = minetest.get_modpath("minedraft")
      local _,_,dx,dz,vx,vz,draftName = params:find("^([+-]?%d+)%s+([+-]?%d+)%s+([+-]?%d+)%s+([+-]?%d+)%s+([+-]?%S+)%s*$")
      local filePath = basePath.."/drafts/"..draftName..".txt"
      -- Debug Print
      print(filePath)
      -- Adjust position
      pos.x = pos.x + dx
      pos.z = pos.z + dz
      -- Start drafting
      local direction = {x=vx, z=vz}
      ProcessDraftFile(filePath, pos, direction)
    end
})