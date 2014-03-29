#==============================================================================
# ** Victor Engine - Damage Limit
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.01.02 > First release
#------------------------------------------------------------------------------
#  This script allows to set a max limit for the damage dealt. You can set
# this features to skills, items, equips, states, enemies, actors or classes.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module'
# 
# * Overwrite methods
#   None
#
# * Alias methods (Default)
#   class Game_ActionResult
#     def make_damage(value, item)
# 
#   class Game_Battler < Game_BattlerBase
#     def make_damage_value(user, item)
#
#   class Game_Actor < Game_Battler
#     def setup(actor_id)
#
#   class Game_Enemy < Game_Battler
#     def initialize(index, enemy_id)
#
# * Alias methods (Basic Module)
#   class Game_Interpreter
#     def comment_call
#
#------------------------------------------------------------------------------
# Comment calls note tags:
#  Tags to be used in events comment box, works like a script call.
#
#  <actor damage limit i: x>
#   Changes the actor damage limit for any action.
#     i : actor ID
#     x : damage limit value
#
#  <actor physical limit i: x>
#   Changes the actor damage limit for physical actions.
#     i : actor ID
#     x : damage limit value
#
#  <actor magical limit i: x>
#   Changes the actor damage limit for magical actions.
#     i : actor ID
#     x : damage limit value
#
#------------------------------------------------------------------------------
# Actors, Classes, Enemies, Weapons, Armors, Items and Skill note tags:
#   Tags to be used on the Actors, Classes, Enemies, Weapons, Armors, Items or
#   Skill note box in the database
#  
#  Definiзгo de limite de dano geral
#  <damage limit: x>
#   Set damage limit valid for any action.
#     x : damage limit value
#
#  <physical limit: x>
#   Set damage limit valid only for physical actions.
#     x : damage limit value
#
#  <magical limit: x>
#   Set damage limit valid only for magical actions.
#     x : damage limit value
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#  When the limit is set for actors and enemies, the limit is always active.
#  If set for equipment and states, the limit only is active while the battler
#  is equiped with the equipment or under the state. If set for skill and
#  items, the limit is valid only for that action.
#
#  If there is more than one valid limit at the same time, the highest will
#  be used.
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  #  * Set base damage limit
  #    This value will be used if the action have no limit
  #--------------------------------------------------------------------------
  VE_BASE_DAMAGE_LIMIT = 9999
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
$imported[:ve_damage_limit] = 1.00
Victor_Engine.required(:ve_damage_limit, :ve_basic_module, 1.00, :above)

#==============================================================================
# ** Game_ActionResult
#------------------------------------------------------------------------------
#  This class handles the battle actions results. It's used within the
# Game_Battler class.
#==============================================================================

