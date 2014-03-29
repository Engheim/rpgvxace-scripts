#==============================================================================
# ** Victor Engine - Element States
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.06.12 > First release
#------------------------------------------------------------------------------
#  This script allows to setup a trait that allows to change the battlers
# states when hit with a specific element. You can make a freeze state that
# is removed when hit with fire, or a machine enemy that enters in confusion
# when hit with lightning.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.19 or higher
#
# * Alias methods
#   class Game_Battler < Game_BattlerBase
#     def make_damage_value(user, item)
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Actors, Classes, Enemies, Weapons, Armors and States note tags:
#   Tags to be used on Actors, Classes, Enemies, Weapons, Armors and States
#   note boxes.
# 
#  <element state add x: y>
#  <element state add x: y, z%>
#   Setup the element and the state added when hit by the element
#     x : ID of the element
#     y : state ID
#     z : chance of happening (100% if not set)
#
#  <element state remove x: y>
#  <element state remove x: y, z%>
#   Setup the element and the state removed when hit by the element
#     x : ID of the element
#     y : state ID
#     z : chance of happening (100% if not set)
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#  States resistances are still valid, so even an 100% rate will not ensure
#  that the state is applied if the target is resistant to that state.
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
$imported[:ve_element_states] = 1.00
Victor_Engine.required(:ve_element_states, :ve_basic_module, 1.19, :above)

#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  This class deals with battlers. It's used as a superclass of the Game_Actor
# and Game_Enemy classes.
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Alias method: make_damage_value
  #--------------------------------------------------------------------------
  alias :make_damage_value_ve_element_states :make_damage_value
  def make_damage_value(user, item)
    make_damage_value_ve_element_states(user, item)
    element_states(user.element_set(item))
  end
  #--------------------------------------------------------------------------
  # * New method: element_states
  #--------------------------------------------------------------------------
  def element_states(elements)
    elements.each {|id| element_state_change(id) }
  end
  #--------------------------------------------------------------------------
  # * New method: element_state_change
  #--------------------------------------------------------------------------
  def element_state_change(id)
    regexp = /<ELEMENT STATE (ADD|REMOVE) #{id}: (\d+)(?:, *(\d+)%)?>/i
    get_all_notes.scan(regexp) do
      type = $1.downcase
      id   = $2.to_i
      rate = $3 ? $3.to_i / 100.0 : 1
      type == "add" ? add_state_normal(id) : remove_state(id) if rand < rate
    end
  end
end