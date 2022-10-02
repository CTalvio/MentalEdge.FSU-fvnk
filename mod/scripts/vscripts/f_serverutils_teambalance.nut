global function FSU_TeamBalance_init

void function FSU_TeamBalance_init ()
{
  
  if( FSU_GetBool( "FSU_SHUFFLE_TEAMS_ON_MATCH_START" ) )
    AddCallback_GameStateEnter( eGameState.Prematch, FSU_ShuffleTeams )
    
  if ( FSU_GetBool ( "FSU_BALANCE_TEAMS_MID_GAME" ) )
    AddCallback_OnPlayerKilled( FSU_CheckTeamBalance )
}




void function FSU_CheckTeamBalance( entity victim, entity attacker, var damageInfo )
{  
  // Blacklist guards
  if ( FSU_GetArray( "FSU_BALANCE_MODE_BLACKLIST" ).contains( GAMETYPE ) || IsFFAGame() )
    return
  
  if ( FSU_GetArray( "FSU_TEAM_MAP_BLACKLIST" ).contains( GetMapName() ) )
    return
  
  // Check if difference is smaller than 2 ( dont balance when it is 0 or 1 )
  // May be too aggresive ??
  if( abs ( GetPlayerArrayOfTeam( TEAM_IMC ).len() - GetPlayerArrayOfTeam( TEAM_MILITIA ).len() ) <= int( FSU_GetFloat("FSU_BALANCE_ALLOWED_TEAM_DIFFERENCE") ) )
    return
  
  if ( GetPlayerArray().len() == 1 )
    return
  
  // Compare victims teams size
  if ( GetPlayerArrayOfTeam( victim.GetTeam() ).len() < GetPlayerArrayOfTeam( GetOtherTeam( victim.GetTeam() ) ).len() )
    return
  
  // We passed all checks, balance the teams
  SetTeam( victim, GetOtherTeam( victim.GetTeam() ) )
  Chat_ServerPrivateMessage( victim, "Your team has been changed to balance the match!", false )
}




void function FSU_ShuffleTeams ()
{
  // Blacklist guards
  if ( FSU_GetArray( "FSU_SHUFFLE_MODE_BLACKLIST" ).contains( GAMETYPE ) || IsFFAGame() )
    return
  
  if ( FSU_GetArray( "FSU_TEAM_MAP_BLACKLIST" ).contains( GetMapName() ) )
    return
    
  if ( GetPlayerArray().len() == 0 )
    return
  
  // Set team to TEAM_UNASSIGNED
  foreach ( player in GetPlayerArray() )
    SetTeam ( player, TEAM_UNASSIGNED )
  
  int maxTeamSize = GetPlayerArray().len() / 2
  
  // Assign teams
  foreach ( player in GetPlayerArray() )
  {
    if( !IsValid( player ) )
      continue
    
    // Get random team
    int team = RandomIntRange( TEAM_IMC, TEAM_MILITIA + 1 )
    // Gueard for team size
    if ( GetPlayerArrayOfTeam( team ).len() >= maxTeamSize )
    {
      SetTeam( player, GetOtherTeam( team ) )
      continue
    }
    // 
    SetTeam( player, team )
  }
}