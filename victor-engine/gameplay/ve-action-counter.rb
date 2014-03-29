#==============================================================================
# ** Victor Engine -  Action Counter
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.07.16 > First release
#  v 1.01 - 2012.12.24 > Compatibility with Counter Options
#------------------------------------------------------------------------------
#  This script allows to setup a trait givas a chance of countering actions
# based on the actions or their types. That way you can create traits that
# makes the battler retaliate when hurt with specific skills or items.
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
#  <skill counter x: +y%>   <item counter x: +y%>
#  <skill counter x: -y%>   <item counter x: -y%>
#   Setup the skill or item and a rate of counter for that action
#     x : ID of the skill or item
#     y : counter chance
#
#  <skill type counter x: +y%>   <item type counter x: +y%>
#  <skill type counter x: -y%>   <item type counter x: -y%>
#   Setup the skill or item type and a rate of counter for that actions
#     x : ID of the skill type or item type
#     y : counter chance
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#  If the action is physical, the action counter chance is added to the
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
$imported[:ve_action_counter] = 1.01
Victor_Engine.required(:ve_action_counter, :ve_basic_module, 1.19, :above)

#==============================================================================
# ** Vocab
#------------------------------------------------------------------------------
#  This module defines terms and messages. It defines some data as constant
# variables. Terms in the database are obtained from $data_system.
#==============================================================================

module Vocab

  # Action Counter Message
  VE_ActionCounter = "%s countered the %s!"
  
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
  attr_reader   :action_countered
  #--------------------------------------------------------------------------
  # * Alias method: item_cnt
  #--------------------------------------------------------------------------
  alias :item_cnt_ve_action_counter :item_cnt
  def item_cnt(user, item)
    result = item_cnt_ve_action_counter(user, item)
    action = action_counter(item)
    @action_countered = action > result
    result + action
  end
  #--------------------------------------------------------------------------
  # * New method: action_counter
  #--------------------------------------------------------------------------
  def action_counter(item)
    item_counter(item) + item_type_counter(item)
  end
  #--------------------------------------------------------------------------
  # * New method: item_counter
  #--------------------------------------------------------------------------
  def item_counter(item)
    get_action_counter(item.skill? ? "SKILL" : "ITEM", item.id)
  end
  #--------------------------------------------------------------------------
  # * New method: item_type_counter
  #--------------------------------------------------------------------------
  def item_type_counter(item)
    type = item.skill? ? "SKILL TYPE" : "ITEM TYPE"
    item.type_set.inject(0.0) {|r, i| r += get_action_counter(type, i) }
  end
  #--------------------------------------------------------------------------
  # * New method: get_action_counter
  #--------------------------------------------------------------------------
  def get_action_counter(type, id)
    regexp = /<#{type} COUNTER #{id}: ([+-]?\d+)%?>/i
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
  alias :display_counter_ve_action_counter :display_counter
  def display_counter(target, item)
    if target.action_countered
      Sound.play_evasion
      add_text(sprintf(Vocab::VE_ActionCounter, target.name, item.name))
      wait
      back_one unless $imported[:ve_animated_battle]
    else
      display_counter_ve_action_counter(target, item)
    end
  end
end