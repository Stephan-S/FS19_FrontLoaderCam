





FrontLoaderCam = {};
FrontLoaderCam = {};
FrontLoaderCam.Version = "1.0.0";
FrontLoaderCam.config_changed = false;
FrontLoaderCam.actions             = { 'FrontLoaderCam_Toggle', 'FrontLoaderCam_MoveCam'}
FrontLoaderCam.ViewActions             = { 'AXIS_LOOK_UPDOWN_VEHICLE', 'AXIS_LOOK_LEFTRIGHT_VEHICLE', 'AXIS_MOVE_FORWARD_PLAYER'}


FrontLoaderCam.directory = g_currentModDirectory;


function FrontLoaderCam:prerequisitesPresent(specializations)
    return true;
end;

function FrontLoaderCam:delete()	

end;

function FrontLoaderCam:loadMap(name)
	print("FrontLoaderCam load map");	
	
	if g_currentMission.FrontLoaderCam_printedDebug ~= true then
		--DebugUtil.printTableRecursively(g_currentMission, "	:	",0,2);
		print("Map title: " .. g_currentMission.missionInfo.map.title);
		if g_currentMission.missionInfo.savegameDirectory ~= nil then 
			print("Savegame location: " .. g_currentMission.missionInfo.savegameDirectory);
		else
			if g_currentMission.missionInfo.savegameIndex ~= nil then
				print("Savegame location via index: " .. getUserProfileAppPath() .. "savegame" .. g_currentMission.missionInfo.savegameIndex);
			else
				print("No savegame located");
			end;
		end;
		
		g_currentMission.FrontLoaderCam_printedDebug = true;
	end;
	
	self.loadedMap = g_currentMission.missionInfo.map.title;
	self.loadedMap = string.gsub(self.loadedMap, " ", "_");
	self.loadedMap = string.gsub(self.loadedMap, "%.", "_");
	g_currentMission.autoLoadedMap = self.loadedMap;
	
	print("map " .. self.loadedMap .. " was loaded");
end;

function FrontLoaderCam.registerEventListeners(vehicleType)
  print("-> registerEventListeners ")
    
  for _,n in pairs( { "onUpdate", "onRegisterActionEvents" } ) do
    SpecializationUtil.registerEventListener(vehicleType, n, FrontLoaderCam)
  end 
end

function FrontLoaderCam:deleteMap()	
	--print("delete map called");
end;

function FrontLoaderCam:load(xmlFile)	
end;

function FrontLoaderCam:onRegisterActionEvents(isSelected, isOnActiveVehicle)
  --print("onRegisterActionEvents - isSelected: " .. bool_to_number(isSelected) .. " isOnActiveVehicle " .. bool_to_number(isOnActiveVehicle));

  -- continue on client side only
  if not self.isClient then
    return
  end
  
  -- only in active vehicle
  if isOnActiveVehicle then
    -- we could have more than one event, so prepare a table to store them  
    if self.ActionEvents == nil then 
      self.ActionEvents = {}
    else  
      self:clearActionEventsTable( self.ActionEvents )
    end 
    
    -- attach our actions
    for _ ,actionName in pairs(FrontLoaderCam.actions) do
		--print("onRegisterActionEvents - attaching - " .. actionName);
		local __, eventName
		if isOnActiveVehicle then
			-- InputBinding.registerActionEvent(g_inputBinding, actionName, object, functionForTriggerEvent, triggerKeyUp, triggerKeyDown, triggerAlways, isActive)
			local toggleButton = false;
			if actionName == "FrontLoaderCam_MoveCam" then
				toggleButton = true;
			end;
			__, eventName = InputBinding.registerActionEvent(g_inputBinding, actionName, self, FrontLoaderCam.onActionCall, toggleButton ,true ,false ,true)
		end
		
		--print("onRegisterActionEvents - attached - " .. actionName .. " as " .. bool_to_number(eventName) .. " , " .. eventName);
	  
		if isSelected then
			g_inputBinding.events[eventName].displayPriority = 1
		elseif isOnActiveVehicle then
			g_inputBinding.events[eventName].displayPriority = 3
		end
    end
	
	for _ ,actionName in pairs(FrontLoaderCam.ViewActions) do
		--print("onRegisterActionEvents - attaching - " .. actionName);
		local __, eventName
		if isOnActiveVehicle then
			__, eventName = InputBinding.registerActionEvent(g_inputBinding, actionName, self, FrontLoaderCam.onActionCall, true ,false ,true ,true)
		end		
		--print("onRegisterActionEvents - attached - " .. actionName .. " as " .. bool_to_number(eventName) .. " , " .. eventName);	  
    end
	
  end
