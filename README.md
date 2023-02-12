# FSU-fvnk

### FSU-fvnk is deprecated in favor of FSU2, and most features have been re-implemented and improved over there. As such new releases of my mods are meant for use with FSU2, rather than this fork. If you still wish to use this fork, the MentalEdge.theme component is still in the Thunderstore release of FSU-fvnk: https://northstar.thunderstore.io/package/MentalEdge/FSUfvnk/

A fork merging many of the commands in fvnk's server mod into FSU, plus some extra things I did. Many similar commands merged, logical aliases set, chat messages made uniform etc.

Based on the fantastic [Fifty's Server Utilities](https://northstar.thunderstore.io/package/Fifty/Server_Utilities/) by Fifty, with lots of [fvnk's server mod](https://github.com/fvnkhead/fvnkhead.mod) sprinkled in.


If you intend to create new FSU compatible modules, the documentation on the FSU thunderstore page still applies, as I have left the actual API for command registration completely untouched. The only addition being my chat color themeing. If you use it, MentalEdge.theme must be installed alongside any module relying on it. This enables using modules created to benefit from the color themeing, with normal FSU as well.

For config, refer to the commented convars in mod.json.

Note: MentalEdge.theme needs to be installed along with FSU-fvnk even if you do not intend to modify chat colors. The MentalEdge.theme component is still included the Thunderstore release of FSUfvnk: https://northstar.thunderstore.io/package/MentalEdge/FSUfvnk/

## New in 1.0.2

- Lockdown now turns off if no admins are on
- Admins are now automatically logged out on disconnect
- Option to allow admin login to persist across matches
- Added option for random map rotation
- !help now accepts "all" argument which will print all pages
- Denser pagination for !help, items per page increased to 8, displayed in two horizontal rows rather than one vertical column
- Added !getuid command
- Mutes/Kicks can now persist, and be set to expire within a configurable number of matches
- Same as 1.0.1 but includes a comment next to admin login persistence in mod.json, and disables it by default

### Screenshots

Taken using default colors, any and all of them can be set to whatever you'd like by editing theme.nut in MentalEdge.theme.

![](https://i.imgur.com/x8eIC1T.png)

![](https://i.imgur.com/tEXQI7A.png)

![](https://i.imgur.com/GxM08nF.png)

### Available Commands

- !kick - vote kick
- !extend - extend map
- !yell/announce - announce something using HUD
- !lockdown - prevent new connections to server from all except admins
- !ban - UID ban a player
- !login/!logout - log in/out as admin
- !mute/!unmute - mute, unmute a player
- !getuid - get the UID of a player
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

Comes with some non-command features from fvnks server mod, such as killstreak/pitfall/marvin kill announcements. These can be found and enabled/disabled in mod.json.

### Additions

- Added commands: !ban, !getuid
- Support color themeing (MentalEdge.theme)
- Admin QOL/security improvements
    - Added option to require admins log in, to access chat
    - Added option to allow admin login to persist across matches
    - Admins are now automatically logged out on disconnect
    - !lockdown is disabled automatically if no admins are on
- Replaced map votes with !nextmap from fvnks server mod
    - Votes can be submitted any time during match, for any map
    - Added option to prevent votes for recently played maps or current map
    - Merged and aliased with !maps command, to view maps, simply run the same command without a vote argument
    - Option for random map rotation
- Improved pagination
    - Pages fit one more item
    - Denser pagination for !help, 8 items per page, displayed in two horizontal rows rather than one vertical column
    - Page number moved to first line
- Improvements to commands
    - !switch now kills if used while alive
    - !switch can be used on other players if admin and logged in
    - !usage command has been merged/aliased with !help
    - !help/!usage now recognizes command abbreviations/aliases
    - !help now accepts "all" argument which will print all pages
- Mutes/Kicks can now persist, and be set to expire within a configurable number of matches

### Removed

- FSU map voting - !nextmap provides the same functionality in a better way
- FSU player balancing - I recommend using my [Better Team Balancing](https://northstar.thunderstore.io/package/MentalEdge/BetterTeamBalance/) add-on to cover this

### ANSI color codes

8bit ANSI color codes are in welcome and broadcast messages written using a %-sign representing the "\x1b[38;5;" part of the color code, this was changed from original FSU in order to enable setting welcome message and broadcast message convars in docker-compose. An example of a welcome message would be:

"Run %113m!help <page\>%15m to list available commands"

The !help and <argument\> portion would get higlighted. Color codes can be found [here](https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit). To use a color, take its number and add "%" in front and "m" after. For red text, it would be "%196m", and to go back to white, use "%15m".

MentalEdge.theme contains the file "theme.nut" and needs to be used regardles of whether you want to customize the colors. If you do want to, in it you can set the color themes for all other messages by simply editing the color codes already there. The colors will apply to any of my installed mods that are used.
