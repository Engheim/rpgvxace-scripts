#==============================================================================
# ** Victor Engine - Active Time Battle
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.12.16 > First release
#  v 1.01 - 2012.12.24 > Fixed issue with changing party during battle
#                      > Fixed ATB value during Surprise and Pre Emptive
#                      > Fixed Command Window position to not cover the ATB
#                      > Fixed issue with freezes after events
#                      > Fixed issue with state timings
#                      > Fixed issue with cast time at battle start
#                      > Fixed issue with escape at battle start
#                      > Added notetags <timed trigger: x> <cast protection: x>
#                        and <delay protection>
#                      > Fixed issue with command window not closing when
#                        the actor is becomes unable to select action
#  v 1.02 - 2012.12.30 > Compatibility with Leap Attack
#                      > Fixed issue with Guard command and ATB Reverse
#  v 1.03 - 2013.01.07 > Fixed issue with selection when all enemies are dead
#  v 1.04 - 2013.01.24 > Fixed issue with skill, item and target windows not
#                        closing when the actor is becomes unable to act
#  v 1.05 - 2013.02.13 > Added notetag <atb speed: x%>
#                      > Added setup for play a SE when the ATB is full
#------------------------------------------------------------------------------
#  This scripts changes the turn management of battles. The default turn based
# system is replaced by an active time system, where the order of actions
# are decided by individual time bars
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.32 or higher
#   If used with 'Victor Engine - Animated Battle' place this bellow it.
#   If used with 'Victor Engine - Skip Battle Log' place this bellow it.
#
# * Overwrite methods
#   class << BattleManager
#     def next_command
#     def prior_command
#     def turn_start
#     def turn_end
#     def make_action_orders
#
#   class Game_Enemy < Game_Battler
#     def conditions_met_turns?(param1, param2)
#
#   class Window_BattleStatus < Window_Selectable
#     def window_width
#     def draw_basic_area(rect, actor)
#     def draw_gauge_area_with_tp(rect, actor)
#     def draw_gauge_area_without_tp(rect, actor)
#     def update
# 
# * Alias methods
#   class << BattleManager
#     def init_members
#     def battle_start
#     def process_escape
#
#   class Game_System
#     def initialize
#
#   class Game_Action
#     def prepare
#
#   class Game_BattlerBase
#     def inputable?
#
#   class Game_Battler < Game_BattlerBase
#     def item_user_effect(user, item)
#
#   class Game_Enemy < Game_Battler
#     def initialize(index, enemy_id)
#
#   class Spriteset_Battle
#     def update_actors
#
#   class Window_BattleLog < Window_Selectable
#     def last_text
#
#   class Window_ActorCommand < Window_Command
#     def make_command_list
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Actors, Classes, Enemies, Weapons, Armors, States, Skills and Items note tags:
#   Tags to be used on Actors, Classes, Enemies, Weapons, Armors, States,
#   Skills and Items note boxes.
# 
#  <cast cancel: x%>
#   Actions will have a chance of canceling spell casting of the targets.
#     x : success rate
# 
#  <atb delay: x%, y%>
#   Actions will have a chance of delaying the ATB of the targets.
#     x : success rate
#     y : delay rate
#
#------------------------------------------------------------------------------
# Actors, Classes, Enemies, Weapons, Armors and States note tags:
#   Tags to be used on Actors, Classes, Enemies, Weapons, Armors and States
#   note boxes.
# 
#  <cast protection: x%>
#   Reduce the success rate of a cast cancel action.
#     x : reduction
# 
#  <delay protection: x%>
#   Reduce the success rate of a atb delay action.
#     x : reduction
# 
#  <atb speed: x%>
#   Changes the rate of a atb fill speed. if the value is higher then 100%
#   the bar fills faster, if it's lower than 100% the bar fills slower.
#     x : speed rate
#
#------------------------------------------------------------------------------
# Skills note tags:
#   Tags to be used on Skills note boxes.
#
#  <cast time: x>
#  <cast time: x, y>
#   Actions with this will have a cast time before executing, you can add
#   opitionally wich stat will be used to define the speed.
#     x : cast speed (100 = default speed)
#     y : stat (any valid battler stat)
#
#  <atb cost: x%>
#   Changes the total ATB spent after executing an action. By default all
#   actions cost 100% of the ATB. Can't be lower than 1%
#     x : ATB cost rate
#
#------------------------------------------------------------------------------
# States note tags:
#   Tags to be used on States note boxes.
#
#  <timed trigger: x>
#   There is two options for state auto-removal on the database: Action End
#   and Turn End. This tag creates a third option, to make the state end
#   and trigger after a set time.
#     x : time for the trigger.
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#  The <cast cancel: x%> and <atb delay: x%, y%> will have effect only on
#  physical actions when added to any object beside Skills and Items.
#
#  The <cast protection: x%> and <delay protection: x%> are multiplied by
#  the cast cancel/atb delay rate. So if an action have 30% cast cancel, and
#  the target have 50% cast protection, the cast cancel will be reduced to 15%
#  Multiple cast cancel effects are added separately. So an action with 40%
#  cast cancel and a target with 50%, 50% and 30% cast protection from different
#  sourcers (let's say 3 different equips) will have the chance reduced to 7%
#  (40 - 50% = 20%, 20% - 50% = 10%, 10% - 30% = 7%)
#
#  The <atb speed: x%> can be used to change the rate of a battler ATB speed
#  without the need of changing the AGI of the battler. Can be used to create
#  effect such as "Haste" and "Slow".
#
#  You can use script calls to change the wait mode and the atb speed
#  $game_system.wait_mode = X
#     :full_wait : time stop to select commands and actions
#     :semi_wait : time stop to select actions 
#     :active    : time don't stop
#
#  $game_system.atb_speed = X
#    1.0 = default speed
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Wait mode
  #   :full_wait : time stop to select commands and actions
  #   :semi_wait : time stop to select actions 
  #   :active    : time don't stop
  #--------------------------------------------------------------------------
  VE_ATB_WAIT_MODE = :full_wait
  #--------------------------------------------------------------------------
  # * Action wait
  #   if true, time will stop while executing actions
  #--------------------------------------------------------------------------
  VE_ATB_WAIT_ACTION = true
  #--------------------------------------------------------------------------
  # * Reverse ATB
  #   This setting revert how the ATB works, instead waiting the bar to fill
  #   up to select actions, you first select the action, the the bar start
  #   to fill and the action is executed once it's full.
  #--------------------------------------------------------------------------
  VE_ATB_REVERSE = false
  #--------------------------------------------------------------------------
  # * Move status window
  #   Setup this true to move the status window when the actor command
  #   window or part command window shows up. If false, both windows will
  #   be displayed above the status window.
  #--------------------------------------------------------------------------
  VE_MOVE_STATUS_WINDOW = true
  #--------------------------------------------------------------------------
  # * ATB Full Sound
  #   Play a sound when the actor command window open. Leave nil for no sound
  #   RPG::SE.new(filename, volume, pitch)
  #--------------------------------------------------------------------------
  VE_ATB_SOUND = RPG::SE.new("Decision2", 100, 100)
  #--------------------------------------------------------------------------
  # * Escape type
  #   :party   : open party menu by pressing the cancel key
  #   :command : add the "Escape" option to actors command list
  #   :key     : press the set keys for a while to escape
  #--------------------------------------------------------------------------
  VE_ATB_ESCAPE_TYPE = :key
  #--------------------------------------------------------------------------
  # * Setup the key that must be pressed for escaping
  #    :A >> keyboard Shift  :B >> keyboard X      :C >> keyboard Z
  #    :X >> keyboard A      :Y >> keyboard S      :Z >> keyboard D
  #    :L >> keyboard Q      :R >> keyboard W
  #   adding more than one key makes need to press all of them at same time
  #--------------------------------------------------------------------------
  VE_ATB_ESCAPE_KEYS = [:R, :L]
  #--------------------------------------------------------------------------
  # * Escape time
  #  Average escape time in frames to escape if VE_ATB_ESCAPE_TYPE = :key
  #  This value vary based on the battlers stats and the ATB speed
  #--------------------------------------------------------------------------
  VE_ATB_ESCAPE_TIME = 200
  #--------------------------------------------------------------------------
  # * Escape text
  #   Display escape text when trying to escape if VE_ATB_ESCAPE_TYPE = :key
  #--------------------------------------------------------------------------
  VE_ATB_ESCAPE_TEXT = true
  #--------------------------------------------------------------------------
  # * Turn count control
  #  This is used to control how the turn count will increase, the turn count
  #  control the battle event conditions
  #   :time     : control by time (in frames)
  #   :battlers : control by the number of alive battlers
  #   :actions  : control by the number of actions executed
  #--------------------------------------------------------------------------
  VE_ATB_TURN_COUNT = :time
  #--------------------------------------------------------------------------
  # * Time count
  #   Valid only if VE_ATB_TURN_COUNT = :time, setup the number of frames
  #   needed to increase the turn count. Is influenced by the ATB speed
  #--------------------------------------------------------------------------
  VE_ATB_TIME_COUNT = 200
  #--------------------------------------------------------------------------
  # * Action count
  #   Valid only if VE_ATB_TURN_COUNT = :actions, setup the number of actions
  #   needed to increase the turn count
  #--------------------------------------------------------------------------
  VE_ATB_ACTION_COUNT = 10
  #--------------------------------------------------------------------------
  # * ATB speed
  #   Multiplier that controls the speed of the ATB bars
  #--------------------------------------------------------------------------
  VE_ATB_SPEED = 1.0
  #--------------------------------------------------------------------------
  # * Speed modifier
  #   Value used to control the influence of the stats on the ATB speed
  #   Higher values reduce the influence of the stats on the speed.
  #--------------------------------------------------------------------------
  VE_speed_modifier = 50
  #--------------------------------------------------------------------------
  # * Start rate
  #   Initial ATB value on battle start, a random value between 0 and X%
  #--------------------------------------------------------------------------
  VE_ATB_START_RATE = 15
  #--------------------------------------------------------------------------
  # * Reverse ATB Guard Time
  #   With VE_ATB_REVERSE = true the guard time is set by this value, not
  #   by the value set on the database
  #--------------------------------------------------------------------------
  VE_ATB_REVERSE_GUARD_TIME = 150
  #--------------------------------------------------------------------------
  # * Default magic cast
  #   Setup a default cast speed for all magic skills. 
  #   Leave nil for no cast time.
  #     100 = default speed (same as the default wait time for actions)
  #--------------------------------------------------------------------------
  VE_ATB_DEFAULT_CAST = nil
  #--------------------------------------------------------------------------
  # * Damage wait
  #   Stop battler wait time during hurt animation. Available only for
  #   Animated Battle
  #--------------------------------------------------------------------------
  VE_ATB_DAMAGE_WAIT = true
  #--------------------------------------------------------------------------
  # * Escaping animation
  #   Add a steping animation while holding the escape key. Available only for
  #   Animated Battle and if VE_ATB_ESCAPE_TYPE = :key
  #--------------------------------------------------------------------------
  VE_ATB_ESCAPING_ANIM = true
  #--------------------------------------------------------------------------
  # * Regenerarion Trigger
  #  All regen effects triggers at same time no matter of the source, here
  #  you can set when the regen trigger
  #    :turn   : at the turn end
  #    :action : at the action end
  #    :timing : at fixed intervals
  #   It's highly recomended to setup all regen and poison states with the
  #   same auto-removal condition to ensure the duration match the trigger
  #--------------------------------------------------------------------------
  VE_ATB_REGEN_TRIGGER = :action
  #--------------------------------------------------------------------------
  # * Regenerarion Timing
  #  Time for regen effects to apply if VE_ATB_REGEN_TRIGGER = :timing
  #  Is influenced by the ATB speed
  #--------------------------------------------------------------------------
  VE_ATB_REGEN_TIMING = 300
  #--------------------------------------------------------------------------
  # * required
  #   This method checks for the existance of the basic module and other
  #   VE scripts required for this script to work, don't edit this
  #--------------------------------------------------------------------------
  def required(name, req, version, type = nil)
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
  def script_name(name, ext = "VE")
    name = name.to_s.gsub("_", " ").upcase.split
    name.collect! {|char| char == ext ? "#{char} -" : char.capitalize }
    name.join(" ")
  end