end

function FrontLoaderCam:onActionCall(actionName, keyStatus, arg4, arg5, arg6)
	--print("-> onActionCall " .. actionName)
	if self.lastInputValues == nil then
		self.lastInputValues = {};		
		self.lastInputValues.upDown = 0;
		self.lastInputValues.leftRight = 0;
		self.movingCam = false;
		self.frontLoaderCamOffsetY = 0;
	end;

	-- front diff
	if actionName == "FrontLoaderCam_Toggle" then
		--print("FLCam input detected");
		if self.ad.cam == false then				
			--print("FLCam set to active");
			self.ad.cam = true;
			self.storedCam = getCamera();
			
			--local _, actionEventId1 = g_inputBinding:registerActionEvent(InputAction.AXIS_LOOK_UPDOWN_VEHICLE, self, FrontLoaderCam.lookUpDown, false, false, true, true, nil)
			--local _, actionEventId2 = g_inputBinding:registerActionEvent(InputAction.AXIS_LOOK_LEFTRIGHT_VEHICLE, self, FrontLoaderCam.lookLeftRight, false, false, true, true, nil)
			--g_inputBinding:setActionEventTextVisibility(actionEventId1, false)
			--g_inputBinding:setActionEventTextVisibility(actionEventId2, false)			
		else
			self.ad.cam = false;
			self.restoreLastCam = true;			
		end;
	elseif actionName == "FrontLoaderCam_MoveCam" then
		self.movingCam = not self.movingCam;	
	elseif actionName == "AXIS_LOOK_UPDOWN_VEHICLE" then		
		if self.ad.cam == true then
			self.lastInputValues.upDown = keyStatus;
			--print("-> onActionCall " .. actionName .. " detected " .. bool_to_number(keyStatus) .. " / " .. keyStatus .. " , " .. bool_to_number(arg4) .. " , " .. bool_to_number(arg5) .. " , " .. bool_to_number(arg6));
		end;
	elseif actionName == "AXIS_LOOK_LEFTRIGHT_VEHICLE" then		
		if self.ad.cam == true then
			self.lastInputValues.leftRight = keyStatus;
			--print("-> onActionCall " .. actionName .. " detected " .. bool_to_number(keyStatus) .. " / " .. keyStatus .. " , " .. bool_to_number(arg4) .. " , " .. bool_to_number(arg5) .. " , " .. bool_to_number(arg6));
		end;
	elseif actionName == "AXIS_MOVE_FORWARD_PLAYER" then		
		if self.ad.cam == true then
			self.lastInputValues.translateUpDown = keyStatus;
		end;
	end;
end

function FrontLoaderCam:onLeave()
end;

