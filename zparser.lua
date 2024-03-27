local Unlocker, Caffeine, addon = ...
print("ZygorParser Loaded")
print("Click the button to turn on/off")
print("If you run into any errors, please report them to Nova")

local Zygor = Caffeine.Module:New('addon')
local Target = Caffeine.UnitManager:Get("target")
local Player = Caffeine.UnitManager:Get("player")
local None = Caffeine.UnitManager:Get("none")
local ZygorON = false
local Draw = Caffeine.Draw:New()

addon.Settings = Caffeine.Interface.Category:New("ZygorRotations")
addon.Settings:AddSubsection("ZygorRotations")

addon.Hotbar = Caffeine.Interface.Hotbar:New({
    name = "Zygor Parser",
    options = addon.Settings,
    buttonCount = 1,
})

addon.Hotbar:AddButton({
    name = "Toggle",
    texture = "Interface\\ICONS\\Achievement_raregarrisonquests_x",
    tooltip = "This button toggles the Rotation.",
    toggle = true,
    onClick = function()
        ZygorON = not ZygorON
        Caffeine:Print('Zygor ' .. (ZygorON and 'enabled' or 'disabled'))
    end
})

function GetObjective()
    local tmp = {}
    if ZGV.CurrentStep and #ZGV.CurrentStep.goals > 0 then
        for i = 1, #ZGV.CurrentStep.goals do
            if ZGV.CurrentStep.goals[i].action == "kill" then
                tinsert(tmp, ZGV.CurrentStep.goals[i].targetid)
            elseif ZGV.CurrentStep.goals[i].action == "talk" then
                tinsert(tmp, ZGV.CurrentStep.goals[i].npcid)
            elseif ZGV.CurrentStep.goals[i].action == "click" then
                tinsert(tmp, ZGV.CurrentStep.goals[i].target)
            end
        end
    end
    return tmp
end

function CurrentGoal()
    local goal = {}
    if ZGV.CurrentStep and #ZGV.CurrentStep.goals > 0 then
        for i = 1, #ZGV.CurrentStep.goals do
            if ZGV.CurrentStep.goals[i].action ~= nil then
                tinsert(goal, ZGV.CurrentStep.goals[i].action)
            end
        end
    end
    return goal
end

function MoveToTarget(x, y, z)
    local px, py, pz = Player:GetPosition()
    local distance = Caffeine.Util.FastDistance(px, py, pz, x, y, z)

    while distance > 1 do
        Caffeine.Util.MoveTo(x, y, z)
        px, py, pz = Player:GetPosition()
        distance = Caffeine.Util.FastDistance(px, py, pz, x, y, z)
        coroutine.yield()
    end
end

function PrintCurrentStep()
    if ZGV.CurrentStep then
        print("Current Step: " .. ZGV.CurrentStep.num .. ". " .. ZGV.CurrentStep.text)
    else
        print("No current step available.")
    end
end

Draw:Sync(function(draw)
    if not ZygorON then
        return
    end

    for _, objective in ipairs(GetObjective()) do
        local object = Caffeine.UnitManager:GetObject(objective)
        if object then
            local tx, ty, tz = object:GetPosition()
            local texture = {
                texture = "interface\\cursor\\quest.blp",
                width = 40,
                scale = 0.6,
                height = 40
            }
            draw:SetColor(255, 255, 0)
            draw:SetWidth(4)
            draw:SetAlpha(150)
            draw:Circle(tx, ty, tz, 2)
            draw:Texture(texture, tx, ty, tz + 2)
        end
    end
end)

Caffeine:Sync(function()
    while true do
        if not ZygorON then
            return
        end

        PrintCurrentStep()

        for _, objective in ipairs(GetObjective()) do
            local object = Caffeine.UnitManager:GetObject(objective)
            if object then
                local tx, ty, tz = object:GetPosition()
                MoveToTarget(tx, ty, tz)

                if object:IsUnit() then
                    object:Interact()
                elseif object:IsGameObject() then
                    object:Interact()
                end
            end
        end

        coroutine.yield()
    end
end)

Draw:Enable()
Caffeine:Register(Zygor)
addon.Settings:Register()
