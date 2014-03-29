#==============================================================================
# ** Victor Engine - State Toggle
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.05.21 > First release
#------------------------------------------------------------------------------
#  This script allows to create toggleable states. States that when applied
# on a target already under the state, will be removed.
# Like the famous Toad state from Final Fantasy, or to make buffs that are
# toggleable (first use activate, use again to cancel)
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module'
#
# * Alias methods (Default)
#   class Game_Battler < Game_BattlerBase
#     def add_state(id)
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
#  <toggle state>
#   States with this tag will be remove when hit a target already under
#   that state
#
#------------------------------------------------------------------------------
# Additional instructions:
#   The state must be applied to have effect. So casting a skill that apply the
#   state on a target unde that state won't ensure that the state will be 
#   removed, since the state resist check comes before.
#   A work around for that is to make the target vulnerable to the state,
#   just add a trait on the state making the target weak to the state itself.
#   So the 'Toad' state makes the target weak to the 'Toad' state.
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
$imported[:ve_state_toggle] = 1.00
Victor_Engine.required(:ve_state_toggle, :ve_basic_module, 1.00, :above)

#==============================================================================
# ** RPG::State
#------------------------------------------------------------------------------
#  This is the data class for states
#==============================================================================

class RPG::State < RPG::BaseItem
  #--------------------------------------------------------------------------
  # * New method: incapacitate_state?
  #--------------------------------------------------------------------------
  def toggle_state?
    note =~ /<TOGGLE STATE>/i
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
  # * Alias method: add_state
  #--------------------------------------------------------------------------
  alias :add_state_ve_state_toggle :add_state
  def add_state(id)
    toggle_state?(id) ? remove_state(id) : add_state_ve_state_toggle(id)
  end
  #--------------------------------------------------------------------------
  # * New method: toggle_state?
  #--------------------------------------------------------------------------
  def toggle_state?(id)
    state?(id) && $data_states[id].toggle_state? && !passive_state(id)
  end
  #--------------------------------------------------------------------------
  # * New method: not_passive_state
  #--------------------------------------------------------------------------
  def passive_state(id)
    $imported[:ve_passive_states] && @passive_states.include?(id)
  end
end