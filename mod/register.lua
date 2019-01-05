--
-- Mod: FrontLoaderCam_Register
--
-- Author: Stephan
-- email: Stephan910@web.de
-- @Date: 03.01.2019
-- @Version: 1.0.0 

-- #############################################################################

source(Utils.getFilename("FrontLoaderCam.lua", g_currentModDirectory))


FrontLoaderCam_Register = {};
FrontLoaderCam_Register.modDirectory = g_currentModDirectory;

local modDesc = loadXMLFile("modDesc", g_currentModDirectory .. "modDesc.xml");
FrontLoaderCam_Register.version = getXMLString(modDesc, "modDesc.version");

if g_specializationManager:getSpecializationByName("FrontLoaderCam") == nil then
  if FrontLoaderCam == nil then 
    print("ERROR: unable to add specialization 'FrontLoaderCam'")
  else 
    for i, typeDef in pairs(g_vehicleTypeManager.vehicleTypes) do
      if typeDef ~= nil and i ~= "locomotive" then 
        local isDrivable  = false
        local isEnterable = false
        local hasMotor    = false 
        for name, spec in pairs(typeDef.specializationsByName) do
          if name == "drivable"  then 
            isDrivable = true 
          elseif name == "motorized" then 
            hasMotor = true 
          elseif name == "enterable" then 
            isEnterable = true 
          end 
        end 
        if isDrivable and isEnterable and hasMotor then 
          print("INFO: attached specialization 'FrontLoaderCam' to vehicleType '" .. tostring(i) .. "'")
          typeDef.specializationsByName["FrontLoaderCam"] = FrontLoaderCam
          table.insert(typeDef.specializationNames, "FrontLoaderCam")
          table.insert(typeDef.specializations, FrontLoaderCam)  
        end 
      end 
    end   
  end 
end 

function FrontLoaderCam_Register:loadMap(name)
	print("--> loaded FrontLoaderCam version " .. self.version .. " (by Stephan) <--");

end;

function FrontLoaderCam_Register:deleteMap()
  
end;

function FrontLoaderCam_Register:keyEvent(unicode, sym, modifier, isDown)

end;

function FrontLoaderCam_Register:mouseEvent(posX, posY, isDown, isUp, button)

end;

function FrontLoaderCam_Register:update(dt)
	
end;

function FrontLoaderCam_Register:draw()
  
end;

addModEventListener(FrontLoaderCam_Register);