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
        return string.format("%d:%02d", minutes, seconds)
    end

    -- between 5sec and 1min --> "SS s"
    if time > 5 then
        return string.format("%d s", time)
    end

    -- sub 10sec --> "SS.s" (with decimal)
    return string.format("%0.1f", time)
end


local function UpdateDuration(self, timeLeft)
    local text = format_time(timeLeft) or ""
    self.Duration:SetFormattedText(text or "");
end


local function add_hooks(frame)
    for _, auraFrame in ipairs(frame.auraFrames) do
        if auraFrame.UpdateDuration then
            hooksecurefunc(auraFrame, "UpdateDuration", UpdateDuration)
        end
    end
end

add_hooks(BuffFrame)
add_hooks(DebuffFrame)
