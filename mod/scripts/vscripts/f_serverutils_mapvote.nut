global function FSU_Map_init

int replayLimit = 2

struct NextMapScore {
    string map
    int votes
}

struct {
    bool mapsEnabled
    array<string> maps
    bool nextMapEnabled
    array<string> nextMapOnlyMaps
    table<entity, string> nextMapVoteTable
    bool nextMapHintEnabled
    array<string> nextMapHintedPlayers
    bool nextMapRepeatEnabled

    bool skipEnabled
    float skipPercentage
    int skipThreshold
    array<entity> skipVoters
} file

void function FSU_Map_init (){
    // maps
    replayLimit = GetConVarInt("FSU_MAP_REPLAY_LIMIT")
    file.mapsEnabled = GetConVarBool("FSU_ENABLE_NEXTMAP")

    file.maps = []
    array<string> maps = split(GetConVarString("FSU_MAP_ARRAY"), ",")
    foreach (string dirtyMap in maps) {
        string map = strip(dirtyMap)
        if (!IsValidMap(map)) {
            continue
        }

        file.maps.append(map)
    }
    file.nextMapEnabled = GetConVarBool("FSU_ENABLE_NEXTMAP")
    file.nextMapOnlyMaps = []
    file.nextMapVoteTable = {}

    array<string> nextMapOnlyMaps = split(GetConVarString("FSU_MAP_ARRAY_ONLYVOTE"), ",")
    foreach (string dirtyMap in nextMapOnlyMaps) {
        string map = strip(dirtyMap)
        if (!IsValidMap(map)) {
            continue
        }
        file.nextMapOnlyMaps.append(map)
    }

    if ( FSU_GetBool("FSU_ENABLE_NEXTMAP") ) {
        FSU_RegisterCommand( "nextmap", AccentOne( FSU_GetString("FSU_PREFIX") + "nextmap <map>") + " - allow players to vote for what map to play next", "map", CommandNextMap,["nm","rtv","map","maps"] )
    }

    if ( FSU_GetBool("FSU_ENABLE_SKIP") ){
        FSU_RegisterCommand( "skip", AccentOne( FSU_GetString("FSU_PREFIX") + "skip") + " - if enough players vote, the current map will be skipped", "map", FSU_C_Skip )
        file.skipPercentage = GetConVarFloat("FSU_MAPSKIP_FRACTION")
    }


    int totalMaps = file.maps.len() + file.nextMapOnlyMaps.len()
    if (totalMaps > 0) {
        AddCallback_GameStateEnter(eGameState.Postmatch, PostmatchChangeMap)
    }

    if (file.mapsEnabled && totalMaps > 1) {
        if (file.nextMapEnabled) {
            AddCallback_GameStateEnter(eGameState.WinnerDetermined, NextMap_OnWinnerDetermined)
            AddCallback_OnClientDisconnected(NextMap_OnClientDisconnected)
        }
    }
    UpdatePlayedMaps()
}

void function UpdatePlayedMaps(){
    if(GetMapName() != "mp_lobby"){
        array <string> playedMaps = split(GetConVarString("FSU_PLAYED_MAPS"), ",")
        playedMaps.append(GetMapName())
        while (playedMaps.len() > replayLimit){
        playedMaps.remove(0)
        }
        string newMaps = ""
        foreach(string map in playedMaps){
            if (newMaps == ""){
                newMaps = map
            }
            else{
                newMaps += "," + map
            }
        }
        SetConVarString("FSU_PLAYED_MAPS", newMaps)
    }
}


void function FSU_C_Skip(entity player, array<string> args) {
    if (GetGameState() < eGameState.Playing) {
        Chat_ServerPrivateMessage(player, ErrorColor("Match hasn't begun yet!"),false)
        return
    }

    if (GetGameState() >= eGameState.WinnerDetermined) {
        Chat_ServerPrivateMessage(player, ErrorColor("Match is already over!"),false)
        return
    }

    if (args.len() == 1 && IsLoggedIn(player) && args[0] == "force" ) {
        DoSkip()
        return
    }

    if (file.skipVoters.len() == 0) {
        file.skipThreshold = int(ceil(GetPlayerArray().len() * file.skipPercentage))
    }

    if (!file.skipVoters.contains(player)) {
        file.skipVoters.append(player)
    }

    if (file.skipVoters.len() >= file.skipThreshold) {
        DoSkip()
    } else {
        Chat_ServerBroadcast( AccentTwo("[" + file.skipVoters.len() + "/" + file.skipThreshold + "]") + AnnounceColor(" players want to skip this map, ") + AccentOne("!skip") + AnnounceColor(".") )
    }

    return
}

