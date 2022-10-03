//------------------------------------------------------------------------------
// disclaimer: shamelessly stolen code from takyon and karma
//------------------------------------------------------------------------------

global function fm_Init

//------------------------------------------------------------------------------
// globals
//------------------------------------------------------------------------------
const int NOMAX = 9999

const int PS_MODIFIERS = 1 << 0
const int PS_ALIVE     = 1 << 1

enum PlayerSearchResultKind {
    DEAD      = -3,
    NOT_FOUND = -2,
    MULTIPLE  = -1,
    SINGLE    =  0,
    ALL       =  1,
    US        =  2,
    THEM      =  3
}

struct PlayerSearchResult {
    int kind
    array<entity> players
}

struct KickInfo {
    array<entity> voters
    int threshold
}

struct {
    bool kickEnabled
    bool kickSave
    float kickPercentage
    int kickMinPlayers
    table<string, KickInfo> kickTable
    array<string> kickedPlayers

    bool extendEnabled
    float extendPercentage
    int extendMinutes
    int extendThreshold
    array<entity> extendVoters

    bool killstreakEnabled
    int killstreakIncrement
    table<string, int> playerKillstreaks

    bool yellEnabled
    bool slayEnabled
    bool freezeEnabled
    bool stimEnabled
    bool salvoEnabled
    bool tankEnabled
    bool flyEnabled
    bool mrvnEnabled
    bool gruntEnabled

    bool jokePitfallsEnabled
    table<string, int> pitfallTable

    bool jokeMarvinEnabled
    table<string, int> marvinKillTable
    int marvinKillsTotal

    bool jokeKillsEnabled

    bool jokeEzfragsEnabled

    bool antispamEnabled
    int antispamPeriod
    int antispamLimit
    table< entity, array<float> > playerMessageTimes
} file

