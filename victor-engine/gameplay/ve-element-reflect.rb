#==============================================================================
# ** Victor Engine - Element Reflect
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.06.11 > First release
#------------------------------------------------------------------------------
#  This script allows to setup a trait gives a chance of reflecting
# actions based on their elements. That way you can create traits that can
# repel specific elements.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.19 or higher
#
# * Alias methods
#   class Game_Battler < Game_BattlerBase
#     def item_mrf(user, item)
#
#   class Window_BattleLog < Window_Selectable
#     def display_reflection(target, item)
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
#  <element reflect x: +y%>
#  <element reflect x: -y%>
#   Setup the element and a rate of reflection for that element
#     x : ID of the element
#     y : reflect chance
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#  If the action is magical, the element reflect chance is added to the
#  magic reflect chance.
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Element Reflect Message
  #   Message displayed on the battle log when sucessfully reflecting a
  #   elemental attack (only if the element reflect rate is higher than the
  #   magic reflect rate)
  #--------------------------------------------------------------------------
  VE_ELEMENT_REFLECT_LOG = "%s reflected the elemental attack!"
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
$imported[:ve_element_reflect] = 1.00
Victor_Engine.required(:ve_element_reflect, :ve_basic_module, 1.19, :above)

#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  This class deals with battlers. It's used as a superclass of the Game_Actor
# and Game_Enemy classes.
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :element_reflected
  #--------------------------------------------------------------------------
  # * Alias method: item_mrf
  #--------------------------------------------------------------------------
  alias :item_mrf_ve_element_reflect :item_mrf
  def item_mrf(user, item)
    result  = item_mrf_ve_element_reflect(user, item)
    element = element_reflect(user.element_set(item))
    @element_reflected = element > result
    result + element
  end
  #--------------------------------------------------------------------------
  # * New method: element_reflect
  #--------------------------------------------------------------------------
  def element_reflect(elements)
    elements.inject(0.0) {|r, i| r += get_element_reflect(i) }
  end
  #--------------------------------------------------------------------------
  # * New method: get_element_reflect
  #--------------------------------------------------------------------------
  def get_element_reflect(id)
    regexp = /<ELEMENT REFLECT #{id}: ([+-]?\d+)%?>/i
    get_all_notes.scan(regexp).inject(0.0) {|r| r += ($1.to_i / 100.0) }
  end
end

#==============================================================================
# ** Window_BattleLog
#------------------------------------------------------------------------------
#  This window shows the battle progress. Do not show the window frame.
#==============================================================================

class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # * Alias method: display_reflection
  #--------------------------------------------------------------------------
  alias :display_reflection_ve_element_reflect :display_reflection
  def display_reflection(target, item)
    if target.element_reflected
      Sound.play_reflection
      add_text(sprintf(VE_ELEMENT_REFLECT_LOG, target.name))
      wait
      back_one unless $imported[:ve_animated_battle]
    else
      display_reflection_ve_element_reflect(target, item)
    end
  end
end