#==============================================================================
# ** Victor Engine - Action Dodge
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.06.16 > First release
#  v 1.01 - 2012.06.17 > Compatibility with Critical Hit Effects
#------------------------------------------------------------------------------
#  This script allows to setup a trait that change the evasion value based on
# the actions or their types. That way you can set actions to be  easier or
# harder to evade based on the actions.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.24 or higher
#
# * Overwrite methods
#   class Game_Battler < Game_BattlerBase
#     def item_cri(user, item)
#
# * Alias methods
#   class Game_Battler < Game_BattlerBase
#     def item_eva(user, item)
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
#  <skill eva x: +y%>   <item eva x: +y%>
#  <skill eva x: -y%>   <item eva x: +y%>
#   Setup the item or skill and a rate of change in the physical evasion
#     x : ID of the skill or item
#     y : amount of change in dodge
#
#  <skill mev x: +y%>   <item mev x: +y%>
#  <skill mev x: -y%>   <item mev x: +y%>
#   Setup the item or skill and a rate of change in the magical evasion
#     x : ID of the skill or item
#     y : amount of change in dodge
#
#  <skill cev x: +y%>   <item cev x: +y%>
#  <skill cev x: -y%>   <item cev x: +y%>
#   Setup the item or skill and a rate of change in the criticall evasion
#     x : ID of the skill or item
#     y : amount of change in dodge
#
#  <skill type eva x: +y%>   <item type eva x: +y%>
#  <skill type eva x: -y%>   <item type eva x: +y%>
#   Setup the item or skill and a rate of change in the physical evasion
#     x : ID of the skill type or item type
#     y : amount of change in dodge
#
#  <skill type mev x: +y%>   <item type mev x: +y%>
#  <skill type mev x: -y%>   <item type mev x: +y%>
#   Setup the item or skill and a rate of change in the magical evasion
#     x : ID of the skill type or item type
#     y : amount of change in dodge
#
#  <skill type cev x: +y%>   <item type cev x: +y%>
#  <skill type cev x: -y%>   <item type cev x: +y%>
#   Setup the item or skill and a rate of change in the critical evasion
#     x : ID of the skill type or item type
#     y : amount of change in dodge
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
  end
end

$imported ||= {}
$imported[:ve_action_dodge] = 1.00
Victor_Engine.required(:ve_action_dodge, :ve_basic_module, 1.24, :above)

#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  This class deals with battlers. It's used as a superclass of the Game_Actor
# and Game_Enemy classes.
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Overwrite method: item_cri
  #--------------------------------------------------------------------------
  def item_cri(user, item)
    item.damage.critical ? setup_critical(user, item) : 0
  end
  #--------------------------------------------------------------------------
  # * Alias method: item_eva
  #--------------------------------------------------------------------------
  alias :item_eva_ve_action_dodge :item_eva
  def item_eva(user, item)
    result  = item_eva_ve_action_dodge(user, item)
    result += action_dodge(item, "eva") if item.physical?
    result += action_dodge(item, "mev") if item.magical?
    result
  end
  #--------------------------------------------------------------------------
  # * Alias method: cri_eva
  #--------------------------------------------------------------------------
  alias :cri_eva_ve_action_dodge :cri_eva
  def cri_eva(user, item)
    cri_eva_ve_action_dodge(user, item) + action_dodge(item, "cev")
  end
  #--------------------------------------------------------------------------
  # * New method: action_dodge
  #--------------------------------------------------------------------------
  def action_dodge(item, type)
    item_dodge(item, type) + item_type_dodge(item, type)
  end
  #--------------------------------------------------------------------------
  # * New method: item_dodge
  #--------------------------------------------------------------------------
  def item_dodge(item, type)
    get_action_dodge(item.skill? ? "SKILL" : "ITEM", type, item.id)
  end
  #--------------------------------------------------------------------------
  # * New method: item_type_dodge
  #--------------------------------------------------------------------------
  def item_type_dodge(item, type)
    action = item.skill? ? "SKILL TYPE" : "ITEM TYPE"
    item.type_set.inject(0.0) {|r, i| r += get_action_dodge(action, type, i) }
  end
  #--------------------------------------------------------------------------
  # * New method: get_action_dodge
  #--------------------------------------------------------------------------
  def get_action_dodge(action, type, id)
    regexp = /<#{action} #{type} #{id}: ([+-]?\d+)%?>/i
    get_all_notes.scan(regexp).inject(0.0) {|r| r += ($1.to_i / 100.0) }
  end
end