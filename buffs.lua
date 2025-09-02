local SECONDS_PER_MIN = 60;

local function format_time(time)

    -- above 10min use bliz formatting
    if time > (10 * SECONDS_PER_MIN) then
        local s, t = SecondsToTimeAbbrev(time)
        return string.format(s, t)
    end

    -- between 1min and 10min == MM:SS
    if time > SECONDS_PER_MIN then
        local minutes = floor(time / SECONDS_PER_MIN);
        local seconds = time - (minutes * SECONDS_PER_MIN);
        return string.format("%d:%2d", minutes, seconds)
    end

    -- between 30sec and 1min --> "SS s"
    if time > 10 then
        return string.format("%d s", time)
    end

    -- sub 10sec --> "SS.s" (with decimal)
    return string.format("%0.1f", time)
end


local function UpdateDuration(self, timeLeft)
    local text = format_time(timeLeft) or ""
    self.Duration:SetFormattedText(text or "");
end


local function add_hooks(self)
    for _, auraFrame in ipairs(self.auraFrames) do
        -- print("auraFrame", auraFrame)
        if not auraFrame.__arrg_hooked and auraFrame.UpdateDuration then
            auraFrame.__arrg_hooked = true
            hooksecurefunc(auraFrame, "UpdateDuration", UpdateDuration)
        end
    end
end

hooksecurefunc(BuffFrame, "UpdateAuraButtons", add_hooks)
hooksecurefunc(DebuffFrame, "UpdateAuraButtons", add_hooks)
