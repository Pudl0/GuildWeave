-- OfficerData.lua
-- Backend logic for encoding and writing guild rules to guild info text.

local function EncodeGuildInfoBlock(mail, ah, trade, group, cap)
    local rules = string.format("%s:%d%d%d%d",
        GuildWeave.Constants.RULES_KEY,
        mail  and 1 or 0,
        ah    and 1 or 0,
        trade and 1 or 0,
        group and 1 or 0)
    local capPart = (cap and cap > 0)
        and string.format(" GuildWeave-Cap:%d", cap) or ""
    return rules .. capPart
end

-- Writes encoded rules into guild info, replacing any existing GuildWeave block.
function GuildWeave:WriteGuildInfo(mail, ah, trade, group, cap)
    if not CanGuildRemove() then return end
    local sep     = GuildWeave.Constants.GUILD_INFO_SEPARATOR
    local current = GetGuildInfoText() or ""

    local sepPos = current:find("\n\n" .. sep, 1, true)
                or current:find("\n"   .. sep, 1, true)
                or current:find(sep, 1, true)
    if sepPos then
        current = current:sub(1, sepPos - 1)
    else
        current = current:gsub(GuildWeave.Constants.RULES_KEY    .. ":%d+", "")
        current = current:gsub(GuildWeave.Constants.RULES_CAP_KEY .. ":%d+", "")
    end
    current = current:gsub("%s+$", "")

    local block   = EncodeGuildInfoBlock(mail, ah, trade, group, cap)
    local newText = (current ~= "")
        and (current .. "\n\n" .. sep .. "\n" .. block)
        or  (sep .. "\n" .. block)

    SetGuildInfoText(newText)
    GuildWeave:Print("Guild info updated with new rules.")
    GuildWeave.Rules:LoadFromGuildInfo()
end
