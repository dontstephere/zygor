---@diagnostic disable: undefined-global
local Tinkr = ...
local ObjectManager = Tinkr.Util.ObjectManager
local Exports = Tinkr:require('Routine.Modules.Exports')
local Common = Tinkr.Common
local Routine = Tinkr.Routine
local Draw = Tinkr.Util.Draw:New()
Tinkr:require('Routine.Modules.Exports')
Draw:Enable()

local function GetObjective()
    local tmp = {}
    if ZGV.CurrentStep and #ZGV.CurrentStep.goals > 0 then
        for i = 1, #ZGV.CurrentStep.goals, 1 do
            if ZGV.CurrentStep.goals[i].action == "kill" then
                tinsert(tmp, ZGV.CurrentStep.goals[i].targetid)
            end
            if ZGV.CurrentStep.goals[i].action == "talk" then
                tinsert(tmp, ZGV.CurrentStep.goals[i].npcid)
            end
            if ZGV.CurrentStep.goals[i].action == "click" then
                tinsert(tmp, ZGV.CurrentStep.goals[i].target)        
            end 
        end
    end
    if ZGV.CurrentStickies and #ZGV.CurrentStickies > 0 then
        for i = 1, #ZGV.CurrentStickies, 1 do
            tinsert(tmp, ZGV.CurrentStickies[i].goals[1].targetid)
        end
    end
    
    return tmp
end

local function CurrentGoal()
    local goal = {}
    if ZGV.CurrentStep and #ZGV.CurrentStep.goals > 0 then
        for i = 1, #ZGV.CurrentStep.goals, 1 do
            if ZGV.CurrentStep.goals[i].action ~= nil then
                tinsert(goal, ZGV.CurrentStep.goals[i].action)
            end
        end
    end
    return goal
end

local function MoveToTarget(x, y, z)
    local px, py, pz = ObjectPosition('player')
    local distance = FastDistance(px, py, pz, x, y, z)

    while distance > 1 do
        MoveTo(x, y, z)
        px, py, pz = ObjectPosition('player')
        distance = FastDistance(px, py, pz, x, y, z)
        Coroutine.Yield()
    end
end

local function PrintCurrentStep()
    if ZGV.CurrentStep then
        print("Current Step: " .. ZGV.CurrentStep.num .. ". " .. ZGV.CurrentStep.text)
    else
        print("No current step available.")
    end
end

Draw:Sync(function(draw)
    for i, object in ipairs(Objects()) do
        for key, value in pairs(GetObjective()) do
            local objective = value
            local name = ObjectName(object)
            local id = ObjectId(object)
            if id and id == value or name == value then  
                local tx, ty, tz = ObjectPosition(object)
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
    end
end)

Sync(function()
    while true do
        PrintCurrentStep()

        for i, object in ipairs(Objects()) do
            for key, value in pairs(GetObjective()) do
                local objective = value
                local name = ObjectName(object)
                local id = ObjectId(object)
                if id and id == value or name == value then  
                    local tx, ty, tz = ObjectPosition(object)
                    MoveToTarget(tx, ty, tz)
                end
            end    
        end

        Coroutine.Yield()
    end
end)