end

$imported ||= {}
$imported[:ve_active_time_battle] = 1.05
Victor_Engine.required(:ve_active_time_battle, :ve_basic_module, 1.32, :above)
Victor_Engine.required(:ve_active_time_battle, :ve_state_auto_apply, 1.00, :bellow)
Victor_Engine.required(:ve_active_time_battle, :ve_damage_pop, 1.00, :bellow)
Victor_Engine.required(:ve_active_time_battle, :ve_leap_attack, 1.00, :bellow)
Victor_Engine.required(:ve_active_time_battle, :ve_cooperation_skill, 1.00, :bellow)

#==============================================================================
# ** Vocab
#------------------------------------------------------------------------------
#  This module defines terms and messages. It defines some data as constant
# variables. Terms in the database are obtained from $data_system.
#==============================================================================

module Vocab
  
  # ATB stat name show above atb bar
  VE_ATB_Name = "ATB"

  # Message displayed when trying to escape using VE_ATB_ESCAPE_TYPE = :key
  VE_Escaping = "Escaping..."
  
  # Message displayed when can't escape using VE_ATB_ESCAPE_TYPE = :key
  VE_CantEscape = "Can't escape!"
  
end

#==============================================================================
# ** class RPG::BaseItem
#------------------------------------------------------------------------------
#  Superclass of actor, class, skill, item, weapon, armor, enemy, and state.
#==============================================================================

class RPG::BaseItem
  #--------------------------------------------------------------------------
  # * New method: atb_speed
  #--------------------------------------------------------------------------
  def atb_speed
    return @atb_speed if @atb_speed
    @atb_speed = note =~ /<ATB SPEED: *(\d+)%?>/i ? [$1.to_f, 1].max / 100 : 1
    @atb_speed
  end
end

#==============================================================================
# ** RPG::UsableItem
#------------------------------------------------------------------------------
#  This is the superclass for skills and items.
#==============================================================================

class RPG::UsableItem < RPG::BaseItem
  #--------------------------------------------------------------------------
  # * New method: castable?
  #--------------------------------------------------------------------------
  def castable?
    (cast_speed && not_cooperation?) ? true : false
  end
  #--------------------------------------------------------------------------
  # * New method: not_cooperation?
  #--------------------------------------------------------------------------
  def not_cooperation?
    !$imported[:ve_cooperation_skill] || !cooperation?
  end
  #--------------------------------------------------------------------------
  # * New method: cast_speed
  #--------------------------------------------------------------------------
  def cast_speed
    regexp = /<CAST TIME: (\d+)(?:, *(\w+))?>/i
    note   =~ regexp ? {spd: $1.to_i, stat: ($2 ? $2 : "agi")} : default_cast
  end
  #--------------------------------------------------------------------------
  # * New method: default_cast
  #--------------------------------------------------------------------------
  def default_cast
    speed = VE_ATB_DEFAULT_CAST
    ((magical? && speed) || VE_ATB_REVERSE) ? {spd: speed, stat: "agi"} : nil
  end
  #--------------------------------------------------------------------------
  # * New method: atb_cost
  #--------------------------------------------------------------------------
  def atb_cost
    regexp = /<ATB COST: (\d+)%?>/i
    note  =~ regexp ? [1.0 - ($1.to_f / 100), 0].max : 0
  end
  #--------------------------------------------------------------------------
  # * New method: cast_cancel
  #--------------------------------------------------------------------------
  def cast_cancel
    regexp = /<CAST CANCEL: (\d+)%?>/i
    note  =~ regexp ? $1.to_f / 100 : 0
  end
  #--------------------------------------------------------------------------
  # * New method: atb_delay
  #--------------------------------------------------------------------------
  def guard_skill?
    effects.any? {|effect| effect.code == 21 && effect.data_id == 9 }
  end
  #--------------------------------------------------------------------------
  # * New method: atb_delay
  #--------------------------------------------------------------------------
  def atb_delay
    regexp = /<ATB DELAY: (\d+)%?, *([+-]?\d+)%?>/i
    note   =~ regexp ? {rate: $1.to_f / 100, delay: $2.to_f / 100} : 
                       {rate: 0, delay: 0}
  end
