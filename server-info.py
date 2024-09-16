import json
from steam import game_servers

server_address = ('54.37.39.245', 27015)
server_info = game_servers.a2s_info(server_address)
print(json.dumps(server_info, indent=4))

# Query the server for player information
players = game_servers.a2s_players(server_address)
print(json.dumps(players, indent=4))
