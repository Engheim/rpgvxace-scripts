#==============================================================================
# ** Victor Engine - Cast Animations
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2011.12.19 > First release
#  v 1.01 - 2011.12.30 > Faster Regular Expressions
#  v 1.02 - 2012.01.14 > Fixed the positive sign on some Regular Expressions
#  v 1.03 - 2012.12.13 > Fixed actors animations
#------------------------------------------------------------------------------
#  This script allows to set cast animations for actions. These animations
# are displayed on the user before the action animation on the target.
# The animation is displayed only for visible battlers.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module'
# 
# * Alias methods (Default)
#   class Game_Battler < Game_BattlerBase
#     def use_item(item)
#
#   class Game_Actor < Game_Battler
#     def setup(actor_id)
#
# * Alias methods (Basic Module)
#   class Game_Interpreter
#     def comment_call
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Comment calls note tags:
#  Tags to be used in events comment box, works like a script call.
#
#  <cast animation id: x>
#   This tag allows to change the actor cast animation permanently.
#     id : actor ID
#     x  : 0 or animation ID
#
#------------------------------------------------------------------------------
# Actors, Enemies, Weapons, Skills and Items note tags:
#   Tags to be used on the Actors, Enemies, Weapons, Skills and Items note
#   boxed in the database
#  
#  <cast animation: x>
#   This tag allows set the cast animation
#     x : -1, 0 or animation ID
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#   Skills and Items cast animations have higher priority than Weapons, Actors 
#   and Enemies cast animations.
#   Weapons animations have higher priority than Actors animations.
#
#   If the cast animation ID = -1, it will display a lower priority
#   animation instead
#
#   If the cast animation ID = 0, it will display no animation
#
#   Using two weapons, only the first weapon animation is used.
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
$imported[:ve_cast_animation] = 1.03
Victor_Engine.required(:ve_cast_animation, :ve_basic_module, 1.00, :above)

#==============================================================================
# ** Game_BaseItem
#------------------------------------------------------------------------------
#  This class handles skills, items, weapons and armors in in a unified way.
# Since it can be included in the saved data, don't keep a reference to
# the database object.
#==============================================================================

class Game_BaseItem
  #--------------------------------------------------------------------------
  # * New method: cast_animation
  #--------------------------------------------------------------------------
  def cast_animation
    regexp = /<CAST ANIMATION: ([+-]?\d+)>/i
    (object && object.note =~ regexp) ? $1.to_i : -1
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
  # * Alias method: use_item
  #--------------------------------------------------------------------------
  alias :use_item_ve_cast_animation :use_item
  def use_item(item)
    use_item_ve_cast_animation(item)
    set_cast_animation(item) if $game_party.in_battle
  end
  #--------------------------------------------------------------------------
  # * New method: set_cast_animation
  #--------------------------------------------------------------------------
  def set_cast_animation(item)
    @animation_id = cast_animation_id(item)
    SceneManager.scene.wait_for_animation
  end
  #--------------------------------------------------------------------------
  # * New method: cast_animation_id
  #--------------------------------------------------------------------------
  def cast_animation_id(item)
    obj = Game_BaseItem.new
    obj.object = item
    is_attack?(obj) ? attack_cast_anim : item_cast_anim(obj)
  end
  #--------------------------------------------------------------------------
  # * New method: is_attack?
  #--------------------------------------------------------------------------
  def is_attack?(item)
    item.is_skill? && item.object.id == attack_skill_id
  end
  #--------------------------------------------------------------------------
  # * New method: attack_cast_anim
  #--------------------------------------------------------------------------
  def attack_cast_anim
    item = Game_BaseItem.new
    item.object = weapons[0] if actor? && weapons[0]
    item.object = weapons[1] if actor? && weapons[1] && !weapons[0]
    anim = item.cast_animation if item.is_weapon?
    (!anim || anim == -1) ? cast_animation : anim
  end
  #--------------------------------------------------------------------------
  # * New method: item_cast_anim
  #--------------------------------------------------------------------------
  def item_cast_anim(item)
    item.cast_animation < 0 ? attack_cast_anim : item.cast_animation
  end
end

#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  This class handles actors. It's used within the Game_Actors class
# ($game_actors) and referenced by the Game_Party class ($game_party).
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :cast_animation
  #--------------------------------------------------------------------------
  # * Alias method: setup
  #--------------------------------------------------------------------------
  alias :setup_ve_cast_animation :setup
  def setup(actor_id)
    setup_ve_cast_animation(actor_id)
    regexp = /<CAST ANIMATION: ([+-]?\d+)>/i
    @cast_animation = note =~ regexp ? [$1.to_i, 0].max : 0
  end
end

#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  This class handles enemy characters. It's used within the Game_Troop class
# ($game_troop).
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # * New method: cast_animation
  #--------------------------------------------------------------------------
  def cast_animation
    regexp = /<CAST ANIMATION: ([+-]?\d+)>/i
    enemy.note =~ regexp ? [$1.to_i, 0].max : 0
  end
end

#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  An interpreter for executing event commands. This class is used within the
# Game_Map, Game_Troop, and Game_Event classes.
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Alias method: comment_call
  #--------------------------------------------------------------------------
  alias :comment_call_ve_cast_animation :comment_call
  def comment_call
    call_change_cast_animation
    comment_call_ve_cast_animation
  end
  #--------------------------------------------------------------------------
  # * New method: call_change_cast_animation
  #--------------------------------------------------------------------------
  def call_change_cast_animation
    regexp = /<CAST ANIMATION (\d+): ([+-]?\d+)>/i
    note.scan(regexp) do |id, anim|
      $game_actors[id].cast_animation = anim
    end
  end
end