end

#==============================================================================
# ** RPG::State
#------------------------------------------------------------------------------
#  This is the data class for states
#==============================================================================

class RPG::State < RPG::BaseItem
  #--------------------------------------------------------------------------
  # * Alias method: auto_removal_timing
  #--------------------------------------------------------------------------
  alias :auto_removal_timing_ve_active_time_battle :auto_removal_timing
  def auto_removal_timing
    timed_trigger ? 3 : auto_removal_timing_ve_active_time_battle
  end
  #--------------------------------------------------------------------------
  # * New method: timed_trigger
  #--------------------------------------------------------------------------
  def timed_trigger
    return @timed_trigger if @timed_trigger
    return VE_ATB_REVERSE_GUARD_TIME if guard_state?
    @timed_trigger = note =~ /<TIMED TRIGGER: (\d+)>/i ? $1.to_i : nil
  end
  #--------------------------------------------------------------------------
  # * New method: guard_state?
  #--------------------------------------------------------------------------
  def guard_state?
    features.any? {|ft| ft.code == 62 && ft.data_id == 1 }
  end
end

#==============================================================================
# ** BattleManager
#------------------------------------------------------------------------------
#  This module handles the battle processing
#==============================================================================

class << BattleManager
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :input_battlers
  #--------------------------------------------------------------------------
  # * Overwrite method: next_command
  #--------------------------------------------------------------------------
  def next_command
    begin
      return false if !actor || !actor.next_command
    end until actor.inputable?
    return true
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: prior_command
  #--------------------------------------------------------------------------
  def prior_command
    begin
      if !actor || !actor.prior_command
        old_actor = actor
        @actor_index -= 1
        @actor_index %= $game_party.members.size
        return false if old_actor == actor
      end
    end until actor.inputable?
    return true
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: turn_start
  #--------------------------------------------------------------------------
  def turn_start
    @phase = :turn
    make_action_orders
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: turn_end
  #--------------------------------------------------------------------------
  def turn_end
    @phase = :turn_end
    $game_troop.increase_turn
    @atb_turn_count = 0
    @abt_turn_speed = setup_atb_turn_speed
    all_battle_members.each do |battler|
      battler.on_turn_end
      next if scene_changing?
      SceneManager.scene.refresh_status
      SceneManager.scene.log_window.display_auto_affected_status(battler)
      SceneManager.scene.log_window.wait_and_clear
    end
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: make_action_orders
  #--------------------------------------------------------------------------
  def make_action_orders
    @action_battlers += @active_members
    @active_members.clear
  end
  #--------------------------------------------------------------------------
  # * Alias method: init_members
  #--------------------------------------------------------------------------
  alias :init_members_ve_active_time_battle :init_members
  def init_members
    init_members_ve_active_time_battle    
    @abt_turn_speed   = setup_atb_turn_speed
    @escape_time      = 0
    @atb_turn_count   = 0
    @key_escape_count = 0
    @input_battlers   = []
    @active_members   = []
    @action_battlers  = []
  end
  #--------------------------------------------------------------------------
  # * Alias method: battle_start
  #--------------------------------------------------------------------------
  alias :battle_start_ve_active_time_battle :battle_start
  def battle_start
    battle_start_ve_active_time_battle
    setup_initial_atb
    @phase = :turn
  end
  #--------------------------------------------------------------------------
  # * Alias method: process_escape
  #--------------------------------------------------------------------------
  alias :process_escape_ve_active_time_battle :process_escape
  def process_escape
    @preemptive = true if @escape_success
    @escape_success = false
    process_escape_ve_active_time_battle
  end
  #--------------------------------------------------------------------------
  # * New method: update_atb
  #--------------------------------------------------------------------------
  def update_atb
    clear_dead_atb
    return if scene_changing?
    return if $game_troop.interpreter.running? 
    return if SceneManager.scene.party_window?
    return if $imported[:ve_animated_battle] && @escaping
    update_timing
    update_turn
    update_all_atb
    update_input
    update_escaping 
  end
  #--------------------------------------------------------------------------
  # * New method: setup_initial_atb
  #--------------------------------------------------------------------------
  def setup_initial_atb
    @escape_success = false
    @key_escaping   = false
    @escap_pose     = false
    @party_escaping = false
    all_battle_members.each {|battler| battler.cast_action = nil }
    if @preemptive
      $game_party.members.each {|battler| battler.atb = battler.max_atb }
      $game_troop.members.each {|battler| battler.atb = 0 }
    elsif @surprise
      $game_party.members.each {|battler| battler.atb = 0 }
      $game_troop.members.each {|battler| battler.atb = battler.max_atb }
    else
      all_battle_members.each {|battler| battler.preset_atb }
    end
  end
  #--------------------------------------------------------------------------
  # * New method: scene_changing?
  #--------------------------------------------------------------------------
  def scene_changing?
    !SceneManager.scene_is?(Scene_Battle)
  end
  #--------------------------------------------------------------------------
  # * New method: update_all_atb
  #--------------------------------------------------------------------------
  def update_all_atb
    return if wating?
    all_battle_members.each {|member| member.atb_update }
  end
  #--------------------------------------------------------------------------
  # * New method: wating?
  #--------------------------------------------------------------------------
  def wating?
    return true if scene_changing?
    return true if $game_troop.interpreter.running? 
    return true if SceneManager.scene.full_wait?
    return true if SceneManager.scene.semi_wait?
    return true if wait_action?
    return false
  end
  #--------------------------------------------------------------------------
  # * New method: update_escaping
  #--------------------------------------------------------------------------
  def update_escaping
    open_party_command   if VE_ATB_ESCAPE_TYPE == :party
    process_party_escape if VE_ATB_ESCAPE_TYPE == :party && party_escape?
    key_press_escape     if VE_ATB_ESCAPE_TYPE == :key
    process_escape       if VE_ATB_ESCAPE_TYPE == :key   && key_escape?
  end
  #--------------------------------------------------------------------------
  # * New method: open_party_command
  #--------------------------------------------------------------------------
  def open_party_command
    return if scene_changing?
    return if SceneManager.scene.windows_active?
    SceneManager.scene.open_party_command_selection if Input.trigger?(:B)
  end
  #--------------------------------------------------------------------------
  # * New method: party_escape?
  #--------------------------------------------------------------------------
  def party_escape?
    $game_party.alive_members.all? {|actor| actor.atb_full? } &&
    all_battle_members.all? {|battler| !active_battler?(battler) }
  end 
  #--------------------------------------------------------------------------
  # * New method: process_party_escape
  #--------------------------------------------------------------------------
  def process_party_escape
    $game_party.members.each do |battler| 
      battler.atb = 0
      battler.cast_action = nil
      battler.clear_actions
    end
    @party_escaping = false
    return if process_escape
    turn_start 
    SceneManager.scene.battle_start_open_window unless scene_changing?
  end
  #--------------------------------------------------------------------------
  # * New method: key_press_escape
  #--------------------------------------------------------------------------
  def key_press_escape
    @key_escaping = VE_ATB_ESCAPE_KEYS.all? {|key| Input.press?(key)}
    update_escape_time
  end
  #--------------------------------------------------------------------------
  # * New method: key_escape?
  #--------------------------------------------------------------------------
  def key_escape?
    all_battle_members.all? {|battler| !active?(battler) } && @escape_success
  end 
  #--------------------------------------------------------------------------
  # * New method: update_escape_time
  #--------------------------------------------------------------------------
  def update_escape_time
    return if @escape_success
    escaping? ? increase_escape_time : decrease_escape_time
  end
  #--------------------------------------------------------------------------
  # * New method: increase_escape_time
  #--------------------------------------------------------------------------
  def increase_escape_time
    reset_escape_pose if !reset_escape_pose?
    @escap_pose = true
    if BattleManager.can_escape?
      @escape_time   = [@escape_time + 5 + rand, max_escape_time].min
      @escape_success = @escape_time == max_escape_time
    end
  end
  #--------------------------------------------------------------------------
  # * New method: decrease_escape_time
  #--------------------------------------------------------------------------
  def decrease_escape_time
    reset_escape_pose if reset_escape_pose?
    @escap_pose  = false
    @escape_time = [@escape_time - 1, 0].max
  end
  #--------------------------------------------------------------------------
  # * New method: reset_escape_pose
  #--------------------------------------------------------------------------
  def reset_escape_pose
    $game_party.alive_members.each {|actor| actor.reset_pose if !actor.active? }
  end
  #--------------------------------------------------------------------------
  # * New method: reset_escape_pose?
  #--------------------------------------------------------------------------
  def reset_escape_pose?
    $imported[:ve_animated_battle] && @escap_pose && VE_ATB_ESCAPING_ANIM
  end
  #--------------------------------------------------------------------------
  # * New method: max_escape_time
  #--------------------------------------------------------------------------
  def max_escape_time
    10.0 * VE_ATB_ESCAPE_TIME * @escape_ratio * $game_system.atb_speed
  end
  #--------------------------------------------------------------------------
  # * New method: wait_action? 
  #--------------------------------------------------------------------------
  def wait_action?
    $imported[:ve_animated_battle]  && !scene_changing? && 
    SceneManager.scene.wait_action? && SceneManager.scene.active?
  end
  #--------------------------------------------------------------------------
  # * New method: update_turn
  #--------------------------------------------------------------------------
  def update_turn
    return if wating?
    increase_atb_turn_count(:time)
    SceneManager.scene.turn_ending if @atb_turn_count >= @abt_turn_speed
  end
  #--------------------------------------------------------------------------
  # * New method: update_timing
  #--------------------------------------------------------------------------
  def update_timing
    return if wating?
    all_battle_members.each {|battler| battler.on_timing }
  end
  #--------------------------------------------------------------------------
  # * New method: update_input
  #--------------------------------------------------------------------------
  def update_input
    all_battle_members.reverse.each do |battler|
      next if (@party_escaping && battler.actor?) || !battler.ready?
      @input_battlers.push(battler)
      battler.on_action_start
      skill_window.refresh if skill_window.active
      item_window.refresh  if item_window.active
    end
    shift_input unless @input_battlers.empty?
  end
  #--------------------------------------------------------------------------
  # * New method: skill_window
  #--------------------------------------------------------------------------
  def skill_window
    SceneManager.scene.skill_window
  end
  #--------------------------------------------------------------------------
  # * New method: item_window
  #--------------------------------------------------------------------------
  def item_window
    SceneManager.scene.item_window
  end
  #--------------------------------------------------------------------------
  # * New method: shift_input
  #--------------------------------------------------------------------------
  def shift_input
    battler = @input_battlers.last
    battler.actor? ? setup_action(battler) : setup_no_selection(battler)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_action
  #--------------------------------------------------------------------------
  def setup_action(battler)
    return if scene_changing?
    return if SceneManager.scene.windows_active? && battler.inputable?
    return if battler.guard? && VE_ATB_REVERSE
    battler.inputable? ? setup_selection(battler) : setup_no_selection(battler) 
  end
  #--------------------------------------------------------------------------
  # * New method: setup_selection
  #--------------------------------------------------------------------------
  def setup_selection(battler)
    @actor_index = battler.index
    battler.make_actions
    SceneManager.scene.start_actor_command_selection
    VE_ATB_SOUND.play if VE_ATB_SOUND
  end
  #--------------------------------------------------------------------------
  # * New method: setup_no_selection
  #--------------------------------------------------------------------------
  def setup_no_selection(battler)
    battler.turn_count += 1 if !battler.actor? && !battler.cast_action?
    battler.make_actions
    battler.setup_cast_action if battler.cast_action?
    @input_battlers.delete(battler)
    @active_members.push(battler)
    turn_start
  end
  #--------------------------------------------------------------------------
  # * New method: add_actor
  #--------------------------------------------------------------------------
  def add_actor(battler)
    return unless input_battlers?(battler)
    @input_battlers.delete(battler)
    @active_members.push(battler)
  end
  #--------------------------------------------------------------------------
  # * New method: active_battler?
  #--------------------------------------------------------------------------
  def active_battler?(battler)
    @active_members.include?(battler) || @action_battlers.include?(battler) ||
    @input_battlers.include?(battler) || battler.current_actor? ||
    active?(battler)
  end
  #--------------------------------------------------------------------------
  # * New method: input_battlers?
  #--------------------------------------------------------------------------
  def input_battlers?(battler)
    @input_battlers.include?(battler)
  end
  #--------------------------------------------------------------------------
  # * New method: all_battle_members
  #--------------------------------------------------------------------------
  def all_battle_members
    $game_party.members + $game_troop.members
  end
  #--------------------------------------------------------------------------
  # * New method: all_dead_members
  #--------------------------------------------------------------------------
  def all_dead_members
    $game_party.dead_members + $game_troop.dead_members
  end
  #--------------------------------------------------------------------------
  # * New method: delete_input
  #--------------------------------------------------------------------------
  def delete_input(battler)
    @input_battlers.delete(battler)
  end
  #--------------------------------------------------------------------------
  # * New method: clear_battler
  #--------------------------------------------------------------------------
  def clear_battler(battler)
    @input_battlers.delete(battler)
    @active_members.delete(battler)
  end
  #--------------------------------------------------------------------------
  # * New method: escaping?
  #--------------------------------------------------------------------------
  def escaping?
    @key_escaping
  end
  #--------------------------------------------------------------------------
  # * New method: party_escaping?
  #--------------------------------------------------------------------------
  def party_escaping?
    @party_escaping
  end
  #--------------------------------------------------------------------------
  # * New method: active?
  #--------------------------------------------------------------------------
  def active?(battler)
    $imported[:ve_animated_battle] && battler.poses.active?
  end
  #--------------------------------------------------------------------------
  # * New method: setup_atb_turn_speed
  #--------------------------------------------------------------------------
  def setup_atb_turn_speed
    case VE_ATB_TURN_COUNT
    when :battlers then all_dead_members.size
    when :actions  then VE_ATB_ACTION_COUNT
    when :time     then VE_ATB_TIME_COUNT
    end
  end
  #--------------------------------------------------------------------------
  # * New method: clear_dead_atb
  #--------------------------------------------------------------------------
  def clear_dead_atb
    all_dead_members.each do |battler|
      next unless active_battler?(battler)
      battler.atb = 0
      @active_members.delete(battler)
      @input_battlers.delete(battler)
      @action_battlers.delete(battler)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: increase_atb_turn_count
  #--------------------------------------------------------------------------
  def increase_atb_turn_count(type)
    @atb_turn_count += $game_system.atb_speed if VE_ATB_TURN_COUNT == type
  end
  #--------------------------------------------------------------------------
  # * New method: setup_escape
  #--------------------------------------------------------------------------
  def setup_escape
    $game_party.members.each {|battler| delete_input(battler) }
    @party_escaping = true
  end
  #--------------------------------------------------------------------------
  # * New method: undo_escape
  #--------------------------------------------------------------------------
  def undo_escape
    @party_escaping = false
  end
  #--------------------------------------------------------------------------
  # * New method: turn_phase
  #--------------------------------------------------------------------------
  def turn_phase
    @phase = :turn
  end
