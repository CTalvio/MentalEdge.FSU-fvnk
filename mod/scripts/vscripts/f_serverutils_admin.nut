// Disabled for now

global function FSU_Admin_init
global function IsLoggedIn
global function CanBeAdmin

// array< UID >
array<string> loggedin_admins


void function FSU_Admin_init()
{
  AddCallback_OnClientConnected(Lockdown_OnPlayerConnected)
  AddCallback_OnClientConnected(Lockdown_OnPlayerConnected)

  FSU_RegisterCommand( "login", AccentOne( FSU_GetString("FSU_PREFIX") + "login <password>") + " - login as admin", "admin", FSU_C_Login, ["auth"], CanBeAdmin )
  FSU_RegisterCommand( "logout", AccentOne( FSU_GetString("FSU_PREFIX") + "logout") + " - logout", "admin", FSU_C_Logout, [], IsLoggedIn )
  FSU_RegisterCommand( "mute", AccentOne( FSU_GetString("FSU_PREFIX") + "mute <player>") + " - to mute player", "admin", FSU_C_Mute, [], IsLoggedIn )
  FSU_RegisterCommand( "unmute", AccentOne( FSU_GetString("FSU_PREFIX") + "unmute <player>") + " - to unmute player", "admin", FSU_C_Unmute, [], IsLoggedIn )
  FSU_RegisterCommand( "kick", AccentOne( FSU_GetString("FSU_PREFIX") + "kick <player>") + " - to kick player", "admin", FSU_C_Kick, [], IsLoggedIn )
  FSU_RegisterCommand( "kill", AccentOne( FSU_GetString("FSU_PREFIX") + "kill <player>") + "- to kill player", "admin", FSU_C_Kill, [], IsLoggedIn )
  FSU_RegisterCommand( "ban", AccentOne( FSU_GetString("FSU_PREFIX") + "ban <player>") + " - to ban player", "admin", FSU_C_Ban, [], IsLoggedIn )
  FSU_RegisterCommand( "lockdown", AccentOne( FSU_GetString("FSU_PREFIX") + "lockdown <up/down>") + " - to prevent/enable players joining the game", "admin", FSU_C_Lockdown, ["quarantine", "lock"], IsLoggedIn )
}

bool function CanBeAdmin( entity player )
{
  foreach ( admin in FSU_GetArray("FSU_ADMIN_UIDS") )
    if( admin == player.GetUID() )
      return true

  return false
}

bool function IsLoggedIn( entity player )
{
  // Check if already logged in
  foreach( uid in loggedin_admins )
  {
    if( player.GetUID() == uid )
    {
      return true
    }
  }
  
  return false
}

bool function Login( entity player )
{  
  // Check if already logged in
  if( IsLoggedIn( player ) )
  {
    Chat_ServerPrivateMessage( player, ErrorColor("Already logged in!"), false )
    return false
  }
  
  // Log in
  loggedin_admins.append( player.GetUID() )
  return true
}

bool function Logout( entity player )
{
  if( IsLoggedIn( player ) )
  {
    loggedin_admins.remove( loggedin_admins.find( player.GetUID() ) )
    Chat_ServerPrivateMessage( player, AdminColor("Logged out!"), false )
    return true
  }
  
  return false
}

bool function CheckPlayerDuplicates( entity player )
{
  int occurences = 0
  foreach( p in GetPlayerArray() )
  {
    if( p.GetUID() == player.GetUID() )
      occurences++
  }
  
  // more than one player with same UID, log everyone out
  if( occurences > 1 )
  {
    foreach( p in GetPlayerArray() )
    {
      Chat_ServerPrivateMessage( p, ErrorColor("Found duplicate UID!") + AdminColor(" logging everyone out!"), false )
      Logout( player )
    }
    return true
  }
  
  return false
}

void function FSU_C_Ban ( entity player, array < string > args ){
  if (args.len() == 0){
    Chat_ServerPrivateMessage(player, ErrorColor("No argument.") + AdminColor(" Who is it you want to ban?"), false )
    return
  }
  foreach ( p in GetPlayerArray() )
  {
    if( p.GetPlayerName().tolower().find( args[0].tolower() ) != null )
    {
      Chat_ServerPrivateMessage( player, AdminColor("Banned ") + UsernameColor(p.GetPlayerName()) + AdminColor("!"), false )
      ServerCommand( "ban " + p.GetUID() )
      return
    }
  }
  Chat_ServerPrivateMessage( player, ErrorColor("Couldn't find a player matching ") + UsernameColor(args[0]) + ErrorColor("!"), false )
}


void function FSU_C_Kill ( entity player, array < string > args ){
  if (args.len() == 0){
    Chat_ServerPrivateMessage(player, ErrorColor("No argument.") + AdminColor(" Who is it you want to kill?"), false )
    return
  }
  foreach ( p in GetPlayerArray() )
  {
    if( p.GetPlayerName().tolower().find( args[0].tolower() ) != null )
    {
      if (IsAlive(p)){
        Chat_ServerPrivateMessage( player, AdminColor("Killed ") + UsernameColor(p.GetPlayerName()) + AdminColor("!"), false )
        p.Die()
      }
      else{
        Chat_ServerPrivateMessage( player, UsernameColor(p.GetPlayerName()) + ErrorColor(" is already dead!"), false )
      }
      return
    }
  }
  Chat_ServerPrivateMessage( player, ErrorColor("Couldn't find a player matching ") + UsernameColor(args[0]) + ErrorColor("!"), false )
}

