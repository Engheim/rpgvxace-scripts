#==============================================================================
# ** Victor Engine - State Aura
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.08.01 > First release
#------------------------------------------------------------------------------
#  This script allows to setup states that spread through allies when a battler
# is under the effect. It's possible to setup an effect range for the state.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.00 or higher
#
# * Overwrite methods
#
# * Alias methods
#   class Game_BattlerBase
#     def clear_states
#     def refresh
#
#   class Game_Battler < Game_BattlerBase
#     def add_new_state(state_id)
#
#   class Scene_Menu < Scene_MenuBase
#     def on_formation_ok
#     def on_formation_cancel
#
#   class Scene_Battle < Scene_Base
#     def battle_start
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# States note tags:
#   Tags to be used on States note boxes.
#
#  <state aura>
#   This tag allows to set states to spread through all allies
#
#  <state aura range: x>
#   This tag allows to set states to spread through allies near the target
#   of the state based on their index
#     x : index range
#
#  <state aura radius: x>
#   This tag allows to set states to spread through allies in a set radius
#     x : radius
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#   The <state aura range: x> tag is based only on index, so the position
#   of the battler in the screen don't matter. The range is the number of
#   indexes range. So if <state aura range: 1> and the state target the battler
#   in position 3, the state will also target the battlers on position 2 and 4.
#
#   The <state aura radius: x> creates a slightly eliptical radius in pixels
#   If the state is cast on actors, if the battlers aren't visible (I.E without
#   the script 'VE - Actor Battlers') or outside of battle the state will
#   have effect on all actors.
# 
#   Although the state is applied on all targer near the state target, removing
#   the state from the targets besides the main target will have no effect.
#   The state will only vanish when it's removed from the main target, when
#   this happen, all other battlers under the state will lose it also.
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
$imported[:ve_state_aura] = 1.00
Victor_Engine.required(:ve_state_aura, :ve_basic_module, 1.00, :above)

#==============================================================================
# ** RPG::State
#------------------------------------------------------------------------------
#  This is the data class for states
#==============================================================================

class RPG::State < RPG::BaseItem
  #--------------------------------------------------------------------------
  # * New method: aura?
  #--------------------------------------------------------------------------
  def aura?
    note =~ /<STATE AURA(?: RANGE: (\d+)| RADIUS: (\d+))?>/i
  end
  #--------------------------------------------------------------------------
  # * New method: aura_range
  #--------------------------------------------------------------------------
  def aura_range
    note =~ /<STATE AURA RANGE: (\d+)>/i ? $1.to_i : nil
  end
  #--------------------------------------------------------------------------
  # * New method: aura_radius
  #--------------------------------------------------------------------------
  def aura_radius
    note =~ /<STATE AURA RADIUS: (\d+)>/i ? $1.to_i : nil
  end
end