end

#==============================================================================
# ** Game_System
#------------------------------------------------------------------------------
#  This class handles system-related data. Also manages vehicles and BGM, etc.
# The instance of this class is referenced by $game_system.
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :wait_mode
  attr_accessor :atb_speed
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_active_time_battle :initialize
  def initialize
    initialize_ve_active_time_battle
    @wait_mode = VE_ATB_WAIT_MODE
    @atb_speed = VE_ATB_SPEED
  end
end

#==============================================================================
# ** Game_Action
#------------------------------------------------------------------------------
#  This class handles battle actions. This class is used within the
# Game_Battler class.
#==============================================================================

class Game_Action
  #--------------------------------------------------------------------------
  # * Alias method: prepare
  #--------------------------------------------------------------------------
  alias :prepare_ve_active_time_battle :prepare
  def prepare
    subject.atb = item ? subject.atb * item.atb_cost : 0
    if item && item.castable? && !subject.cast_action? &&
       !subject.confusion? && !forcing
      subject.cast_action = self.clone
      subject.skip_actions
      subject.reset_pose if $imported[:ve_animated_battle]
    else
      subject.cast_action = nil if !forcing
      prepare_ve_active_time_battle
    end
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
  # * Alias method: inputable?
  #--------------------------------------------------------------------------
  alias :inputable_ve_active_time_battle? :inputable?
  def inputable?
    inputable_ve_active_time_battle? && atb_full? && input? && !cast_action? 
  end
  #--------------------------------------------------------------------------
  # * Alias method: clear_states
  #--------------------------------------------------------------------------  
  alias :clear_states_ve_active_time_battle :clear_states
  def clear_states
    clear_states_ve_active_time_battle
    @state_timing = {}
  end
  #--------------------------------------------------------------------------
  # * Alias method: erase_state
  #--------------------------------------------------------------------------
  alias :erase_state_ve_active_time_battle :erase_state
  def erase_state(state_id)
    erase_state_ve_active_time_battle(state_id)
    @state_timing.delete(state_id)
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
  attr_accessor :cast_action
  #--------------------------------------------------------------------------
  # * Overwite method: on_action_end
  #--------------------------------------------------------------------------
  def on_action_end
    @result.clear
    regenerate_all if VE_ATB_REGEN_TRIGGER == :action
    @result.clear  if VE_ATB_REGEN_TRIGGER == :action
    remove_states_auto(1)
    update_buff_turns
    remove_buffs_auto
  end
  #--------------------------------------------------------------------------
  # * Overwite method: on_turn_end
  #--------------------------------------------------------------------------
  def on_turn_end
    @result.clear
    remove_states_auto(2)
  end
  #--------------------------------------------------------------------------
  # * Alias method: remove_states_auto
  #--------------------------------------------------------------------------
  alias :remove_states_auto_ve_active_time_battle :remove_states_auto
  def remove_states_auto(timing)
    update_state_auto(timing)
    remove_states_auto_ve_active_time_battle(timing)
  end
  #--------------------------------------------------------------------------
  # * Alias method: item_user_effect
  #--------------------------------------------------------------------------
  alias :item_user_effect_ve_active_time_battle :item_user_effect
  def item_user_effect(user, item)
    item_user_effect_ve_active_time_battle(user, item)
    setup_cast_cancel(user, item)
    setup_atb_delay(user, item)
  end
  #--------------------------------------------------------------------------
  # * Alias method: reset_state_counts
  #--------------------------------------------------------------------------
  alias :reset_state_counts_ve_active_time_battle :reset_state_counts
  def reset_state_counts(state_id)
    reset_state_counts_ve_active_time_battle(state_id)
    state = $data_states[state_id]
    @state_timing[state_id] = state.timed_trigger if state.timed_trigger
  end
  #--------------------------------------------------------------------------
  # * New method: max_atb
  #--------------------------------------------------------------------------
  def max_atb
    @max_atb ||= 1000
  end
  #--------------------------------------------------------------------------
  # * New method: atb
  #--------------------------------------------------------------------------
  def atb
    @atb ||= 0
  end
  #--------------------------------------------------------------------------
  # * New method: atb=
  #--------------------------------------------------------------------------
  def atb=(n)
    @atb = [[n, 0].max, max_atb].min
  end
  #--------------------------------------------------------------------------
  # * New method: atb_freeze
  #--------------------------------------------------------------------------
  def atb_freeze
    @atb_freeze
  end
  #--------------------------------------------------------------------------
  # * New method: regen_timing
  #--------------------------------------------------------------------------
  def regen_timing
    @regen_timing ||= 0
  end
  #--------------------------------------------------------------------------
  # * New method: regen_timing=
  #--------------------------------------------------------------------------
  def regen_timing=(n)
    @regen_timing = [[n, 0].max, VE_ATB_REGEN_TIMING].min
  end
  #--------------------------------------------------------------------------
  # * New method: regen_timing_full?
  #--------------------------------------------------------------------------
  def regen_timing_full?
    regen_timing == VE_ATB_REGEN_TIMING
  end
  #--------------------------------------------------------------------------
  # * New method: atb_freeze=
  #--------------------------------------------------------------------------
  def atb_freeze=(n)
    @atb_freeze = n
  end
  #--------------------------------------------------------------------------
  # * New method: atb_full?
  #--------------------------------------------------------------------------
  def atb_full?
    @atb == max_atb
  end
  #--------------------------------------------------------------------------
  # * New method: atb_rate
  #--------------------------------------------------------------------------
  def atb_rate
    atb.to_f / max_atb
  end
  #--------------------------------------------------------------------------
  # * New method: ready?
  #--------------------------------------------------------------------------
  def ready?
    movable? && atb_full? && !active_battler?
  end
  #--------------------------------------------------------------------------
  # * New method: cast_action?
  #--------------------------------------------------------------------------
  def cast_action?
    cast_action ? true : false
  end
  #--------------------------------------------------------------------------
  # * New method: preset_atb
  #--------------------------------------------------------------------------
  def preset_atb
    self.atb = max_atb * VE_ATB_START_RATE * rand / 100
  end
  #--------------------------------------------------------------------------
  # * New method: total_agi
  #--------------------------------------------------------------------------
  def total_agi
    SceneManager.scene.all_battle_members.inject(0.0) {|r, obj| r += obj.agi }
  end
  #--------------------------------------------------------------------------
  # * New method: atb_update
  #--------------------------------------------------------------------------
  def atb_update
    update_atb_freeze if atb_freeze?
    return if atb_wait?
    self.atb_freeze = nil
    self.atb += update_atb
    self.atb  = max_atb if VE_ATB_REVERSE && !cast_action?
  end
  #--------------------------------------------------------------------------
  # * New method: atb_freeze?
  #--------------------------------------------------------------------------
  def atb_freeze?
    !movable?
  end
  #--------------------------------------------------------------------------
  # * New method: update_atb
  #--------------------------------------------------------------------------
  def update_atb
    speed = cast_action? ? cast_speed : agi
    20.0 * $game_system.atb_speed * atb_speed_mod(speed) * speed_modifier
  end
  #--------------------------------------------------------------------------
  # * New method: atb_wait?
  #--------------------------------------------------------------------------
  def atb_wait?
    atb_full? || atb_freeze? || pause_damage? || current_actor? ||
    (actor? && BattleManager.escaping?)
  end
  #--------------------------------------------------------------------------
  # * New method: update_atb_freeze
  #--------------------------------------------------------------------------
  def update_atb_freeze
    self.cast_action = nil
    self.atb_freeze ||= self.atb
    self.atb_freeze  += update_atb
    atb_freeze_result unless @atb_freeze < max_atb
  end
  #--------------------------------------------------------------------------
  # * New method: atb_freeze_result
  #--------------------------------------------------------------------------
  def atb_freeze_result
    @result.clear
    remove_states_auto(1)
    regenerate_all if VE_ATB_REGEN_TRIGGER == :action
    self.atb_freeze = 0
  end
  #--------------------------------------------------------------------------
  # * New method: pause_damage?
  #--------------------------------------------------------------------------
  def pause_damage?
    VE_ATB_DAMAGE_WAIT && $imported[:ve_animated_battle] && poses.damage_pose?
  end
  #--------------------------------------------------------------------------
  # * New method: cast_speed
  #--------------------------------------------------------------------------
  def cast_speed
    return agi if !cast_action
    speed = cast_action.item.cast_speed
    speed[:spd] * send(make_symbol(speed[:stat])) / 100.0 
  end
  #--------------------------------------------------------------------------
  # * New method: atb_speed_mod
  #--------------------------------------------------------------------------
  def atb_speed_mod(speed)
    (speed + [VE_speed_modifier, 0].max) / total_agi
  end
  #--------------------------------------------------------------------------
  # * New method: setup_cast_action
  #--------------------------------------------------------------------------
  def setup_cast_action
    @actions = [cast_action]
  end
  #--------------------------------------------------------------------------
  # * New method: setup_cast_cancel
  #--------------------------------------------------------------------------
  def setup_cast_cancel(user, item)
    rate  = item.cast_cancel
    rate += user.cast_cancel if item.physical?
    rate *= cast_protection
    execute_cast_cancel      if rand < rate && cast_action?
  end
  #--------------------------------------------------------------------------
  # * New method: setup_atb_delay
  #--------------------------------------------------------------------------
  def setup_atb_delay(user, item)
    rate  = item.atb_delay[:rate]
    rate += user.atb_delay[:rate] if item.physical?
    rate *= delay_protection
    execute_atb_delay(user, item) if rand < rate
  end
  #--------------------------------------------------------------------------
  # * New method: execute_cast_cancel
  #--------------------------------------------------------------------------
  def execute_cast_cancel
    skip_actions
    self.atb = 0
    self.cast_action = nil
  end
  #--------------------------------------------------------------------------
  # * New method: execute_atb_delay
  #--------------------------------------------------------------------------
  def execute_atb_delay(user, item)
    rate  = item.atb_delay[:delay]
    rate += user.atb_delay[:delay] if item.physical?
    self.atb -= max_atb * rate
  end
  #--------------------------------------------------------------------------
  # * New method: cast_cancel
  #--------------------------------------------------------------------------
  def cast_cancel
    regexp = /<CAST CANCEL: (\d+)%?>/i
    get_all_notes.scan(regexp).inject(0.0) {|r| r += ($1.to_f / 100) }
  end
  #--------------------------------------------------------------------------
  # * New method: atb_delay
  #--------------------------------------------------------------------------
  def atb_delay
    result = {}
    notes  = get_all_notes.dup
    regexp = /<ATB DELAY: (\d+)%?, *(\d+)%?>/i
    result[:rate]  = notes.scan(regexp).inject(0.0) {|r| r += ($1.to_f / 100) }
    result[:delay] = notes.scan(regexp).inject(0.0) {|r| r += ($1.to_f / 100) }
    result
  end
  #--------------------------------------------------------------------------
  # * New method: cast_protection
  #--------------------------------------------------------------------------
  def cast_protection
    regexp = /<CAST PROTECTION: (\d+)%?>/i
    get_all_notes.scan(regexp).inject(1.0) {|r| r *= 1 - ($1.to_f / 100) }
  end
  #--------------------------------------------------------------------------
  # * New method: delay_protection
  #--------------------------------------------------------------------------
  def delay_protection
    regexp = /<DELAY PROTECTION: (\d+)%?>/i
    get_all_notes.scan(regexp).inject(1.0) {|r| r *= 1 - ($1.to_f / 100) }
  end
  #--------------------------------------------------------------------------
  # * New method: update_state_auto
  #--------------------------------------------------------------------------
  def update_state_auto(timing)
    states.each do |state|
      if @state_turns[state.id] > 0 && state.auto_removal_timing == timing
        @state_turns[state.id] -= 1
      end
    end
  end
  #--------------------------------------------------------------------------
  # * New method: on_timing
  #--------------------------------------------------------------------------
  def on_timing
    timing_regen
    remove_timing_states
  end
  #--------------------------------------------------------------------------
  # * New method: timing_regen
  #--------------------------------------------------------------------------
  def timing_regen
    return unless VE_ATB_REGEN_TRIGGER == :timing
    self.regen_timing += $game_system.atb_speed if regen?
    @result.clear     if regen_timing_full?
    regenerate_all    if regen_timing_full?
    @regen_timing = 0 if regen_timing_full? || !regen?
  end
  #--------------------------------------------------------------------------
  # * New method: remove_timing_states
  #--------------------------------------------------------------------------
  def remove_timing_states
    states.each do |state|
      next if state.auto_removal_timing != 3 
      next if state.guard_state? && !VE_ATB_REVERSE
      @state_timing[state.id] -= $game_system.atb_speed
      if @state_turns[state.id] > 0 && @state_timing[state.id] <= 0
        @state_turns[state.id] -= 1
        @state_timing[state.id] = state.timed_trigger
      end
      remove_state(state.id) if @state_turns[state.id] == 0
    end
  end
  #--------------------------------------------------------------------------
  # * New method: regen?
  #--------------------------------------------------------------------------
  def regen?
    hrg != 0 || mrg != 0 || trg != 0
  end
  #--------------------------------------------------------------------------
  # * Overwite method: on_action_end
  #--------------------------------------------------------------------------
  def on_action_start
    make_actions
    remove_guard_state
  end
  #--------------------------------------------------------------------------
  # * Overwite method: remove_guard_state
  #--------------------------------------------------------------------------
  def remove_guard_state
    return if VE_ATB_REVERSE
    states.each do |state|
      next unless state.guard_state?
      remove_state(state.id)
      @damaged = true
    end
  end
  #--------------------------------------------------------------------------
  # * New method: skip_actions
  #--------------------------------------------------------------------------
  def skip_actions
    clear_actions
    @actions = [Game_Action.new(self)]
  end
  #--------------------------------------------------------------------------
  # * New method: active_battler?
  #--------------------------------------------------------------------------
  def active_battler?
    BattleManager.active_battler?(self)
  end
  #--------------------------------------------------------------------------
  # * New method: input?
  #--------------------------------------------------------------------------
  def input?
    BattleManager.input_battlers?(self)
  end
  #--------------------------------------------------------------------------
  # * New method: current_actor?
  #--------------------------------------------------------------------------
  def current_actor?
    SceneManager.scene_is?(Scene_Battle) && SceneManager.scene.subject == self
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
  # * New method: speed_modifier
  #--------------------------------------------------------------------------
  def speed_modifier
    list = [self.actor] + [self.class] + states + equips
    list.compact.inject(1.0) {|r, obj| r *= obj.atb_speed }
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
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :turn_count
  #--------------------------------------------------------------------------
  # * Overwrite method: conditions_met_turns?
  #--------------------------------------------------------------------------
  def conditions_met_turns?(param1, param2)
    n = @turn_count
    if param2 == 0
      n == param1
    else
      n > 0 && n >= param1 && n % param2 == param1 % param2
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_active_time_battle :initialize
  def initialize(index, enemy_id)
    initialize_ve_active_time_battle(index, enemy_id)
    @turn_count = 0
  end
  #--------------------------------------------------------------------------
  # * New method: speed_modifier
  #--------------------------------------------------------------------------
  def speed_modifier
    enemy.atb_speed * states.inject(1.0) {|r, state| r *= state.atb_speed }
  end
