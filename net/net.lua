Zeta.Net = Zeta.Net or Zeta.Events.EventEmitter()
Zeta.Net.Receivers = Zeta.Net.Receivers or {}
Zeta.Net.MaxChunkSize = 40000

function Zeta.Net.Receive(name, callback)
	Zeta.Net.Pool(name)
	Zeta.Net.Receivers[name] = callback

	net.Receive(name, function(length, ply)
		local data = Zeta.Serialization.Pon.Deserialize(net.ReadData(net.ReadUInt(32)))

		if data then
			if SERVER then
				callback(ply, unpack(data))
			else
				callback(unpack(data))
			end
		end
	end)
end

function Zeta.Net.Pool(networkStrings)
	if SERVER then
		if type(networkStrings) == "table" then
			for _, networkString in ipairs(networkStrings) do
				util.AddNetworkString(networkString)
			end
		else
			util.AddNetworkString(networkStrings)
		end
	end
end

if SERVER then
	Zeta.Net.ChunkTransferNumber = Zeta.Net.ChunkTransferNumber or 1
	Zeta.Net.Pool("ZetaChunk")

	function Zeta.Net.Send(name, players, ...)
		local data = Zeta.Serialization.Pon.Serialize({...})

		if type(players) == "Player" and IsValid(players) then
			players = {players}
		elseif not players then
			players = player.GetAll()
		end

		net.Start(name)
			net.WriteUInt(#data, 32)
			net.WriteData(data, #data)
		net.Send(players)
	end

	function Zeta.Net.SendChunked(name, players, ...)
		local data = Zeta.Serialization.Pon.Serialize({...})
		local networkId = util.NetworkStringToID(name)
		local chunks = {}
		local totalChunks = 1
		local chunkNumber = 1

		for chunkPortion = 1, #data, Zeta.Net.MaxChunkSize do
			chunks[#chunks + 1] = data:sub(chunkPortion, (chunkPortion + Zeta.Net.MaxChunkSize) - 1)
		end

		totalChunks = #chunks

		timer.Create("Zeta.ChunkTransfer" .. Zeta.Net.ChunkTransferNumber, 0.1, totalChunks, function()
			local chunk = table.remove(chunks, 1)

			Zeta.Net.Send("ZetaChunk", players, networkId, Zeta.Net.ChunkTransferNumber, chunkNumber, totalChunks, chunk)
			Zeta.Net:Emit("ChunkProgress", players, networkId, chunkNumber, totalChunks, chunk)
			chunkNumber = chunkNumber + 1
		end)

		Zeta.Net.ChunkTransferNumber = Zeta.Net.ChunkTransferNumber + 1
	end
else
	Zeta.Net.ChunkTranfers = Zeta.Net.ChunkTranfers or {}

	function Zeta.Net.Send(name, ...)
		local data = Zeta.Serialization.Pon.Serialize({...})

		net.Start(name)
			net.WriteUInt(#data, 32)
			net.WriteData(data, #data)
		net.SendToServer()
	end

	Zeta.Net.Receive("ZetaChunk", function(networkId, chunkTransferNumber, chunkNumber, totalChunks, chunk)
		local receiver = Zeta.Net.Receivers[util.NetworkIDToString(networkId)]

		if receiver then
			Zeta.Net:Emit("ChunkProgress", networkId, chunkNumber, totalChunks, chunk)

			Zeta.Net.ChunkTranfers[chunkTransferNumber] = Zeta.Net.ChunkTranfers[chunkTransferNumber] or Zeta.String()
			Zeta.Net.ChunkTranfers[chunkTransferNumber]:Append(chunk)

			if chunkNumber == totalChunks then
				local data = Zeta.Serialization.Pon.Deserialize(tostring(Zeta.Net.ChunkTranfers[chunkTransferNumber]))

				Zeta.Net.ChunkTranfers[chunkTransferNumber] = nil
				receiver(unpack(data))
			end
		end
	end)
end