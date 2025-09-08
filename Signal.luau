--!strict

export type Connection = {
	_connected: boolean,
	Connected: boolean,
	Disconnect: (self: Connection) -> (),
}

export type Listener = {
	callback: () -> (),
	connection: Connection,
	priority: number,
}

export type InvokeResult = {any} | any

export type Signal = {
	_listeners: {Listener},
	
	Connect: (self: Signal, callback: () -> (), priority: number?) -> Connection,
	Once: (self: Signal, callback: () -> ()) -> Connection,
	Fire: (self: Signal, ...any) -> (InvokeResult),
	Wait: (self: Signal) -> (...any),
	DisconnectAll: (self: Signal) -> (),
	HasConnections: (self: Signal) -> (boolean),
	GetConnectionCount: (self: Signal) -> (number),
	IsConnected: (self: Signal, callback: () -> ()) -> (boolean),
	Destroy: (self: Signal) -> (),
}

local Signal = {}
Signal.__index = Signal

function Signal.new(): Signal
	local self = setmetatable({}, Signal)
	self._listeners = {}
	return (self:: unknown):: Signal
end

function Signal:Connect(callback: () -> (), priority: number?): Connection
	local connection: Connection = {
		_connected = true,
		Disconnect = function(self)
			self._connected = false
			self.Connected = false
		end,
		Connected = true,
	}

	local listener: Listener = {
		callback = callback,
		connection = connection,
		priority = priority or 1,
	}

	table.insert(self._listeners, listener)
	return connection
end

function Signal:Once(callback: () -> ()): Connection
	local conn
	conn = self:Connect(function(...)
		conn:Disconnect()
		callback(...)
	end)

	return conn
end

function Signal:Fire(...): InvokeResult
	table.sort(self._listeners, function(a: Listener, b: Listener)
		return a.priority > b.priority
	end)
	
	local results = {}
	for i = #self._listeners, 1, -1 do
		local listener = self._listeners[i]
		if not listener.connection._connected then
			table.remove(self._listeners, i)
			continue
		end

		task.spawn(function(...)
			local success: boolean, err: any = xpcall(listener.callback, debug.traceback, ...)
			if not success then
				warn("[Signal] Listener error:\n" .. err)
			end
		end, ...)
	end
	
	if #results == 1 then
		return results[1]
		
	elseif #results > 1 then
		return results
	end
	
	return nil
end

function Signal:Wait(): any
	local thread = coroutine.running()
	local conn
	conn = self:Connect(function(...)
		conn:Disconnect()
		coroutine.resume(thread, ...)
	end)
	return coroutine.yield()
end

function Signal:DisconnectAll()
	for _, listener in self._listeners do
		listener.connection._connected = false
	end
	table.clear(self._listeners)
end

function Signal:HasConnections(): boolean
	return self:GetConnectionCount() > 0
end

function Signal:GetConnectionCount(): number
	local amount = 0

	for _, listener in self._listeners do
		if not listener.connection._connected then
			continue
		end

		amount += 1
	end

	return amount
end

function Signal:IsConnected(callback: () -> ()): boolean
	for _, listener in self._listeners do
		if callback == listener.callback then
			return true
		end
	end

	return false
end

function Signal:Destroy()
	self:DisconnectAll()
	table.clear(self)
end

return Signal
