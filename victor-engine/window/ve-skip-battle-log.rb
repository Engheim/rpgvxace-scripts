#==============================================================================
# ** Victor Engine - Skip Battle Log
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.01.08 > First release
#  v 1.01 - 2012.01.18 > Fixed multi-hit damage not displaying
#  v 1.02 - 2012.01.28 > Compatibility with Animated Battle
#  v 1.03 - 2012.07.11 > Compatibility with Element Reflect
#                      > Compatibility with Element Counter
#  v 1.04 - 2012.07.11 > Improved code with less overwrites
#                      > Can setup the frame for waits after messages
#  v 1.05 - 2012.12.24 > Compatibility with Active Time Battle
#------------------------------------------------------------------------------
#  This script allows to set some of the Battle Log Messages to be skiped.
# Useful when using a damage pop up system. You can also skip the wait time
# when skiping the text to make the battle flows faster.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.11 or higher
# 
# * Overwrite methods
#   class << BattleManager
#     def battle_start
#
#   class Window_BattleLog < Window_Selectable
#     def message_speed
#     def display_added_states(target)
#     def display_removed_states(target)
#     def display_buffs(target, buffs, fmt)
#
# * Alias methods
#   class Window_BattleLog < Window_Selectable
#     def wait
#     def display_current_state(subject)
#     def display_failure(target, item)
#     def display_hp_damage(target, item)
#     def display_mp_damage(target, item)
#     def display_tp_damage(target, item)
#     def display_use_item(subject, item)
#     def display_counter(target, item)
#     def display_reflection(target, item)
#     def display_substitute(substitute, target)
#     def display_critical(target, item)
#     def display_miss(target, item)
#     def display_evasion(target, item)
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Set texts to be displayed
  #    if true the text will be displyed, if false the text will be skiped
  #--------------------------------------------------------------------------
  VE_EMERGE_MESSAGE         = false # Show enemy appearence
  VE_PREEMPTIVE_MESSAGE     = true  # Show preemptive attack warning
  VE_SURPRISE_MESSAGE       = true  # Show surprise attack warning
  VE_CURRENT_STATE_MESSAGE  = false # Show the battler current states
  VE_ITEM_USE_MESSAGE       = true  # Show item use message
  VE_ATTACK_USE_MESSAGE     = false # Show normal attack message
  VE_DEFEND_USE_MESSAGE     = true  # Show defend message
  VE_SKILL_USE_MESSAGE      = true  # Show skill use message
  VE_COUNTER_MESSAGE        = true  # Show counter attack message
  VE_REFLECTION_MESSAGE     = true  # Show magic reflection message
  VE_SUBSTITUTE_MESSAGE     = true  # Show substitution message
  VE_FAILURE_MESSAGE        = false # Show failuer message
  VE_CRITICAL_MESSAGE       = false # Show critical attack
  VE_PHYSICAL_MISS_MESSAGE  = false # Show physical miss
  VE_MAGICAL_MISS_MESSAGE   = false # Show magical miss
  VE_PHYSICAL_EVA_MESSAGE   = false # Show physical evasion 
  VE_MAGICAL_EVA_MESSAGE    = false # Show magical evasion
  VE_HP_DAMAGE_MESSAGE      = false # Show hp damage
  VE_MP_DAMAGE_MESSAGE      = false # Show mp damage
  VE_TP_DAMAGE_MESSAGE      = false # Show tp damage
  VE_ADDED_STATE_MESSAGE    = false # Show added states
  VE_REMOVED_STATE_MESSAGE  = false # Show removed states
  VE_BUFF_ADD_MESSAGE       = false # Show buff add message
  VE_DEBUFF_ADD_MESSAGE     = false # Show debuff add message
  VE_BUFF_REMOVE_MESSAGE    = false # Show buff remove message
  #--------------------------------------------------------------------------
  # * Set texts wait time when the text log is skiped
  #    time in frames
  #--------------------------------------------------------------------------  
  VE_CURRENT_STATE_WAIT  = 1  # wait for the battler current states
  VE_COUNTER_WAIT        = 20 # wait for counter attack message
  VE_REFLECTION_WAIT     = 20 # wait for magic reflection message
  VE_SUBSTITUTE_WAIT     = 20 # wait for substitution message
  VE_FAILURE_WAIT        = 1  # wait for failuer message
  VE_CRITICAL_WAIT       = 1  # wait for critical attack
  VE_PHYSICAL_MISS_WAIT  = 1  # wait for physical miss
  VE_MAGICAL_MISS_WAIT   = 1  # wait for magical miss
  VE_PHYSICAL_EVA_WAIT   = 1  # wait for physical evasion 
  VE_MAGICAL_EVA_WAIT    = 1  # wait for magical evasion
  VE_HP_DAMAGE_WAIT      = 1  # wait for hp damage
  VE_MP_DAMAGE_WAIT      = 1  # wait for mp damage
  VE_TP_DAMAGE_WAIT      = 1  # wait for tp damage
  VE_ADDED_STATE_WAIT    = 1  # wait for added states
  VE_REMOVED_STATE_WAIT  = 1  # wait for removed states
  VE_BUFF_ADD_WAIT       = 1  # wait for buff add message
  VE_DEBUFF_ADD_WAIT     = 1  # wait for debuff add message
  VE_BUFF_REMOVE_WAIT    = 1  # wait for buff remove message
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
$imported[:ve_skip_log] = 1.05
Victor_Engine.required(:ve_skip_log, :ve_basic_module, 1.11, :above)
Victor_Engine.required(:ve_skip_log, :ve_element_reflect, 1.00, :bellow)
Victor_Engine.required(:ve_skip_log, :ve_element_counter, 1.00, :bellow)
Victor_Engine.required(:ve_skip_log, :ve_active_time_battle, 1.00, :bellow)