end

#==============================================================================
# ** Spriteset_Battle
#------------------------------------------------------------------------------
#  This class brings together battle screen sprites. It's used within the
# Scene_Battle class.
#==============================================================================

class Spriteset_Battle
  #--------------------------------------------------------------------------
  # * Alias method: update_actors
  #--------------------------------------------------------------------------
  alias :update_actors_ve_active_time_battle :update_actors
  def update_actors
    uptate_actors_atb
    update_actors_ve_active_time_battle
  end
  #--------------------------------------------------------------------------
  # * New method: uptate_actors_atb
  #--------------------------------------------------------------------------
  def uptate_actors_atb
    return if @atb_actors == $game_party.members
    $game_party.members.each do |actor|
      actor.preset_atb if @atb_actors && !@atb_actors.include?(actor)
    end
    @atb_actors = $game_party.members.dup
  end
end

#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  This is a superclass of all windows in the game.
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :hidden
end

#==============================================================================
# ** Window_BattleLog
#------------------------------------------------------------------------------
#  This window shows the battle progress. Do not show the window frame.
#==============================================================================

class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # * Alias method: last_text
  #--------------------------------------------------------------------------
  alias :last_text_ve_active_time_battle :last_text
  def last_text
    last_text_ve_active_time_battle ? last_text_ve_active_time_battle : ""
  end
