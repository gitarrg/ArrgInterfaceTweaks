---@type string
local ADDON_NAME = ...

---@class AddonNamespace
local NS = select(2, ...)


-- Config
local FONT_PATH = "Interface/Addons/" .. ADDON_NAME .. "/media/fonts/Cabin.ttf"
local FONT_SIZE = 14
local FONT_FLAGS = "OUTLINE"


local MISSING_ENCHANT = DULL_RED_FONT_COLOR:WrapTextInColorCode("missing")


-- internal vars
local characterWindowOpen = false


---@class SlotFrame: Frame
---@field arrg__ilvl SimpleFontString
---@field arrg_line2 SimpleFontString
---@field arrg__gems Texture[]


---@class SlotInfo
---@field name string
---@field side string
---@field enchantable boolean?

---@type table<number, SlotInfo>
local SLOTS = {
    [1]  = {name="Head", side="l" },
    [2]  = {name="Neck", side="l" },
    [3]  = {name="Shoulder", side="l" },
    [15] = {name = "Back", side="l", enchantable=true },
    [5]  = {name="Chest", side="l", enchantable=true },
    [4]  = {name="Shirt", side="l" },
    [19] = {name = "Tabard", side="l"},
    [9]  = {name = "Wrist", side="l", enchantable=true},
    
    [6]  = {name = "Waist", side="r"},
    [7]  = {name = "Legs", side="r", enchantable=true},
    [8]  = {name = "Feet", side="r", enchantable=true},
    [10] = { name = "Hands", side="r"},
    [11] = { name = "Finger0", side="r", enchantable=true},
    [12] = { name = "Finger1", side="r", enchantable=true},
    [13] = { name = "Trinket0", side="r"},
    [14] = { name = "Trinket1", side="r"},
    
    [16] = { name = "MainHand", side="r", enchantable=true},
    [17] = { name = "SecondaryHand", side="r"},
}


local TooltipDataType = {
    Enchant = 15,
    UpgradeTrack = 42,
}


---@class TextReplacement
---@field original string The localization key for the original text to search for when abbreviating text
---@field replacement string The localization key for the abbreviation for the original text



---A list of tables containing text replacement patterns for enchants
---@type TextReplacement[]
local EnchantTextReplacements = {
    { original = "%%", replacement = "%%%%" }, -- Required for proper string formatting (% is a special character in formatting)
    { original = "+", replacement = "" }, -- Removes the '+' that usually prefixes enchantment text
    { original = "Enchanted: ", replacement = "" },
    { original = "Radiant Critical Strike", replacement = "Rad Crit" },
    { original = "Radiant Haste", replacement = "Rad Hst" },
    { original = "Radiant Mastery", replacement = "Rad Mast" },
    { original = "Radiant Versatility", replacement = "Rad Vers" },
    { original = "Cursed Critical Strike", replacement = "Curs Crit" },
    { original = "Cursed Haste", replacement = "Curs Hst" },
    { original = "Cursed Mastery", replacement = "Curs Mast" },
    { original = "Cursed Versatility", replacement = "Curs Vers" },
    { original = "Whisper of Armored Avoidance", replacement = "Arm Avoid" },
    { original = "Whisper of Armored Leech", replacement = "Arm Leech" },
    { original = "Whisper of Armored Speed", replacement = "Arm Spd" },
    { original = "Whisper of Silken Avoidance", replacement = "Silk Avoid" },
    { original = "Whisper of Silken Leech", replacement = "Silk Leech" },
    { original = "Whisper of Silken Speed", replacement = "Silk Spd" },
    { original = "Chant of Armored Avoidance", replacement = "Arm Avoid" },
    { original = "Chant of Armored Leech", replacement = "Arm Leech" },
    { original = "Chant of Armored Speed", replacement = "Arm Spd" },
    { original = "Scout's March", replacement = "Sco March" },
    { original = "Defender's March", replacement = "Def March" },
    { original = "Cavalry's March", replacement = "Cav March" },
    { original = "Stormrider's Agility", replacement = "Agi" },
    { original = "Council's Intellect", replacement = "Int" },
    { original = "Crystalline Radiance", replacement = "Crys Rad" },
    { original = "Oathsworn's Strength", replacement = "Oath Str" },
    { original = "Chant of Winged Grace", replacement = "Wing Grc" },
    { original = "Chant of Leeching Fangs", replacement = "Leech" },
    { original = "Chant of Burrowing Rapidity", replacement = "Burr Rap" },
    { original = "Authority of Air", replacement = "Auth Air" },
    { original = "Authority of Fiery Resolve", replacement = "Fire Res" },
    { original = "Authority of Radiant Power", replacement = "Rad Pow" },
    { original = "Authority of the Depths", replacement = "Auth Deps" },
    { original = "Authority of Storms", replacement = "Auth Storm" },
    { original = "Oathsworn's Tenacity", replacement = "Oath Ten" },
    { original = "Stonebound Artistry", replacement = "Stn Art" },
    { original = "Stormrider's Fury", replacement = "Fury" },
    { original = "Council's Guile", replacement = "Guile" },
    { original = "Stamina", replacement = "Stam" },
    { original = "Intellect", replacement = "Int" },
    { original = "Strength", replacement = "Str" },
    { original = "Agility", replacement = "Agi" },
    { original = "Speed", replacement = "Spd" },
    { original = "Avoidance", replacement = "Avoid" },
    { original = "Armor", replacement = "Arm" },
    { original = "Haste", replacement = "Hst" },
    { original = "Damage", replacement = "Dmg" },
    { original = "Mastery", replacement = "Mast" },
    { original = "Critical Strike", replacement = "Crit" },
    { original = "Versatility", replacement = "Vers" },
    { original = "Deftness", replacement = "Deft" },
    { original = "Finesse", replacement = "Fin" },
    { original = "Ingenuity", replacement = "Ing" },
    { original = "Perception", replacement = "Perc" },
    { original = "Resourcefulness", replacement = "Rsrc" },
    { original = "Absorption", replacement = "Absorb" },
}