void function DoSkip() {
    float waitTime = 5.0
    thread SkipAnnounceLoop(waitTime)
    thread DoChangeMap(waitTime)
    file.skipVoters.clear()
}

void function SkipAnnounceLoop(float waitTime) {
    int seconds = int(waitTime)
    Chat_ServerBroadcast( AnnounceColor("Map will be skipped in " + seconds + "..."))
    for (int i = seconds - 1; i > 0; i--) {
        // ctf fix, skip crashes if player has flag
        if (GameRules_GetGameMode() == CAPTURE_THE_FLAG && i <= 3) {
            KillAll()
        }

        wait 1.0
        Chat_ServerBroadcast(AnnounceColor(i + "..."))
    }
}

void function KillAll() {
    foreach (entity player in GetPlayerArray()) {
        if (IsAlive(player)) {
            player.Die()
        }
    }
}

void function Skip_OnClientDisconnected(entity player) {
    if (file.skipVoters.contains(player)) {
        file.skipVoters.remove(file.skipVoters.find(player))
    }
}



//------------------------------------------------------------------------------
// maps
//------------------------------------------------------------------------------
table<string, string> MAP_NAME_TABLE = {
    mp_angel_city = "Angel City",
    mp_black_water_canal = "Black Water Canal",
    mp_coliseum = "Coliseum",
    mp_coliseum_column = "Pillars",
    mp_colony02 = "Colony",
    mp_complex3 = "Complex",
    mp_crashsite3 = "Crash Site",
    mp_drydock = "Drydock",
    mp_eden = "Eden",
    mp_forwardbase_kodai = "Forwardbase Kodai",
    mp_glitch = "Glitch",
    mp_grave = "Boomtown",
    mp_homestead = "Homestead",
    mp_lf_deck = "Deck",
    mp_lf_meadow = "Meadow",
    mp_lf_stacks = "Stacks",
    mp_lf_township = "Township",
    mp_lf_traffic = "Traffic",
    mp_lf_uma = "UMA",
    mp_relic02 = "Relic",
    mp_rise = "Rise",
    mp_thaw = "Exoplanet",
    mp_wargames = "Wargames"
}

string function MapName(string map) {
    return MAP_NAME_TABLE[map].tolower()
}

string function MapNameCapitalized(string map) {
    return MAP_NAME_TABLE[map]
}

bool function IsValidMap(string map) {
    return map in MAP_NAME_TABLE
}

string function MapsString(array<string> maps) {
    array<string> mapNames = []
    foreach (string map in maps) {
        mapNames.append(MapNameCapitalized(map))
    }

    return Join(mapNames, ", ")
}

array<string> function AllMaps() {
    array<string> allMaps = []
    foreach (map in file.maps) {
        allMaps.append(map)
    }
    foreach (map in file.nextMapOnlyMaps) {
        allMaps.append(map)
    }
    foreach (string map in split(GetConVarString("FSU_PLAYED_MAPS"), ",")){
        allMaps.remove(allMaps.find(map))
    }

    return allMaps
}

void function CommandNextMap(entity player, array<string> args) {
    if (args.len() == 0){
        string mapsInRotation = MapsString(file.maps)
        Chat_ServerPrivateMessage(player, "Maps in rotation:" + "\n" + AccentTwo(mapsInRotation), false)
        if (file.nextMapOnlyMaps.len() > 0) {
            string voteOnlyMaps = MapsString(file.nextMapOnlyMaps)
            Chat_ServerPrivateMessage(player, "Maps by vote only:" + "\n" + AdminColor(voteOnlyMaps), false)
        }
        if (split(GetConVarString("FSU_PLAYED_MAPS"), ",").len() > 0) {
            string voteOnlyMaps = MapsString(split(GetConVarString("FSU_PLAYED_MAPS"), ","))
            Chat_ServerPrivateMessage(player, "Last maps played (not vote-able):" + "\n" + ErrorColor(voteOnlyMaps), false)
        }
        Chat_ServerPrivateMessage(player, "Use " + AccentOne("!nm <map>") + " to vote for the next map.", false)
        return
    }

    string mapName = Join(args, " ")
    array<string> foundMaps = FindMapsBySubstring(mapName)

    if (foundMaps.len() == 0) {
        Chat_ServerPrivateMessage(player, ErrorColor("Map ") + AccentOne(mapName) + ErrorColor(" not found."), false)
        return
    }

    if (foundMaps.len() > 1) {
        Chat_ServerPrivateMessage(player, ErrorColor("Multiple matches for ") + AccentOne(mapName) + ", be more specific.", false)
        return
    }

    string nextMap = foundMaps[0]
    if (!file.maps.contains(nextMap) && !file.nextMapOnlyMaps.contains(nextMap)) {
        string mapsAvailable = MapsString(AllMaps())
        Chat_ServerPrivateMessage( player, AccentOne(MapName(nextMap)) + ErrorColor(" is not in the map pool, available maps: ") + "\n" + AccentTwo(mapsAvailable), false)
        return
    }

    if (mapName == "anal") {
        Chat_ServerBroadcast(AnnounceColor(player.GetPlayerName() + " tried the funny."))
        return
    }

    if (nextMap == GetMapName() && GetConVarInt("FSU_MAP_REPLAY_LIMIT") > 0 ) {
        Chat_ServerPrivateMessage(player, ErrorColor("You can't vote for the current map!"), false)
        return
    }

    foreach(string playedMap in split(GetConVarString("FSU_PLAYED_MAPS"), ",")){
        if (nextMap == playedMap){
            Chat_ServerPrivateMessage(player, ErrorColor("You can't vote for a recently played map!"), false)
            return
        }
    }

    file.nextMapVoteTable[player] <- nextMap
    Chat_ServerBroadcast( AnnounceColor("A player has voted for ") + AccentTwo(MapNameCapitalized(nextMap)) + AnnounceColor(" to be the next map, ") + AccentOne("!nm <map>") + AnnounceColor(".") )
    return
}

