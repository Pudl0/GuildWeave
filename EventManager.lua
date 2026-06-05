-- EventManager.lua
-- Central event manager for the GuildWeave addon
-- Manages all WoW events in one place for better performance and maintainability

GuildWeave.EventManager = {
	frame = nil,
	handlers = {},  -- { eventName = { {callback, priority, enabled}, ... } }
	registeredEvents = {}
}

-- priority: higher runs first (default 0). identifier: deduplication key.
function GuildWeave.EventManager:RegisterHandler(event, callback, priority, identifier)
	priority = priority or 0
	identifier = identifier or tostring(callback)

	-- Initialize handler list for this event
	if not self.handlers[event] then
		self.handlers[event] = {}
	end

	-- Check if this handler already exists
	for _, handler in ipairs(self.handlers[event]) do
		if handler.identifier == identifier then
			-- Handler already registered, skip
			return identifier
		end
	end

	-- Add handler
	table.insert(self.handlers[event], {
		callback = callback,
		priority = priority,
		enabled = true,
		identifier = identifier
	})

	-- Sort handlers by priority (highest first)
	table.sort(self.handlers[event], function(a, b)
		return a.priority > b.priority
	end)

	-- Register event with frame if not already done
	if not self.registeredEvents[event] then
		self.frame:RegisterEvent(event)
		self.registeredEvents[event] = true
	end

	return identifier
end

function GuildWeave.EventManager:UnregisterHandler(event, identifier)
	if not self.handlers[event] then return end

	for i = #self.handlers[event], 1, -1 do
		if self.handlers[event][i].identifier == identifier then
			table.remove(self.handlers[event], i)
		end
	end

	-- If no more handlers exist for this event, unregister from frame
	if #self.handlers[event] == 0 then
		self.frame:UnregisterEvent(event)
		self.registeredEvents[event] = nil
		self.handlers[event] = nil
	end
end

function GuildWeave.EventManager:SetHandlerEnabled(event, identifier, enabled)
	if not self.handlers[event] then return end

	for _, handler in ipairs(self.handlers[event]) do
		if handler.identifier == identifier then
			handler.enabled = enabled
			return
		end
	end
end

local function OnEvent(self, event, ...)
	local handlers = GuildWeave.EventManager.handlers[event]
	if not handlers then return end

	-- Call all enabled handlers for this event
	for _, handler in ipairs(handlers) do
		if handler.enabled then
			-- Execute handler with error handling
			pcall(handler.callback, event, ...)
		end
	end
end

function GuildWeave.EventManager:Initialize()
	if self.frame then
		-- Already initialized
		return
	end

	-- Create the central event frame
	self.frame = CreateFrame("Frame", "GuildWeaveEventManagerFrame")
	self.frame:SetScript("OnEvent", OnEvent)
end

function GuildWeave.EventManager:DebugInfo()
	print("=== GuildWeave EventManager Debug ===")
	local eventCount = 0
	for _ in pairs(self.registeredEvents) do eventCount = eventCount + 1 end
	print("Registered events: " .. eventCount)

	for event, handlers in pairs(self.handlers) do
		print("Event: " .. event .. " (" .. #handlers .. " handlers)")
		for i, handler in ipairs(handlers) do
			local status = handler.enabled and "active" or "inactive"
			print(string.format("  [%d] Priority: %d, Status: %s, ID: %s",
				i, handler.priority, status, handler.identifier))
		end
	end
	print("=======================================")
end