end

#==============================================================================
# ** Window_ActorCommand
#------------------------------------------------------------------------------
#  This window is used to select actor commands, such as "Attack" or "Skill".
#==============================================================================

class Window_ActorCommand < Window_Command
  #--------------------------------------------------------------------------
  # * Alias method: make_command_list
  #--------------------------------------------------------------------------
  alias :make_command_list_ve_active_time_battle :make_command_list
  def make_command_list
    make_command_list_ve_active_time_battle
    add_escape_command if VE_ATB_ESCAPE_TYPE == :command
  end
  #--------------------------------------------------------------------------
  # * New method: add_escape_command
  #--------------------------------------------------------------------------
  def add_escape_command
    add_command(Vocab::escape, :escape, BattleManager.can_escape?)
  end
end

#==============================================================================
# ** Window_BattleStatus
#------------------------------------------------------------------------------
#  Esta janela exibe as condições de todos membros do grupo na tela de batalha.
#==============================================================================

class Window_BattleStatus < Window_Selectable
  #--------------------------------------------------------------------------
  # * Overwrite method: window_width
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width - ($data_system.opt_display_tp ? 0 : 128)
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: draw_basic_area
  #--------------------------------------------------------------------------
  def draw_basic_area(rect, actor)
    width = $data_system.opt_display_tp ? 180 : 104
    draw_actor_name(actor, rect.x + 0, rect.y, 100)
    draw_actor_icons(actor, rect.x + 104, rect.y, [rect.width - width, 24].max)
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: draw_gauge_area_with_tp
  #--------------------------------------------------------------------------
  def draw_gauge_area_with_tp(rect, actor)
    draw_actor_hp(actor, rect.x - 82, rect.y, 72)
    draw_actor_mp(actor, rect.x + 0, rect.y, 64)
    draw_actor_tp(actor, rect.x + 74, rect.y, 64)
    update_atb
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: draw_gauge_area_without_tp
  #--------------------------------------------------------------------------
  def draw_gauge_area_without_tp(rect, actor)
    draw_actor_hp(actor, rect.x + 0, rect.y, 72)
    draw_actor_mp(actor, rect.x + 82, rect.y, 64)
    update_atb
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: update
  #--------------------------------------------------------------------------
  def update
    super
    update_atb
  end
  #--------------------------------------------------------------------------
  # * New method: update_atb
  #--------------------------------------------------------------------------
  def update_atb
    @count ||= 0
    @count  += 1
    return if @count % 2 != 0
    update_atb_bars
  end
  #--------------------------------------------------------------------------
  # * New method: update_atb_bars
  #--------------------------------------------------------------------------
  def update_atb_bars
    tp_adjust = $data_system.opt_display_tp ? 148 : 156
    item_max.times do |i| 
      actor = $game_party.battle_members[i]
      rect  = gauge_area_rect(i)
      rect.x += tp_adjust
      contents.clear_rect(rect)
      draw_actor_atb(actor, rect.x, rect.y, 64)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: draw_actor_atb
  #--------------------------------------------------------------------------
  def draw_actor_atb(actor, x, y, width = 124)
    color1 = setup_atb_color1(actor)
    color2 = setup_atb_color2(actor)
    draw_gauge(x, y, width, actor.atb_rate, color1, color2)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::VE_ATB_Name)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_atb_color1
  #--------------------------------------------------------------------------
  def setup_atb_color1(actor)
    return text_color(2) if actor.cast_action?
    return text_color(6) if BattleManager.party_escaping?
    return text_color(5) 
  end
  #--------------------------------------------------------------------------
  # * New method: setup_atb_color2
  #--------------------------------------------------------------------------
  def setup_atb_color2(actor)
    return text_color(10) if actor.cast_action?
    return text_color(14) if BattleManager.party_escaping?
    return text_color(13)
  end