class Game_ActionResult
  #--------------------------------------------------------------------------
  # * Alias method: make_damage
  #--------------------------------------------------------------------------
  alias :make_damage_ve_damage_limit :make_damage
  def make_damage(value, item)
    limit = @battler.max_damage
    value = [[value, -limit].max, limit].min
    make_damage_ve_damage_limit(value, item)
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
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :max_damage
  attr_accessor :damage_limit
  #--------------------------------------------------------------------------
  # * Alias method: make_damage_value
  #--------------------------------------------------------------------------
  alias :make_damage_value_ve_damage_limit :make_damage_value
  def make_damage_value(user, item)
    @max_damage = user.set_max_damage(item)
    make_damage_value_ve_damage_limit(user, item)
  end
  #--------------------------------------------------------------------------
  # * New method: set_max_damage
  #--------------------------------------------------------------------------
  def set_max_damage(item)
    obj = Game_BaseItem.new
    obj.object = item
    limit = VE_BASE_DAMAGE_LIMIT
    limit = item_limit(limit, item)  if obj.is_item?
    limit = skill_limit(limit, item) if obj.is_skill?
    limit = class_limit(limit, item) if actor?
    limit = equip_limit(limit, item) if actor?
    limit = state_limit(limit, item)
    limit = battler_limit(limit, item)
    limit
  end
  #--------------------------------------------------------------------------
  # * New method: item_limit
  #--------------------------------------------------------------------------
  def item_limit(limit, item)
    get_limit(item.note, limit, item)
  end
  #--------------------------------------------------------------------------
  # * New method: class_limit
  #--------------------------------------------------------------------------
  def class_limit(limit, item)
    get_limit(self.class.note, limit, item)
  end
  #--------------------------------------------------------------------------
  # * New method: skill_limit
  #--------------------------------------------------------------------------
  def skill_limit(limit, item)
    get_limit(item.note, limit, item)
  end
  #--------------------------------------------------------------------------
  # * New method: equipment_limit
  #--------------------------------------------------------------------------
  def equip_limit(limit, item)
    equips.compact.each {|equip| limit = get_limit(equip.note, limit, item) }
    limit
  end
  #--------------------------------------------------------------------------
  # * New method: state_limit
  #--------------------------------------------------------------------------
  def state_limit(limit, item)
    states.each {|state| limit = get_limit(state.note, limit, item) }
    limit
  end
  #--------------------------------------------------------------------------
  # * New method: battler_limit
  #--------------------------------------------------------------------------
  def battler_limit(limit, item)
    limit = @damage_limit   if @damage_limit   > limit
    limit = @physical_limit if @physical_limit > limit && item.physical?
    limit = @magical_limit  if @magical_limit  > limit && item.magical?
    limit
  end
  #--------------------------------------------------------------------------
  # * New method: get_limit
  #--------------------------------------------------------------------------
  def get_limit(note, limit, item)
    case note
    when /<DAMAGE LIMIT: (\d+)>/i
      limit = $1.to_i if $1.to_i > limit
    when /<PHYSICAL LIMIT: (\d+)>/i
      limit = $1.to_i if $1.to_i > limit && item.physical?
    when /<MAGICAL LIMIT: (\d+)>/i
      limit = $1.to_i if $1.to_i > limit && item.magical?
    end
    limit
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
  # * Alias method: setup
  #--------------------------------------------------------------------------
  alias :setup_ve_damage_limit :setup
  def setup(actor_id)
    setup_ve_damage_limit(actor_id)
    init_damage_limit
  end
  #--------------------------------------------------------------------------
  # * New method: init_damage_limit
  #--------------------------------------------------------------------------
  def init_damage_limit
    @damage_limit   = note =~ /<DAMAGE LIMIT: (\d+)>/i   ? $1.to_i : 0
    @physical_limit = note =~ /<PHYSICAL LIMIT: (\d+)>/i ? $1.to_i : 0
    @magical_limit  = note =~ /<MAGICAL LIMIT: (\d+)>/i  ? $1.to_i : 0
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
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_damage_limit :initialize
  def initialize(index, enemy_id)
    initialize_ve_damage_limit(index, enemy_id)
    init_damage_limit
  end
  #--------------------------------------------------------------------------
  # * New method: init_damage_limit
  #--------------------------------------------------------------------------
  def init_damage_limit
    @damage_limit   = note =~ /<DAMAGE LIMIT: (\d+)>/i   ? $1.to_i : 0
    @physical_limit = note =~ /<PHYSICAL LIMIT: (\d+)>/i ? $1.to_i : 0
    @magical_limit  = note =~ /<MAGICAL LIMIT: (\d+)>/i  ? $1.to_i : 0
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
  alias :comment_call_ve_damage_limit :comment_call
  def comment_call
    change_damage_limit
    change_physical_limit
    change_magical_limit
    comment_call_ve_damage_limit
  end
  #--------------------------------------------------------------------------
  # * New method: change_damage_limit
  #--------------------------------------------------------------------------
  def change_damage_limit
    note.scan(/<ACTOR DAMAGE LIMIT (\d+): (\d+)>/i) do |id, limit|
      next if !$game_actors[id.to_i]
      $game_actors[id].damage_limit = limit.to_i
    end
  end
  #--------------------------------------------------------------------------
  # * New method: change_physical_limit
  #--------------------------------------------------------------------------
  def change_physical_limit
    note.scan(/<ACTOR PHYSICAL LIMIT (\d+): (\d+)>/i) do |id, limit|
      next if !$game_actors[id.to_i]
      $game_actors[id].physical_limit = limit.to_i
    end
  end
  #--------------------------------------------------------------------------
  # * New method: change_magical_limit
  #--------------------------------------------------------------------------
  def change_magical_limit
    note.scan(/<ACTOR MAGICAL LIMIT (\d+): (\d+)>/i) do |id, limit|
      next if !$game_actors[id.to_i]
      $game_actors[id].magical_limit = limit.to_i
    end
  end
end