//------------------------------------------------------------------------------
// init
//------------------------------------------------------------------------------
void function fm_Init() {

    // kick
    file.kickEnabled = GetConVarBool("fm_kick_enabled")
    file.kickSave = GetConVarBool("fm_kick_save")
    file.kickPercentage = GetConVarFloat("fm_kick_percentage")
    file.kickMinPlayers = GetConVarInt("fm_kick_min_players")
    file.kickTable = {}
    file.kickedPlayers = []

    // extend
    file.extendEnabled = GetConVarBool("fm_extend_enabled")
    file.extendPercentage = GetConVarFloat("fm_extend_percentage")
    file.extendMinutes = GetConVarInt("fm_extend_minutes")
    file.extendThreshold = 0
    file.extendVoters = []

    file.yellEnabled = GetConVarBool("fm_yell_enabled")
    file.slayEnabled = GetConVarBool("fm_slay_enabled")
    file.freezeEnabled = GetConVarBool("fm_freeze_enabled")
    file.stimEnabled = GetConVarBool("fm_stim_enabled")
    file.salvoEnabled = GetConVarBool("fm_salvo_enabled")
    file.tankEnabled = GetConVarBool("fm_tank_enabled")
    file.flyEnabled = GetConVarBool("fm_fly_enabled")
    file.mrvnEnabled = GetConVarBool("fm_mrvn_enabled")
    file.gruntEnabled = GetConVarBool("fm_grunt_enabled")

    // player experience
    file.killstreakEnabled = GetConVarBool("fm_killstreak_enabled")
    file.killstreakIncrement = GetConVarInt("fm_killstreak_increment")
    file.playerKillstreaks = {}

    // jokes
    file.jokePitfallsEnabled = GetConVarBool("fm_joke_pitfalls_enabled")
    file.pitfallTable = {}

    file.jokeMarvinEnabled = GetConVarBool("fm_joke_marvin_enabled")
    file.marvinKillTable = {}
    file.marvinKillsTotal = 0

    file.jokeKillsEnabled = GetConVarBool("fm_joke_kills_enabled")

    file.jokeEzfragsEnabled = GetConVarBool("fm_joke_ezfrags_enabled")

    if (file.kickEnabled) {
        FSU_RegisterCommand( "kick", AccentOne( FSU_GetString("FSU_PREFIX") + "kick <full or partial player name>") + " - vote to kick a player.", "fvk", CommandKick, [] )
        AddCallback_OnPlayerRespawned(Kick_OnPlayerRespawned)
        AddCallback_OnClientDisconnected(Kick_OnClientDisconnected)
    }

    if (file.extendEnabled) {
        FSU_RegisterCommand( "extend", AccentOne( FSU_GetString("FSU_PREFIX") + "extend") + " - vote to extend map time.", "fvk", CommandExtend, ["ex"] )
        AddCallback_OnClientDisconnected(Extend_OnClientDisconnected)
    }

    if (file.yellEnabled) {
        FSU_RegisterCommand( "announce", AccentOne( FSU_GetString("FSU_PREFIX") + "announce") + " - announce something.", "fvk", CommandYell, ["yell"], IsLoggedIn )
    }

    if (file.slayEnabled) {
        FSU_RegisterCommand( "slay", AccentOne( FSU_GetString("FSU_PREFIX") + "slay <player/all/us/them>>") + " - slay players.", "fvk", CommandSlay, [], IsLoggedIn )
    }

    if (file.freezeEnabled) {
        FSU_RegisterCommand( "freeze", AccentOne( FSU_GetString("FSU_PREFIX") + "freeze <player/all/us/them>>") + " - freeze players.", "fvk", CommandFreeze, ["stop", "fr"], IsLoggedIn )
    }

    if (file.stimEnabled) {
        FSU_RegisterCommand( "stim", AccentOne( FSU_GetString("FSU_PREFIX") + "stim <player/all/us/them>") + " - give stim to players.", "fvk", CommandStim, ["speedyboi"], IsLoggedIn )
    }

    if (file.salvoEnabled) {
        FSU_RegisterCommand( "salvo", AccentOne( FSU_GetString("FSU_PREFIX") + "salvo <player/all/us/them>") + " - give flight core to players.", "fvk", CommandSalvo, [], IsLoggedIn )
    }

    if (file.tankEnabled) {
        FSU_RegisterCommand( "tank", AccentOne( FSU_GetString("FSU_PREFIX") + "tank <player/all/us/them>") + " - make players tanky.", "fvk", CommandTank, [], IsLoggedIn )
    }

    if (file.flyEnabled) {
        FSU_RegisterCommand( "fly", AccentOne( FSU_GetString("FSU_PREFIX") + "fly <player/all/us/them>") + " - make players floaty.", "fvk", CommandFly, [], IsLoggedIn )
        FSU_RegisterCommand( "unfly", AccentOne( FSU_GetString("FSU_PREFIX") + "unfly <player/all/us/them>") + " - make players not floaty.", "fvk", CommandUnfly, [], IsLoggedIn )
    }

    if (file.mrvnEnabled) {
        FSU_RegisterCommand( "mrvn", AccentOne( FSU_GetString("FSU_PREFIX") + "mrvn <player/all/us/them>") + " - spawn a marvin.", "fvk", CommandMrvn, ["marvin"], IsLoggedIn )
    }

    if (file.gruntEnabled) {
        FSU_RegisterCommand( "grunt", AccentOne( FSU_GetString("FSU_PREFIX") + "grunt <player/all/us/them>") + " - spawn a grunt.", "fvk", CommandGrunt, [], IsLoggedIn )
    }


    if (file.killstreakEnabled) {
        AddCallback_OnPlayerKilled(Killstreak_OnPlayerKilled)
    }

    if (file.jokePitfallsEnabled) {
        AddCallback_OnPlayerKilled(Pitfalls_OnPlayerKilled)
    }

    if (file.jokeMarvinEnabled) {
        AddDeathCallback("npc_marvin", Marvin_DeathCallback)
    }

    if (file.jokeKillsEnabled) {
        AddCallback_OnPlayerKilled(JokeKills_OnPlayerKilled)
    }

    // the beef
    if (file.jokeEzfragsEnabled) {
        AddCallback_OnReceivedSayTextMessage(EzfragsCallback)
    }
}