void function PostmatchChangeMap() {
    thread DoChangeMap(GAME_POSTMATCH_LENGTH - 1)
}

void function DoChangeMap(float waitTime) {
    wait waitTime

    string nextMap = GetUsualNextMap()
    if (file.nextMapEnabled) {
        string drawnNextMap = DrawNextMapFromVoteTable()
        if (drawnNextMap != "") {
            nextMap = drawnNextMap
        }
    }
    GameRules_ChangeMap(nextMap, GameRules_GetGameMode())
}

string function GetUsualNextMap() {
    string currentMap = GetMapName()
    bool noPlayers = GetPlayerArray().len() == 0
    bool isLastMap = currentMap == file.maps[file.maps.len() - 1]
    bool isUnknownMap = !file.maps.contains(currentMap)
    if (noPlayers || isLastMap || isUnknownMap) {
        return file.maps[0]
    }

    string nextMap = file.maps[file.maps.find(currentMap) + 1]

    return nextMap
}

string function DrawNextMapFromVoteTable() {
    array<string> maps = []
    foreach (entity player, string map in file.nextMapVoteTable) {
        maps.append(map)
    }

    if (maps.len() == 0) {
        return ""
    }

    string nextMap = maps[RandomInt(maps.len())]
    return nextMap
}

string function NextMapCandidatesString() {
    array<NextMapScore> scores = NextMapCandidates()
    int totalVotes = file.nextMapVoteTable.len()
    array<string> chanceStrings = []
    for (int i = 0; i < scores.len(); i++) {
        NextMapScore score = scores[i]
        float chance = 100 * (float(score.votes) / float(totalVotes))
        string chanceString = format("%s (%.0f%%)", MapName(score.map), chance)
        chanceStrings.append(chanceString)
    }

    return Join(chanceStrings, ", ")
}

array<NextMapScore> function NextMapCandidates() {
    table<string, int> mapVotes = {}
    foreach (entity player, string map in file.nextMapVoteTable) {
        if (map in mapVotes) {
            int currentVotes = mapVotes[map]
            mapVotes[map] <- currentVotes + 1
        } else {
            mapVotes[map] <- 1
        }
    }

    array<NextMapScore> scores = []
    foreach (string map, int votes in mapVotes) {
        NextMapScore score
        score.map = map
        score.votes = votes
        scores.append(score)
    }

    scores.sort(NextMapScoreSort)
    return scores
}

int function NextMapScoreSort(NextMapScore a, NextMapScore b) {
    if (a.votes == b.votes) {
        return 0
    }
    return a.votes < b.votes ? 1 : -1
}

void function NextMap_OnWinnerDetermined() {
    if (file.nextMapVoteTable.len() > 0) {
        Chat_ServerBroadcast(AnnounceColor("Next map chances: " + NextMapCandidatesString()))
    }
}

void function NextMap_OnClientDisconnected(entity player) {
    if (player in file.nextMapVoteTable) {
        delete file.nextMapVoteTable[player]
    }
}

string function Join(array<string> list, string separator) {
    string s = ""
    for (int i = 0; i < list.len(); i++) {
        s += list[i]
        if (i < list.len() - 1) {
            s += separator
        }
    }

    return s
}

array<string> function FindMapsBySubstring(string substring) {
    substring = substring.tolower()
    array<string> maps = []
    foreach (string mapKey, string mapName in MAP_NAME_TABLE) {
        if (mapName.tolower().find(substring) != null) {
            maps.append(mapKey)
        }
    }

    return maps
}
