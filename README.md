# FSU-fvnk

A fork merging many of the commands in fvnk's server mod into FSU, plus some extra things I did. Many similar commands merged, logical aliases set, chat messages made uniform etc.

Based on the fantastic [Fifty's Server Utilities](https://northstar.thunderstore.io/package/Fifty/Server_Utilities/) by Fifty, with lots of [fvnk's server mod](https://github.com/fvnkhead/fvnkhead.mod) sprinkled in.

Fully FSU compatible! This is a drop-in FSU core replacement. Compatible with my [Better Team Balancing](https://northstar.thunderstore.io/package/MentalEdge/BetterTeamBalance/) and [MentalreBalance](https://northstar.thunderstore.io/package/MentalEdge/MentalreBalance/) mods, the former of which I highly recommend to *all* server hosts.

If you intend to create new FSU compatible modules, the documentation on the FSU thunderstore page still applies, as I have left the actual API for command registration completely untouched. The only addition being my chat color themeing. If you use it, MentalEdge.theme must be installed alongside any module relying on it. This enables using a modules created to benefit from the color themeing, with normal FSU as well.

For config, refer to the commented convars in mod.json.

### Available Commands

- !kick - vote kick
- !extend - extend map
- !yell/announce - announce something using HUD
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
- !slay - slay a player/team/everyone
- !freeze - freeze a player
- !stim - give someone stim
- !salvo - give someone flight core
- !tank - make someone tanky
- !fly - noclip
- !marvn - spawn a marvin
- !grunt - spawn a grunt

Also of course still includes the spam handling from FSU.

### Additions

- Added admin command: !ban
- Support color themeing (MentalEdge.theme)
- Added option to require admins log in, to access chat
- Replaced map votes with !nextmap from fvnks server mod
    - Votes can be submitted any time during match, for any map
    - Added option to prevent votes for recent/current map
    - Merged and aliased with !maps command, to view maps, simply run the same command without a vote argument
- Improved pagination
    - Pages fit one more item
    - Page number moved to first line
- !switch now kills if used while alive
- !switch can be used on other players if admin and logged in
- !usage command has been merged/aliased into !help
- !help/!usage now recognizes command abbreviations/aliases

### Removed

- FSU map voting - !nextmap provides the same functionality in a better way
- FSU player balancing - I recommend using my [Better Team Balancing](https://northstar.thunderstore.io/package/MentalEdge/BetterTeamBalance/) add-on to cover this

### ANSI color codes

8bit ANSI color codes are in welcome and broadcast messages written using a %-sign representing the "\x1b[38;5;" part of the color code, this was changed from original FSU in order to enable setting welcome message and broadcast message convars in docker-compose. An example of a welcome message would be:

"Run %113m!help <page\>%15m to list available commands"

The !help and <argument\> portion would get higlighted. Color codes can be found [here](https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit). To use a color, take its number and add "%" in front and "m" after. For red text, it would be "%196m", and to go back to white, use "%15m".

MentalEdge.theme contains the file "theme.nut". In it you can set the color themes for all other messages by simply editing the color codes already there.
