#==============================================================================
# ** Victor Engine - State Change Anim
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.05.30 > First release
#------------------------------------------------------------------------------
#  This script allows to display animations on battlers or characters when
# states are added or removed.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.00 or higher
#   If used with 'Victor Engine - Animated Battle' place this bellow it.
#
# * Alias methods (Default)
#   class Game_BattlerBase
#     def erase_state(state_id)
# 
#   class Game_Battler < Game_BattlerBase
#     def add_new_state(state_id)
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# States note tags:
#   Tags to be used on States note boxes.
# 
# <map state add anim: x>
#   Display an animation when a state is applied to the characters on map
#   x : animation id
#
# <map state remove anim: x>
#   Display an animation when a state is removed to the characters on map
#   x : animation id
#
# <battle state add anim: x>
#   Display an animation when a state is applied during battles
#   x : animation id
#
# <battle state remove anim: x>
#   Display an animation when a state is removed during battles
#   x : animation id
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
$imported[:ve_state_change_animations] = 1.00
Victor_Engine.required(:ve_state_change_animations, :ve_basic_module, 1.00, :above)

#==============================================================================
# ** Game_BattlerBase
#------------------------------------------------------------------------------
#  This class handles battlers. It's used as a superclass of the Game_Battler
# classes.
#==============================================================================

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Alias method: erase_state
  #--------------------------------------------------------------------------
  alias :erase_state_ve_state_change_animations :erase_state
  def erase_state(state_id)
    state_change_animation(state_id, "REMOVE")
    erase_state_ve_state_change_animations(state_id)
  end
  #--------------------------------------------------------------------------
  # * New method: state_change_animation
  #--------------------------------------------------------------------------
  def state_change_animation(state_id, type)
    if SceneManager.scene_is?(Scene_Battle)
      anim_id = state_change_anim_id("BATTLE", type, state_id)
    elsif SceneManager.scene_is?(Scene_Map) && actor?
      anim_id = state_change_anim_id("MAP", type, state_id)
    end
    state_change_display_animation(anim_id) if anim_id
  end
  #--------------------------------------------------------------------------
  # * New method: state_change_anim_id
  #--------------------------------------------------------------------------
  def state_change_anim_id(local, type, state_id)
    regexp = /<#{local} STATE #{type} anim: (\d+)>/i
    $data_states[state_id].note =~ regexp ? $1.to_i : nil
  end
  #--------------------------------------------------------------------------
  # * New method: state_change_display_animation
  #--------------------------------------------------------------------------
  def state_change_display_animation(anim_id)
    @animation_id = anim_id if SceneManager.scene_is?(Scene_Battle)
    map_animation(anim_id)  if SceneManager.scene_is?(Scene_Map) && actor?
  end
end

#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  This class deals with battlers. It's used as a superclass of the Game_Actor
# and Game_Enemy classes.
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Alias method: add_new_state
  #--------------------------------------------------------------------------
  alias :add_new_state_ve_state_change_animations :add_new_state
  def add_new_state(state_id)
    state_change_animation(state_id, "ADD") unless @states.include?(state_id)
    add_new_state_ve_state_change_animations(state_id)
  end
end