---A list of tables containing text replacement patterns for upgrade tracks
---@type TextReplacement[]
local UpgradeTextReplacements = {
    { original = "Upgrade Level: ", replacement = "" },
    { original = "Explorer ", replacement = "E" },
    { original = "Adventurer ", replacement = "A" },
    { original = "Veteran ", replacement = "V" },
    { original = "Champion ", replacement = "C" },
    { original = "Hero ", replacement = "H" },
    { original = "Myth ", replacement = "M" }
}


local UPGRADE_TIERS = {
    {
        name="Explorer",
        short="E",
        color=ITEM_POOR_COLOR,
    },
    {
        name="Adventurer",
        short="A",
        color=WHITE_FONT_COLOR,
    },
    {
        name="Veteran",
        short="V",
        color=UNCOMMON_GREEN_COLOR,
    },
    {
        name="Champion",
        short="C",
        color=RARE_BLUE_COLOR,
    },
    {
        name="Hero",
        short="H",
        color=ITEM_EPIC_COLOR,
    },
    {
        name="Myth",
        short="M",
        color=ITEM_LEGENDARY_COLOR,
    },
}

--------------------------------------------------------------------------------
--- Helpers
--- 

local function abbreviateText(text, replacementTable)
    if not text then return "" end
    if not replacementTable then return text end

    local abbreviation = text
    for _, repl in pairs(replacementTable) do
        abbreviation = abbreviation:gsub(repl.original, repl.replacement)
    end
    return abbreviation
end


---@param unit string
---@param slot number
local function getSlotFrameName(unit, slot)

    local prefix = "Inspect"
    if (unit == "player") then
        prefix = "Character"
    end
    
    local slotName
    if (SLOTS[slot]) then
        slotName = SLOTS[slot].name
    end

    return prefix .. slotName .. "Slot"
end


local gem_icon = {}


local function get_gem_text(itemLink)

    local text = ""

    local gemCount = C_Item.GetItemNumSockets(itemLink)
    for i = 1, gemCount do
        local icon
        
        local gemId = C_Item.GetItemGemID(itemLink, i)
        if gemId then
            icon = C_Item.GetItemIconByID(gemId)
        else
            icon = "Interface\\ITEMSOCKETINGFRAME\\UI-EmptySocket-Prismatic.blp"
            icon = "458977"
            -- gem_frame:SetTexture()
        end

        if icon then
            text = text .. CreateSimpleTextureMarkup(icon)
        end
    end

    return text
end


--------------------------------------------------------------------------------
--- Core



---@class ItemInfo
---@field link string
---@field ilvl number
---@field quality Enum.ItemQuality
---@field enchant string
---@field upgradeText string


