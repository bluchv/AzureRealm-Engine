local JoinLog = {}

function JoinLog:PlayerAdded(player: Player)
	print(`{player} has joined the game.`)
end

function JoinLog:PlayerRemoving(player: Player)
	print(`{player} has left the game.`)
end

return JoinLog