#==============================================================================
# ** BattleManager
#------------------------------------------------------------------------------
#  This module handles the battle processing
#==============================================================================

class << BattleManager
  #--------------------------------------------------------------------------
  # * Overwrite method: battle_start
  #--------------------------------------------------------------------------
  def battle_start
    $game_system.battle_count += 1
    $game_party.on_battle_start
    $game_troop.on_battle_start
    if VE_EMERGE_MESSAGE
      message_wait = true
      $game_troop.enemy_names.each do |name|
        $game_message.add(sprintf(Vocab::Emerge, name))
      end
    end
    if @preemptive && VE_PREEMPTIVE_MESSAGE
      message_wait = true
      $game_message.add(sprintf(Vocab::Preemptive, $game_party.name))
    elsif @surprise && VE_SURPRISE_MESSAGE
      message_wait = true
      $game_message.add(sprintf(Vocab::Surprise, $game_party.name))
    end
    wait_for_message if message_wait
  end
end

#==============================================================================
# ** Window_BattleLog
#------------------------------------------------------------------------------
#  This window shows the battle progress. Do not show the window frame.
#==============================================================================

class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # * Overwrite method: message_speed
  #--------------------------------------------------------------------------
  def message_speed
    @message_speed ? @message_speed : 20
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: display_added_states
  #--------------------------------------------------------------------------
  def display_added_states(target)
    target.result.added_state_objects.each do |state|
      state_msg = target.actor? ? state.message1 : state.message2
      unless $imported[:ve_animated_battle]
        target.perform_collapse_effect if state.id == target.death_state_id
      end
      next if state_msg.empty? || !VE_ADDED_STATE_MESSAGE
      @message_speed = VE_ADDED_STATE_WAIT
      replace_text(target.name + state_msg)
      wait
      wait_for_effect
    end
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: display_removed_states
  #--------------------------------------------------------------------------
  def display_removed_states(target)
    target.result.removed_state_objects.each do |state|
      next if state.message4.empty? || !VE_REMOVED_STATE_MESSAGE
      @message_speed = VE_REMOVED_STATE_WAIT
      replace_text(target.name + state.message4)
      wait
    end
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: display_buffs
  #--------------------------------------------------------------------------
  def display_buffs(target, buffs, fmt)
    buffs.each do |param_id|
      next if hide_deuff_display(fmt)
      @message_speed = wait_deuff_display(fmt)
      replace_text(sprintf(fmt, target.name, Vocab::param(param_id)))
      wait
      @message_speed = nil
    end
  end  
  #--------------------------------------------------------------------------
  # * Alias method: wait
  #--------------------------------------------------------------------------
  alias :wait_ve_skip_log :wait
  def wait
    wait_ve_skip_log
    @message_speed = nil
  end
  #--------------------------------------------------------------------------
  # * Alias method: display_current_state
  #--------------------------------------------------------------------------
  alias :display_current_state_ve_skip_log :display_current_state
  def display_current_state(subject)
    return unless VE_CURRENT_STATE_MESSAGE
    @message_speed = VE_CURRENT_STATE_WAIT
    display_current_state_ve_skip_log(subject)
  end
  #--------------------------------------------------------------------------
  # * Alias method: display_failure
  #--------------------------------------------------------------------------
  alias :display_failure_ve_skip_log :display_failure
  def display_failure(target, item)
    return unless VE_FAILURE_MESSAGE
    @message_speed = VE_CURRENT_STATE_WAIT
    display_failure_ve_skip_log(target, item)
  end
  #--------------------------------------------------------------------------
  # * Alias method: display_hp_damage
  #--------------------------------------------------------------------------
  alias :display_hp_damage_ve_skip_log :display_hp_damage
  def display_hp_damage(target, item)
    return unless VE_HP_DAMAGE_MESSAGE
    @message_speed = VE_HP_DAMAGE_WAIT
    display_hp_damage_ve_skip_log(target, item)
  end
  #--------------------------------------------------------------------------
  # * Alias method: display_mp_damage
  #--------------------------------------------------------------------------
  alias :display_mp_damage_ve_skip_log :display_mp_damage
  def display_mp_damage(target, item)
    return unless VE_MP_DAMAGE_MESSAGE
    @message_speed = VE_MP_DAMAGE_WAIT
    display_mp_damage_ve_skip_log(target, item)
  end
  #--------------------------------------------------------------------------
  # * Alias method: display_tp_damage
  #--------------------------------------------------------------------------
  alias :display_tp_damage_ve_skip_log :display_tp_damage
  def display_tp_damage(target, item)
    return unless VE_TP_DAMAGE_MESSAGE
    @message_speed = VE_TP_DAMAGE_WAIT
    display_tp_damage_ve_skip_log(target, item)
  end
  #--------------------------------------------------------------------------
  # * Alias method: display_use_item
  #--------------------------------------------------------------------------
  alias :display_use_item_ve_skip_log :display_use_item
  def display_use_item(subject, item)
    return if hide_action_display(subject, item)
    display_use_item_ve_skip_log(subject, item)
  end
  #--------------------------------------------------------------------------
  # * Alias method: display_counter
  #--------------------------------------------------------------------------
  alias :display_counter_ve_skip_log :display_counter
  def display_counter(target, item)
    @message_speed = VE_COUNTER_WAIT
    if VE_COUNTER_MESSAGE
      display_counter_ve_skip_log(target, item)
    end
    @message_speed = nil
  end
  #--------------------------------------------------------------------------
  # * Alias method: display_reflection
  #--------------------------------------------------------------------------
  alias :display_reflection_ve_skip_log :display_reflection
  def display_reflection(target, item)
    @message_speed = VE_REFLECTION_WAIT
    if VE_REFLECTION_MESSAGE
      display_reflection_ve_skip_log(target, item)
    end
    @message_speed = nil
  end
  #--------------------------------------------------------------------------
  # * Alias method: display_substitute
  #--------------------------------------------------------------------------
  alias :display_substitute_ve_skip_log :display_substitute
  def display_substitute(substitute, target)
    @message_speed = VE_SUBSTITUTE_WAIT
    if VE_SUBSTITUTE_MESSAGE
      display_substitute_ve_skip_log(substitute, target)
    end
    @message_speed = nil
  end
  #--------------------------------------------------------------------------
  # * Alias method: display_critical
  #--------------------------------------------------------------------------
  alias :display_critical_ve_skip_log :display_critical
  def display_critical(target, item)
    @message_speed = VE_CRITICAL_WAIT
    if VE_CRITICAL_MESSAGE || $imported[:ve_damage_pop]
      display_critical_ve_skip_log(target, item)
    end
    @message_speed = nil
  end
  #--------------------------------------------------------------------------
  # * Alias method: display_miss
  #--------------------------------------------------------------------------
  alias :display_miss_ve_skip_log :display_miss
  def display_miss(target, item)
    @message_speed = VE_PHYSICAL_EVA_WAIT if !item || item.physical?
    @message_speed = VE_MAGICAL_EVA_WAIT  if item && !item.physical?
    if (!item || item.physical?) && !VE_PHYSICAL_MISS_MESSAGE
      Sound.play_miss
    elsif (item && !item.physical?) && !VE_MAGICAL_MISS_MESSAGE
    else
      display_miss_ve_skip_log(target, item)
    end
    @message_speed = nil
  end
  #--------------------------------------------------------------------------
  # * Alias method: display_evasion
  #--------------------------------------------------------------------------
  alias :display_evasion_ve_skip_log :display_evasion
  def display_evasion(target, item)
    @message_speed = VE_PHYSICAL_EVA_WAIT if !item || item.physical?
    @message_speed = VE_MAGICAL_EVA_WAIT  if item && !item.physical?
    if (!item || item.physical?)    && !VE_PHYSICAL_EVA_MESSAGE
      Sound.play_evasion
    elsif (item && !item.physical?) && !VE_MAGICAL_EVA_MESSAGE
      Sound.play_magic_evasion
    else
      display_evasion_ve_skip_log(target, item)
    end
    @message_speed = nil
  end
  #--------------------------------------------------------------------------
  # * New method: hide_action_display
  #--------------------------------------------------------------------------
  def hide_action_display(subject, item)
    (item.item?  && !VE_ITEM_USE_MESSAGE) ||
    (item.skill? && (!VE_SKILL_USE_MESSAGE ||
    (item.id == subject.attack_skill_id && !VE_ATTACK_USE_MESSAGE) ||
    (item.id == subject.guard_skill_id  && !VE_DEFEND_USE_MESSAGE)))
  end
  #--------------------------------------------------------------------------
  # * New method: hide_deuff_display
  #--------------------------------------------------------------------------
  def hide_deuff_display(fmt)
    (fmt == Vocab::BuffAdd && !VE_BUFF_ADD_MESSAGE) ||
    (fmt == Vocab::DebuffAdd && !VE_DEBUFF_ADD_MESSAGE) ||
    (fmt == Vocab::BuffRemove && !VE_BUFF_REMOVE_MESSAGE)
  end
  #--------------------------------------------------------------------------
  # * New method: hide_deuff_display
  #--------------------------------------------------------------------------
  def wait_deuff_display(fmt)
    return VE_BUFF_ADD_WAIT    if fmt == Vocab::BuffAdd
    return VE_DEBUFF_ADD_WAIT  if fmt == Vocab::DebuffAdd
    return VE_BUFF_REMOVE_WAIT if fmt == Vocab::BuffRemove
  end
end