function init(self)
	print("FrontLoaderCam init");
	
	self.lastInputValues =  {};
	self.lastInputValues.upDown = 0;
	self.lastInputValues.leftRight = 0;
	self.movingCam = false;
	self.frontLoaderCamOffsetY = 0;
	
	--for i=1, 2 do
       -- if self.cameras[i].isInside then    
		--	self.internalCamera = Utils.indexToObject(self.components, self.camIndex);				
		--end;
	--end;
	
	self.bDisplay = 1; 
	if self.ad == nil then
		self.ad = {};
	end;

	self.storedCam = getCamera();
	self.restoreLastCam = false;
	
	self.moduleInitialized = true;
	self.currentInput = "";

	--if self.frontloaderAttacher ~= nil or self.typeDesc == "telehandler" then
		if self.frontLoaderCam == nil then
		
			print("FrontLoaderCam init - create cam");
			--DebugUtil.printTableRecursively(self, " . " , 0, 3);
			
			--DebugUtil.printTableRecursively(self:getAttacherJoints() , " . " , 0, 1); --vehicleType.specializationsByName.attacherJoints.
			
			
			self.frontLoaderCam = createCamera("frontLoaderCam",  30, 0.2, 200);
			local node = self.components[1].node
			local nodeTool = nil;
			
			local attachedImplements
			if self.getAttachedImplements ~= nil then
				attachedImplements = self:getAttachedImplements()
			end
			if attachedImplements ~= nil then
				for _, implement in pairs(attachedImplements) do
					if implement.object ~= nil then
						print("FrontLoaderCam init - found implement: " .. implement.object.typeName);
							if implement.object.typeName == "attachableFrontloader" then
								print("Selected frontloader attachment as root node");
								local attacherJoints = implement.object:getAttacherJoints();
								
								if attacherJoints ~= nil then
								
									print("Selected frontloader attachment[1] as root node");
									nodeTool = attacherJoints[1].jointTransform; --implement.object.attacherJoints[1].jointTransform;
								end;
							end;
					end;
				end;
			end;
			
			if self.typeDesc == "telehandler" then
				nodeTool = self.attacherJoints[1].jointTransform;
			end;
			if nodeTool == nil then
				nodeTool = node;
			end;

			link(node, self.frontLoaderCam);
			rotate(self.frontLoaderCam,0,math.pi*0.84,math.pi);

			local xW,yW,zW = getWorldTranslation(node);
			local xTool,yTool,zTool = getWorldTranslation(nodeTool);
			local xCam,yCam,zCam = getWorldTranslation(self.frontLoaderCam);

			self.frontLoaderCamOffsetX = -0.9; --self.sizeWidth/2 - 0.8;
			self.frontLoaderCamOffsetZ = -0.4; --self.sizeLength/2 - 1.0; -- -1.0
			
			local x,y,z = worldToLocal(node,xTool+self.frontLoaderCamOffsetX,yTool+0.75,zTool+self.frontLoaderCamOffsetZ) --+self.ad.frontLoaderCamShift
			setTranslation(self.frontLoaderCam,x,y,z);
			--rotate(self.frontLoaderCam,self.ad.frontLoaderCamShiftAngle ,-self.ad.frontLoaderCamShiftSide,0);
			--setCamera(self.frontLoaderCam);
			self.ad.cam = false;
			
			print("x: " .. x .. " y: " .. y .. " z: " .. z);
			print("xCam: " .. xCam .. " yCam: " .. yCam .. " zCam: " .. zCam);
			print("frontLoaderCamOffsetX: " .. self.frontLoaderCamOffsetX .. " frontLoaderCamOffsetZ: " .. self.frontLoaderCamOffsetZ);
				
		end;
	--end;
	
	self.trafficVehicle = nil;
end;

function FrontLoaderCam:newMouseEvent(superFunc,posX, posY, isDown, isUp, button)
end;

function FrontLoaderCam:mouseEvent(posX, posY, isDown, isUp, button)	
end; 

function FrontLoaderCam:keyEvent(unicode, sym, modifier, isDown) 	
end; 

