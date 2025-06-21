---@type string
local ADDON_NAME = ...

---@class AddonNamespace
local NS = select(2, ...)

local LSM = LibStub("LibSharedMedia-3.0")


local FONT_NAME = "Interface/Addons/" .. ADDON_NAME .. "/media/fonts/Cabin.ttf"

LSM:Register("font", "Cabin", FONT_NAME)


_G.UNIT_NAME_FONT = FONT_NAME
_G.DAMAGE_TEXT_FONT = FONT_NAME

ChatBubbleFont:SetFont(FONT_NAME, 10, "OUTLINE")


if WeakAuras then
    WeakAuras.defaultFont = "Cabin"
    WeakAuras.defaultFontSize = 12
end

