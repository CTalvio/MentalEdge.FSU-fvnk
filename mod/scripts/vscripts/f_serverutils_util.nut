untyped

global function FSU_Util_init

global function FSU_Localize
global function FSU_GetBool
global function FSU_GetFloat
global function FSU_GetArray
global function FSU_GetString
global function FSU_Split
global function FSU_GetStringArray

// My version of convars :)
global table<string,string> fsu_local_strings
global table<string,array<string> > fsu_local_arrays

global table<string,bool> fsu_settings_bool
global table<string,float> fsu_settings_float
global table<string,array<string> > fsu_settings_arrays


void function FSU_Util_init ()
{
  fsu_local_strings["mp_angel_city"]               <- "Angel City"
  fsu_local_strings["mp_black_water_canal"]        <- "Black Water Canal"
  fsu_local_strings["mp_grave"]                    <- "Boomtown"
  fsu_local_strings["mp_colony02"]                 <- "Colony"
  fsu_local_strings["mp_complex3"]                 <- "Complex"
  fsu_local_strings["mp_crashsite3"]               <- "Crashsite"
  fsu_local_strings["mp_drydock"]                  <- "DryDock"
  fsu_local_strings["mp_eden"]                     <- "Eden"
  fsu_local_strings["mp_thaw"]                     <- "Exoplanet"
  fsu_local_strings["mp_forwardbase_kodai"]        <- "Forward Base Kodai"
  fsu_local_strings["mp_glitch"]                   <- "Glitch"
  fsu_local_strings["mp_homestead"]                <- "Homestead"
  fsu_local_strings["mp_relic02"]                  <- "Relic"
  fsu_local_strings["mp_rise"]                     <- "Rise"
  fsu_local_strings["mp_wargames"]                 <- "Wargames"
  fsu_local_strings["mp_lobby"]                    <- "Lobby"
  fsu_local_strings["mp_lf_deck"]                  <- "Deck"
  fsu_local_strings["mp_lf_meadow"]                <- "Meadow"
  fsu_local_strings["mp_lf_stacks"]                <- "Stacks"
  fsu_local_strings["mp_lf_township"]              <- "Township"
  fsu_local_strings["mp_lf_traffic"]               <- "Traffic"
  fsu_local_strings["mp_lf_uma"]                   <- "UMA"
  fsu_local_strings["mp_coliseum"]                 <- "The Coliseum"
  fsu_local_strings["mp_coliseum_column"]          <- "Pillars"
  fsu_local_strings["mp_box"]                      <- "Box"
  fsu_local_strings["mp_amongus"]                  <- "Amongus"
}

// Local for maps
string function FSU_Localize( string map )
{
  if ( map in fsu_local_strings )
    return fsu_local_strings[map]
  
  return "Unknown map"
}

// Getter funcs
array<string> function FSU_GetArray( string convar )
{
  return split( GetConVarString( convar ),"," )
}


float function FSU_GetFloat( string convar )
{
  return GetConVarFloat( convar )
}

bool function FSU_GetBool( string convar )
{
  return GetConVarBool( convar )
}

// I hate this I hate this I hate this I hate this I hate this I hate this I hate this I hate this I hate this I hate this I hate this I hate this I hate this I hate this I hate this I hate this I hate this
array<string> function FSU_Split ( string splitme, string separator )
{
  array<string> return_array
  string temp_string = splitme
  
  var last_index = 0
  var temp_index = 0
  while ( true )
  {
    temp_index = temp_string.find( separator )
    
    if( temp_index == null )
      break
    
    
    temp_string = temp_string.slice( 0, temp_index ) + temp_string.slice( temp_index + separator.len() , temp_string.len() )
    
    return_array.append( temp_string.slice( last_index, temp_index ) )
    
    last_index = temp_index
  }
  
  if ( return_array.len() == 0 )
    return_array.append( splitme )
  
  return return_array
}

string function FSU_GetString( string convar )
{
  string real_value = GetConVarString( convar )
  array<string> split_value = FSU_Split(real_value,"\\x1b")
  string return_value
  
  
  foreach ( _index, string value in split_value )
  {
    return_value += value
    
    if( _index != split_value.len() - 1 )
      return_value += "\x1b"
  }
  print( return_value )
  return return_value
}

array<string> function FSU_GetStringArray( string convar )
{
  string temp_value = FSU_GetString( convar )
  
  return split(temp_value,",")
}