ClServer_MessageStruct function EzfragsCallback(ClServer_MessageStruct messageInfo) {
    if (messageInfo.shouldBlock) {
        return messageInfo
    }

    if (messageInfo.message.tolower().find("ezfrags") == null) {
        return messageInfo
    }

    array<string> words = []
    foreach (string word in split(messageInfo.message, " ")) {
        if (word.tolower().find("ezfrags") != null) {
            words.append("https://tinyurl.com/mrxtmpj5")
        } else {
            words.append(word)
        }
    }

    messageInfo.message = Join(words, " ")
    return messageInfo
}


//------------------------------------------------------------------------------
// kick
//------------------------------------------------------------------------------
void function CommandKick(entity player, array<string> args) {
    if (args.len() == 0){
        SendMessage(player, ErrorColor("No argument.") + " Who is it you want to kick?")
        return
    }

    string targetSearchName = args[0]
    PlayerSearchResult result = RunPlayerSearch(player, targetSearchName)
    if (result.kind < 0) {
        return
    }

    entity target = result.players[0]
    string targetUid = target.GetUID()
    string targetName = target.GetPlayerName()

    if (player == target) {
        SendMessage(player, ErrorColor("You can't kick yourself."))
        return
    }

    if (IsLoggedIn(player) && args.len() == 2 && args[1] == "force") {
        // allow admins to force kick spoofed admins
        if (IsLoggedIn(target)) {
            SendMessage(player, ErrorColor("You can't kick an authenticated admin."))
            return
        }

        print("[FSU][FVNK] " + targetName + " kicked by " + player.GetPlayerName())
        KickPlayer(target)
        return
    }

    if (CanBeAdmin(target)) {
        SendMessage(player, ErrorColor("You can't kick an admin."))
        return
    }

    // check if admin
    if (CanBeAdmin(player)){
        SendMessage(player, AdminColor("You are admin, you can force kick: ") + AccentOne("!kick " + args[0] + " force"))
    }

    if (GetPlayerArray().len() < file.kickMinPlayers) {
        // TODO: store into kicktable anyway?
        SendMessage(player, ErrorColor("Not enough players for vote kick!") + "At least " + file.kickMinPlayers + " are needed!")
        return
    }

    // ensure kicked player is in file.kickTable
    if (targetUid in file.kickTable) {
        KickInfo kickInfo = file.kickTable[targetUid]
        if (!kickInfo.voters.contains(player)){
            kickInfo.voters.append(player)
        }
    } else {
        KickInfo kickInfo
        kickInfo.voters = []
        kickInfo.voters.append(player)
        kickInfo.threshold = Threshold(GetPlayerArray().len(), file.kickPercentage)
        file.kickTable[targetUid] <- kickInfo
        AnnounceMessage( AnnounceColor("A vote to kick ") + UsernameColor(targetName) + AnnounceColor(" has been started!") )
    }

    // kick if votes exceed threshold
    KickInfo kickInfo = file.kickTable[targetUid]
    if (kickInfo.voters.len() >= kickInfo.threshold) {
        print("[FSU][FVNK] " + targetName + " kicked by player vote!")
        KickPlayer(target)
    } else {
        AnnounceMessage( AccentTwo("[" + kickInfo.voters.len() + "/" + kickInfo.threshold + "]") + AnnounceColor(" players have voted to kick ") + UsernameColor(targetName) + AnnounceColor(", ") + AccentOne("!kick <player>") + AnnounceColor(".") )
    }

    return
}

