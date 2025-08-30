# Roblox Signal Class

This class is supposed to be used as a simple way for custom Signals like the roblox RBXScriptSignal

# API

.new(), returns (Signal) -> This returns a new Signal object<br/>
:Connect(callback: () -> (), priority: number?), returns (conn: Connection) -> returns a Connection object<br/>
:Once(callback: () -> ()), returns (conn: Connection) -> returns a Connection object, which is only fired once and automatically disconnected after<br/>
:Fire(...), returns none -> fires all currently connected Connections, Connection Objects made with :Once will be cleared, Connections are called in order set by priority<br/>
:Wait(), returns (...: any) -> similar to Connect, but it returns the values instead of calling a function and yields until fired<br/>
:DisconnectAll(), returns none -> Disconnects all Connection Objects<br/>
:HasConnections(), returns (boolean) -> Returns true if Signal contains Connection Objects, otherwise false<br/>
:GetConnectionCount(), returns (number) -> Returns amount of connected Connection Objects<br/>
:IsConnected(callback: () -> ()), returns (boolean) -> Returns true if callback has been connected via :Connect or :Once, otherwise false<br/>
:Destroy(), returns none -> Disconnects all Connections and clears itself<br/>