end

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :log_window
  attr_reader   :item_window
  attr_reader   :skill_window
  #--------------------------------------------------------------------------
  # * Overwrite method: update_info_viewport
  #--------------------------------------------------------------------------
  def update_all_windows
    update_active_windows
    super
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: update_info_viewport
  #--------------------------------------------------------------------------
  def update_info_viewport
    if VE_MOVE_STATUS_WINDOW
      @move_info_wait  = 4 if @moved_info != windows_active?
      @move_info_wait -= 1
      move_info_viewport(0) if @party_command_window.active
      move_info_viewport(right_status_window)  if right_info_viewport
      move_info_viewport(center_status_window) if center_info_viewport
      @moved_info = windows_active?
    else
      move_info_viewport(128)
    end
    update_close_command_window
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: turn_start
  #--------------------------------------------------------------------------
  def turn_start
    BattleManager.add_actor(BattleManager.actor)
    @close_command_wait   = 2
    @close_command_window = true
    @status_window.unselect
    BattleManager.turn_start
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: start_party_command_selection
  #--------------------------------------------------------------------------
  def start_party_command_selection
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: turn_end
  #--------------------------------------------------------------------------
  def turn_end
  end
  #--------------------------------------------------------------------------
  # * Alias method: battle_start
  #--------------------------------------------------------------------------
  alias :battle_start_ve_active_time_battle :battle_start
  def battle_start
    battle_start_ve_active_time_battle
    battle_start_open_window
  end
  #--------------------------------------------------------------------------
  # * Alias method: create_all_windows
  #--------------------------------------------------------------------------
  alias :create_all_windows_ve_active_time_battle :create_all_windows
  def create_all_windows
    create_all_windows_ve_active_time_battle
    create_escape_window
    @close_command_wait = 0
    @move_info_wait     = 4
  end
  #--------------------------------------------------------------------------
  # * Alias method: reate_party_command_window
  #--------------------------------------------------------------------------
  alias :create_party_command_window_ve_active_time_battle :create_party_command_window
  def create_party_command_window
    create_party_command_window_ve_active_time_battle
    unless VE_MOVE_STATUS_WINDOW
      @party_command_window.x = @party_command_window.width
    end
    @info_viewport.ox = center_status_window
  end
  #--------------------------------------------------------------------------
  # * Alias method: create_actor_command_window
  #--------------------------------------------------------------------------
  alias :create_command_window_ve_active_time_battle :create_actor_command_window
  def create_actor_command_window
    create_command_window_ve_active_time_battle
    @actor_command_window.set_handler(:escape,  method(:command_escape))
    if !VE_MOVE_STATUS_WINDOW
      @actor_command_window.x = @actor_command_window.width
    elsif $data_system.opt_display_tp
      @actor_command_window.x = Graphics.width + 128
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :update_ve_active_time_battle :update
  def update
    result = update_ve_active_time_battle
    BattleManager.update_atb unless result
    result
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_basic
  #--------------------------------------------------------------------------
  alias :update_basic_ve_active_time_battle :update_basic
  def update_basic
    update_basic_ve_active_time_battle
    update_escape_window if VE_ATB_ESCAPE_TYPE == :key
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_for_wait
  #--------------------------------------------------------------------------
  alias :update_for_wait_ve_active_time_battle :update_for_wait
  def update_for_wait
    update_for_wait_ve_active_time_battle
    BattleManager.update_atb if BattleManager.in_turn? && !wait_action?
  end
  #--------------------------------------------------------------------------
  # * Alias method: wait_for_message
  #--------------------------------------------------------------------------
  alias :wait_for_message_ve_active_time_battle :wait_for_message
  def wait_for_message
    wait_for_message_ve_active_time_battle
    open_windows
  end
  #--------------------------------------------------------------------------
  # * Atualização da mensagem aberta
  #--------------------------------------------------------------------------
  alias :update_message_open_ve_active_time_battle :update_message_open
  def update_message_open
    close_windows
    update_message_open_ve_active_time_battle
  end
  #--------------------------------------------------------------------------
  # * Alias method: start_actor_command_selection
  #--------------------------------------------------------------------------
  alias :start_actor_command_selection_ve_active_time_battle :start_actor_command_selection
  def start_actor_command_selection
    start_actor_command_selection_ve_active_time_battle
    @close_command_window = false
  end
  #--------------------------------------------------------------------------
  # * Alias method: process_action_end
  #--------------------------------------------------------------------------
  alias :process_action_end_ve_active_time_battle :process_action_end
  def process_action_end
    return if $imported[:ve_animated_battle] && @subject.poses.active?
    BattleManager.increase_atb_turn_count(:battlers)
    BattleManager.increase_atb_turn_count(:actions)
    process_action_end_ve_active_time_battle
  end
  #--------------------------------------------------------------------------
  # * Alias method: command_fight
  #--------------------------------------------------------------------------
  alias :command_fight_end_ve_active_time_battle :command_fight
  def command_fight
    command_fight_end_ve_active_time_battle
    @party_command_window.close
    BattleManager.undo_escape
  end
  #--------------------------------------------------------------------------
  # * Alias method: command_escape
  #--------------------------------------------------------------------------
  alias :command_escape_end_ve_active_time_battle :command_escape
  def command_escape
    if VE_ATB_ESCAPE_TYPE == :command
      BattleManager.actor.atb = 0 
      command_escape_end_ve_active_time_battle
      battle_start_open_window
    else
      @party_command_window.close
      BattleManager.setup_escape
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: prior_command
  #--------------------------------------------------------------------------
  alias :prior_command_ve_active_time_battle :prior_command
  def prior_command
    prior_command_ve_active_time_battle
    open_party_command_selection if !BattleManager.actor.prior_command
  end
  #--------------------------------------------------------------------------
  # * Alias method: on_enemy_ok
  #--------------------------------------------------------------------------
  alias :on_enemy_ok_ve_active_time_battle :on_enemy_ok
  def on_enemy_ok
    return if !@enemy_window.enemy
    on_enemy_ok_ve_active_time_battle
  end
  #--------------------------------------------------------------------------
  # * Alias method: refresh_status
  #--------------------------------------------------------------------------
  alias :refresh_status_ve_active_time_battle :refresh_status
  def refresh_status
    refresh_status_ve_active_time_battle
    @skill_window.refresh if @skill_window.active
    @item_window.refresh  if @item_window.active
  end
  #--------------------------------------------------------------------------
  # * New method: update_close_command_window
  #--------------------------------------------------------------------------
  def update_close_command_window
    @close_command_wait -= 1
    if @close_command_wait == 0 && @close_command_window
      @actor_command_window.close
      @close_command_window = false
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_active_windows
  #--------------------------------------------------------------------------
  def update_active_windows
    @enemy_window.hide if @enemy_window.active && @enemy_window.item_max == 0
    @actor_window.hide if @actor_window.active && @actor_window.item_max == 0
    close_command_windows
  end
  #--------------------------------------------------------------------------
  # * New method: close_command_windows
  #--------------------------------------------------------------------------
  def close_command_windows
    return if !BattleManager.actor || BattleManager.actor.inputable?
    on_enemy_cancel if @enemy_window.active
    on_actor_cancel if @actor_window.active
    on_skill_cancel if @skill_window.active
    on_item_cancel  if @item_window.active
    @actor_command_window.close.deactivate
    @skill_window.deactivate
    @item_window.deactivate
    @actor_window.deactivate
    @enemy_window.deactivate
    BattleManager.clear_actor
    next_command
  end
  #--------------------------------------------------------------------------
  # * New method: create_escape_window
  #--------------------------------------------------------------------------
  def create_escape_window
    @escape_window = Window_Help.new(1)
    @escape_window.openness = 0
  end
  #--------------------------------------------------------------------------
  # * New method: update_escape_window
  #--------------------------------------------------------------------------
  def update_escape_window
    escaping = BattleManager.escaping?
    open_escape_window   if  escaping && @escape_window.openness == 0
    @escape_window.close if !escaping && @escape_window.openness != 0
  end
  #--------------------------------------------------------------------------
  # * New method: open_escape_window
  #--------------------------------------------------------------------------
  def open_escape_window
    return if BattleManager.can_escape? && !VE_ATB_ESCAPE_TEXT
    txt = BattleManager.can_escape? ? Vocab::VE_Escaping : Vocab::VE_CantEscape
    @escape_window.set_text(txt)
    @escape_window.open
  end
  #--------------------------------------------------------------------------
  # * New method: on_turn_end
  #--------------------------------------------------------------------------
  def on_turn_end
  end
  #--------------------------------------------------------------------------
  # * New method: close_windows
  #--------------------------------------------------------------------------
  def close_windows
    if $game_message.busy? && !@status_window.close?
      command_windows.each {|window| window.hidden ||= window.open?  }
      @help_window.close
      @item_window.close
      @skill_window.close
      @actor_window.close
      @enemy_window.close
    end
  end
  #--------------------------------------------------------------------------
  # * New method: open_windows
  #--------------------------------------------------------------------------
  def open_windows
    command_windows.each do |window| 
      window.open if window.hidden
      window.hidden = false
    end
  end
  #--------------------------------------------------------------------------
  # * New method: command_windows
  #--------------------------------------------------------------------------
  def command_windows
    [@party_command_window, @actor_command_window, @help_window, @skill_window,
     @item_window, @actor_window, @enemy_window, @status_window]
  end
  #--------------------------------------------------------------------------
  # * New method: battle_start_open_window
  #--------------------------------------------------------------------------
  def battle_start_open_window
    unless scene_changing?
      refresh_status
      @status_window.unselect
      @status_window.open
    end
  end
  #--------------------------------------------------------------------------
  # * New method: open_party_command_selection
  #--------------------------------------------------------------------------
  def open_party_command_selection
    return if scene_changing? || VE_ATB_ESCAPE_TYPE != :party
    BattleManager.delete_input(BattleManager.actor)
    refresh_status
    @status_window.unselect
    @status_window.open
    @actor_command_window.close.deactivate
    @party_command_window.setup
  end
  #--------------------------------------------------------------------------
  # * New method: wait_action?
  #--------------------------------------------------------------------------
  def wait_action?
    VE_ATB_WAIT_ACTION
  end
  #--------------------------------------------------------------------------
  # * New method: full_wait?
  #--------------------------------------------------------------------------
  def full_wait?
    $game_system.wait_mode == :full_wait && windows_active?(true)
  end
  #--------------------------------------------------------------------------
  # * New method: semi_wait?
  #--------------------------------------------------------------------------
  def semi_wait?
    $game_system.wait_mode == :semi_wait && windows_active?(false)
  end
  #--------------------------------------------------------------------------
  # * New method: party_window?
  #--------------------------------------------------------------------------
  def party_window?
    @party_command_window.active
  end
  #--------------------------------------------------------------------------
  # * New method: windows_active?
  #--------------------------------------------------------------------------
  def windows_active?(command = true)
    (command && @actor_command_window.active)   || @skill_window.active ||
    @item_window.active || @actor_window.active || @enemy_window.active
  end
  #--------------------------------------------------------------------------
  # * New method: turn_ending
  #--------------------------------------------------------------------------
  def turn_ending
    BattleManager.turn_end
    process_event
    BattleManager.turn_phase
  end
  #--------------------------------------------------------------------------
  # * New method: right_status_window
  #--------------------------------------------------------------------------
  def right_status_window
    256 - (Graphics.width - @status_window.width)
  end
  #--------------------------------------------------------------------------
  # * New method: center_status_window
  #--------------------------------------------------------------------------
  def center_status_window
    128 - (Graphics.width - @status_window.width) / 2
  end
  #--------------------------------------------------------------------------
  # * New method: right_info_viewport
  #--------------------------------------------------------------------------
  def right_info_viewport
    !@party_command_window.active && windows_active? && @move_info_wait < 0
  end
  #--------------------------------------------------------------------------
  # * New method: center_info_viewport
  #--------------------------------------------------------------------------
  def center_info_viewport
    !@party_command_window.active && !windows_active? && @move_info_wait < 0
  end
end