untyped

global function FSU_Util_init

global function FSU_Localize
global function FSU_GetBool
global function FSU_GetFloat
global function FSU_GetArray
global function FSU_GetString
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

string function FSU_GetString( string convar ){
  array <string> split_array = split(GetConVarString( convar ),"%")
  string return_value = ""

  foreach (string snippet in split_array ){
    if( return_value == "" ){
      return_value = snippet
    }
    else{
      return_value += "\x1b[38;5;" + snippet
    }
  }
  if( GetConVarString( convar ).find("%") == 0 ){
    return_value = "\x1b[38;5;" + return_value
  }

  return return_value
}

array<string> function FSU_GetStringArray( string convar )
{
  string temp_value = FSU_GetString( convar )
  
  return split(temp_value,",")
}
