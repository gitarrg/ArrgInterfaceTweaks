local ADDON_NAME = ...
local LSM = LibStub("LibSharedMedia-3.0")


local FONT_NAME = "Interface/Addons/" .. ADDON_NAME .. "/media/fonts/Cabin.ttf"

LSM:Register("font", "Cabin", FONT_NAME)


_G.UNIT_NAME_FONT = FONT_NAME
_G.DAMAGE_TEXT_FONT = FONT_NAME

ChatBubbleFont:SetFont(FONT_NAME, 10, "OUTLINE")



-- Buff and Debuff Frame
local function set_duration_font(frame)
    for _, auraFrame in ipairs(frame.auraFrames) do
        if auraFrame and auraFrame.Duration and auraFrame.Duration.SetFont then
            auraFrame.Duration:SetFont(FONT_NAME, 12, "")
        end
    end
end

set_duration_font(BuffFrame)
set_duration_font(DebuffFrame)

