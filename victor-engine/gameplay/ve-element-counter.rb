#==============================================================================
# ** Victor Engine - Element Counter
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.07.10 > First release
#  v 1.01 - 2012.12.24 > Compatibility with Counter Options
#------------------------------------------------------------------------------
#  This script allows to setup a trait givas a chance of countering actions
# based on their elements. That way you can create traits that makes the
# battler retaliate when hurt with a specific element.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.19 or higher
#   If used with 'Victor Engine - Counter Options' place this bellow it.
#
# * Alias methods
#   class Game_Battler < Game_BattlerBase
#     def item_cnt(user, item)
#
#   class Window_BattleLog < Window_Selectable
#     def display_counter(target, item)
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
#  <element counter x: +y%>
#  <element counter x: -y%>
#   Setup the element and a rate of counter for that element
#     x : ID of the element
#     y : counter chance
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#  If the action is physical, the element counter chance is added to the
#  counter attack chance.
#
#  You can edit the log window message on the module Vocab withing the script
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
$imported[:ve_element_counter] = 1.01
Victor_Engine.required(:ve_element_counter, :ve_basic_module, 1.19, :above)

#==============================================================================
# ** Vocab
#------------------------------------------------------------------------------
#  This module defines terms and messages. It defines some data as constant
# variables. Terms in the database are obtained from $data_system.
#==============================================================================

module Vocab

  # Element Counter Message
  VE_ElmentCounter = "%s countered the elemental attack!"
  
end

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
  attr_reader   :element_countered
  #--------------------------------------------------------------------------
  # * Alias method: item_cnt
  #--------------------------------------------------------------------------
  alias :item_cnt_ve_element_counter :item_cnt
  def item_cnt(user, item)
    result  = item_cnt_ve_element_counter(user, item)
    element = element_counter(user.element_set(item))
    @element_countered = element > result
    result + element
  end
  #--------------------------------------------------------------------------
  # * New method: element_counter
  #--------------------------------------------------------------------------
  def element_counter(elements)
    elements.inject(0.0) {|r, i| r += get_element_counter(i) }
  end
  #--------------------------------------------------------------------------
  # * New method: get_element_counter
  #--------------------------------------------------------------------------
  def get_element_counter(id)
    regexp = /<ELEMENT COUNTER #{id}: ([+-]?\d+)%?>/i
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
  # * Alias method: display_counter
  #--------------------------------------------------------------------------
  alias :display_counter_ve_element_counter :display_counter
  def display_counter(target, item)
    if target.element_countered
      Sound.play_evasion
      add_text(sprintf(Vocab::VE_ElmentCounter, target.name))
      wait
      back_one unless $imported[:ve_animated_battle]
    else
      display_counter_ve_element_counter(target, item)
    end
  end
end