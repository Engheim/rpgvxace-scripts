#==============================================================================
# ** Victor Engine - Action Restriction
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.06.16 > First release
#  v 1.01 - 2012.06.16 > Fixed issue when no user is available to use the item.
#------------------------------------------------------------------------------
#  This script allows to set restrictions for action use and effect.
# It's possible to make some items not usable by some actors or to have no
# effect on specific battlers.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.09 or higher
#
# * Overwrite methods
#   class Scene_ItemBase < Scene_MenuBase
#     def user
#
# * Alias methods
#   class Game_BattlerBase
#     def usable?(item)
#
#   class Game_Battler < Game_BattlerBase
#     def item_effect_test(user, item, effect)
#     def item_test(user, item)
#
#   class Scene_Battle < Scene_Base
#     def command_item
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Actors, Classes, Enemies, States, Weapons and Armors note tags:
#   Tags to be used on the Actors, Classes, Enemies, States, Weapons and Armors 
#   note box in the database
#  
#  <restrict skill use: x>       <restrict item use: x>    
#  <restrict skill use: x, x>    <restrict item use: x, x>
#   The user will not be able to use the action with the ids listed here
#     x = item or skill ID
#  
#  <restrict skill effect: x>       <restrict item effect: x>    
#  <restrict skill effect: x, x>    <restrict item effect: x, x>
#   The actions with id listed won't have any effect on the target
#     x = item or skill ID
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
  #   Get the script name base on the imported value, don't edit this
  #--------------------------------------------------------------------------
  def self.script_name(name, ext = "VE")
    name = name.to_s.gsub("_", " ").upcase.split
    name.collect! {|char| char == ext ? "#{char} -" : char.capitalize }
    name.join(" ")
  end
end

$imported ||= {}
$imported[:ve_action_restriction] = 1.00
Victor_Engine.required(:ve_action_restriction, :ve_basic_module, 1.09, :above)
Victor_Engine.required(:ve_action_restriction, :ve_element_states, 1.00, :bellow)

#==============================================================================
# ** Game_BattlerBase
#------------------------------------------------------------------------------
#  This class handles battlers. It's used as a superclass of the Game_Battler
# classes.
#==============================================================================

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Alias method: usable?
  #--------------------------------------------------------------------------
  alias :usable_ve_action_restriction? :usable?
  def usable?(item)
    return false if !action_restriction?(item)
    usable_ve_action_restriction?(item)
  end
  #--------------------------------------------------------------------------
  # * New method: ction_restriction?
  #--------------------------------------------------------------------------
  def action_restriction?(item)
    return true  if !item
    return false if item_restricted?(item, "USE")
    return true
  end
  #--------------------------------------------------------------------------
  # * New method: item_restricted?
  #--------------------------------------------------------------------------
  def item_restricted?(item, type)
    id     = item.id
    action = item.skill? ? "SKILL" : "ITEM"
    regexp = /<RESTRICT #{action} #{type}: ((?:\d+ *,? *)+)>/i
    get_all_notes.scan(regexp).any? { $1.scan(/(\d+)/i).include?([id.to_s]) }
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
  # * Alias method: item_effect_test
  #--------------------------------------------------------------------------
  alias :item_effect_test_ve_action_restriction :item_effect_test
  def item_effect_test(user, item, effect)
    return false if item_restricted?(item, "EFFECT")
    item_effect_test_ve_action_restriction(user, item, effect)
  end
  #--------------------------------------------------------------------------
  # * Alias method: item_test
  #--------------------------------------------------------------------------
  alias :item_test_ve_action_restriction :item_test
  def item_test(user, item)
    return false if item_restricted?(item, "EFFECT")
    item_test_ve_action_restriction(user, item)
  end
end

#==============================================================================
# ** Window_ItemList
#------------------------------------------------------------------------------
#  This window displays a list of items for the item screen.
#==============================================================================

class Window_ItemList < Window_Selectable
  #--------------------------------------------------------------------------
  # * New method: actor=
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
    self.oy = 0
  end
end

#==============================================================================
# ** Window_BattleItem
#------------------------------------------------------------------------------
#  This window displays a list of items for the battle screen.
#==============================================================================

class Window_BattleItem < Window_ItemList
  #--------------------------------------------------------------------------
  # * New method: enable?
  #--------------------------------------------------------------------------
  def enable?(item)
    @actor && @actor.usable?(item) && super(item)
  end
end

#==============================================================================
# ** Scene_ItemBase
#------------------------------------------------------------------------------
#  This is the superclass for the classes that performs the item and skill
# screens.
#==============================================================================

class Scene_ItemBase < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Overwrite method: user
  #--------------------------------------------------------------------------
  def user
    users = $game_party.movable_members.select {|member| member.usable?(item)}
    users.max_by {|member| member.pha }
  end
  #--------------------------------------------------------------------------
  # * Alias method: item_usable?
  #--------------------------------------------------------------------------
  alias :item_usable_ve_action_restriction? :item_usable?
  def item_usable?
    user && item_usable_ve_action_restriction?
  end
end

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Alias method: command_item
  #--------------------------------------------------------------------------
  alias :command_item_ve_action_restriction :command_item
  def command_item
    @item_window.actor = BattleManager.actor
    command_item_ve_action_restriction
  end
end