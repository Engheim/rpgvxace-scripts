#==============================================================================
# ** Victor Engine - Element Set
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.07.05 > First relase
#  v 1.01 - 2012.07.05 > Compatibility with Element States
#  v 1.02 - 2013.02.13 > Compatibility with Cooperation Skills
#------------------------------------------------------------------------------
#  This script allows to set more than one element to a single skill.
# It also allows to change how multiple resistances are handled.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.35 or higher.
#   If used with 'Victor Engine - Animated Battle' place this bellow it.
#
# * Overwrite methods (Default)
#   class Game_Battler < Game_BattlerBase
#     def item_element_rate(user, item)
#
# * Alias methods (Default)
#   class Game_Battler < Game_BattlerBase
#     def elements_max_rate(elements)
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Skills and Items note tags:
#   Tags to be used on Skills and Items note boxes.
#
#  <element set: x>
#  <element set: x, x>
#   Setup the ID of the extra elements of the skill.
#     x : ID of the element
#
#------------------------------------------------------------------------------
# Additional instructions:
#  The element set on the skill damage section are still valid, the element
#  is added to the list. If Normal Attack element is set, the attack elements
#  are added to the extra elements.
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Set how multiple element resistance will be calculated
  #    Choose here how the elemental resist  will be calculated when handling
  #    multiples elements
  #    :highest  : use the highest resistance (default behavior)
  #    :lowest   : use the lowest resistance
  #    :addition : sum of all resistance modifiers
  #    :average  : avarage of all resistance modifiers
  #    :multiply : multiply all values
  #--------------------------------------------------------------------------
  VE_RESIST_ADDITION_TYPE = :highest
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
$imported[:ve_element_set] = 1.02
Victor_Engine.required(:ve_element_set, :ve_basic_module, 1.35, :above)
Victor_Engine.required(:ve_element_set, :ve_element_strenghten, 1.00, :bellow)
Victor_Engine.required(:ve_element_set, :ve_element_states, 1.00, :bellow)
Victor_Engine.required(:ve_element_set, :ve_damage_popup, 1.00, :bellow)
Victor_Engine.required(:ve_element_set, :ve_action_streghten, 1.00, :bellow)
Victor_Engine.required(:ve_element_set, :ve_element_strenghten, 1.00, :bellow)

#==============================================================================
# ** RPG::UsableItem
#------------------------------------------------------------------------------
#  This is the superclass for skills and items.
#==============================================================================

class RPG::UsableItem < RPG::BaseItem
  #--------------------------------------------------------------------------
  # * New method: element_set
  #--------------------------------------------------------------------------
  def element_set
    set    = damage.element_id > 0 ? [damage.element_id] : []
    regexp = /<ELEMENT SET: ((?:\d+,? *)+)>/i
    note.scan(regexp).each { set += $1.scan(/\d+/i).collect {|i| i.to_i } }
    set.compact
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
  # * Overwrite method: item_element_rate
  #--------------------------------------------------------------------------
  def item_element_rate(user, item)
    elements = user.element_set(item)
    elements.empty? ? 1.0 : elements_max_rate(elements)
  end
  #--------------------------------------------------------------------------
  # * Alias method: elements_max_rate
  #--------------------------------------------------------------------------
  alias :elements_max_rate_ve_element_set :elements_max_rate
  def elements_max_rate(elements)
    case VE_RESIST_ADDITION_TYPE
    when :lowest   then lowest_element_rate(elements)
    when :addition then addition_element_rate(elements)
    when :average  then average_element_rate(elements)
    when :multiply then multiply_element_rate(elements)
    else elements_max_rate_ve_element_set(elements)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: lowest_element_rate
  #--------------------------------------------------------------------------
  def lowest_element_rate(elements)
    elements.inject([1.0]) {|r, i| r.push(element_rate(i)) }.min
  end
  #--------------------------------------------------------------------------
  # * New method: addition_element_rate
  #--------------------------------------------------------------------------
  def addition_element_rate(elements)
    elements.inject([1.0]) {|r, i| r.push(element_rate(i) - 1.0) }.sum
  end
  #--------------------------------------------------------------------------
  # * New method: average_element_rate
  #--------------------------------------------------------------------------
  def average_element_rate(elements)
    elements.inject([1.0]) {|r, i| r.push(element_rate(i)) }.average
  end
  #--------------------------------------------------------------------------
  # * New method: multiply_element_rate
  #--------------------------------------------------------------------------
  def multiply_element_rate(elements)
    elements.inject(1.0) {|r, i| r *= element_rate(i) }
  end
end