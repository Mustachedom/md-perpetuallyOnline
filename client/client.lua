local peds = {}

local function spawnPeds(model)
    local amount = 5
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
    repeat
        Wait(10)
        peds[#peds + 1] = CreatePed(4, model, GetEntityCoords(PlayerPedId()) + vector3(math.random(-5, 5), math.random(-5, 5), 0), 0.0, true, false)
        TaskFollowToOffsetOfEntity(peds[#peds], PlayerPedId(), 0.0, 0.0, 0.0, 2.0, -1, 5.0, true)
        amount = amount - 1
        SetPedRelationshipGroupHash(peds[#peds], GetHashKey('PLAYER'))
        SetPedKeepTask(peds[#peds], true)
    until amount == 0
end

local commandsStart = {
    beANeckbeard = "a_f_m_beach_01",
    beAnEGangster = "csb_ramp_gang",
    beAVirgin = 'csb_stripper_02',
}

for command, model in pairs(commandsStart) do
    RegisterCommand(command, function()
        if #peds > 0 then
            for _, ped in pairs(peds) do
                if DoesEntityExist(ped) then
                    DeleteEntity(ped)
                end
            end
            peds = {}
        end
        spawnPeds(model)
    end, false)
end

local animation = {
    cheer = {active = false, scenario = "WORLD_HUMAN_CHEERING"},
    blowKiss = {active = false, animDict = "anim@mp_player_intselfieblow_kiss", anim = "exit"},
    flipOff = {active = false, animDict = "anim@arena@celeb@podium@no_prop@", anim = "flip_off_c_1st"},
}

for k, v in pairs (animation) do
    RegisterCommand(k, function()
        if v.active then
            v.active = false
            for _, ped in pairs(peds) do
                ClearPedTasks(ped)
                TaskFollowToOffsetOfEntity(ped, PlayerPedId(), 0.0, 0.0, 0.0, 2.0, -1, 5.0, true)
            end
            return
        else
            v.active = true
            for _, ped in pairs(peds) do
                if v.scenario then
                    TaskStartScenarioInPlace(ped, v.scenario, 0, true)
                end
                if v.animDict and v.anim then
                    RequestAnimDict(v.animDict)
                    while not HasAnimDictLoaded(v.animDict) do
                        Wait(10)
                    end
                    TaskPlayAnim(ped, v.animDict, v.anim, 8.0, -8.0, -1, 1, 0, false, false, false)
                end
            end
        end
    end, false)
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    for _, ped in pairs(peds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
end)

RegisterCommand('backToReality', function()
    for _, ped in pairs(peds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
    peds = {}
end, false)