function FrontLoaderCam:onUpdate(dt)
	--print("FLCam onUpdate called");
	if self.moduleInitialized == nil then
		init(self);
	end;	

	if self.currentInput ~= "" and self.isServer then
		--print("I am the server and start input handling. lets see if they think so too");
		FrontLoaderCam:InputHandling(self, self.currentInput);
	end;	
	
	--DebugUtil.drawDebugNode(self.frontLoaderCam, "self.frontLoaderCam");
	--DebugUtil.drawDebugNode(self.components[1].node, "node");
	
	if self == g_currentMission.controlledVehicle then
		if self.frontLoaderCam ~= nil then		
			if self.ad.cam == true then			
				--print("FLCam onUpdater called - self.ad.cam == true");
				local node = self.components[1].node --self.frontloaderAttacher.attacherJoint.rootNode;
				local nodeTool = node;
				
				local attachedImplements
				if self.getAttachedImplements ~= nil then
					attachedImplements = self:getAttachedImplements()
				end
				if attachedImplements ~= nil then
					for _, implement in pairs(attachedImplements) do
						if implement.object ~= nil then
							--print("FrontLoaderCam update - found implement: " .. implement.object.typeName);
							if implement.object.typeName == "attachableFrontloader" then
								--print("Selected frontloader attachment as root node");
								local attacherJoints = implement.object:getAttacherJoints();
								
								if attacherJoints ~= nil then								
									--print("Selected frontloader attachment[1] as root node");
									nodeTool = attacherJoints[1].jointTransform; --implement.object.attacherJoints[1].jointTransform;
								end;
							end;
						end;
					end;
				end;
				if self.typeDesc == "telehandler" then
					nodeTool = self.attacherJoints[1].jointTransform;
				end;
				
				local xW,yW,zW = getWorldTranslation(node);
				local xTool,yTool,zTool = getWorldTranslation(node);
				local xCam,yCam,zCam = getWorldTranslation(self.frontLoaderCam);
				
				if nodeTool == nil then
					print("nodeTool == nil");
					nodeTool = node;
					self.frontLoaderCamOffsetX = self.sizeWidth/2; -- + 0.8;
					self.frontLoaderCamOffsetZ = self.sizeLength/2 + 1.0; -- -1.0
				else
					xTool,yTool,zTool = getWorldTranslation(nodeTool);
				end;
				
				local x,y,z = worldToLocal(node,xTool,yTool+0,zTool)
				
				pitch, yaw, roll = getRotation(self.frontLoaderCam);
			
				if self.lastInputValues.upDown ~= 0 then
					if self.movingCam == false then
						local value = self.lastInputValues.upDown * g_gameSettings:getValue(GameSettings.SETTING.CAMERA_SENSITIVITY) * 0.075;
						--print("upDown: " .. value);
						pitch = pitch + value;
						self.lastInputValues.upDown = 0;
					else
						local value = self.lastInputValues.upDown * g_gameSettings:getValue(GameSettings.SETTING.CAMERA_SENSITIVITY) * 0.075;
						self.frontLoaderCamOffsetZ = self.frontLoaderCamOffsetZ - value;
						self.lastInputValues.upDown = 0;
					end;
				end;
				
				if self.lastInputValues.leftRight ~= 0 then
					if self.movingCam == false then
						local value = self.lastInputValues.leftRight * g_gameSettings:getValue(GameSettings.SETTING.CAMERA_SENSITIVITY) * 0.075;
						--print("leftRight: " .. value);
						yaw = yaw + value;
						self.lastInputValues.leftRight = 0;
					else
						local value = self.lastInputValues.leftRight * g_gameSettings:getValue(GameSettings.SETTING.CAMERA_SENSITIVITY) * 0.075;
						self.frontLoaderCamOffsetX = self.frontLoaderCamOffsetX - value;
						self.lastInputValues.leftRight = 0;
					end;
				end;
				
				if self.lastInputValues.translateUpDown ~= 0 then
					if self.movingCam == false then
						self.lastInputValues.translateUpDown = 0;
					else
						local value = self.lastInputValues.translateUpDown * g_gameSettings:getValue(GameSettings.SETTING.CAMERA_SENSITIVITY) * 0.075;
						self.frontLoaderCamOffsetY = self.frontLoaderCamOffsetY - value;
						self.lastInputValues.translateUpDown = 0;
					end;
				end;
				
				setTranslation(self.frontLoaderCam,x+self.frontLoaderCamOffsetX,y + self.frontLoaderCamOffsetY, z+self.frontLoaderCamOffsetZ);				
				setRotation(self.frontLoaderCam, pitch, yaw, roll);
				
				setCamera(self.frontLoaderCam);
			else
				if (self.restoreLastCam == true) then
					self.restoreLastCam = false;
					setCamera(self.storedCam);
				end;			
			end;
		end;
	end;
end;

function FrontLoaderCam:lookUpDown(actionName, keyStatus, arg4, arg5, arg6)
	print("-> onActionCall " .. actionName)
end;

function FrontLoaderCam:lookLeftRight(actionName, keyStatus, arg4, arg5, arg6)
	print("-> onActionCall " .. actionName)
end;

function createVector(x,y,z)
	local table t = {};
	t["x"] = x;
	t["y"] = y;
	t["z"] = z;
	return t; 
end;

function getDistance(x1,z1,x2,z2)
	return math.sqrt((x1-x2)*(x1-x2) + (z1-z2)*(z1-z2) );
end;

function FrontLoaderCam:draw()
end; 

function round(num, idp) 
	if Utils.getNoNil(num, 0) > 0 then 
		local mult = 10^(idp or 0); 
		return math.floor(num * mult + 0.5) / mult; 
	else 
		return 0; 
	end; 
end; 

function getPercentage(capacity, level) 
	return level / capacity * 100; 
end;

function FrontLoaderCam:angleBetween(vec1, vec2)

	local scalarproduct_top = vec1.x * vec2.x + vec1.z * vec2.z;
	local scalarproduct_down = math.sqrt(vec1.x * vec1.x + vec1.z*vec1.z) * math.sqrt(vec2.x * vec2.x + vec2.z*vec2.z)
	local scalarproduct = scalarproduct_top / scalarproduct_down;

	return math.deg(math.acos(scalarproduct));
end

function mySelf(obj)
  return " (rootNode: " .. obj.rootNode .. ", typeName: " .. obj.typeName .. ", typeDesc: " .. obj.typeDesc .. ")"
end

function bool_to_number(value)
  return value and 1 or 0
end

addModEventListener(FrontLoaderCam);