#==============================================================================
# ** Game_BattlerBase
#------------------------------------------------------------------------------
#  This class handles battlers. It's used as a superclass of the Game_Battler
# classes.
#==============================================================================

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Alias method: clear_states
  #--------------------------------------------------------------------------
  alias :clear_states_ve_state_aura :clear_states
  def clear_states
    clear_states_ve_state_aura
    @aura_states = {}
  end
  #--------------------------------------------------------------------------
  # * Alias method: refresh
  #--------------------------------------------------------------------------
  alias :refresh_ve_state_aura :refresh
  def refresh
    refresh_ve_state_aura
    refresh_aura_states
  end
  #--------------------------------------------------------------------------
  # * Alias method: refresh
  #--------------------------------------------------------------------------
  def refresh_aura_states
    @aura_states.keys.each {|state| update_aura(state) }
  end
  #--------------------------------------------------------------------------
  # * New method: update_aura
  #--------------------------------------------------------------------------
  def update_aura(id)
    state = $data_states[id]
    user  = @aura_states[id]
    user_update_aura(state)    if self == user
    self_add_aura(user, state) if self != user
    remove_aura(state, user)   if self != user
  end
  #--------------------------------------------------------------------------
  # * New method: user_update_aura
  #--------------------------------------------------------------------------
  def user_update_aura(state)
    party = actor? ? $game_party.battle_members : $game_troop.members
    party.each do |battler|
      next if battler == self
      valid   = battler.in_range?(state, self)
      invalid = battler.invalid_aura?(state, party, self)
      battler.add_aura_state(state.id, self) if valid
      battler.remove_aura_state(state)       if invalid
    end
  end
  #--------------------------------------------------------------------------
  # * New method: add_aura
  #--------------------------------------------------------------------------
  def self_add_aura(user, state)
    add_aura_state(state.id, user) if in_range?(state, user)
  end
  #--------------------------------------------------------------------------
  # * New method: add_aura
  #--------------------------------------------------------------------------
  def remove_aura_state(state)
    erase_state(state.id)
    @aura_states.delete(state.id)
  end
  #--------------------------------------------------------------------------
  # * New method: remove_aura
  #--------------------------------------------------------------------------
  def remove_aura(state, user)
    party = actor? ? $game_party.battle_members : $game_troop.members
    remove_aura_state(state) if invalid_aura?(state, party, user)
  end
  #--------------------------------------------------------------------------
  # * New method: invalid_aura?
  #--------------------------------------------------------------------------
  def invalid_aura?(state, party, user)
    return true if !user.state?(state.id)
    return true if !party.include?(user)
    return true if !in_range?(state, user)
    return false
  end
  #--------------------------------------------------------------------------
  # * New method: in_range?
  #--------------------------------------------------------------------------
  def in_range?(state, user)
    range  = state.aura_range
    radius = state.aura_radius
    return true unless range || radius
    return true if range  && in_aura_range?(user, range)
    return true if radius && in_aura_radius?(user, radius)
    return false
  end
  #--------------------------------------------------------------------------
  # * New method: in_aura_range?
  #--------------------------------------------------------------------------
  def in_aura_range?(user, range)
    (index - user.index).abs <= range
  end
  #--------------------------------------------------------------------------
  # * New method: in_aura_radius?
  #--------------------------------------------------------------------------
  def in_aura_radius?(user, radius)
    return true if actor? && !$imported[:ve_actor_battlers]
    return true if !$game_party.in_battle
    w  = radius
    h  = 0.8
    x1 = screen_x
    y1 = screen_y
    x2 = user.screen_x
    y2 = user.screen_y
    in_radius?(w, h, x1, y1, x2, y2)
  end
  #--------------------------------------------------------------------------
  # * New method: add_aura_state
  #--------------------------------------------------------------------------
  def add_aura_state(state_id, user)
    return if state?(state_id)
    @aura_states[state_id] = user
    @states.push(state_id) 
    sort_states
    reset_state_counts(state_id)
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
  # * Alias method: refresh
  #--------------------------------------------------------------------------
  alias :add_new_state_ve_state_aura :add_new_state
  def add_new_state(state_id)
    if $data_states[state_id].aura? && !@aura_states[state_id]
      @aura_states[state_id] = self
    end
    add_new_state_ve_state_aura(state_id)
  end
end


#==============================================================================
# ** Scene_Menu
#------------------------------------------------------------------------------
#  This class performs the menu screen processing.
#==============================================================================

class Scene_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Alias method: on_formation_ok
  #--------------------------------------------------------------------------
  alias :on_formation_ok_ve_state_aura :on_formation_ok
  def on_formation_ok
    on_formation_ok_ve_state_aura
    $game_party.refresh
    @status_window.refresh
  end
  #--------------------------------------------------------------------------
  # * Alias method: on_formation_cancel
  #--------------------------------------------------------------------------
  alias :on_formation_cancel_ve_state_aura :on_formation_cancel
  def on_formation_cancel
    on_formation_cancel_ve_state_aura
    $game_party.refresh
    @status_window.refresh
  end
end

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Alias method: on_formation_ok
  #--------------------------------------------------------------------------
  alias :battle_start_ve_state_aura :battle_start
  def battle_start
    battle_start_ve_state_aura
    $game_party.refresh
    @status_window.refresh
  end
end