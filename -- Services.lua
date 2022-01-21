-- Services
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CS = game:GetService("CollectionService")
local HTTP = game:GetService("HttpService")


-- Modules
local MaidModule = require(game.ReplicatedStorage.Modules.Maid)



-- Variables
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local Cam = workspace.CurrentCamera

local Maid = MaidModule.new()
local ProxEvent = game.ReplicatedStorage.Events.BindableEvents.Proximity
local RemoveProxEvent = game.ReplicatedStorage.Events.BindableEvents.RemoveProximity



local function AddEvent(Obj, EventType, Module)
	local UniqueID = Obj:FindFirstChild("UniqueID") and Obj.UniqueID.Value or nil
	if not UniqueID then
		UniqueID = HTTP:GenerateGUID()
		local SVal = Instance.new("StringValue")
		SVal.Name = "UniqueID"
		SVal.Value = UniqueID
		SVal.Parent = Obj
	end
	ProxEvent:Fire(Obj, Module.Trigger_Distance, Module.Must_Be_Visible_On_Screen_For_Activation, Module.TriggerWhenInsideRange, Module.TriggerWhenOutsideRange, EventType..UniqueID)
end


local function RemoveEvent(Obj, EventType)
	local UniqueID = Obj:FindFirstChild("UniqueID") and Obj.UniqueID.Value or nil  
	if UniqueID then
		RemoveProxEvent:Fire(EventType..UniqueID)
	end
end


for i,ModuleObj in pairs (game.ReplicatedStorage["Proximity Modules"]:GetChildren()) do
	local Module = require(ModuleObj)
	for i,Obj in pairs (CS:GetTagged(ModuleObj.Name)) do
		AddEvent(Obj, ModuleObj.Name, Module)
	end
	CS:GetInstanceAddedSignal(ModuleObj.Name):Connect(function(Obj)
		AddEvent(Obj, ModuleObj.Name, Module)
	end)
	CS:GetInstanceRemovedSignal(ModuleObj.Name):Connect(function(Obj)
		RemoveEvent(Obj, ModuleObj.Name)
	end)
end
