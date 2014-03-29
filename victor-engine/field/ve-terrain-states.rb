#==============================================================================
# ** Victor Engine - Terrain States
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.07.02 > First release
#  v 1.01 - 2012.07.24 > Compatibility with Moving Platforms and Free Jump
#  v 1.02 - 2012.08.02 > Compatibility with Basic Module 1.27
#------------------------------------------------------------------------------
#  This script allows to setup tiles with certain terrain tags and region id
# to change character states when step on them. You can make swamps that
# poison the targets or terrain that dispel buffs.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.27 or higher
#
# * Alias methods
#   class Game_Actor < Game_Battler
#     def check_floor_effect
#
#   class Game_Actor < Game_Battler
#     def check_floor_effect
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Maps and Tilests note tags:
#   Tags to be used on Maps and Tilests note boxes.
# 
#  <terrain state>
#  settings
#  </terrain state>
#   Setup the states changes when steping on a tile with terrain or region set,
#   add the following values to the settings. only the ID is mandatory, other
#   values are optional (although you must add either the add or remove value,
#   otherwise there will be no effect at all)
#     id: x     : region ID or terrain ID
#     add: x    : states added, can add multiple states separating with coma
#     remove: x : states removed, can add multiple states separating with coma
#     rate: x%  : chance of the state to be applied (default = 100%)
#     flash     : flash effect when states are changed
#     message   : display state change message
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#   The state resistances are still valid, so even a 100% rate will not ensure
#   that the state will land.
#
#   If the tags are added to the tileset note box it will use terrain tag,
#   If the tags are added to the map note box it will use region id
#
#------------------------------------------------------------------------------
# Example settings:
#
#  <terrain state>
#  id: 2;
#  add: 2, 3;
#  rate: 75%;
#  flash;
#  message;
#  </terrain state>
#   This setup gives 75% of adding the states id 2 and 3 when steping on a tile
#   with terrain or region id = 2 (this will depend on wich note box you add
#   the tag), there will be a flash and a message if the state is added.
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
  #   Get the script name base on the imported value
  #--------------------------------------------------------------------------
  def self.script_name(name, ext = "VE")
    name = name.to_s.gsub("_", " ").upcase.split
    name.collect! {|char| char == ext ? "#{char} -" : char.capitalize }
    name.join(" ")
  end
end

$imported ||= {}
$imported[:ve_terrain_states] = 1.02
Victor_Engine.required(:ve_terrain_states, :ve_basic_module, 1.27, :above)
Victor_Engine.required(:ve_terrain_states, :ve_moving_platform, 1.00, :bellow)
Victor_Engine.required(:ve_terrain_states, :ve_free_jump, 1.00, :bellow)
 
#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  This class handles actors. It's used within the Game_Actors class
# ($game_actors) and referenced by the Game_Party class ($game_party).
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * Alias method: check_floor_effect
  #--------------------------------------------------------------------------
  alias :check_floor_effect_ve_terrain_states :check_floor_effect
  def check_floor_effect
    return unless on_damage_floor?
    check_floor_effect_ve_terrain_states
    execute_floor_state if $game_player.on_state_floor?
  end
  #--------------------------------------------------------------------------
  # * Alias method: on_damage_floor?
  #--------------------------------------------------------------------------
  alias :on_damage_floor_ve_terrain_states? :on_damage_floor?
  def on_damage_floor?
    on_damage_floor_ve_terrain_states? || $game_player.on_state_floor?
  end
  #--------------------------------------------------------------------------
  # * New method: execute_floor_state
  #--------------------------------------------------------------------------
  def execute_floor_state
    setup_terrain_state($game_map.note, $game_player.terrain_tag)
    setup_terrain_state($game_map.tileset.note, $game_player.region_id)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_terrain_state
  #--------------------------------------------------------------------------
  def setup_terrain_state(notes, terrain)
    regexp = get_all_values("TERRAIN STATE")
    notes.scan(regexp) do
      value = $1.dup
      id    = value =~ /ID: (\d+)/i     ? $1.to_i : nil
      rate  = value =~ /RATE: (\d+)%?/i ? $1.to_i / 100.0 : 1
      flash = value =~ /FLASH/i
      msg   = value =~ /MESSAGE/i
      next unless rand < rate && terrain == id
      value.scan(/(ADD|REMOVE): ((?:\d+ *,? *)+)/i) do
        type  = $1.upcase.dup 
        $2.scan(/(\d+)/i) { change_terrain_state(type, $1.to_i, flash, msg) }
      end
    end
  end
  #--------------------------------------------------------------------------
  # * New method: change_terrain_state
  #--------------------------------------------------------------------------
  def change_terrain_state(type, state, flash, message)
    old_states = @states.dup
    add_state_normal(state) if type == "ADD" && !@states.include?(state)
    remove_state(state)     if type == "REMOVE"
    $game_map.screen.start_flash_for_damage if flash && old_states != @states
    @result.added_states.clear   unless message
    @result.removed_states.clear unless message
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
  # * New method: on_state_floor?
  #--------------------------------------------------------------------------
  def on_state_floor?
    (terrain_state? || region_state?) && !in_airship?
  end
  #--------------------------------------------------------------------------
  # * New method: terrain_state?
  #--------------------------------------------------------------------------
  def terrain_state?
    get_terrain_id($game_map.note, terrain_tag)
  end
  #--------------------------------------------------------------------------
  # * New method: region_state?
  #--------------------------------------------------------------------------
  def region_state?
    get_terrain_id($game_map.tileset.note , region_id)
  end
  #--------------------------------------------------------------------------
  # * New method: get_terrain_id
  #--------------------------------------------------------------------------
  def get_terrain_id(notes, type)
    regexp = get_all_values("TERRAIN STATE")
    notes.scan(regexp).any? { $1 =~ /ID: (\d+)/i ? $1.to_i == type : false }
  end
end