void function KickPlayer(entity player, bool announce = true) {
    string playerUid = player.GetUID()
    if (playerUid in file.kickTable) {
        delete file.kickTable[playerUid]
    }

    if (file.kickSave && !file.kickedPlayers.contains(playerUid)) {
        file.kickedPlayers.append(playerUid)
    }

    ServerCommand("kick " + player.GetPlayerName())
    if (announce) {
        AnnounceMessage(UsernameColor(player.GetPlayerName()) + SuccessColor(" has been kicked"))
    }
}

void function Kick_OnPlayerRespawned(entity player) {
    if (file.kickedPlayers.contains(player.GetUID())) {
        print("[FSU][FVNK] previously kicked " + player.GetPlayerName() + " tried to rejoin")
        KickPlayer(player, false)
    }
}

void function Kick_OnClientDisconnected(entity player) {
    foreach (string targetUid, KickInfo kickInfo in file.kickTable) {
        array<entity> voters = kickInfo.voters
        if (voters.contains(player)) {
            voters.remove(voters.find(player))
        }

        if (voters.len() == 0) {
            delete file.kickTable[targetUid]
        } else {
            kickInfo.voters = voters
            file.kickTable[targetUid] = kickInfo
        }
    }
}


//------------------------------------------------------------------------------
// extend
//------------------------------------------------------------------------------
void function CommandExtend( entity player, array <string> args ) {

    if (file.extendVoters.len() == 0) {
        file.extendThreshold = Threshold(GetPlayerArray().len(), file.extendPercentage)
    }

    if (!file.extendVoters.contains(player)) {
        file.extendVoters.append(player)
    }

    if (file.extendVoters.len() >= file.extendThreshold) {
        DoExtend()
    } else {
        AnnounceMessage( AccentTwo("[" + file.extendVoters.len() + "/" + file.extendThreshold + "]") + AnnounceColor(" players want to extend the map, ") + AccentOne("!extend") + AnnounceColor(".") )
    }
}

void function DoExtend() {
    float currentEndTime = expect float(GetServerVar("gameEndTime"))
    float newEndTime = currentEndTime + (60 * file.extendMinutes)
    SetServerVar("gameEndTime", newEndTime)

    AnnounceMessage(SuccessColor("Map has been extended!"))

    file.extendVoters.clear()
}

void function Extend_OnClientDisconnected(entity player) {
    if (file.extendVoters.contains(player)) {
        file.extendVoters.remove(file.extendVoters.find(player))
    }
}

//------------------------------------------------------------------------------
// yell
//------------------------------------------------------------------------------
void function CommandYell(entity player, array<string> args) {
    if (args.len() == 0){
        SendMessage(player, ErrorColor("No argument.") + "What is it you want to announce?")
        return
    }

    string msg = Join(args, " ").toupper()
    AnnounceHUD(msg, 255, 200, 200)
}

//------------------------------------------------------------------------------
// slay
//------------------------------------------------------------------------------
void function CommandSlay(entity player, array<string> args) {
    if (args.len() == 0){
        SendMessage(player, ErrorColor("No argument.") + " Who is it you want to slay?")
        return
    }
    string targetSearchName = args[0]
    PlayerSearchResult result = RunPlayerSearch(player, targetSearchName, PS_MODIFIERS | PS_ALIVE)
    if (result.kind < 0) {
        return
    }

    foreach (entity target in result.players) {
        if (IsAlive(target)) {
            target.Die()
        }
    }

    string name = PlayerSearchResultName(player, result)
    AnnounceMessage(UsernameColor(name) + AnnounceColor(" has been slain!"))
}

//------------------------------------------------------------------------------
// freeze
//------------------------------------------------------------------------------
void function CommandFreeze(entity player, array<string> args) {
    if (args.len() == 0){
        SendMessage(player, ErrorColor("No argument.") + " Who is it you want to freeze?")
        return
    }
    string targetSearchName = args[0]
    PlayerSearchResult result = RunPlayerSearch(player, targetSearchName, PS_MODIFIERS | PS_ALIVE)
    if (result.kind < 0) {
        return
    }

    foreach (entity target in result.players) {
        if (IsAlive(target)) {
            target.MovementDisable()
            target.ConsumeDoubleJump()
            target.DisableWeaponViewModel()
        }
    }

    string name = PlayerSearchResultName(player, result)
    AnnounceMessage(UsernameColor(name) + AnnounceColor( " has been frozen!"))
}

