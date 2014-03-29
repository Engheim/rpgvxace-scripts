#==============================================================================
# ** Victor Engine - Multiple Troops
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2011.12.21 > First release
#  v 1.01 - 2011.12.30 > Faster Regular Expressions
#  v 1.02 - 2011.03.11 > Added position adjust for the extra troops
#  v 1.03 - 2011.03.12 > Fixed iterate enemy function
#------------------------------------------------------------------------------
#  This script allows to set more than one troop to participate in battle.
# The basic use for this is to pass the 8 enemies limit for a sigle fight.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.01 or higher
#
# * Overwrite methods (Default)
#   class Game_Interpreter
#     def iterate_enemy_index(param)
#
# * Alias methods (Default)
#   class Game_Temp
#     def initialize
#
#   class Game_Troop < Game_Unit
#     def clear
#     def make_unique_names
#     def setup_battle_event
#     def increase_turn
#
# * Alias methods (Basic Module)
#   class Game_Interpreter
#     def comment_call
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section on bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Comment calls note tags:
#  Tags to be used in events comment box, works like a script call.
#
#  <extra troops: x>
#  <extra troops: x, x>
#   The next battle after this call will have the troops listed added
#   to the battle.
#     x : ID of the troops
#
#------------------------------------------------------------------------------
# Battle Comment boxes note tags:
#   Tags to be used on battle events Comment boxes.
#
#  <extra troops: x>
#  <extra troops: x, x>
#   The battle with the troop with this tag will have the troops listed added
#   to the battle. Only the main troop add new troops to the battle, if
#   one of the added troops have this tag, it will have no effect.
#     x : ID of the troops
#
#------------------------------------------------------------------------------
# Additional instructions:
#  
#  The events of all troops are processed, but if two or more troop events
#  span at the same time, only the first one will take place.
#  The battle events of a troop affect only the enemies of that troop.
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Adjust the position of the extra troops
  #--------------------------------------------------------------------------
  VE_EXTRA_TROOP_ADJUST = {x: 0, y: -32} 
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
$imported[:ve_multiple_troop] = 1.02
Victor_Engine.required(:ve_multiple_troop, :ve_basic_module, 1.01, :above)

#==============================================================================
# ** Game_Temp
#------------------------------------------------------------------------------
#  This class handles temporary data that is not included with save data.
# The instance of this class is referenced by $game_temp.
#==============================================================================

class Game_Temp
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :extra_troops
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_multiple_troops :initialize
  def initialize
    initialize_ve_multiple_troops
    @extra_troops = []
  end
end

#==============================================================================
# ** Game_Troop
#------------------------------------------------------------------------------
#  This class handles enemy groups and battle-related data. Also performs
# battle events. The instance of this class is referenced by $game_troop.
#==============================================================================

class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :current_troop
  #--------------------------------------------------------------------------
  # * Alias method: clear
  #--------------------------------------------------------------------------
  alias :clear_ve_multiple_troops :clear
  def clear
    clear_ve_multiple_troops
    @extra_troops = []
    @current_troop = 0
  end
  #--------------------------------------------------------------------------
  # * Alias method: make_unique_names
  #--------------------------------------------------------------------------
  alias :make_unique_names_ve_multiple_troops :make_unique_names
  def make_unique_names
    setup_extra_troops
    make_unique_names_ve_multiple_troops
  end
  #--------------------------------------------------------------------------
  # * Alias method: setup_battle_event
  #--------------------------------------------------------------------------
  alias :setup_battle_event_ve_multiple_troops :setup_battle_event
  def setup_battle_event
    setup_battle_event_ve_multiple_troops
    setup_extra_battle_event
  end
  #--------------------------------------------------------------------------
  # * Alias method: increase_turn
  #--------------------------------------------------------------------------
  alias :increase_turn_ve_multiple_troops :increase_turn
  def increase_turn
    increase_extra_turn
    increase_turn_ve_multiple_troops
  end
  #--------------------------------------------------------------------------
  # * New method: troop_id
  #--------------------------------------------------------------------------
  def troop_id
    @troop_id
  end
  #--------------------------------------------------------------------------
  # * New method: setup_extra_troops
  #--------------------------------------------------------------------------
  def setup_extra_troops
    @extra_troops = get_extra_troops
    @extra_troops.each_with_index do |troop, i|
      troop.members.each do |member|
        next unless $data_enemies[member.enemy_id]
        enemy = Game_Enemy.new(@enemies.size, member.enemy_id)
        enemy.hide if member.hidden
        enemy.screen_x = member.x + (i + 1) * VE_EXTRA_TROOP_ADJUST[:x]
        enemy.screen_y = member.y + (i + 1) * VE_EXTRA_TROOP_ADJUST[:y]
        @enemies.push(enemy)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * New method: get_extra_troops
  #--------------------------------------------------------------------------
  def get_extra_troops
    troops = $game_temp.extra_troops.dup
    $game_temp.extra_troops.clear
    regexp = /<EXTRA TROOPS: ((?:\d+ *,? *)+)>/i
    troop.pages.each do |page|
      page.note.scan(regexp) { $1.scan(/(\d+)/i) { troops.push($1.to_i) } }
    end
    troops.uniq.collect {|id| $data_troops[id] }
  end
  #--------------------------------------------------------------------------
  # * New method: setup_extra_battle_event
  #--------------------------------------------------------------------------
  def setup_extra_battle_event
    return if @interpreter.running?
    return if @interpreter.setup_reserved_common_event
    @current_troop = troop.members.size
    @extra_troops.each do |troop|
      troop.pages.each do |page|
        next unless conditions_met?(page)
        @interpreter.setup(page.list)
        @event_flags[page] = true if page.span <= 1
        return
      end
      @current_troop += troop.members.size
    end
  end
  #--------------------------------------------------------------------------
  # * New method: increase_extra_turn
  #--------------------------------------------------------------------------
  def increase_extra_turn
    @extra_troops.each do |troop|
      troop.pages.each {|page| @event_flags[page] = false if page.span == 1 }
    end
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
  # * Overwrite method: iterate_enemy_index
  #--------------------------------------------------------------------------
  def iterate_enemy_index(param)
    if param >= 0 && $game_troop.members[$game_troop.current_troop + param]
      enemy = $game_troop.members[$game_troop.current_troop + param]
      yield enemy if enemy
    elsif param < 0
      $game_troop.members.each {|enemy| yield enemy }
    else
      enemy = $game_troop.members[param]
      yield enemy if enemy
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: comment_call
  #--------------------------------------------------------------------------
  alias :comment_call_ve_multiple_troops :comment_call
  def comment_call
    call_setup_extra_toops
    comment_call_ve_multiple_troops
  end  
  #--------------------------------------------------------------------------
  # * New method: call_setup_extra_toops
  #--------------------------------------------------------------------------
  def call_setup_extra_toops
    $game_temp.extra_troops.clear
    regexp = /<EXTRA TROOPS: ((?:\d+,? *)+)>/i
    note.scan(regexp) do
      $1.scan(/(\d+)/i) { $game_temp.extra_troops.push($1.to_i) }
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: command_301
  #--------------------------------------------------------------------------
  alias :command_301_ve_multiple_troops :command_301
  def command_301
    if SceneManager.scene_is?(Scene_Battle)
      SceneManager.return
      $game_temp.extra_troops.push($game_troop.troop_id)
    end
    command_301_ve_multiple_troops
  end
end