---@return ItemInfo?
local function get_slot_info(unit, slot)

    local itemLink = GetInventoryItemLink(unit, slot)
    if itemLink == nil then return end

    local _, _, itemQuality = C_Item.GetItemInfo(itemLink)

    ---@type ItemInfo
    local info = {
        link = itemLink,
        ilvl = C_Item.GetDetailedItemLevelInfo(itemLink),
        quality = itemQuality,
        enchant = "",
        upgradeText = "",
    }

    local slot_info = SLOTS[slot]
    if slot_info and slot_info.enchantable then
        info.enchant = MISSING_ENCHANT  -- until overwirtten
    end


    local tooltip = C_TooltipInfo.GetHyperlink(itemLink)
    if tooltip and tooltip.lines then

        for _, ttdata in pairs(tooltip.lines) do

            if ttdata and ttdata.type then
                
                if ttdata.type == TooltipDataType.Enchant then
                    local text = ttdata.leftText
                    text = text:gsub("Enchanted: ", "")
                    text = abbreviateText(text, EnchantTextReplacements)
                    text = text:gsub("|A:(.+)|a", "")  -- remove quality icon eg.: "|A:Profession-ChatIcon-Quality-Tier3:20:20|a"
                    text = strtrim(text)
                    info.enchant = text
                end
                
                if ttdata.type == TooltipDataType.UpgradeTrack then
                    local text = ttdata.leftText or ""
                    -- upgradeText = abbreviateText(upgradeText, UpgradeTextReplacements)

                    local tier, current, total = text:match(ITEM_UPGRADE_TOOLTIP_FORMAT_STRING:gsub("%%s %%d/%%d", "(%%D+) (%%d+)/(%%d+)"))
                    for _, upgradeTier in pairs(UPGRADE_TIERS) do
                        if tier == upgradeTier.name then

                            text = current .. "/" .. total
                            text = strtrim(text)
                            text = upgradeTier.color:WrapTextInColorCode(text)
                            text = " " .. text -- add a separator space
                            info.upgradeText = text
                        end
                    end
                end
            end --/if ttdata
        end --/for ttdata
    end --/if tooltip

    return info
end




---@param unit string
---@param slot number
local function updateSlot(unit, slot)

    if not unit then return end
    if not slot then return end

    local itemInfo = get_slot_info(unit, slot)
    if not itemInfo then return end

    local slotFrameName = getSlotFrameName(unit, slot)
    if not slotFrameName == nil then return end

    ---@type SlotFrame
    local slotFrame = _G[slotFrameName]
    if not slotFrame == nil then return end

    local slotInfo = SLOTS[slot]
    if not slotInfo == nil then return end

    local rightSide = slotInfo.side == "r"
    local framePoint = rightSide and "RIGHT" or "LEFT"
    local parentPoint = rightSide and "LEFT" or "RIGHT"
    local offsetX = rightSide and -10 or 9

    -- ilvl


    --- Line 1:
    --- ilvl and gems
    


    local text_line1
    local text_ilvl = "|cnIQ" .. itemInfo.quality .. ":" .. itemInfo.ilvl .. "|r"
    local text_gems = get_gem_text(itemInfo.link)
    
    if slotInfo.side == "l" then
       text_line1 = text_ilvl .. " " .. text_gems
    else
        text_line1 = text_gems .. " " .. text_ilvl
    end
    text_line1 = strtrim(text_line1)

    if not slotFrame.arrg_line1 then
        slotFrame.arrg_line1 = slotFrame:CreateFontString("", "ARTWORK", "GameTooltipText")
        slotFrame.arrg_line1:SetFont(FONT_PATH, FONT_SIZE, FONT_FLAGS)
        
        if (slot == 16 or slot == 17) then -- weapons put the ilvl on top
            slotFrame.arrg_line1:SetPoint("BOTTOM", slotFrame, "TOP", 0, 5)
        else
            slotFrame.arrg_line1:SetPoint(framePoint, slotFrame, parentPoint, offsetX, 5)
        end
    end

    slotFrame.arrg_line1:SetText(text_line1)
    slotFrame.arrg_line1:SetShown(text_line1 ~= "")

    --- Line 2:
    --- Upgrade Text & Enchant
    local text_line2
    if slotInfo.side == "l" then
       text_line2 = (itemInfo.upgradeText or "") .. " " .. (itemInfo.enchant or "")
    else
        text_line2 = (itemInfo.enchant or "") .. " " .. (itemInfo.upgradeText or "")
    end
    text_line2 = strtrim(text_line2)
    
    if not slotFrame.arrg_line2 then
        slotFrame.arrg_line2 = slotFrame:CreateFontString("", "ARTWORK", "GameTooltipText")
        slotFrame.arrg_line2:SetFont(FONT_PATH, FONT_SIZE, FONT_FLAGS)
        slotFrame.arrg_line2:SetTextColor(0, 255, 0) --- this is only for the enchant
        
        if (slot == 16 or slot == 17) then -- weapons put the ilvl on top
            slotFrame.arrg_line2:SetPoint("BOTTOM", slotFrame, "TOP", 0, 20)
        else
            slotFrame.arrg_line2:SetPoint(framePoint, slotFrame, parentPoint, offsetX, -12)
        end
    end

    slotFrame.arrg_line2:SetText(text_line2)
    slotFrame.arrg_line2:SetShown(text_line2 ~= "")

