-- Made by AlgyLacey, please do not use elsewhere. :)
local RS = game:GetService("RunService")
local Player = game.Players.LocalPlayer
local Cam = workspace.CurrentCamera

local MaxRange = 100 -- Only scans for objects within this radius
local LastCalcCharPos = Vector3.new(0,-90000,0)

local Objects = {}
local CurrentClosest = nil
local NumClosest = 0


local function SortToClosest()
	local MyPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.HumanoidRootPart.Position
	if not MyPos then return end
	
	-- Setup new start for CurrentClosest
	local Start = {Distance = 0, Next = nil}
	local Num = 0
	
	-- Sort the objects into the closest list
	for i,Obj in pairs (Objects) do
		local dist = (Obj.Position  - MyPos).magnitude 
		if dist < MaxRange then
			local Stop;
			local ListObj = Start
			local PreviousListObj = Start
			Num = Num + 1
			repeat
				if not ListObj or ListObj.Distance > dist then
					PreviousListObj.Next = {Distance = dist, Next = ListObj, Proximity = Obj}
					Stop = true
				else
					PreviousListObj = ListObj
					ListObj = ListObj.Next
				end
			until Stop
			if Num%100 == 1 then
				wait()
			end
		end
	end
	CurrentClosest = Start.Next
	NumClosest = Num
	LastCalcCharPos = MyPos
end



RS.Heartbeat:Connect(function()
	local MyPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.HumanoidRootPart.Position
	if not MyPos then return end
	
	local Current = CurrentClosest
	

	for i=1, NumClosest do
		local dist = (Current.Proximity.Position - MyPos).magnitude
		if dist < Current.Proximity.Distance and not Current.Proximity.IsWithinRange then
			if Current.Proximity.MustBeVisible then
				local _, Visible = Cam:WorldToScreenPoint(Current.Proximity.Position)
				if Visible then
					coroutine.wrap(Current.Proximity.InsideRange)(Current.Proximity.Object)
					Current.Proximity.IsWithinRange = true					
				end
			else
				coroutine.wrap(Current.Proximity.InsideRange)(Current.Proximity.Object)
				Current.Proximity.IsWithinRange = true
			end
		elseif dist > Current.Proximity.Distance and Current.Proximity.IsWithinRange then
			coroutine.wrap(Current.Proximity.OutsideRange)(Current.Proximity.Object)
			Current.Proximity.IsWithinRange = false			
		end
		if Current.Next then
			Current = Current.Next
		else
			break
		end
	end
	if (MyPos - LastCalcCharPos).magnitude > MaxRange*0.5 then
		--print((MyPos - LastCalcCharPos).magnitude)
		SortToClosest()
	end
end)

local function RemoveObject(ProxObj)
	local Current = CurrentClosest
	local Prev = nil
	if Current then
		repeat
			if Current.Proximity == ProxObj then
				if Prev then
					Prev.Next = Current.Next -- Link the gap
				else
					CurrentClosest = Current.Next -- First one, so set the start to the 2nd in the list
				end
				break
			end
			Prev = Current
			Current = Current.Next
		until not Current
	end
	for i,v in pairs (Objects) do
		if v == ProxObj then
			table.remove(Objects, i)
		end
	end
end

game.ReplicatedStorage.Events.BindableEvents.RemoveProximity.Event:Connect(function(EventName)
	if EventName ~= nil then
		for i,v in pairs (Objects) do
			if v.Name == EventName then
				RemoveObject(v)
			end
		end
	end
end)

game.ReplicatedStorage.Events.BindableEvents.Proximity.Event:Connect(function(Obj, Dist, BeVisible, InsRange, OutRange, EventName)
	if EventName ~= nil then
		for i,v in pairs (Objects) do
			if v.Name == EventName then
				RemoveObject(v)
			end
		end
	end
	table.insert(Objects, {Name = EventName, Object = Obj, MustBeVisible = BeVisible, Position = Obj.Position, Distance = Dist, InsideRange = InsRange, OutsideRange = OutRange, IsWithinRange = false})
	SortToClosest()
end)




--[[

	game.ReplicatedStorage.Events.RemoteEvents.Proximity:Fire(
		Position, 
		ActivationDistance,
		function()Part.BrickColor = BrickColor.Red() wait(1) end, -- Function to call when player comes into range
		function()Part.BrickColor = BrickColor.Gray() wait(1) end -- Function to call when player leaves range
	)
	
	
	
	
	
--]]