//------------------------------------------------------------------------------
// stim
//------------------------------------------------------------------------------
void function CommandStim(entity player, array<string> args) {
    if (args.len() == 0){
        SendMessage(player, ErrorColor("No argument.") + " Who is it you want to make a speedy boi?")
        return
    }
    string targetSearchName = args[0]
    PlayerSearchResult result = RunPlayerSearch(player, targetSearchName, PS_MODIFIERS | PS_ALIVE)
    if (result.kind < 0) {
        return
    }

    foreach (entity target in result.players) {
        if (IsAlive(target)) {
            StimPlayer(target, 9999)
        }
    }

    string name = PlayerSearchResultName(player, result)
    AnnounceMessage(UsernameColor(name) + AnnounceColor(" is going fast!"))
}

//------------------------------------------------------------------------------
// salvo
//------------------------------------------------------------------------------
void function CommandSalvo(entity player, array<string> args) {
    if (args.len() == 0){
        SendMessage(player, ErrorColor("No argument.") + " Who is it you want to death from above?")
        return
    }
    string targetSearchName = args[0]
    PlayerSearchResult result = RunPlayerSearch(player, targetSearchName, PS_MODIFIERS | PS_ALIVE)
    if (result.kind < 0) {
        return
    }

    foreach (entity target in result.players) {
        if (!IsAlive(target)) {
            continue
        }

        foreach (entity weapon in target.GetMainWeapons()) {
            target.TakeWeaponNow(weapon.GetWeaponClassName())
        }
        target.GiveWeapon("mp_titanweapon_flightcore_rockets", [])
    }

    string name = PlayerSearchResultName(player, result)
    AnnounceMessage(UsernameColor(name) + AnnounceColor(" has flight core!"))
}

//------------------------------------------------------------------------------
// tank
//------------------------------------------------------------------------------
void function CommandTank(entity player, array<string> args) {
    if (args.len() == 0){
        SendMessage(player, ErrorColor("No argument.") + " Who is it you want to make tanky?")
        return
    }
    string targetSearchName = args[0]
    PlayerSearchResult result = RunPlayerSearch(player, targetSearchName, PS_MODIFIERS | PS_ALIVE)
    if (result.kind < 0) {
        return
    }

    int health = 1000
    foreach (entity target in result.players) {
        if (IsAlive(target)) {
            target.SetMaxHealth(health)
            target.SetHealth(health)
        }
    }

    string name = PlayerSearchResultName(player, result)
    AnnounceMessage(UsernameColor(name) + AnnounceColor(" is tanky!"))
}

//------------------------------------------------------------------------------
// fly
//------------------------------------------------------------------------------
void function CommandFly(entity player, array<string> args) {
    if (args.len() == 0){
        SendMessage(player, ErrorColor("No argument.") + " Who is it you want make floaty?")
        return
    }
    string targetSearchName = args[0]
    PlayerSearchResult result = RunPlayerSearch(player, targetSearchName, PS_MODIFIERS | PS_ALIVE)
    if (result.kind < 0) {
        return
    }

    foreach (entity target in result.players) {
        if (IsAlive(target)) {
            target.SetPhysics(MOVETYPE_NOCLIP)
        }
    }

    string name = PlayerSearchResultName(player, result)
    AnnounceMessage(UsernameColor(name) + AnnounceColor(" is flying!"))
}

