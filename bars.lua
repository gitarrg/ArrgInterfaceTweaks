-- Module to hide Actions Bars


local BARS = {

    ["MainMenuBar"] = true,

    ["MultiBarBottomLeft"] = true,
	["MultiBarBottomLeftButton"] = true,

    ["MultiBarBottomRight"] = true,
	["MultiBarBottomRightButton"] = true,

    ["MultiBarRight"] = true,
	["MultiBarRightButton"] = true,

    ["MultiBarLeft"] = true,
	["MultiBarLeftButton"] = true,

    ["MultiBar5"] = true,
	["MultiBar5Button"] = true,

    ["MultiBar6"] = true,
	["MultiBar6Button"] = true,

    ["MultiBar7"] = true,
    ["MultiBar7Button"] = true,

    ["StanceBar"] = true,
	["StanceButton"]  = true,

    ["PetActionBar"] = true,
    ["PetActionButton"] = true,

    ["MainMenuBarVehicleLeaveButton"] = false,
}

local FRAMES = {}


-- flags
local mouse_over = false

-- local SHOW = true

local function show()
    for _, frame in pairs(FRAMES) do
        frame:SetAlpha(1)
    end
end

local function hide()
    for _, frame in pairs(FRAMES) do
        frame:SetAlpha(0.25)
    end
end


local function should_show()

    if mouse_over == true then return true end

    -- check action bar page
    local page = GetActionBarPage()
    if page ~= 1 then return true end

    -- Skyriding?
    if UnitPowerBarID("player") == 631 then return true end

    if UnitInVehicle("player") or UnitOnTaxi("player") then return true end

    -- nothing?
    return false
end


local function update()

    local alpha = should_show() and 1.0 or 0.25

    for _, frame in pairs(FRAMES) do
        frame:SetAlpha(alpha)
    end
end


local function hook_frame(frame)
    if not frame then return end

    frame:HookScript("OnEnter",  function()
        if mouse_over == true then return end -- already set

        mouse_over = true
        update()
    end)
    
    frame:HookScript("OnLeave",  function()
        if mouse_over == false then return end -- already set

        mouse_over = false
        update()
    end)
end


-- local skyriding = UnitPowerBarID("player") == 631
-- addon.bars[MAIN_BAR]:SetAlpha(1)
-- local vehicle = UnitInVehicle("player") or UnitOnTaxi("player") or false


for name, enable in pairs(BARS) do

    if enable then
        FRAMES[name] = _G[name]  -- Bar?
        for i = 1, 12, 1 do
            FRAMES[name .. i] = _G[name .. i]
        end
    end

    for _, frame in pairs(FRAMES) do
        hook_frame(frame)
    end
end


local event_frame = CreateFrame("Frame")
event_frame:SetScript("OnEvent", update)   -- for now, we always just "update"

-- Skyriding events
event_frame:RegisterEvent("PLAYER_ENTERING_WORLD")
event_frame:RegisterEvent("UNIT_POWER_BAR_SHOW")
event_frame:RegisterEvent("UNIT_POWER_BAR_HIDE")

-- Action Bar Page
event_frame:RegisterEvent("ACTIONBAR_PAGE_CHANGED")

-- Vehicle events
event_frame:RegisterEvent("UNIT_ENTERED_VEHICLE")
event_frame:RegisterEvent("UNIT_EXITED_VEHICLE")
event_frame:RegisterEvent("VEHICLE_UPDATE")
event_frame:RegisterEvent("TAXIMAP_CLOSED")

-- init
update()
