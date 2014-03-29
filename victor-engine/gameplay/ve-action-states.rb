#==============================================================================
# ** Victor Engine - Action States
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.07.16 > First release
#  v 1.01 - 2012.07.30 > Fixed issue that made the game crash when attacking
#  v 1.02 - 2012.08.03 > Fixed issue with skill and item type changes
#------------------------------------------------------------------------------
#  This script allows to setup a trait that allows to change the battlers
# states when hit with a specific action.
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
#  <skill state add x: y>       <item state add x: y>
#  <skill state add x: y, z%>   <item state add x: y, z%>
#   Setup the skill or item and the state added when hit by the action
#     x : ID of the action
#     y : state ID
#     z : chance of happening (100% if not set)
#
#  <skill state remove x: y>       <item state remove x: y>
#  <skill state remove x: y, z%>   <item state remove x: y, z%>
#   Setup the skill or item and the state removed when hit by the action
#     x : ID of the action
#     y : state ID
#     z : chance of happening (100% if not set)
#
#  <skill type state add x: y>       <item type state add x: y>
#  <skill type state add x: y, z%>   <item type state add x: y, z%>
#   Setup the skill or item and the state added when hit by the action
#     x : ID of the action
#     y : state ID
#     z : chance of happening (100% if not set)
#
#  <skill type state remove x: y>       <item type state remove x: y>
#  <skill type state remove x: y, z%>   <item type state remove x: y, z%>
#   Setup the skill or item and the state removed when hit by the action
#     x : ID of the action
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
$imported[:ve_action_states] = 1.02
Victor_Engine.required(:ve_action_states, :ve_basic_module, 1.19, :above)

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
  alias :make_damage_value_ve_action_states :make_damage_value
  def make_damage_value(user, item)
    make_damage_value_ve_action_states(user, item)
    action_states(item)
  end
  #--------------------------------------------------------------------------
  # * New method: action_states
  #--------------------------------------------------------------------------
  def action_states(item)
    item_state_change(item)
    item_type_state_change(item)
  end
  #--------------------------------------------------------------------------
  # * New method: item_state_change
  #--------------------------------------------------------------------------
  def item_state_change(item)
    action_state_change(item.skill? ? "SKILL" : "ITEM", item.id)
  end
  #--------------------------------------------------------------------------
  # * New method: item_type_state_change
  #--------------------------------------------------------------------------
  def item_type_state_change(item)
    type = item.skill? ? "SKILL TYPE" : "ITEM TYPE"
    item.type_set.each {|i| action_state_change(type, i) }
  end
  #--------------------------------------------------------------------------
  # * New method: action_state_change
  #--------------------------------------------------------------------------
  def action_state_change(type, id)
    regexp = /<#{type} STATE (ADD|REMOVE) #{id}: (\d+)(?:, *(\d+)%)?>/i
    get_all_notes.scan(regexp) do
      type = $1.downcase
      id   = $2.to_i
      rate = $3 ? $3.to_i / 100.0 : 1
      type == "add" ? add_state_normal(id) : remove_state(id) if rand < rate
    end
  end
end