void function CommandUnfly(entity player, array<string> args) {
    if (args.len() == 0){
        SendMessage(player, ErrorColor("No argument.") + " Who is it you want to take te gift of flight away from?")
        return
    }
    string targetSearchName = args[0]
    PlayerSearchResult result = RunPlayerSearch(player, targetSearchName, PS_MODIFIERS | PS_ALIVE)
    if (result.kind < 0) {
        return
    }

    foreach (entity target in result.players) {
        if (IsAlive(target)) {
            target.SetPhysics(MOVETYPE_WALK)
        }
    }

    string name = PlayerSearchResultName(player, result)
    AnnounceMessage(UsernameColor(name) + AnnounceColor(" is no longer flying!"))
}

//------------------------------------------------------------------------------
// mrvn
//------------------------------------------------------------------------------

void function CommandMrvn(entity player, array<string> args) {
    int health = 1000
    entity marvin = CreateMarvin(TEAM_UNASSIGNED, player.GetOrigin(), player.GetAngles())
    marvin.kv.health = health
    marvin.kv.max_health = health
    DispatchSpawn(marvin)
    HideName(marvin)

    thread MarvinJobThink(marvin)
}

void function CommandGrunt(entity player, array<string> args) {
    string targetSearchName = args.len() == 1 ? args[0] : "me"
    PlayerSearchResult result = RunPlayerSearch(player, targetSearchName, PS_MODIFIERS | PS_ALIVE)
    if (result.kind < 0) {
        return
    }

    foreach (entity target in result.players) {
        if (!IsAlive(target)) {
            continue
        }

        entity grunt = CreateSoldier(target.GetTeam(), target.GetOrigin(), target.GetAngles())
        DispatchSpawn(grunt)
        string squadName = format("%s_%d", target.GetPlayerName(), target.GetTeam())
        SetSquad(grunt, squadName)
        grunt.EnableNPCFlag(NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE)
    }
}


//------------------------------------------------------------------------------
// killstreak
//------------------------------------------------------------------------------
void function Killstreak_OnPlayerKilled(entity victim, entity attacker, var damageInfo) {
    if (!victim.IsPlayer() || !attacker.IsPlayer() || GetGameState() != eGameState.Playing) {
        return
    }

    string victimName = victim.GetPlayerName()
    string attackerName = attacker.GetPlayerName()

    int victimKillstreak = GetKillstreak(victim)
    int attackerKillstreak = GetKillstreak(attacker)
    if (victimKillstreak >= file.killstreakIncrement) {
        string msg = ErrorColor(attackerName)
        msg += AnnounceColor(" ended ")
        msg += ErrorColor(victimName + "'s")
        msg += AnnounceColor(" " + victimKillstreak + "-kill streak")
        AnnounceMessage(msg)
    }

    SetKillstreak(victim, 0)
    if (attacker == victim) {
        return
    }

    attackerKillstreak += 1
    if (attackerKillstreak % file.killstreakIncrement == 0) {
        string msg = ErrorColor(attackerName)
        msg += AnnounceColor(" is on a " + attackerKillstreak + "-kill streak")
        AnnounceMessage(msg)
    }

    SetKillstreak(attacker, attackerKillstreak)
}

int function GetKillstreak(entity player) {
    string uid = player.GetUID()
    return uid in file.playerKillstreaks ? file.playerKillstreaks[uid] : 0
}

void function SetKillstreak(entity player, int killstreak) {
    string uid = player.GetUID()
    file.playerKillstreaks[uid] <- killstreak
}

//------------------------------------------------------------------------------
// pitfall joke
//------------------------------------------------------------------------------
table<string, string> PITFALL_MAP_SUBJECT_TABLE = {
    mp_glitch            = "into the pit",
    mp_wargames          = "into the pit",
    mp_crashsite3        = "into the pit",
    mp_drydock           = "off the map",
    mp_relic02           = "off the map",
    mp_complex3          = "off the map",
    mp_forwardbase_kodai = "off the map"
}