void function FSU_C_Kick ( entity player, array < string > args ){
  if (args.len() == 0){
    Chat_ServerPrivateMessage(player, ErrorColor("No argument.") + AdminColor(" Who is it you want to kick?"), false )
    return
  }
  foreach ( p in GetPlayerArray() )
  {
    if( p.GetPlayerName().tolower().find( args[0].tolower() ) != null )
    {
      Chat_ServerPrivateMessage( player, AdminColor("Kicked ") + UsernameColor(p.GetPlayerName()) + AdminColor("!"), false )
      ServerCommand( "kickid " + p.GetUID() )
      return
    }
  }
  Chat_ServerPrivateMessage( player, ErrorColor("Couldn't find a player matching ") + UsernameColor(args[0]) + ErrorColor("!"), false )
}


bool lockdown = false

void function FSU_C_Lockdown ( entity player, array < string > args ){
  if (args.len() == 0){
    Chat_ServerPrivateMessage( player, ErrorColor("Missing argument!") + AdminColor(" Use ") + AccentOne("up") + AdminColor(" or ") + AccentOne("down") + AdminColor(" to enable/disable lockdown."), false )
    return
  }
  if (args[0] == "up"){
    if (!lockdown){
      lockdown = true
      Chat_ServerPrivateMessage( player, AdminColor("Server is in lockdown!"), false )
      return
    }
    Chat_ServerPrivateMessage( player, ErrorColor("Server is already in lockdown!"), false )
    return
  }
  else if (args[0] == "down"){
    if (lockdown){
      lockdown = false
      Chat_ServerPrivateMessage( player, AdminColor("Server is no longer in lockdown!"), false )
      return
    }
    Chat_ServerPrivateMessage( player, ErrorColor("Server is not in lockdown!"), false )
    return
  }
}

void function Lockdown_OnPlayerConnected(entity player) { //Prevent new connections during lockdown
    if (!lockdown || CanBeAdmin(player)) {
        return
    }
    ServerCommand("kick " + player.GetPlayerName())
}


// !mute
void function FSU_C_Mute ( entity player, array < string > args )
{
  if( CheckPlayerDuplicates( player ) )
    return
  
  if ( args.len() == 0 )
  {
    Chat_ServerPrivateMessage( player, ErrorColor("Missing argument!"), false )
    return
  }
  
  foreach ( p in GetPlayerArray() )
  {
    if( p.GetPlayerName().tolower().find( args[0].tolower() ) != null )
    {
      FSU_Mute( p.GetUID() )
      Chat_ServerPrivateMessage( player, AdminColor("Muted ") + UsernameColor(p.GetPlayerName()) + AdminColor("!"), false )
      Chat_ServerPrivateMessage( p, ErrorColor("You were muted!"), false )
      return
    }
  }
  
  Chat_ServerPrivateMessage( player, ErrorColor("Couldn't find a player matching ") + UsernameColor(args[0]) + ErrorColor("!"), false )
}

// !unmute
void function FSU_C_Unmute ( entity player, array < string > args )
{
  if( CheckPlayerDuplicates( player ) )
    return
  
  if ( args.len() == 0 )
  {
    Chat_ServerPrivateMessage( player, ErrorColor("Missing argument!"), false )
    return
  }
  
  foreach ( p in GetPlayerArray() )
  {
    if( p.GetPlayerName().tolower().find( args[0].tolower() ) != null )
    {
      FSU_Unmute( p.GetUID() )
      Chat_ServerPrivateMessage( player, AdminColor("Unmuted ") + UsernameColor(p.GetPlayerName()) + AdminColor("!"), false )
      Chat_ServerPrivateMessage( p, AdminColor("You were unmuted!"), false )
      return
    }
  }
  
  Chat_ServerPrivateMessage( player, ErrorColor("Couldn't find a player matching ") + UsernameColor(args[0]) + ErrorColor("!"), false )
}

// !logout
void function FSU_C_Logout ( entity player, array < string > args )
{
  if( CheckPlayerDuplicates( player ) )
    return
  
  if ( !Logout( player ) )
    Chat_ServerPrivateMessage( player, ErrorColor("Already logged out!"), false )
}

// !login
int logintries = 0

void function FSU_C_Login ( entity player, array < string > args )
{
  if( CheckPlayerDuplicates( player ) )
    return
  
  if ( args.len() == 0 )
  {
    Chat_ServerPrivateMessage( player, ErrorColor("Missing argument!"), false )
    return
  }
  
  if ( FSU_GetArray("FSU_ADMIN_UIDS").len() != FSU_GetArray("FSU_ADMIN_PASSWORDS").len() )
  {
    Chat_ServerPrivateMessage( player, ErrorColor("Admin UID/Passord array lenght mistmatch!") + AdminColor("Please check the FSU_ADMIN_UIDS and FSU_ADMIN_PASSWORDS convars."), false )
    return
  }
  
  for( int i = 0; i < FSU_GetArray("FSU_ADMIN_UIDS").len(); i++ )
  {
    if( player.GetUID() == FSU_GetArray("FSU_ADMIN_UIDS")[i] )
    {
      if ( args[0] == FSU_GetArray("FSU_ADMIN_PASSWORDS")[i] )
        {
          if( Login( player ) )
            Chat_ServerPrivateMessage( player, AdminColor("Logged in!"), false )
          return
        }
    }
  }
  
  Chat_ServerPrivateMessage( player, ErrorColor("Wrong password!") + AdminColor(" You have " + (4 - logintries) + " tries left."), false )
  logintries += 1
  if (logintries > 3){
    ServerCommand( "kickid " + player.GetUID() )
    logintries = 2
  }
}
