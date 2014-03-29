#==============================================================================
# ** Victor Engine - Element Dodge
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.06.09 > First release
#  v 1.01 - 2012.06.17 > Compatibility with Critical Hit Effects
#------------------------------------------------------------------------------
#  This script allows to setup a trait that change the evasion value based on
# the action elements of current action. That way you can set actions to be 
# easier or harder to evade based on their elements.
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
#  <element eva x: +y%>
#  <element eva x: -y%>
#   Setup the element and a rate of change in the physical evasion
#     x : ID of the element
#     y : amount of change in dodge
#
#  <element mev x: +y%>
#  <element mev x: -y%>
#   Setup the element and a rate of change in the magical evasion
#     x : ID of the element
#     y : amount of change in dodge
#
#  <element cev x: +y%>
#  <element cev x: -y%>
#   Setup the element and a rate of change in the critical evasion
#     x : ID of the element
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
$imported[:ve_element_dodge] = 1.00
Victor_Engine.required(:ve_element_dodge, :ve_basic_module, 1.24, :above)

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
  alias :item_eva_ve_element_dodge :item_eva
  def item_eva(user, item)
    result  = item_eva_ve_element_dodge(user, item)
    result += element_dodge(user.element_set(item), "eva") if item.physical?
    result += element_dodge(user.element_set(item), "mev") if item.magical?
    result
  end
  #--------------------------------------------------------------------------
  # * Alias method: cri_eva
  #--------------------------------------------------------------------------
  alias :cri_eva_ve_element_dodge :cri_eva
  def cri_eva(user, item)
    result = cri_eva_ve_element_dodge(user, item)
    result + element_dodge(user.element_set(item), "cev")
  end
  #--------------------------------------------------------------------------
  # * New method: element_dodge
  #--------------------------------------------------------------------------
  def element_dodge(elements, type)
    elements.inject(0.0) {|r, i| r += get_element_dodge(type, i) }
  end
  #--------------------------------------------------------------------------
  # * New method: get_element_dodge
  #--------------------------------------------------------------------------
  def get_element_dodge(type, id)
    regexp = /<ELEMENT #{type} #{id}: ([+-]?\d+)%?>/i
    get_all_notes.scan(regexp).inject(0.0) {|r| r += ($1.to_i / 100.0) }
  end
end