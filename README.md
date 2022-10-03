# FSU-fvnk

A fork merging many of the commands in fvnk's server mod into FSU, plus some extras things I did. Many similar commands merged, chat messages made uniform etc.

### Available Commands

- !kick - vote kick
- !extend - extend map
- !yell/announce - announce something using HUD
- !slay - slay a player/team/everyone
- !freeze - freeze a player
- !stim - give someone stim
- !salvo - give someone flight core
- !tank - make someone tanky
- !fly - noclip
- !marvn - spawn a marvin
- !grunt - spawn a grunt
- !nextmap - vote for the next map, or view rotations
- !lockdown - prevent new connections to server from all except admins
- !ban - UID ban a player
- !login/!logout - log in/out as admin
- !mute/!unmute - mute, unmute a player
- !help - display commands, or the instructions of one
- !name - display server name
- !owner - display server host
- !mods - list mods
- !rules - display rules
- !discord - display server discord details
- !switch - switch teams, or, if admin, switch someone elses team
- !nextmap - vote for the next map or view current maps in rotation
- !skip - skip map

### Additions

- Added admin command: !ban
- Support color themeing (MentalEdge.theme)
- Added option to require admins log in, to access chat
- Replaced map votes with !nextmap from fvnks server mod
    - Votes can be submitted any time during match, for any map
    - Added option to prevent votes for recent/current map
    - Merged with !maps command, to view maps, simply run the same command without a vote argument
- Improved pagination
    - Pages fit one more item
    - Page number moved to first line
- !switch now kills if used while alive
- !switch can be used on other players if admin and logged in
- !usage command has been merged into !help
- !help/!usage now also recognizes command abbreviations/aliases