void function Pitfalls_OnPlayerKilled(entity victim, entity attacker, var damageInfo) {
    string map = GetMapName()
    if (!(map in PITFALL_MAP_SUBJECT_TABLE)) {
        return
    }

    if (!victim.IsPlayer() || GetGameState() != eGameState.Playing) {
        return
    }
    
    int damageSourceId = DamageInfo_GetDamageSourceIdentifier(damageInfo)
    if (damageSourceId != eDamageSourceId.fall) {
        return
    }

    string playerName = victim.GetPlayerName()
    int count = 1
    if (playerName in file.pitfallTable) {
        count = file.pitfallTable[playerName] + 1
    }

    string subject = PITFALL_MAP_SUBJECT_TABLE[map]
    string msg = playerName + " has fallen " + subject + " " + count + " times!"
    if (count == 1) {
        msg = playerName + " fell " + subject
    } else if (count == 2) {
        msg = playerName + " fell " + subject + ", again :D"
    }

    AnnounceMessage(AnnounceColor(msg))

    file.pitfallTable[playerName] <- count
}

//------------------------------------------------------------------------------
// marvin joke
//------------------------------------------------------------------------------
void function Marvin_DeathCallback(entity victim, var damageInfo) {
    entity attacker = DamageInfo_GetAttacker(damageInfo)
    if (!IsValid(attacker) || !attacker.IsPlayer()) {
        return
    }

    file.marvinKillsTotal += 1

    string playerName = attacker.GetPlayerName()
    int count = 1
    if (playerName in file.marvinKillTable) {
        count = file.marvinKillTable[playerName] + 1
    }

    string msg = playerName + " has killed " + count + " marvins!"
    if (count == 1) {
        msg = playerName + " killed a marvin!"
    } else if (count == 2) {
        msg = playerName + " killed a marvin, again D:"
    }

    AnnounceMessage(AnnounceColor(msg))

    file.marvinKillTable[playerName] <- count
}

//------------------------------------------------------------------------------
// kill jokes
//------------------------------------------------------------------------------
void function JokeKills_OnPlayerKilled(entity victim, entity attacker, var damageInfo) {
    if (!attacker.IsPlayer() || !victim.IsPlayer() || GetGameState() != eGameState.Playing) {
        return
    }
    
    int damageSourceId = DamageInfo_GetDamageSourceIdentifier(damageInfo)
    string verb
    switch (damageSourceId) {
        case eDamageSourceId.phase_shift:
            verb = "got phased by!"
            break
        default:
            return
    }

    string attackerName = attacker.GetPlayerName()
    string victimName = victim.GetPlayerName()
    string msg = format("%s %s %s", victimName, verb, attackerName)

    AnnounceMessage(AnnounceColor(msg))
}

//------------------------------------------------------------------------------
// utils
//------------------------------------------------------------------------------

PlayerSearchResult function RunPlayerSearch(
    entity commandUser,
    string playerName,
    int flags = 0x0
) {
    PlayerSearchResult result
    result.kind = PlayerSearchResultKind.NOT_FOUND
    result.players = []

    if ((flags & PS_MODIFIERS) > 0) {
        switch (playerName.tolower()) {
            case "me":
                result.kind = PlayerSearchResultKind.SINGLE
                result.players.append(commandUser)
                return result

            case "all":
                result.kind = PlayerSearchResultKind.ALL
                result.players = GetPlayerArray()
                return result

            case "us":
                if (IsFFAGame()) {
                    result.kind = PlayerSearchResultKind.ALL
                    result.players = GetPlayerArray()
                    return result
                }
                result.kind = PlayerSearchResultKind.US
                result.players = GetPlayerArrayOfTeam(commandUser.GetTeam())
                return result

            case "them":
                if (IsFFAGame()) {
                    result.kind = PlayerSearchResultKind.ALL
                    result.players = GetPlayerArray()
                    return result
                }
                result.kind = PlayerSearchResultKind.THEM
                result.players = GetPlayerArrayOfTeam(GetOtherTeam(commandUser.GetTeam()))
                return result
            default:
                break
        }
    }

    result.players = FindPlayersBySubstring(playerName)
    if (result.players.len() == 0) {
        SendMessage(commandUser, ErrorColor("Player matching ") + UsernameColor(playerName) + ErrorColor(" not found!"))
        result.kind = PlayerSearchResultKind.NOT_FOUND
        return result
    }

    if (result.players.len() > 1) {
        SendMessage(commandUser, ErrorColor("There are multiple matching players for ") + UsernameColor(playerName) + ErrorColor(", be more specific."))
        result.kind = PlayerSearchResultKind.MULTIPLE
        return result
    }

    if ((flags & PS_ALIVE) > 0) {
        entity target = result.players[0]
        if (!IsAlive(target)) {
            SendMessage(commandUser, ErrorColor(target.GetPlayerName() + " is dead."))
            result.kind = PlayerSearchResultKind.DEAD
            return result
        }
    }

    result.kind = PlayerSearchResultKind.SINGLE
    return result
}