--[[     ----------------------------
    -- Gems
    local ilvlSpacingX = 27 * (FONT_SIZE / 12);
    slotFrame.arrg__gems = slotFrame.arrg__gems or {}
    for i = 1, 3 do

        local gem_frame = slotFrame.arrg__gems[i]
        if not gem_frame then
            gem_frame = slotFrame:CreateTexture()
            gem_frame:SetPoint(framePoint, slotFrame, parentPoint, offsetX, -12)
            gem_frame:SetSize(14, 14)

            local gemOffsetX = rightSide and offsetX - (15 * (i - 1)) or offsetX + (15 * (i - 1))
            gemOffsetX = rightSide and gemOffsetX - ilvlSpacingX or gemOffsetX + ilvlSpacingX
            gem_frame:SetPoint(framePoint, slotFrame, parentPoint, gemOffsetX, 0)

            slotFrame.arrg__gems[i] = gem_frame
        end
    end


    --------------------------



    local gemCount = C_Item.GetItemNumSockets(itemInfo.link)
    for i = 1, 3 do

        local gem_frame = slotFrame.arrg__gems[i]
        gem_frame:SetShown(i <= gemCount)
        
        local gemId = C_Item.GetItemGemID(itemInfo.link, i)
        if gemId then
            local gemIcon = C_Item.GetItemIconByID(gemId);
            gem_frame:SetTexture(gemIcon)
        else
            gem_frame:SetTexture("Interface\\ITEMSOCKETINGFRAME\\UI-EmptySocket-Prismatic.blp")
        end
    end

    -- slotFrame.arrg__ilvl:SetText("nothing") ]]
end


local function updateAllSlots(unit)
    for slot = 1, 19 do
        updateSlot(unit, slot)
    end
end




--------------------------------------------------------------------------------
--- Events


local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(_, event, ...)

    -- An equipment slot is changed
    if (event == "PLAYER_EQUIPMENT_CHANGED" and characterWindowOpen) then
        local slot = ...
        updateSlot("player", slot)
    end

    if event == "INSPECT_READY" then
        local unit = InspectFrame and InspectFrame.unit
        if unit then
            updateAllSlots(unit)
        end
        return
    end

    --[[
        if event == "GET_ITEM_INFO_RECEIVED" then
            return
        end
        
        if event == "UNIT_INVENTORY_CHANGED" then
            local unit = ...
            if unit == "player" and aura_env.characterOpen then -- needed for item enchants
                -- updateAllSlots(unit)
            end
            return
        end
    ]]
end)

eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
eventFrame:RegisterEvent("INSPECT_READY")
-- eventFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
-- eventFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")


if PaperDollFrame then
    hooksecurefunc(PaperDollFrame, "Show", function()
        characterWindowOpen = true
        updateAllSlots("player")
    end)

    hooksecurefunc(PaperDollFrame, "Hide", function()
        characterWindowOpen = false
    end)
end


--[[ local lastInspectUnit
local lastInspectGuid

hooksecurefunc("NotifyInspect", function(unit)

        print("NotifyInspect", unit)
        
        -- don't run on mouseover
        if (unit == "mouseover") then return end
        
        -- there's some weird thing where inspect is called on yourself? Ignore these
        if (unit == GetUnitName("player")) then return end
        
        lastInspectUnit = unit
        lastInspectGuid = UnitGUID(unit)
end)

 ]]