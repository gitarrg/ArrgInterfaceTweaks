

---@type table<string, boolean>
local IGNORED_ITEM_TYPES = {
    ["INVTYPE_BAG"] = true,
    ["INVTYPE_QUIVER"] = true,
    ["INVTYPE_TABARD"] = true,
    ["INVTYPE_AMMO"] = true,
    ["INVTYPE_NON_EQUIP"] = true,
    ["INVTYPE_NON_EQUIP_IGNORE"] = true
}


local TOOLTIP_TO_BIND_TYPE = {

    -- Warbound
    [ITEM_ACCOUNTBOUND] = Enum.ItemBind.ToBnetAccount,
    [ITEM_BNETACCOUNTBOUND] = Enum.ItemBind.ToBnetAccount,

    -- Warbound until equipped
    [ITEM_ACCOUNTBOUND_UNTIL_EQUIP] = Enum.ItemBind.ToBnetAccountUntilEquipped,
    [ITEM_BIND_TO_ACCOUNT_UNTIL_EQUIP] = Enum.ItemBind.ToBnetAccountUntilEquipped,

    [ITEM_SOULBOUND] = Enum.ItemBind.None, -- Hide text on Soulbound items
}

-- https://warcraft.wiki.gg/wiki/Enum.ItemBind
local BIND_TEXT = {
    -- [Enum.ItemBind.OnAcquire or 1] = "BoP",
    [Enum.ItemBind.OnEquip or 2] = "BoE",
    [Enum.ItemBind.OnUse or 3] = "BoU",
    [Enum.ItemBind.ToBnetAccount or 8] = "BoA",
    [Enum.ItemBind.ToBnetAccountUntilEquipped or 9] = "WuE",
}


---@class BagItemInfo : Frame
---@field clear fun(self: BagItemInfo)
---@field setItem fun(self: BagItemInfo, location: ItemLocation)
---@field ilvl FontString
---@field bind FontString



---@param location ItemLocation
---@return number
local function get_bind_type(location)

    local bag, slot = location:GetBagAndSlot()
    local itemLink = C_Container.GetContainerItemLink(bag, slot)
    local _, _, _, _, _, _, _, _, _, _, _, _, _, bindType = C_Item.GetItemInfo(itemLink)

    -- Check if its WuE
    if bindType == Enum.ItemBind.OnEquip and C_Item.IsBoundToAccountUntilEquip(location) then
        return Enum.ItemBind.ToBnetAccountUntilEquipped
    end

    -- check if its BoA
    local tooltip = C_TooltipInfo.GetBagItem(bag, slot)
    if tooltip then
        for _, row in ipairs(tooltip.lines) do
            local text = TOOLTIP_TO_BIND_TYPE[row.leftText]
            if text then return text end
        end
    end

    return bindType
end


---@param itemLink string
---@return number?
local function get_item_level(itemLink)

    local _, _, itemQuality, _, _, _, _, _, itemEquipLoc = C_Item.GetItemInfo(itemLink)

    if not itemQuality or itemQuality <= 0 then return end
    if not itemEquipLoc or IGNORED_ITEM_TYPES[itemEquipLoc] then return end

    local itemLevel = C_Item.GetDetailedItemLevelInfo(itemLink)
    return itemLevel
end


---@return BagItemInfo
local function create_bag_info_frame(parent)

    ---@type BagItemInfo
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetFrameLevel(parent:GetFrameLevel() + 5)
    frame:SetAllPoints()

    frame.ilvl = frame:CreateFontString()
    frame.ilvl:SetDrawLayer("ARTWORK", 1)
    frame.ilvl:SetPoint("TOPLEFT", 2, -2)
    frame.ilvl:SetFontObject(NumberFont_Outline_Med or NumberFontNormal)
    frame.ilvl:SetShadowOffset(1, -1)
    frame.ilvl:SetShadowColor(0, 0, 0, .5)

    frame.bind = frame:CreateFontString()
    frame.bind:SetDrawLayer("ARTWORK", 1)
    frame.bind:SetPoint("BOTTOMLEFT", 2, 2)
    frame.bind:SetFontObject(NumberFont_Outline_Med or NumberFontNormal)
    frame.bind:SetShadowOffset(1, -1)
    frame.bind:SetShadowColor(0, 0, 0, .5)

    function frame:setItem(location)

        if not location:IsValid() then
            self:clear()
            return
        end
        
        local bag, slot = location:GetBagAndSlot()
        local itemLink = C_Container.GetContainerItemLink(bag, slot)
        local _, _, itemQuality = C_Item.GetItemInfo(itemLink)
        if not itemLink then
            self:clear()
            return
        end

        -- ilvl
        local itemLevel = get_item_level(itemLink)
        if itemLevel then
            self.ilvl:SetText(string.format("%d", itemLevel))
            self.ilvl:Show()
        else
            self.ilvl:SetText("")
            self.ilvl:Hide()
        end

        -- bind text
        local bindType = get_bind_type(location)
        local bind_text = BIND_TEXT[bindType]
        if bind_text then
            self.bind:SetText(bind_text)
            self.bind:Show()
        else
            self.bind:SetText("")
            self.bind:Hide()
        end

        -- Color
        local r, g, b = C_Item.GetItemQualityColor(itemQuality or 0)
        if (r and g and b) then
            self.ilvl:SetTextColor(r, g, b)
            self.bind:SetTextColor(r, g, b)
        end
    end

    function frame:clear()
        self.ilvl:SetText("")
        self.ilvl:Hide()
        self.bind:SetText("")
        self.bind:Hide()
    end

    return frame
end


---@type table<Frame, BagItemInfo>
local CACHE = {}


-- Update an itembutton's itemlevel
local function Update(button)

    local frame = CACHE[button]

   -- create parent frame
    if not frame then
        frame = create_bag_info_frame(button)
        CACHE[button] = frame
    end

    ---@type ItemLocation
    local location = button:GetItemLocation()
    frame:setItem(location)
end


--------------------------------------------------------------------------------
-- Bags

local function update_all_slots(self)
	for _, button in self:EnumerateValidItems() do
        Update(button)
	end
end

if ContainerFrameCombinedBags then
    hooksecurefunc(ContainerFrameCombinedBags, "Update", update_all_slots)
end


--------------------------------------------------------------------------------
-- Bank

local function update_bank_slots(self)
    for itemButton in self:EnumerateValidItems() do
        Update(itemButton)
    end
end

if BankPanel then
    hooksecurefunc(BankPanel, "RefreshBankPanel", update_bank_slots)
    hooksecurefunc(BankPanel, "RefreshAllItemsForSelectedTab", update_bank_slots)
end
