#==============================================================================
# ** Victor Engine - Encounter Rates Mod
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.01.12 > First release
#------------------------------------------------------------------------------
#  This script allows to change the encounter rates based on the terrain ID
# or Region ID.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module'
#
# * Alias methods (Default)
#   class Game_Map
#     def setup(map_id)
#
#   class Game_Player < Game_Character
#     def encounter_progress_value
#
#------------------------------------------------------------------------------
# Tileset and Region note tags:
#   Tags to be used on  Tileset and Region note boxes.
#
#  <encounter rate id: x%>
#   Change the encounter rate for regions (for map) or terrains (for tileset).
#     id : region or terrain ID
#     x  : rate modifier (default = 100)
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * required
  #   This method checks for the existance of the basic module and other
  #   VE scripts required for this script to work, don't edit this
  #--------------------------------------------------------------------------
  def self.required(name, req, version, type = nil)
    if !$imported[:ve_basic_module]
      msg = "The script '%s' requires the script\n"
      msg += "'VE - Basic Module' v%s or higher above it to work properly\n"
      msg += "Go to http://victorscripts.wordpress.com/ to download this script."
      msgbox(sprintf(msg, self.script_name(name), version))
      exit
    else
      self.required_script(name, req, version, type)
    end
  end
  #--------------------------------------------------------------------------
  # * script_name
  #   Get the script name base on the imported value, don't edit this
  #--------------------------------------------------------------------------
  def self.script_name(name, ext = "VE")
    name = name.to_s.gsub("_", " ").upcase.split
    name.collect! {|char| char == ext ? "#{char} -" : char.capitalize }
    name.join(" ")
  end
end

$imported ||= {}
$imported[:ve_encounter_mod] = 1.00
Victor_Engine.required(:ve_encounter_mod, :ve_basic_module, 1.00, :above)

#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  This class handles maps. It includes scrolling and passage determination
# functions. The instance of this class is referenced by $game_map.
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # * Publig Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :terrain_mod
  attr_reader   :regions_mod
  #--------------------------------------------------------------------------
  # * Alias method: setup_ve_encounter_mod
  #--------------------------------------------------------------------------
  alias :setup_ve_encounter_mod :setup
  def setup(map_id)
    setup_ve_encounter_mod(map_id)
    setup_map_encounter_mod
  end
  #--------------------------------------------------------------------------
  # * New method: setup_map_encounter_mod
  #--------------------------------------------------------------------------
  def setup_map_encounter_mod
    @terrain_mod = set_encouter_mod(tileset.note)
    @regions_mod = set_encouter_mod(note)
  end
  #--------------------------------------------------------------------------
  # * New method: set_encouter_mod
  #--------------------------------------------------------------------------
  def set_encouter_mod(note)
    result = {}
    regexp = /<ENCOUNTER RATE (\d+): (\d+)\%?>/i
    note.scan(regexp) {|id, rate| result[id.to_i] = rate.to_f / 100.0 }
    result
  end
end

#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
#  This class handles the player.
# The instance of this class is referenced by $game_map.
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # * Alias method: encounter_progress_value
  #--------------------------------------------------------------------------
  alias :encounter_progress_value_ve_encounter_mod :encounter_progress_value
  def encounter_progress_value
    value = encounter_progress_value_ve_encounter_mod
    value *= set_mod_multiplier
    value
  end
  #--------------------------------------------------------------------------
  # * New method: set_mod_multiplier
  #--------------------------------------------------------------------------
  def set_mod_multiplier
    value = 1.0
    terrain = $game_map.terrain_tag(x, y)
    region  = $game_map.region_id(x, y)
    value *= $game_map.terrain_mod[terrain] if $game_map.terrain_mod[terrain]
    value *= $game_map.regions_mod[region]  if $game_map.regions_mod[region]
    value
  end
end