string function TeamName(int team) {
    if (team == TEAM_IMC) {
        return "IMC"
    } else if (team == TEAM_MILITIA) {
        return "Militia"
    }

    return "???"
}

string function PlayerSearchResultName(entity commandUser, PlayerSearchResult result) {
    switch (result.kind) {
        case PlayerSearchResultKind.SINGLE:
            return result.players[0].GetPlayerName()

        case PlayerSearchResultKind.ALL:
            return "Everyone"

        case PlayerSearchResultKind.US:
            if (IsFFAGame()) {
                return "Everyone"
            }
            int usTeam = commandUser.GetTeam()
            return "Team " + TeamName(usTeam)

        case PlayerSearchResultKind.THEM:
            if (IsFFAGame()) {
                return "Everyone"
            }
            int themTeam = GetOtherTeam(commandUser.GetTeam())
            return "Team " + TeamName(themTeam)

        default:
            break
    }
    return ErrorColor("??? fvnhead pls fix ???")
}

// string function ErrorColor(string s) {
//     return "\x1b[112m" + s
// }
//
// string function PrivateColor(string s) {
//     return "\x1b[111m" + s
// }
//
// string function AnnounceColor(string s) {
//     return "\x1b[95m" + s
// }
//
// string function White(string s) {
//     return "\x1b[0m" + s
// }
//
// string function Green(string s) {
//     return "\x1b[92m" + s
// }

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

int function Threshold(int count, float percentage) {
    return int(ceil(count * percentage))
}

void function SendMessage(entity player, string text) {
    thread AsyncSendMessage(player, text)
    // TODO: testing
    //Chat_ServerPrivateMessage(player, text, false)
}

void function AsyncSendMessage(entity player, string text) {
    wait 0.1

    if (!IsValid(player)) {
        return
    }

    Chat_ServerPrivateMessage(player, text, false)
}

void function AnnounceMessage(string text) {
    AsyncAnnounceMessage(text)
    // TODO: testing
    //Chat_ServerBroadcast(text)
}

void function AsyncAnnounceMessage(string text) {
    foreach (entity player in GetPlayerArray()) {
        SendMessage(player, text)
    }
    // TODO: testing
    //Chat_ServerBroadcast(text)
}

void function SendHUD(entity player, string msg, int r, int g, int b, int time = 10) {
    SendHudMessage(player, msg, -1, 0.2, r, g, b, 255, 0.15, time, 1)
}

void function AnnounceHUD(string msg, int r, int g, int b, int time = 10) {
    foreach (entity player in GetPlayerArray()) {
        SendHUD(player, msg, r, g, b, time)
    }
}

array<entity> function FindPlayersBySubstring(string substring) {
    substring = substring.tolower()
    array<entity> players = []
    foreach (entity player in GetPlayerArray()) {
        string name = player.GetPlayerName().tolower()
        if (name.find(substring) != null) {
            players.append(player)
        }
    }

    return players
}

bool function IsCTF() {
    return GameRules_GetGameMode() == CAPTURE_THE_FLAG
}
