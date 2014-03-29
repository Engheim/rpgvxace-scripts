#==============================================================================
# ** Victor Engine - Materia System
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Aditional Credit :
#   - Tamsynn/Apoclaydon (Commission requester)
#
# Version History:
#  v 1.00 - 2012.11.01 > First relase
#  v 1.01 - 2013.01.05 > Fixed Added Effect and Elemental Materia
#  v 1.02 - 2013.02.13 > Compatibility with Passive States
#------------------------------------------------------------------------------
#  This script replicate the Materia system from FFVII. You can attch
# 'materias' on the actor equipment to gain skills, status boost and varied
# special effects.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.29 or higher
#   If used with 'Victor Engine - Target Arrow' place this bellow it.
#
# * Overwrite methods
#   class Window_MenuActor < Window_MenuStatus
#     def select_for_item(item, for_all = false)
#
#   class Scene_ItemBase < Scene_MenuBase
#     def determine_item
#     def item_target_actors
#
# * Alias methods
#   class << BattleManager
#     def display_exp
#
#   class Game_Temp
#     def initialize
#
#   class Game_Action
#     def targets_for_opponents
#     def targets_for_friends
#
#   class Game_BattlerBase
#     def skill_mp_cost(skill)
#     def skill_conditions_met?(skill)
#
#   class Game_Battler < Game_BattlerBase
#     def use_item(item)
#     def item_apply(user, item)
#     def make_damage_value(user, item)
#     def apply_guard(damage)
#
#   class Game_Actor < Game_Battler
#     def setup(actor_id)
#     def skills
#     def param(param_id)
#     def param_plus(param_id)
#     def param_rate(param_id)
#     def xparam(param_id)
#     def sparam(param_id)
#     def element_rate(id)
#     def state_rate(id)
#     def atk_elements
#     def atk_states
#     def atk_states_rate(id)
#     def feature_objects
#
#   class Game_Party < Game_Unit
#     def init_all_items
#     def gain_item(item, amount, include_equip = false)
#
#   class Game_Interpreter
#     def command_319
#     def command_302
#     def comment_call
#
#   class Window_MenuCommand < Window_Command
#     def add_main_commands
#
#   class Window_SkillList < Window_Selectable
#     def draw_skill_cost(rect, skill)
#
#   class Window_BattleLog < Window_Selectable
#     def display_failure(target, item)
#
#   class Scene_Menu < Scene_MenuBase
#     def create_command_window
#     def on_personal_ok
#
#   class Scene_Equip < Scene_MenuBase
#     def on_actor_change
#
#   class Scene_Battle < Scene_Base
#     def on_skill_ok
#     def battle_start
#     def pre_terminate
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Comment calls note tags:
#  Tags to be used on the events comment box, works like a script call
#
#  <materia shop>
#   Place this before calling the shop event command for materias
#  
#  <equip materia: actor, equip, slot, materia>
#   Adds a materia on a specific slot of one actor.
#     actor   : actor ID
#     equip   : equip slot
#     slot    : materia slot
#     materia : materia ID
#
#  <unequip materia: actor, equip, slot>
#   Remove the materia equiped on a specific slot of one actor.
#     actor : actor id
#     equip : equip slot
#     slot  : materia slot
#
#  <drop materia: id, amount>
#   Remove one materia with the selected id
#     id     : materia id
#     amount : amount removed
#
#------------------------------------------------------------------------------
# Enemies note tags:
#   Tags to be used on Enemies note boxes.
#
#  <ap: x>
#   Ap given by the enemy upon defeat. If not set the value is equal the enemy
#   EXP / 10
#     x : Ap value
#
#------------------------------------------------------------------------------
# Skills note tags:
#   Tags to be used on the Skills note box in the database.
#
#  <negate cost>
#   The skill will ignore the effects "Mp Cost: +x%" and "Mp Cost: -x%"
#
#  <negate damage>
#   The skill will ignore the effects "Damage: +x%" and "Damage: -x%"
#
#  <negate absorb>
#   The skill will ignore the effects "HP Absorb: x%" and "MP Absorb: x%"
#
#  <negate all>
#   The skill will ignore the effects "All"
#
#------------------------------------------------------------------------------
# Armors (Non-Materia) note tags:
#   Tags to be used on the Weapons and non-materia Armors note box in the
#   database. (Only for Armors tagged as Materia)
# 
#  <materia slots: slots>
#   Setup the materia slots.
#     slots : slots setup, you must add a 0 for each slot, slots can be linked
#             using =. Correct White spacing is very important for the setup.
#     Ex.: <materia slots: 0 0 0>     # Materia with 3 single slots
#          <materia slots: 0=0 0=0 0> # Materia with 2 paired slots and 1 single
#
#  <materia growth: x>
#   Materia growth multiplier for materias equiped on this equip.
#     x : muliplier, can be decimal.
#     Obs.: Equiment with growth 0 will use a diffetent icon for the slots
#
#------------------------------------------------------------------------------
# Armors (Materia) note tags:
#   Tags to be used on the Armors note box in the database. (Only for Armors
#   tagged as Materia)
#
#  <materia type: x>
#   This tag define the armor as a materia. 
#     x : type. Can be either Support, Independet or Magic
#        Support     : materias that can have special effects when paired
#        Magic       : materias that receive bonus when paired with support
#        Independent : materias that don't gain any bonus for being paired
#
#  <ap list: x>
#  <ap list: x, x>
#   The list of AP needed for the materia to level up. This also set the
#   materia max level. Each value added increase the max level by 1.
#     x : AP for next level
#
#  <level icon: x>
#   Setup the icon that will be used to represent the level of the materia
#     x : icon index
#
#  <master value: x>
#   Price that the materia can be sold when reach the max level (master)
#     x : price
#
#  <limited use>
#   Materias with this tag can be used one time for each level per battle
#
#  <stats: stat: +x%>              <stats: stat: -x%>
#  <stats: stat: +x%, stat: +x%>   <stats: stat: -x%, stat: -x%>
#   Setup % change values for the stats. These values don't change with materia
#   level
#     stat : stat name (HP, MP, Atk, Def, Mat, Mdf, Agi, Luk)
#     x    : value change
#
#  <elements: x>
#  <elements: x, x>
#   Tag elements for the materia, these elements have effect when the materia
#   is paired with support materia with "Elemental" effect
#     x : elements IDs
#
#  <states: x>
#  <states: x, x>
#   Tag statea for the materia, these states have effect when the materia
#   is paired with support materia with "Added Effect" effect
#     x : states IDs
#
#  <effect name: x>
#   By default, the materia info display a list of values for the materia 
#   effects, using this tag you can use a custom name for info display
#     x : effect name
#
#  <skills: level: x>
#  <skills: level: x, level: x>
#   skills granted by the materia.
#     level : level that the materia must be to grant the skill
#     x     : skill id
#
#  <effects: x>  
#  <effects: x, x>
#   This tag allows to add special effects for the materia. These effects
#   vary a lot, and some are based on the materia level.
#     x : effect
#      Stat: +x%   : Increase a param, sparam or xparam by x% for each level
#      Stat: -x%   : Decrease a param, sparam or xparam by x% for each level
#      Damage: +x% : Increase skill damage x% for each level
#      Damage: -x% : Decrease skill damage x% for each level
#      Hp Mp       : Invert the HP and MP values
#      Enemy Skill : Change the materia setup to use "Enemy Skill"
#
#    - Only for Support materia, affects paired materia skills
#      Mp Cost: +x%   : Increase Mp Cost for x% for each level
#      Mp Cost: -x%   : Decrease Mp Cost for x% for each level
#      Hp Absorb: x%  : Absorb Hp x% of the damage dealt for each level
#      Mp Absorb: x%  : Absorb Mp x% of the damage dealt for each level
#      All            : Skill affect all targets per use for each level
#      Elemental: +x% : Increase element resistance by x% for each level
#      Elemental: -x% : Decrease element resistance by x% for each level
#      Added Effect: +x% : Increase state effect by x% for each level
#      Added Effect: -x% : Decrease state effect by x% for each level
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#  Materias are setup using Armors slots from the database, all stats bonus
#  and traits you setup on the armor that will be used as a materia works
#  normally.
#
#  The first step to setup the materia is to define it's tipe with the
#  tag <materia type: x>, the main difference between each type is how
#  they interact with paired slots. The types are Magic, Support and
#  Independent
#  There's no Summon or Command types, since mechanically both works like
#  magic materias.
#   
#  The tag <stats: stat: +x%> <stats: stat: -x%> allows you to setup % changes
#  on the status. Fixed values can be set on the database itself.
#
#  Elements set with the tag <elements: x> have effect when paired with 
#  support materias with the 'Elemental' effect. The effect will change
#  depending on the equipment that the pair is set. If it's on a weapon
#  the attacks will gain elemental damage, if it's on a armor the actor
#  will gain elemental resistance based on the materia level.
#
#  States set with the <states: x> works like the elements: when added to
#  a weapon, the attacks will gain a chance of inflicting the state, when
#  added to armors, it will change the state resist.
#
#  Materias can grant skills using the tag <skills: level: x> based on the
#  current materia level. The skills becomes avaiable as soon the materia
#  reach the min level needed, and are removed if the materia is removed.
#
#  The effects <effects: x> is the most complex settings, it's have a high
#  number of possible effects. 
#  The Stat: +x% and Stat: -x% effects allows to add any param, sparam or
#  xparam. The value is based on the materia level.
#  so if you setup a effect CNT: +10% and the materia is at level 3, the
#  actor will gain 30% counter attack rate.
#  Some effects works only with paired support materias.
#
#  The Enemy Skill Effect is a very special effect. A materia with this effect
#  allows the actor to learn the skills when hit by one of the skills that
#  this materia can give. The materia don't level up with AP, but instead
#  gain 1 level for each skill learned. When setting up the skills, you
#  still need to add a level for them, but the values are arbritary and
#  is used only to sort the skills.
#
#  You can edit the materia related texts on the module Vocab withing the script
#
#------------------------------------------------------------------------------
# Examples:
#
# Fire
#  <materia type: Magic>
#  <level icon: 547>
#  <master value: 42000>
#  <elements: 3>
#  <ap list: 2000, 18000, 35000>
#  <stats: hp: -2%, mp: +2%>
#  <skills: 1: 51, 2: 53, 3: 52, 4: 54>
#
# MP Turbo
#  <materia type: Support>
#  <level icon: 550>
#  <master value: 1>
#  <effect name: MP Turbo>
#  <effects: MP Cost: +10%, Damage: +10%>
#  <ap list: 10000, 30000, 60000, 120000>
#
# Enemy Skill
#  <materia type: Command>
#  <level icon: 548>
#  <master value: 1>
#  <effects: Enemy Skill>
#  <skills: 1: 8, 2: 9, 3: 10, 4: 11, 5: 12, 6: 13, 7: 14, 8: 15,
#  9: 16, 10: 17, 11: 18, 12: 19, 13: 20, 14: 21, 15: 22, 16: 23>
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Max materia number
  #   The max ammount of materias that the player can keep, leave nil for
  #   no limit. Be aware that if the player have 300 or more materia 
  #   there might be freezes when opening the materia menus
  #--------------------------------------------------------------------------
  Max_Materia_Number = 255
  #--------------------------------------------------------------------------
  # * Max slot number
  #   Max number of slots for equipment
  #--------------------------------------------------------------------------
  Max_Slot_Number    = 8
  #--------------------------------------------------------------------------
  # * Materia Brreding
  #   If true the player will gain a new level 1 materia when a materia
  #   reach the max level
  #--------------------------------------------------------------------------
  Materia_Breeding  = true
  #--------------------------------------------------------------------------
  # * Icons setup
  #   Default icons for materia slots
  #--------------------------------------------------------------------------
  Slot_Icon_Normal   = 528
  Slot_Icon_Nothing  = 529
  Slot_Link_Icon     = 530
  Materia_Level_Icon = 547
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
$imported[:ve_materia_system] = 1.02
Victor_Engine.required(:ve_materia_system, :ve_basic_module, 1.29, :above)

#==============================================================================
# ** Vocab
#------------------------------------------------------------------------------
#  This module defines terms and messages. It defines some data as constant
# variables. Terms in the database are obtained from $data_system.
#==============================================================================

module Vocab

  # Materia menu options
  VE_MateriaMenu = "Materia"
  
  # Message displayed when learning Enemies Skills
  VE_EnemySkill  = "%s learend %s"
  
  # AP stat name
  VE_ApName      = "AP"
  
  # AP received message on battle end
  VE_ApReceived  = "%s AP received!"
  
  # Max level materia text
  VE_MasterText  = "Master!"
  
end

#==============================================================================
# ** RPG::Skill
#------------------------------------------------------------------------------
#  This is the data class for skills.
#==============================================================================

class RPG::Skill < RPG::UsableItem
  #--------------------------------------------------------------------------
  # * New method: cost?
  #--------------------------------------------------------------------------
  def cost?(id)
    @id == id && !(note =~ /<NEGATE COST>/i)
  end 
  #--------------------------------------------------------------------------
  # * New method: damage?
  #--------------------------------------------------------------------------
  def damage?(id)
    @id == id && !(note =~ /<NEGATE DAMAGE>/i)
  end 
  #--------------------------------------------------------------------------
  # * New method: absorb?
  #--------------------------------------------------------------------------
  def absorb?(id)
    @id == id && !(note =~ /<NEGATE ABSORB>/i)
  end
  #--------------------------------------------------------------------------
  # * New method: all?
  #--------------------------------------------------------------------------
  def all?
    for_one? && !(note =~ /<NEGATE ALL>/i)
  end
end

#==============================================================================
# ** RPG::UsableItem
#------------------------------------------------------------------------------
#  This is the superclass for skills and items.
#==============================================================================

class RPG::UsableItem < RPG::BaseItem
  #--------------------------------------------------------------------------
  # * New method: all?
  #--------------------------------------------------------------------------
  def all?
    return false
  end
  #--------------------------------------------------------------------------
  # * New method: materia?
  #--------------------------------------------------------------------------
  def materia?
    return false
  end
end

#==============================================================================
# ** RPG::EquipItem
#------------------------------------------------------------------------------
#  This is the superclass of weapons and armor.
#==============================================================================

class RPG::EquipItem < RPG::BaseItem
  #--------------------------------------------------------------------------
  # * New method: materia?
  #--------------------------------------------------------------------------
  def materia?
    return false
  end
  #--------------------------------------------------------------------------
  # * New method: growth
  #--------------------------------------------------------------------------
  def growth
    return @growth if @growth
    @growth = note =~ /<MATERIA GROWTH: (\d+)>/i ? $1.to_f : 1
  end
  #--------------------------------------------------------------------------
  # * New method: nothing?
  #--------------------------------------------------------------------------
  def nothing?
    growth == 0
  end
  #--------------------------------------------------------------------------
  # * New method: double_slots
  #--------------------------------------------------------------------------
  def double_slots
    return @double_slots if @double_slots
    list = note =~ /<MATERIA SLOTS: ([ 0o=]*)>/i ? $1.dup : ""
    @double_slots = list.scan(/[0o]=[0o]/i).size * 2
  end
  #--------------------------------------------------------------------------
  # * New method: single_slots
  #--------------------------------------------------------------------------
  def single_slots
    return @single_slots if @single_slots
    list   = note =~ /<MATERIA SLOTS: ([ 0o=]*)>/i ? $1.dup : ""
    @single_slots = list.scan(/[0o]/i).size - double_slots
  end
  #--------------------------------------------------------------------------
  # * New method: slots
  #--------------------------------------------------------------------------
  def slots
    double_slots + single_slots
  end
end

#==============================================================================
# ** RPG::Armor
#------------------------------------------------------------------------------
#  The data class for armor.
#==============================================================================

class RPG::Armor < RPG::EquipItem
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :ap
  attr_accessor :times
  attr_accessor :limit
  attr_reader   :type
  attr_reader   :stats
  attr_reader   :learn
  attr_reader   :skills
  attr_reader   :states
  attr_reader   :master
  attr_reader   :elements
  attr_reader   :effects
  #--------------------------------------------------------------------------
  # * New method: materia?
  #--------------------------------------------------------------------------
  def materia?
    note =~ /<MATERIA TYPE: (\w+)>/i
  end
  #--------------------------------------------------------------------------
  # * New method: setup_materia
  #--------------------------------------------------------------------------
  def setup_materia
    setup_base
    setup_type
    setup_name
    setup_price
    setup_stats
    setup_skills
    setup_states
    setup_elements
    setup_effects
    setup_limit
    self
  end
  #--------------------------------------------------------------------------
  # * New method: setup_base
  #--------------------------------------------------------------------------
  def setup_base
    @ap    ||= 0
    @times ||= 1
    @level ||= 0
    @learn ||= {}
    @ap_list = setup_lists("AP LIST", [0])
  end
  #--------------------------------------------------------------------------
  # * New method: setup_states
  #--------------------------------------------------------------------------
  def setup_states
    @states = setup_lists("STATES")
  end
  #--------------------------------------------------------------------------
  # * New method: setup_elements
  #--------------------------------------------------------------------------
  def setup_elements
    @elements = setup_lists("ELEMENTS") 
  end
  #--------------------------------------------------------------------------
  # * New method: setup_type
  #--------------------------------------------------------------------------
  def setup_type
    @type = note =~ /<MATERIA TYPE: (\w+)>/i ? $1.upcase : "MAGIC"
  end
  #--------------------------------------------------------------------------
  # * New method: setup_name
  #--------------------------------------------------------------------------
  def setup_name
    @effect_name = note =~ /<EFFECT NAME: ([\w\s.,;]+)>/i ? $1.to_s : nil
  end
  #--------------------------------------------------------------------------
  # * New method: setup_price
  #--------------------------------------------------------------------------
  def setup_price
    @master = note =~ /<MASTER VALUE: (\d+)>/i ? $1.to_i : price * 10
  end
  #--------------------------------------------------------------------------
  # * New method: setup_limit
  #--------------------------------------------------------------------------
  def setup_limit
    @limited = note =~ /<LIMITED USE>/i ? true : false
    @limit   = {}
    @skills.values.each {|i| @limit[i] = level }
  end
  #--------------------------------------------------------------------------
  # * New method: setup_stats
  #--------------------------------------------------------------------------
  def setup_stats
    @stats = {}
    values = note =~ /<STATS:\s([\w\s\+\-:%,;]+)>/i ? $1.dup : ""
    regexp = /(\w+):\s*([+-]?\d+)%/i
    values.scan(regexp).each {|x, y| @stats[get_param_id(x)] = y.to_i }
  end
  #--------------------------------------------------------------------------
  # * New method: setup_skills
  #--------------------------------------------------------------------------
  def setup_skills
    @skills = {}
    values  = note =~ /<SKILLS:\s([\d\s\:,;]+)>/i ? $1.dup : ""
    values.scan(/(\d+):\s*(\d+)/i).each {|x, y| @skills[x.to_i] = y.to_i }
  end
  #--------------------------------------------------------------------------
  # * New method: setup_effects
  #--------------------------------------------------------------------------
  def setup_effects
    values   = note =~ /<EFFECTS:\s([\w\s\+\-:%,;]+)>/i ? $1.dup : ""
    @effects = values.scan(/[\w\s\+\-\:\%]*/i).inject({}) do |r, i|
      if i =~ /([\w\s]+)(?:: *([+-]?\d+)%?)?/i
        r[make_symbol($1)] = $2 ? $2.to_i / 100.0 : true
      end
      r
    end
    @effects.default = 0
  end
  #--------------------------------------------------------------------------
  # * New method: elements?
  #--------------------------------------------------------------------------
  def setup_lists(type, base = [])
    values = note =~ /<#{type}: ([\d\s;,]+)>/i ? $1.dup : ""
    values.scan(/\d+/i).inject(base) { |r, i| r.push(i.to_i) }
  end
  #--------------------------------------------------------------------------
  # * New method: 
  #--------------------------------------------------------------------------
  def elements?(elements)
    @elements.include?(elements)
  end
  #--------------------------------------------------------------------------
  # * New method: states?
  #--------------------------------------------------------------------------
  def states?(states)
    @states.include?(states)
  end
  #--------------------------------------------------------------------------
  # * New method: effect?
  #--------------------------------------------------------------------------
  def effect?(effect)
    @effects.keys.include?(effect)
  end
  #--------------------------------------------------------------------------
  # * New method: effect
  #--------------------------------------------------------------------------
  def effect(value)
    @effects[value]
  end
  #--------------------------------------------------------------------------
  # * New method: ap=
  #--------------------------------------------------------------------------
  def ap=(n)
    @ap = [n, @ap_list.last].min
  end
  #--------------------------------------------------------------------------
  # * New method: level
  #--------------------------------------------------------------------------
  def level
    max_level.times {|i| break @level += 1 if level_up? }
    enemy_skill? ? @learn.values.size : @level
  end
  #--------------------------------------------------------------------------
  # * New method: max_level
  #--------------------------------------------------------------------------
  def max_level
    enemy_skill? ? @skills.size : @ap_list.size
  end
  #--------------------------------------------------------------------------
  # * New method: level_up?
  #--------------------------------------------------------------------------
  def level_up?
    @ap >= next_level && @level < max_level
  end
  #--------------------------------------------------------------------------
  # * New method: master?
  #--------------------------------------------------------------------------
  def master?
    level == max_level
  end
  #--------------------------------------------------------------------------
  # * New method: next_level
  #--------------------------------------------------------------------------
  def next_level
    @level.times.inject([0]) {|r, i| r + [@ap_list[i + 1]] }.sum
  end
  #--------------------------------------------------------------------------
  # * New method: stat
  #--------------------------------------------------------------------------
  def stat(i)
    @stats[i] ? @stats[i] : 0
  end
  #--------------------------------------------------------------------------
  # * New method: reset_times
  #--------------------------------------------------------------------------
  def reset_times
    @times = level
    setup_limit
  end
  #--------------------------------------------------------------------------
  # * New method: sell_price
  #--------------------------------------------------------------------------
  def sell_price
    base = (price / 2)
    var  = @master - base
    rate = [@ap * 100 / [@ap_list.sum, 1].max, 100].min
    @master <= price ? @master : [((var * rate) / 100) + base, 0].max
  end
  #--------------------------------------------------------------------------
  # * New method: gain_ap
  #--------------------------------------------------------------------------
  def gain_ap(n, growth)
    old_level = level
    @ap += (n * growth).to_i
    if Materia_Breeding && old_level < max_level && level == max_level
      $game_party.gain_materia($data_armors[@id])
    end
  end
  #--------------------------------------------------------------------------
  # * New method: level_icon
  #--------------------------------------------------------------------------
  def level_icon
    note =~ /<LEVEL ICON: (\d+)>/i ? $1.to_i : Materia_Level_Icon
  end
  #--------------------------------------------------------------------------
  # * New method: level_value
  #--------------------------------------------------------------------------
  def level_value(value)
    level * effect(value)
  end
  #--------------------------------------------------------------------------
  # * New method: support?
  #--------------------------------------------------------------------------
  def support?
    @type == "SUPPORT"
  end
  #--------------------------------------------------------------------------
  # * New method: independent?
  #--------------------------------------------------------------------------
  def independent?
    @type == "INDEPENDENT"
  end
  #--------------------------------------------------------------------------
  # * New method: effect_name
  #--------------------------------------------------------------------------
  def effect_name
    @effect_name
  end
  #--------------------------------------------------------------------------
  # * New method: cost?
  #--------------------------------------------------------------------------
  def cost?(skill)
    !support? && skill?(skill) && effect?(:mp_cost)
  end
  #--------------------------------------------------------------------------
  # * New method: damage?
  #--------------------------------------------------------------------------
  def damage?(skill)
    !support? && skill?(skill) && effect?(:damage)
  end
  #--------------------------------------------------------------------------
  # * New method: skill?
  #--------------------------------------------------------------------------
  def skill?(id)
    @skills.values.include?(id)
  end
  #--------------------------------------------------------------------------
  # * New method: all?
  #--------------------------------------------------------------------------
  def all?
    effect?(:all) && @times > 0
  end
  #--------------------------------------------------------------------------
  # * New method: enemy_skill?
  #--------------------------------------------------------------------------
  def enemy_skill?
    effect?(:enemy_skill)
  end
  #--------------------------------------------------------------------------
  # * New method: on_limit?
  #--------------------------------------------------------------------------
  def on_limit?(id)
    !limited? || (@limit[id] && @limit[id] > 0)
  end
  #--------------------------------------------------------------------------
  # * New method: limited?
  #--------------------------------------------------------------------------
  def limited?
    @limited
  end
  #--------------------------------------------------------------------------
  # * New method: learn_enemy_skill
  #--------------------------------------------------------------------------
  def learn_enemy_skill(id)
    if skill?(id) && !@learn.values.include?(id)
      @skills.keys.each {|i| @learn[i] = @skills[i] if @skills[i] == id }
    end
  end
  #--------------------------------------------------------------------------
  # * New method: learned_enemy_skill?
  #--------------------------------------------------------------------------
  def learned_enemy_skill?(id)
    @learn.values.include?(id)
  end
end

#==============================================================================
# ** BattleManager
#------------------------------------------------------------------------------
#  This module manages battle progress.
#==============================================================================

class << BattleManager
  #--------------------------------------------------------------------------
  # * Alias method: display_exp
  #--------------------------------------------------------------------------
  alias :display_exp_ve_materia_system :display_exp
  def display_exp
    display_exp_ve_materia_system
    display_ap
  end
  #--------------------------------------------------------------------------
  # * New method: display_ap
  #--------------------------------------------------------------------------
  def display_ap
    return if $game_troop.ap_total == 0
    text = sprintf(Vocab::VE_ApReceived, $game_troop.ap_total)
    $game_message.add('\.' + text)
    $game_party.all_members.each {|actor| actor.ap += $game_troop.ap_total }
  end
end

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
  attr_accessor :materia_shop
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_materia_system :initialize
  def initialize
    initialize_ve_materia_system
    @materia_shop = false
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
  # * Alias method: targets_for_opponents
  #--------------------------------------------------------------------------
  alias :targets_for_opponents_ve_materia_system :targets_for_opponents
  def targets_for_opponents
    if @subject.actor? && item.all? && for_all?(item)
      return opponents_unit.alive_members
    end
    targets_for_opponents_ve_materia_system
  end
  #--------------------------------------------------------------------------
  # * Alias method: targets_for_friends
  #--------------------------------------------------------------------------
  alias :targets_for_friends_ve_materia_system :targets_for_friends
  def targets_for_friends
    if @subject.actor? && item.all? && for_all?(item)
      return friends_unit.alive_members if item.for_friend?
      return friends_unit.dead_members  if item.fitem.for_dead_friend?
    end
    targets_for_friends_ve_materia_system
  end
  #--------------------------------------------------------------------------
  # * New method: for_all?
  #--------------------------------------------------------------------------
  def for_all?(item)
    @subject.paired_materia.each do |pair|
      if pair[:main].all? && pair[:other].skill?(item.id)
        pair[:main].times -= 1
        return true
      end
    end
    return false    
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
  # * Alias method: skill_mp_cost
  #--------------------------------------------------------------------------
  alias :skill_mp_cost_ve_materia_system :skill_mp_cost
  def skill_mp_cost(skill)
    cost = skill_mp_cost_ve_materia_system(skill)
    cost += cost_change_materia(skill, cost, :plus) if actor?
    cost -= cost_change_materia(skill, cost, :cut)  if actor?
    cost.to_i
  end
  #--------------------------------------------------------------------------
  # * Alias method: skill_conditions_met?
  #--------------------------------------------------------------------------
  alias :skill_conditions_met_ve_materia_system? :skill_conditions_met?
  def skill_conditions_met?(skill)
    skill_conditions_met_ve_materia_system?(skill) &&
    materia_conditions_met?(skill.id)
  end
  #--------------------------------------------------------------------------
  # * New method: cost_change_materia
  #--------------------------------------------------------------------------
  def cost_change_materia(skill, cost, type)
    list = paired_materia.inject([0]) do |r, pair|
      m  = pair[:main]
      o  = pair[:other]
      r + [pair_change_cost(m, o, cost, skill.id, type)]
    end
    list.max
  end
  #--------------------------------------------------------------------------
  # * New method: pair_change_cost
  #--------------------------------------------------------------------------
  def pair_change_cost(m, o, cost, id, type)
    return 0 unless m.effect?(:mp_cost)
    list = o.skills.values.inject([0]) do |r, i|
      value = m.level_value(:mp_cost).abs
      r + (id == i && valid_cost_type?(value, type) ? [value] : [])
    end
    cost * list.compact.max
  end
  #--------------------------------------------------------------------------
  # * New method: valid_cost_type?
  #--------------------------------------------------------------------------
  def valid_cost_type?(value, type)
    value > 0 && type == :plus || value < 0 && type == :cut
  end
  #--------------------------------------------------------------------------
  # * New method: materia_conditions_met?
  #--------------------------------------------------------------------------
  def materia_conditions_met?(id)
    return true
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
  alias :use_item_ve_materia_system :use_item
  def use_item(item)
    materia_use_item(item.id) if actor? && item.is_a?(RPG::Skill)
    use_item_ve_materia_system(item)
  end
  #--------------------------------------------------------------------------
  # * Alias method: item_apply
  #--------------------------------------------------------------------------
  alias :item_apply_ve_materia_system :item_apply
  def item_apply(user, item)
    learn_enemy_skill(item.id) if actor?
    item_apply_ve_materia_system(user, item)
  end
  #--------------------------------------------------------------------------
  # * Alias method: make_damage_value
  #--------------------------------------------------------------------------
  alias :make_damage_value_ve_materia_system :make_damage_value
  def make_damage_value(user, item)
    @materia_user = user
    make_damage_value_ve_materia_system(user, item)
  end
  #--------------------------------------------------------------------------
  # * Alias method: apply_guard
  #--------------------------------------------------------------------------
  alias :apply_guard_ve_materia_system :apply_guard
  def apply_guard(damage)
    result = apply_guard_ve_materia_system(damage)
    @materia_user.actor? ? materia_damage(@materia_user, result) : result
  end
  #--------------------------------------------------------------------------
  # * New method: materia_use_item
  #--------------------------------------------------------------------------
  def materia_use_item(id)
    all_materias.each {|m| m.limit[id] -= 1 if m.limited? && m.on_limit?(id) }
  end
  #--------------------------------------------------------------------------
  # * New method: learn_enemy_skill
  #--------------------------------------------------------------------------
  def learn_enemy_skill(id)
    all_materias.each do |m|
      if m.enemy_skill? && m.skill?(id) && !m.learned_enemy_skill?(id)
        @learned_enemy_skill = id
        m.learn_enemy_skill(id)
        update_materia_skills
      end
    end
  end
  #--------------------------------------------------------------------------
  # * New method: materia_damage
  #--------------------------------------------------------------------------
  def materia_damage(user, damage)
    obj = user.current_action ? user.current_action.item : nil
    return damage if damage == 0 || !obj || !obj.is_a?(RPG::Skill)
    damage += damage_plus(damage, user, obj)
    damage += damage_pair(damage, user, obj)
    materia_absorb(damage, user, obj)
    damage.to_i
  end
  #--------------------------------------------------------------------------
  # * New method: damage_plus
  #--------------------------------------------------------------------------
  def damage_plus(damage, user, skill)
    user.all_materias.inject(0) do |r, m|
      r + (m.damage?(skill.id) ? (damage * m.level_value(:damage)).to_i : 0)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: damage_pair
  #--------------------------------------------------------------------------
  def damage_pair(damage, user, skill)
    user.paired_materia.inject(0) do |r, pair|
      m = pair[:main]
      o = pair[:other]
      r + (m.effect?(:damage) ? pair_damage(m, o, damage, skill.id) : 0)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: pair_damage
  #--------------------------------------------------------------------------
  def pair_damage(m, o, damage, id)
    o.skills.values.compact.inject(0) do |r, i|
      mskill = $data_skills[i]
      r + (mskill.damage?(id) ? (damage * m.level_value(:damage)).to_i : 0)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: materia_absorb
  #--------------------------------------------------------------------------
  def materia_absorb(damage, user, skill)
    user.paired_materia.each do |pair|
      m = pair[:main]
      o = pair[:other]
      pair_absorb(user, m, o, damage, skill, "HP")
      pair_absorb(user, m, o, damage, skill, "MP")
    end
  end
  #--------------------------------------------------------------------------
  # * New method: pair_absorb
  #--------------------------------------------------------------------------
  def pair_absorb(user, m, o, damage, skill, type)
    o.skills.values.compact.each do |id|
      mskill = $data_skills[id]
      next unless mskill.absorb?(skill.id) 
      result = (damage * m.level_value(make_symbol("#{type} ABSORB"))).to_i
      type == "HP" ? user.hp += [result, user.mhp - result].min : 
                     user.mp += [result, user.mmp - result].min
    end
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
  attr_accessor :materia_slots
  attr_accessor :learned_enemy_skill
  attr_accessor :ap
  #--------------------------------------------------------------------------
  # * Alias method: setup
  #--------------------------------------------------------------------------
  alias :setup_ve_materia_system :setup
  def setup(actor_id)
    setup_materia_system
    setup_ve_materia_system(actor_id)
    start_materia_slots
  end
  #--------------------------------------------------------------------------
  # * Alias method: skills
  #--------------------------------------------------------------------------
  alias :skills_ve_materia_system :skills
  def skills
    update_materia_skills
    skills_ve_materia_system
  end
  #--------------------------------------------------------------------------
  # * Alias method: param
  #--------------------------------------------------------------------------
  alias :param_ve_materia_system :param
  def param(param_id)
    new_id = hp_mp_check(param_id)
    param_ve_materia_system(new_id)
  end
  #--------------------------------------------------------------------------
  # * Alias method: param_plus
  #--------------------------------------------------------------------------
  alias :param_plus_ve_materia_system :param_plus
  def param_plus(param_id)
    result = param_plus_ve_materia_system(param_id)
    all_materias.inject(result) {|r, item| r += item.params[param_id] }
  end
  #--------------------------------------------------------------------------
  # * Alias method: param_rate
  #--------------------------------------------------------------------------
  alias :param_rate_ve_materia_system :param_rate
  def param_rate(param_id)
    result = param_rate_ve_materia_system(param_id)
    result + materia_param(param_id)
  end
  #--------------------------------------------------------------------------
  # * Alias method: xparam
  #--------------------------------------------------------------------------
  alias :xparam_ve_materia_system :xparam
  def xparam(param_id)
    result = xparam_ve_materia_system(param_id)
    result + materia_xparam(param_id)
  end
  #--------------------------------------------------------------------------
  # * Alias method: sparam
  #--------------------------------------------------------------------------
  alias :sparam_ve_materia_system :sparam
  def sparam(param_id)
    result = sparam_ve_materia_system(param_id)
    result + materia_sparam(param_id)
  end  
  #--------------------------------------------------------------------------
  # * Alias method: element_rate
  #--------------------------------------------------------------------------
  alias :element_rate_ve_materia_system :element_rate
  def element_rate(id)
    element_rate_ve_materia_system(id) + materia_element_rate(id)
  end
  #--------------------------------------------------------------------------
  # * Alias method: state_rate
  #--------------------------------------------------------------------------
  alias :state_rate_ve_materia_system :state_rate
  def state_rate(id)
    state_rate_ve_materia_system(id) + materia_state_rate(id)
  end
  #--------------------------------------------------------------------------
  # * Alias method: atk_elements
  #--------------------------------------------------------------------------
  alias :atk_elements_ve_materia_system :atk_elements
  def atk_elements
    result = atk_elements_ve_materia_system
    materia_atk_elements(result).compact.uniq
  end
  #--------------------------------------------------------------------------
  # * Alias method: atk_states
  #--------------------------------------------------------------------------
  alias :atk_states_ve_materia_system :atk_states
  def atk_states
    result = atk_states_ve_materia_system
    materia_atk_states(result).compact.uniq
  end
  #--------------------------------------------------------------------------
  # * Alias method: atk_states_rate
  #--------------------------------------------------------------------------
  alias :atk_states_rate_ve_materia_system :atk_states_rate
  def atk_states_rate(id)
    atk_states_rate_ve_materia_system(id) + materia_atk_states_rate(id)
  end
  #--------------------------------------------------------------------------
  # * Alias method: feature_objects
  #--------------------------------------------------------------------------
  alias :feature_objects_ve_materia_system :feature_objects
  def feature_objects
    feature_objects_ve_materia_system + all_materias
  end
  #--------------------------------------------------------------------------
  # * New method: setup_materia_system
  #--------------------------------------------------------------------------
  def setup_materia_system
    @materia_slots  = {}
    @materia_skills = []
    @paired_materia = []
  end
  #--------------------------------------------------------------------------
  # * New method: start_materia_slots
  #--------------------------------------------------------------------------
  def start_materia_slots
    equip_slots.size.times do |i| 
      @materia_slots[i] = equips[i] ? Array.new(equips[i].slots, nil) : []
    end
    setup_old_equips
  end
  #--------------------------------------------------------------------------
  # * New method: setup_equipments
  #--------------------------------------------------------------------------
  def setup_equipments
    equip_slots.size.times {|i| setup_materia_slots(i) }
    setup_old_equips
  end
  #--------------------------------------------------------------------------
  # * New method: setup_materia_slots
  #--------------------------------------------------------------------------
  def setup_materia_slots(i)
    return if @equips[i].object == @old_equips[i].object
    @materia_slots[i].compact.each {|m| $game_party.gain_materia(m) }
    @materia_slots[i] = equips[i] ? Array.new(equips[i].slots, nil) : []
  end
  #--------------------------------------------------------------------------
  # * New method: setup_old_equips
  #--------------------------------------------------------------------------
  def setup_old_equips
    @old_equips = @equips.collect {|item| item.clone }
  end
  #--------------------------------------------------------------------------
  # * New method: materia_param
  #--------------------------------------------------------------------------
  def materia_param(id)
    all_materias.inject(0.0) do |r, m|
      r += m.stat(id) / 100.0
      r += m.level * materia_param_plus(m, id)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: materia_param_plus
  #--------------------------------------------------------------------------
  def materia_param_plus(m, id)
    m.effect(make_symbol(get_param_text(id)))
  end
  #--------------------------------------------------------------------------
  # * New method: materia_xparam
  #--------------------------------------------------------------------------
  def materia_xparam(id)
    all_materias.inject(0.0) do |r, m|
      r += m.level * materia_xparam_plus(m, id)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: materia_xparam_plus
  #--------------------------------------------------------------------------
  def materia_xparam_plus(m, id)
    m.effect(make_symbol(get_xparam_text(id)))
  end
  #--------------------------------------------------------------------------
  # * New method: materia_sparam
  #--------------------------------------------------------------------------
  def materia_sparam(id)
    all_materias.inject(0.0) do |r, m|
      r += m.level * materia_sparam_plus(m, id)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: materia_sparam_plus
  #--------------------------------------------------------------------------
  def materia_sparam_plus(m, id)
    m.effect(make_symbol(get_sparam_text(id)))
  end
  #--------------------------------------------------------------------------
  # * New method: ap
  #--------------------------------------------------------------------------
  def ap
    @ap ? @ap : 0
  end
  #--------------------------------------------------------------------------
  # * New method: ap=
  #--------------------------------------------------------------------------
  def ap=(n)
    equip_slots.size.times do |i|
      next if !@equips[i].object || @materia_slots[i].compact.empty?
      growth = @equips[i].object.growth
      @materia_slots[i].compact.each {|m| m.gain_ap(n, growth) }
    end
  end
  #--------------------------------------------------------------------------
  # * New method: all_materias
  #--------------------------------------------------------------------------
  def all_materias
    @materia_slots.values.inject([]) {|r, i| r += i }.compact
  end
  #--------------------------------------------------------------------------
  # * New method: update_materia_skills
  #--------------------------------------------------------------------------
  def update_materia_skills
    @materia_skills.each {|id| forget_skill(id) }
    @materia_skills.clear
    all_materias.each {|m| learn_materia_skill(m) }
  end
  #--------------------------------------------------------------------------
  # * New method: learn_materia_skill
  #--------------------------------------------------------------------------
  def learn_materia_skill(m)
    m.level.times {|i| gain_materia_skill(m, i) if valid_skill?(m, i) }
  end
  #--------------------------------------------------------------------------
  # * New method: gain_materia_skill
  #--------------------------------------------------------------------------
  def gain_materia_skill(m, i)
    id = m.enemy_skill? ? m.learn.values[i] : m.skills[i + 1]
    learn_skill(id)
    @materia_skills.push(id)
    @materia_skills.compact!
  end
  #--------------------------------------------------------------------------
  # * New method: valid_skill?
  #--------------------------------------------------------------------------
  def valid_skill?(m, i)
     (m.enemy_skill? ? m.learn.values[i] : m.skills[i + 1]) &&
     !@skills.include?(m.skills[i + 1])
  end
  #--------------------------------------------------------------------------
  # * New method: hp_mp_check
  #--------------------------------------------------------------------------
  def hp_mp_check(id)
    return id if id > 1
    all_materias.each {|m| return id == 0 ? 1 : 0 if m.effect?(:hp_mp) }
    id
  end
  #--------------------------------------------------------------------------
  # * New method: materia_conditions_met?
  #--------------------------------------------------------------------------
  def materia_conditions_met?(id)
    usable = nil
    all_materias.each {|m| usable |= m.on_limit?(id) if m.skill?(id) }
    usable.nil? ? true : usable
  end
  #--------------------------------------------------------------------------
  # * New method: equip_materia
  #--------------------------------------------------------------------------
  def equip_materia(equip, slot, id, forced = false)
    old = @materia_slots[equip][slot] 
    @materia_slots[equip][slot] = $game_party.materias[id]
    $game_party.lose_materia(id) unless forced
    $game_party.gain_item(old, 1) if old
    make_paired_materia
    update_materia_skills
    refresh
  end
  #--------------------------------------------------------------------------
  # * New method: force_materia
  #--------------------------------------------------------------------------
  def force_materia(equip, slot, id)
    @materia_slots[equip][slot] = $data_armors[id].setup_materia
    make_paired_materia
    update_materia_skills
    refresh
  end
  #--------------------------------------------------------------------------
  # * New method: unequip_materia
  #--------------------------------------------------------------------------
  def unequip_materia(equip, slot)
    $game_party.gain_item(@materia_slots[equip][slot], 1)
    @materia_slots[equip][slot] = nil
    make_paired_materia
    update_materia_skills
    refresh
  end
  #--------------------------------------------------------------------------
  # * New method: paired_materia
  #--------------------------------------------------------------------------
  def paired_materia
    @paired_materia
  end
  #--------------------------------------------------------------------------
  # * New method: make_paired_materia
  #--------------------------------------------------------------------------
  def make_paired_materia
    @paired_materia = []
    equip_slots.each_with_index do |x, i|
      equip   = equips[i]
      @paired_materia += materia_pairs(equip.double_slots, i) if equip
    end
    @paired_materia.compact
  end
  #--------------------------------------------------------------------------
  # * New method: materia_pairs
  #--------------------------------------------------------------------------
  def materia_pairs(slots, i)
    slots.times.collect {|x| setup_pairs(i, x) }.compact
  end
  #--------------------------------------------------------------------------
  # * New method: setup_pairs
  #--------------------------------------------------------------------------
  def setup_pairs(i, x)
    type = equip_slots[i] == 0 ? :weapon : :armor
    main = @materia_slots[i][x]
    pair = setup_pair_info(i, x, main, type) if main && main.support?
    main && pair ? pair : nil
  end
  #--------------------------------------------------------------------------
  # * New method: setup_pair_info
  #--------------------------------------------------------------------------
  def setup_pair_info(i, x, m, t)
    y = x + (x % 2 == 0 ? 1 : - 1)
    o = @materia_slots[i][y]
    o && !o.independent? ? {type: t, main: m, other: o} : nil
  end
  #--------------------------------------------------------------------------
  # * New method: materia_element_rate
  #--------------------------------------------------------------------------
  def materia_element_rate(id)
    paired_materia.inject(0.0) do |r, pair|
      m = pair[:main].effect(:elemental)
      o = pair[:other].elements?(id)
      v = (pair[:type] == :armor && o) ? -m  : 0
      r += v
    end
  end
  #--------------------------------------------------------------------------
  # * New method: materia_state_rate
  #--------------------------------------------------------------------------
  def materia_state_rate(id)
    paired_materia.inject(0.0) do |r, pair|
      m = pair[:main].effect(:added_effect)
      o = pair[:other].states?(id)
      v = (pair[:type] == :armor && o) ? -m : 0
      r += v
    end
  end
  #--------------------------------------------------------------------------
  # * New method: materia_atk_elements
  #--------------------------------------------------------------------------
  def materia_atk_elements(result)
    paired_materia.inject(result) do |r, pair|
      m = pair[:main].effect(:elemental)
      o = (pair[:type] == :weapon && m && m > 0) ? pair[:other].elements : []
      i = o.empty? ? [] : [1]
      r + o - i
    end
  end
  #--------------------------------------------------------------------------
  # * New method: materia_atk_states
  #--------------------------------------------------------------------------
  def materia_atk_states(result)
    paired_materia.inject(result) do |r, pair|
      m = pair[:main].effect?(:added_effect)
      o = (pair[:type] == :weapon && m) ? pair[:other].states : []
      r + o
    end
  end
  #--------------------------------------------------------------------------
  # * New method: materia_atk_states_rate
  #--------------------------------------------------------------------------
  def materia_atk_states_rate(id)
    paired_materia.inject(0.0) do |r, pair|
      m = pair[:main].effect(:added_effect)
      o = pair[:other].states?(id)
      v = (pair[:type] == :weapon && o) ? m : 0
      r + v
    end
  end
  #--------------------------------------------------------------------------
  # * New method: for_all?
  #--------------------------------------------------------------------------
  def for_all?(item)
    return false unless item.all?
    paired_materia.each do |pair|
      return true if pair[:main].all? && pair[:other].skill?(item.id)
    end
    return false
  end
end

#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  This class handles enemies. It used within the Game_Troop class 
# ($game_troop).
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # * New method: ap
  #--------------------------------------------------------------------------
  def ap
    note =~ /<AP: (\d+)>/i ? $1.to_i : (exp / 10).to_i
  end
end

#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  This class handles parties. Information such as gold and items is included.
# Instances of this class are referenced by $game_party.
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # * 
  #--------------------------------------------------------------------------
  attr_reader   :materias
  #--------------------------------------------------------------------------
  # * Alias method: init_all_items
  #--------------------------------------------------------------------------
  alias :init_all_items_ve_materia_system :init_all_items
  def init_all_items
    init_all_items_ve_materia_system
    @materias = []
  end
  #--------------------------------------------------------------------------
  # * Alias method: gain_item
  #--------------------------------------------------------------------------
  alias :gain_item_ve_materia_system :gain_item
  def gain_item(item, amount, include_equip = false)
    if item && item.materia?
      gain_materia(item, amount)
    else
      gain_item_ve_materia_system(item, amount, include_equip)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: gain_materia
  #--------------------------------------------------------------------------
  def gain_materia(item, amount = 1)
    if amount > 0
      materia = item.clone.setup_materia
      amount.times { @materias.push(materia) if !max_materia? }
    elsif amount < 0
      remove_materia(item, amount.abs)
    end
    @materias.sort! {|a, b| a.id <=> b.id }
    $game_map.need_refresh = true
  end
  #--------------------------------------------------------------------------
  # * New method: remove_materia
  #--------------------------------------------------------------------------
  def remove_materia(item, amount = 1, actor = false)
    amount.times do
      removed = false
      @materias.each_with_index do |m, i|
        if m.id == item.id && !removed
          removed = true
          break @materias.delete_at(i) 
        end
      end
      members.each do |actor|
        actor.equip_slots.size.times do |i| 
          if actor.materia_slots[i]
            actor.materia_slots[i].each_with_index do |m, x|
              next if !m || m.id != item.id || removed
              actor.materia_slots[i][x] = nil
              removed = true
            end
          end
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * New method: lose_materia
  #--------------------------------------------------------------------------
  def lose_materia(index)
    @materias.delete_at(index)
    @materias.sort! {|a, b| a.id <=> b.id }
  end
  #--------------------------------------------------------------------------
  # * New method: max_materia?
  #--------------------------------------------------------------------------
  def max_materia?
    Max_Materia_Number && @materias.size >= Max_Materia_Number
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
  # * New method: ap_total
  #--------------------------------------------------------------------------
  def ap_total
    dead_members.inject(0) {|r, enemy| r += enemy.ap }
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
  # * Alias method: command_319
  #--------------------------------------------------------------------------
  alias :command_319_ve_materia_system :command_319
  def command_319
    command_319_ve_materia_system
    $game_actors[@params[0]].setup_equipments if $game_actors[@params[0]]
  end
  #--------------------------------------------------------------------------
  # * Alias method: command_302
  #--------------------------------------------------------------------------
  alias :command_302_ve_materia_system :command_302
  def command_302
    if $game_temp.materia_shop
      call_materia_shop
    else
      command_302_ve_materia_system
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: comment_call
  #--------------------------------------------------------------------------
  alias :comment_call_ve_materia_system :comment_call
  def comment_call
    $game_temp.materia_shop = true if note =~ /<MATERIA SHOP>/i
    call_materia_equip
    call_materia_unequip
    call_drop_materia
    comment_call_ve_materia_system
  end
  #--------------------------------------------------------------------------
  # * New method: call_materia_shop
  #--------------------------------------------------------------------------
  def call_materia_shop
    return if $game_party.in_battle
    $game_temp.materia_shop = false
    goods = [@params]
    while next_event_code == 605
      @index += 1
      goods.push(@list[@index].parameters)
    end
    SceneManager.call(Scene_MateriaShop)
    SceneManager.scene.prepare(goods)
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # * New method: materia_shop
  #--------------------------------------------------------------------------
  def materia_shop(list)
    $game_temp.materia_shop = list.dup
    SceneManager.call(Scene_MateriaShop)
  end
  #--------------------------------------------------------------------------
  # * New method: call_materia_equip
  #--------------------------------------------------------------------------
  def call_materia_equip
    if note =~ /<EQUIP MATERIA: (\d+), *(\d+), *(\d+), *(\d+)>/i
      $game_actors[$1.to_i].force_materia($2.to_i - 1, $3.to_i - 1, $4.to_i)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: call_materia_unequip
  #--------------------------------------------------------------------------
  def call_materia_unequip
    if note =~ /<UNEQUIP MATERIA: (\d+), *(\d+), *(\d+)>/i
      $game_actors[$1.to_i].unequip_materia($2.to_i - 1, $3.to_i - 1)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: call_drop_materia
  #--------------------------------------------------------------------------
  def call_drop_materia
    if note =~ /<DROP MATERIA: (\d+), *(\d+)>/i
      materia = $data_armors[$1.to_i].setup_materia
      $game_party.remove_materia(materia, $2.to_i, true)
    end
  end
end
#==============================================================================
# ** Window_Selectable
#------------------------------------------------------------------------------
#  This window contains cursor movement and scroll functions.
#==============================================================================

class Window_Selectable < Window_Base
  #--------------------------------------------------------------------------
  # * New method: target_all?
  #--------------------------------------------------------------------------
  alias :target_all_ve_materia_system? :target_all? if $imported[:ve_target_arrow]
  def target_all?
    target_all_ve_materia_system? || (@action && BattleManager.actor &&
    BattleManager.actor.for_all?(@action))
  end
end

#==============================================================================
# ** Window_MenuCommand
#------------------------------------------------------------------------------
#  This command window appears on the menu screen.
#==============================================================================

class Window_MenuCommand < Window_Command
  #--------------------------------------------------------------------------
  # * Alias method: add_main_commands 
  #--------------------------------------------------------------------------
  alias :add_main_commands_ve_materia_system :add_main_commands
  def add_main_commands
    add_main_commands_ve_materia_system
    add_command(Vocab::VE_MateriaMenu, :materia, main_commands_enabled)
  end
end

#==============================================================================
# ** Window_MenuActor
#------------------------------------------------------------------------------
#  This window is for selecting actors that will be the target of item or
# skill use.
#==============================================================================

class Window_MenuActor < Window_MenuStatus
  #--------------------------------------------------------------------------
  # * Overwrite method: select_for_item
  #--------------------------------------------------------------------------
  def select_for_item(item, for_all = false)
    @cursor_fix = item.for_user?
    @cursor_all = for_all
    if @cursor_fix
      select($game_party.menu_actor.index)
    elsif @cursor_all
      select(0)
    else
      select_last
    end
  end
end

#==============================================================================
# ** Window_SkillList
#------------------------------------------------------------------------------
#  This window is for displaying a list of available skills on the skill window.
#==============================================================================

class Window_SkillList < Window_Selectable
  #--------------------------------------------------------------------------
  # * Alias method: draw_skill_cost
  #--------------------------------------------------------------------------
  alias :draw_skill_cost_ve_materia_system :draw_skill_cost
  def draw_skill_cost(rect, skill)
    draw_skill_cost_ve_materia_system(rect, skill)
    change_color(text_color(18), enable?(skill))
    rect.x += (32 + text_size(skill.name).width)
    draw_text(rect, ">") if @actor.for_all?(skill)
  end
end

#==============================================================================
# ** Window_BattleLog
#------------------------------------------------------------------------------
#  This window shows the battle progress. Do not show the window frame.
#==============================================================================

class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # * Alias method: display_failure
  #--------------------------------------------------------------------------
  alias :display_failure_ve_materia_system :display_failure
  def display_failure(target, item)
    display_failure_ve_materia_system(target, item)
    if target.actor? && target.learned_enemy_skill
      skill = $data_skills[target.learned_enemy_skill].name
      target.learned_enemy_skill = nil
      add_text(sprintf(Vocab::VE_EnemySkill, target.name, skill))
      wait
    end
  end
end

#==============================================================================
# ** Window_MateriaInfo
#------------------------------------------------------------------------------
#  This window shows the materia information.
#==============================================================================

class Window_MateriaInfo < Window_Base
  #--------------------------------------------------------------------------
  # * initialize
  #--------------------------------------------------------------------------
  def initialize(width, height, shop = false)
    super(0, 176, width, height)
    @shop = shop
  end
  #--------------------------------------------------------------------------
  # * materia
  #--------------------------------------------------------------------------
  def materia=(materia)
    @materia = materia
    refresh
  end
  #--------------------------------------------------------------------------
  # * refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    return if @materia.nil?
    contents.font.size = Font.default_size
    draw_item_name(@materia, 0, 0, true, width)
    contents.font.size = 19
    if @materia.enemy_skill?
      draw_enemy_skill_level
      draw_enemy_skill_list
    else
      draw_materia_elements
      draw_materia_level
      draw_materia_ap
      draw_materia_skills
      draw_materia_abilities
      draw_materia_stats
    end
  end
  #--------------------------------------------------------------------------
  # * draw_item_name
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y, enabled = true, width = 172)
    return unless item
    draw_icon(item.icon_index, x, y - 2, enabled)
    change_color(normal_color, enabled)
    draw_text(x + 24, y, width, line_height, item.name)
  end
  #--------------------------------------------------------------------------
  # * draw_icon
  #--------------------------------------------------------------------------
  def draw_icon(icon_index, x, y, enabled = true)
    bitmap = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    contents.blt(x, y, bitmap, rect, enabled ? 255 : 120)
  end
  #--------------------------------------------------------------------------
  # * draw_materia_elements
  #--------------------------------------------------------------------------
  def draw_materia_elements
    change_color(crisis_color)
    @materia.elements.each_with_index do |id, i|
      element = $data_system.elements[id]
      x = i % 2 * 96 + 24
      y = i / 2 * 18 + 24
      draw_text(x, y, width, line_height, element)
    end
    @materia.states.each_with_index do |id, i|
      states = $data_states[id].name
      x = (i + @materia.elements.size) % 2 * 96 + 16
      y = (i + @materia.elements.size) / 2 * 18 + 24
      draw_text(x, y, width, line_height, states)
    end
  end
  #--------------------------------------------------------------------------
  # * draw_materia_level
  #--------------------------------------------------------------------------
  def draw_materia_level
    icon = @materia.level_icon
    x    = width - [@materia.max_level * 32, 160].max
    @materia.max_level.times {|i| draw_icon(icon, x + i * 26, 0, false) }
    @materia.level.times     {|i| draw_icon(icon, x + i * 26, 0) }
  end
  #--------------------------------------------------------------------------
  # * draw_materia_ap
  #--------------------------------------------------------------------------
  def draw_materia_ap
    change_color(system_color)
    x1 = width - 312 + [352 - width, 24].min
    x2 = width - 204
    contents.draw_text(x1, 24, 172, 24, Vocab::VE_ApName, 2)
    contents.draw_text(x1, 44, 172, 24, 'To next level', 2)
    change_color(normal_color)
    ap = @materia.master? ? Vocab::VE_MasterText : @materia.ap.to_s
    contents.draw_text(x2, 24, 172, 24, ap, 2)
    nl = @materia.master? ? '-------' : @materia.next_level - @materia.ap
    contents.draw_text(x2, 44, 172, 24, nl.to_s, 2)
  end
  #--------------------------------------------------------------------------
  # * draw_materia_skills
  #--------------------------------------------------------------------------
  def draw_materia_skills
    draw_materia_price if @shop
    change_color(system_color)
    y = @shop ? 120 : 88
    contents.draw_text(4, y - 20, 172, 24, "Ability list")
    change_color(normal_color)
    @materia.skills.keys.sort.each_with_index do |key, i|
      name = $data_skills[@materia.skills[key]].name
      change_color(normal_color, key <= @materia.level)
      contents.draw_text(12, y + i * 18, 172, 24, name)
    end
  end
  #--------------------------------------------------------------------------
  # * draw_materia_price
  #--------------------------------------------------------------------------
  def draw_materia_price
    contents.font.size = 18
    buy    = @materia.price
    sell   = @materia.sell_price
    master = @materia.master
    contents.draw_text(4, 76, 172, 24, "Buy:#{buy}")
    contents.draw_text(width / 2 - 64, 76, 172, 24, "Sell:#{sell}")
    contents.draw_text(width - 128, 76, 172, 24, "Master:#{master}")
    contents.font.size = 19
  end
  #--------------------------------------------------------------------------
  # * draw_materia_abilities
  #--------------------------------------------------------------------------
  def draw_materia_abilities
    y = @materia.skills.keys.size
    z = @shop ? 120 : 88
    change_color(normal_color, true)
    list = @materia.effects.keys.collect {|effect| effect }
    list.each_with_index do |effect, i|
      if @materia.effect_name
        contents.draw_text(12, z + (i + y) * 18, 172, 24, @materia.effect_name)
        break
      elsif @materia.effects[effect].numeric?
        name  = make_string(effect).capitalize
        value = @materia.effects[effect] * 100
        draw_effect_value(effect, i + y, name, value)
      else
        name = make_string(effect).capitalize
        contents.draw_text(12, z + (i + y) * 18, 172, 24, name)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * draw_materia_stats
  #--------------------------------------------------------------------------
  def draw_materia_stats
    list1 = get_params_values
    list2 = get_stats_values
    change_color(system_color)
    y = @shop ? 100 : 68
    contents.draw_text(width - 172, y, 172, 24, "Equip effect")
    change_color(normal_color)
    list1.each_with_index {|param, i| draw_param_value(param, i, false) }
    list2.each_with_index {|param, i| draw_param_value(param, i + list1.size) }
  end
  #--------------------------------------------------------------------------
  # * get_params_values
  #--------------------------------------------------------------------------
  def get_params_values
    list = []
    @materia.params.size.times do |i|
      next if @materia.params[i] == 0
      list.push({name: Vocab::param(i), value: @materia.params[i]})
    end
    list
  end
  #--------------------------------------------------------------------------
  # * get_stats_values
  #--------------------------------------------------------------------------
  def get_stats_values
    list = []
    @materia.stats.keys.each do |i|
      next if @materia.stats[i] == 0
      list.push({name: Vocab::param(i), value: @materia.stats[i]})
    end
    list
  end
  #--------------------------------------------------------------------------
  # * draw_effect_value
  #--------------------------------------------------------------------------
  def draw_effect_value(effect, i, s1, s2)
    name  = effect_name(s1)
    plus  = s2 >= 0 ? "+" : "-"
    value = sprintf("%03d", s2.abs * @materia.level)
    draw_param_info(name, plus, value, "%", i, 12, 108)
  end
  #--------------------------------------------------------------------------
  # * draw_param_value
  #--------------------------------------------------------------------------
  def draw_param_value(param, i, rate = true)
    name  = param[:name]
    plus  = param[:value] < 0 ? "-" : "+"
    value = sprintf("%02d", param[:value].abs)
    rate  = rate ? "%" : ""
    draw_param_info(name, plus, value, rate, i, width - 176, 108)
  end
  #--------------------------------------------------------------------------
  # * draw_param_info
  #--------------------------------------------------------------------------
  def draw_param_info(name, plus, value, rate, i, x, y)
    z = @shop ? 120 : 88
    contents.draw_text(x, z + i * 18, 172, 24, name)
    contents.draw_text(x + y, z + i * 18, 172, 24, plus)
    change_color(plus == "-" ? knockout_color : crisis_color)
    wid = text_size(plus).width
    contents.draw_text(x + y + wid, z + i * 18, 172, 24, value)
    change_color(normal_color)
    wid += text_size(value).width
    contents.draw_text(x + y + wid, z + i * 18, 172, 24, rate)
  end
  #--------------------------------------------------------------------------
  # * draw_enemy_skill_level
  #--------------------------------------------------------------------------
  def draw_enemy_skill_level
    icon = @materia.level_icon
    @materia.max_level.times do |i| 
      draw_icon(icon, level_x(i), level_y(i), @materia.learn[i])
    end
  end
  #--------------------------------------------------------------------------
  # * level_x
  #--------------------------------------------------------------------------
  def level_x(i)
    x = @materia.max_level / 2
    i % x * 26 + [(width / 2) - (x * 26) / 2, 0].max
  end
  #--------------------------------------------------------------------------
  # * level_y
  #--------------------------------------------------------------------------
  def level_y(i)
    i / (@materia.max_level / 2) * 26 + 28
  end
  #--------------------------------------------------------------------------
  # * draw_enemy_skill_list
  #--------------------------------------------------------------------------
  def draw_enemy_skill_list
    draw_materia_price if @shop
    color = Color.new(0, 0, 0, 50)
    y = @shop ? 20 : 0
    contents.fill_rect(8, 82 + y, width - 36, height - 112 - y, color)
    z = @shop ? 116 : 84
    @materia.max_level.times do |i| 
      if @materia.learn[i + 1]
        name = $data_skills[@materia.learn[i + 1]].name
        x = i % 3 * (width / 3 - 16) + 16
        y = i / 3 * 18 + z
        contents.draw_text(x, y, width / 3 - 12, 24, name)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * effect_name
  #--------------------------------------------------------------------------
  def effect_name(name)
    case name.upcase
    when "HIT" then "Hit"
    when "EVA" then "Evasion"
    when "CRI" then "Critical"
    when "CEV" then "C. Evasion"
    when "MEV" then "M. Evasion"
    when "MRF" then "Reflection"
    when "CNT" then "Counter"
    when "HRG" then "HP Regen"
    when "MRG" then "MP Regen"
    when "TRG" then "TP Regen"
    when "TGR" then "Target"
    when "GRD" then "Guard"
    when "REC" then "Recover"
    when "PHA" then "Pharmacology"
    when "MCR" then "MP Rate"
    when "TCR" then "TP Charge"
    when "PDR" then "P. Reduction"
    when "MDR" then "M. Reduction"
    when "FDR" then "Floor Damage"
    when "EXR" then "EXP Rate"
    else 
      id = get_param_id(name.upcase)
      id ? Vocab::param(id) : name
    end
  end
end

#==============================================================================
# ** Window_MateriaList
#------------------------------------------------------------------------------
#  This window shows the materia list.
#==============================================================================

class Window_MateriaList < Window_Selectable
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :materia_window
  #--------------------------------------------------------------------------
  # * item_max
  #--------------------------------------------------------------------------
  def item_max
    @data ? @data.size : 1
  end
  #--------------------------------------------------------------------------
  # * materia
  #--------------------------------------------------------------------------
  def materia
    @data[index]
  end
  #--------------------------------------------------------------------------
  # * draw_item
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y)
    end
  end
  #--------------------------------------------------------------------------
  # * draw_item_name
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y, enabled = true, width = 172)
    return unless item
    draw_icon(item.icon_index, x, y, enabled, item)
    change_color(normal_color, enabled)
    draw_text(x + 24, y, width, line_height, item.name)
  end
  #--------------------------------------------------------------------------
  # * draw_icon
  #--------------------------------------------------------------------------
  def draw_icon(icon_index, x, y, enabled = true, item)
    bitmap = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    contents.blt(x, y, bitmap, rect, enabled ? 255 : translucent_alpha)
  end
  #--------------------------------------------------------------------------
  # * refresh
  #--------------------------------------------------------------------------
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
  #--------------------------------------------------------------------------
  # * materia_window
  #--------------------------------------------------------------------------
  def materia_window=(materia_window)
    @materia_window = materia_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # * update_help
  #--------------------------------------------------------------------------
  def update_help
    super
    @materia_window.materia = materia if @materia_window
    @help_window.set_item(materia)
  end  
end

#==============================================================================
# ** Window_MateriaStatus
#------------------------------------------------------------------------------
#  This window shows the materias on the materia equip screen.
#==============================================================================

class Window_MateriaStatus < Window_MateriaList
  #--------------------------------------------------------------------------
  # * initialize
  #--------------------------------------------------------------------------
  def initialize
    super(window_x, 176, 192, window_height)
    @data = []
  end
  #--------------------------------------------------------------------------
  # * window_x
  #--------------------------------------------------------------------------
  def window_x
    352 + [Graphics.width - 544, 0].max
  end
  #--------------------------------------------------------------------------
  # * window_height
  #--------------------------------------------------------------------------
  def window_height
    240 + [Graphics.height - 416, 0].max
  end
  #--------------------------------------------------------------------------
  # * make_item_list
  #--------------------------------------------------------------------------
  def make_item_list
    @data = $game_party.materias.collect {|materia| materia }
    @data.push(nil)
  end
end

#==============================================================================
# ** Window_MateriaShop
#------------------------------------------------------------------------------
#  This window shows the materias on the materia shop screen.
#==============================================================================

class Window_MateriaShop < Window_MateriaList
  #--------------------------------------------------------------------------
  # * initialize
  #--------------------------------------------------------------------------
  def initialize(y, width, height, materia_list = nil)
    super(0, y, width, height)
    @materia_list = materia_list
    @data = []
    select(0)
  end
  #--------------------------------------------------------------------------
  # * make_item_list
  #--------------------------------------------------------------------------
  def make_item_list
    @data  = []
    @price = {}
    lsit   = @materia_list ? @materia_list : make_sell_list
    lsit.each do |goods|
      item = @materia_list ? $data_armors[goods[1]] : goods[1]
      item.setup_materia
      if item
        @data.push(item)
        @price[item] = goods[2] == 0 ? setup_price(item) : goods[3]
      end
    end
  end
  #--------------------------------------------------------------------------
  # * setup_price
  #--------------------------------------------------------------------------
  def setup_price(item)
    @materia_list ? item.price : item.sell_price
  end
  #--------------------------------------------------------------------------
  # * make_sell_list
  #--------------------------------------------------------------------------
  def make_sell_list
    $game_party.materias.collect {|m| [0, m, 0] }
  end
  #--------------------------------------------------------------------------
  # * money
  #--------------------------------------------------------------------------
  def money=(money)
    @money = money
    refresh
  end
  #--------------------------------------------------------------------------
  # * current_item_enabled?
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(@data[index])
  end
  #--------------------------------------------------------------------------
  # * price
  #--------------------------------------------------------------------------
  def price(item)
    @price[item]
  end
  #--------------------------------------------------------------------------
  # * enable?
  #--------------------------------------------------------------------------
  def enable?(item)
    item && (!@materia_list || (item && price(item) <= @money &&
    !$game_party.max_materia?))
  end
  #--------------------------------------------------------------------------
  # * draw_item_name
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y)
    return unless item
    draw_icon(item.icon_index, x, y, enable?(item), item)
    change_color(normal_color, enable?(item))
    draw_text(x + 24, y, width, line_height, item.name)
    draw_text(4, y, self.width - 32, line_height, ":#{price(item)}", 2)
  end
end

#==============================================================================
# ** Window_MateriaActor
#------------------------------------------------------------------------------
#  This window shows the actor status on the materia equip screen.
#==============================================================================

class Window_MateriaActor < Window_Selectable
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :actor
  #--------------------------------------------------------------------------
  # * initialize
  #--------------------------------------------------------------------------
  def initialize
    @equip = 0
    super(0, 0, Graphics.width, 128)
    @index = 0
  end
  #--------------------------------------------------------------------------
  # * actor
  #--------------------------------------------------------------------------
  def actor=(actor)
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # * refresh
  #--------------------------------------------------------------------------
  def refresh
    super
    draw_face(actor.face_name, actor.face_index, 4, 4)
    draw_actor_name(actor, 104, line_height * 0)
    draw_actor_level(actor, 104, line_height * 1)
    draw_actor_hp(actor, 104, line_height * 2)
    draw_actor_mp(actor, 104, line_height * 3)
  end
end

#==============================================================================
# ** Window_MateriaEquip
#------------------------------------------------------------------------------
#  This window shows the actor equipe materia. Do not show the window frame.
#==============================================================================

class Window_MateriaEquip < Window_Selectable
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :equip  
  attr_reader   :actor
  attr_reader   :materia_window
  #--------------------------------------------------------------------------
  # * initialize
  #--------------------------------------------------------------------------
  def initialize
    @equip = 0
    super(window_x, 0, Graphics.width -  window_x, 128)
    @index = 0
  end
  #--------------------------------------------------------------------------
  # * item_max
  #--------------------------------------------------------------------------
  def item_max
    return 1
  end
  #--------------------------------------------------------------------------
  # * contents_width
  #--------------------------------------------------------------------------
  def contents_width
    width - standard_padding * 2
  end
  #--------------------------------------------------------------------------
  # * contents_height
  #--------------------------------------------------------------------------
  def contents_height
    actor ? actor.equip_slots.size * 48 + 48 - standard_padding * 2 : 1
  end
  #--------------------------------------------------------------------------
  # * update_padding_bottom
  #--------------------------------------------------------------------------
  def update_padding_bottom
  end
  #--------------------------------------------------------------------------
  # * actor
  #--------------------------------------------------------------------------
  def actor=(actor)
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # * materia
  #--------------------------------------------------------------------------
  def materia
    slots = actor.materia_slots[equip]
    slots ? slots[index] : slots
  end
  #--------------------------------------------------------------------------
  # * slot_width
  #--------------------------------------------------------------------------
  def slot_width
    Max_Slot_Number * 32
  end
  #--------------------------------------------------------------------------
  # * window_x
  #--------------------------------------------------------------------------
  def window_x
    return 244
  end
  #--------------------------------------------------------------------------
  # * base_x
  #--------------------------------------------------------------------------
  def base_x
    [Graphics.width - 544, 4].max + window_x
  end
  #--------------------------------------------------------------------------
  # * refresh
  #--------------------------------------------------------------------------
  def refresh
    super
    create_contents
    self.opacity = 0
    draw_equipments(8 + base_x - slot_width)
    draw_materias(28 + base_x - slot_width)
  end
  #------------------------------------------------------------------------------
  # * draw_equipments 
  #------------------------------------------------------------------------------
  def draw_equipments(x)
    actor.equips.each_with_index do |item, i|
      draw_item_name(item, x, y + 50 * i + 1)
    end
  end
  #------------------------------------------------------------------------------
  # * draw_materias
  #------------------------------------------------------------------------------
  def draw_materias(x)
    draw_background(x)
    draw_slots(x)
    draw_materia_icons(x)
  end
  #------------------------------------------------------------------------------
  # * draw_background
  #------------------------------------------------------------------------------
  def draw_background(x)
    color = Color.new(0, 0, 0, 50)
    actor.equip_slots.size.times do |i|
      contents.fill_rect(x - 4, i * 50 + 26, slot_width, 22, color)
    end
  end
  #------------------------------------------------------------------------------
  # * draw_slots
  #------------------------------------------------------------------------------
  def draw_slots(x)
    actor.equip_slots.size.times do |i|
      next unless actor.equips[i]
      equip = @actor.equips[i]
      links = equip.double_slots / 2
      slots = equip.double_slots + equip.single_slots
      icon1 = equip.nothing? ? Slot_Icon_Nothing : Slot_Icon_Normal
      icon2 = Slot_Link_Icon
      slots.times {|y| draw_icon(icon1, x + y * 32, i * 50 + 24) }
      links.times {|y| draw_icon(icon2, x + 16 + y * 64, i * 50 + 24) }
    end
  end
  #------------------------------------------------------------------------------
  # * draw_materia_icons
  #------------------------------------------------------------------------------
  def draw_materia_icons(x)
    actor.equip_slots.size.times do |i|
      next unless actor.materia_slots[i]
      actor.materia_slots[i].each_with_index do |m, y|
        draw_materia(m.icon_index, x + y * 32, i * 50 + 24, m, 200) if m
      end
    end
  end
  #--------------------------------------------------------------------------
  # * draw_materia
  #--------------------------------------------------------------------------
  def draw_materia(icon_index, x, y, item, opacity = 255)
    bitmap = Cache.system("Iconset")
    rect   = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    contents.blt(x, y, bitmap, rect, opacity)
  end
  #--------------------------------------------------------------------------
  # * equip
  #--------------------------------------------------------------------------
  def equip=(equip)
    @equip = equip
    update_cursor
    call_update_help
  end
  #--------------------------------------------------------------------------
  # * update_cursor
  #--------------------------------------------------------------------------
  def update_cursor
    ensure_cursor_visible
    cursor_rect.set(item_rect(@index, @equip))
  end
  #--------------------------------------------------------------------------
  # * item_rect
  #--------------------------------------------------------------------------
  def item_rect(index, equip)
    rect = Rect.new
    rect.width  = 26
    rect.height = 26
    rect.x  = index * 32 + 27 + base_x - slot_width
    rect.y  = equip * 50 + 24
    self.oy = (equip - equip % 2) * 50
    rect
  end
  #--------------------------------------------------------------------------
  # * process_cursor_move
  #--------------------------------------------------------------------------
  def process_cursor_move
    return unless cursor_movable?
    last_equip = @equip
    super
    Sound.play_cursor if @equip != last_equip
  end
  #--------------------------------------------------------------------------
  # * cursor_down
  #--------------------------------------------------------------------------
  def cursor_down(wrap = false)
    self.equip += 1
    self.equip %= actor.equip_slots.size
  end
  #--------------------------------------------------------------------------
  # * cursor_up
  #--------------------------------------------------------------------------
  def cursor_up(wrap = false)
    self.equip -= 1
    self.equip %= actor.equip_slots.size
  end
  #--------------------------------------------------------------------------
  # * cursor_right
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
    self.index += 1
    self.index %= Max_Slot_Number
  end
  #--------------------------------------------------------------------------
  # * cursor_left
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)
    self.index -= 1
    self.index %= Max_Slot_Number
  end
  #--------------------------------------------------------------------------
  # * current_item_enabled?
  #--------------------------------------------------------------------------
  def current_item_enabled?
    index < actor.materia_slots[equip].size
  end
  #--------------------------------------------------------------------------
  # * process_handling
  #--------------------------------------------------------------------------
  def process_handling
    return unless open? && active
    return process_clear  if handler_clear?  && Input.trigger?(:A)
    super 
  end
  #--------------------------------------------------------------------------
  # * handler_clear?
  #--------------------------------------------------------------------------
  def handler_clear?
    handle?(:clear) && materia
  end
  #--------------------------------------------------------------------------
  # * process_clear
  #--------------------------------------------------------------------------
  def process_clear
    call_handler(:clear) 
  end
  #--------------------------------------------------------------------------
  # * materia_window=
  #--------------------------------------------------------------------------
  def materia_window=(materia_window)
    @materia_window = materia_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # * update_help
  #--------------------------------------------------------------------------
  def update_help
    super
    @materia_window.materia = materia if @materia_window
    @help_window.set_item(materia)
  end
end

#==============================================================================
# ** Scene_Menu
#------------------------------------------------------------------------------
#  This class performs the menu screen processing.
#==============================================================================

class Scene_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Alias method: create_command_window
  #--------------------------------------------------------------------------
  alias :materia_system_create_command_window :create_command_window
  def create_command_window
    materia_system_create_command_window
    @command_window.set_handler(:materia,   method(:command_personal))
  end
  #--------------------------------------------------------------------------
  # * Alias method: on_personal_ok
  #--------------------------------------------------------------------------
  alias :materia_system_on_personal_ok :on_personal_ok
  def on_personal_ok
    materia_system_on_personal_ok
    if @command_window.current_symbol == :materia
      SceneManager.call(Scene_MateriaEquip)
    end
  end
end

#==============================================================================
# ** Scene_Equip
#------------------------------------------------------------------------------
#  This class performs the equipment screen processing.
#==============================================================================

class Scene_Equip < Scene_MenuBase
  #------------------------------------------------------------------------------
  # * Alias method: on_actor_change
  #------------------------------------------------------------------------------
  alias :materia_system_on_actor_change :on_actor_change
  def on_actor_change
    @actor.setup_equipments
    materia_system_on_actor_change
  end
  #------------------------------------------------------------------------------
  # * New method: terminate
  #------------------------------------------------------------------------------
  def terminate
    super
    @actor.setup_equipments
  end
end

#==============================================================================
# ** Scene_MateriaEquip
#------------------------------------------------------------------------------
#  This class performs the materia equip screen processing.
#==============================================================================

class Scene_MateriaEquip < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * start
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_materia_window
    create_status_window
    create_equip_window
    create_item_window
  end
  #--------------------------------------------------------------------------
  # * create_help_window
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_Help.new(1)
    @help_window.viewport = @viewport
    @help_window.y = 128
  end
  #--------------------------------------------------------------------------
  # * create_materia_window
  #--------------------------------------------------------------------------
  def create_materia_window
    ww = 352 + [Graphics.width - 544, 0].max
    wh = 240 + [Graphics.height - 416, 0].max
    @materia_window = Window_MateriaInfo.new(ww, wh)
    @materia_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # * create_status_window
  #--------------------------------------------------------------------------
  def create_status_window
    @status_window = Window_MateriaActor.new
    @status_window.actor = @actor
    @status_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # * create_equip_window
  #--------------------------------------------------------------------------
  def create_equip_window
    @equip_window = Window_MateriaEquip.new
    @equip_window.actor = @actor
    @equip_window.viewport = @viewport
    @equip_window.help_window = @help_window
    @equip_window.materia_window = @materia_window
    @equip_window.set_handler(:ok,       method(:command_equip))
    @equip_window.set_handler(:clear,    method(:command_clear))
    @equip_window.set_handler(:cancel,   method(:return_scene))
    @equip_window.set_handler(:pagedown, method(:next_actor))
    @equip_window.set_handler(:pageup,   method(:prev_actor))
    @equip_window.activate
  end
  #--------------------------------------------------------------------------
  # * create_item_window
  #--------------------------------------------------------------------------
  def create_item_window
    @item_window = Window_MateriaStatus.new
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.materia_window = @materia_window
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @item_window.refresh
  end
  #--------------------------------------------------------------------------
  # * command_equip
  #--------------------------------------------------------------------------
  def command_equip
    @item_window.activate
    @item_window.select(0)
  end
  #--------------------------------------------------------------------------
  # * command_clear
  #--------------------------------------------------------------------------
  def command_clear
    Sound.play_equip
    @actor.unequip_materia(@equip_window.equip, @equip_window.index)
    @item_window.refresh
    @equip_window.refresh
    @status_window.refresh
    @materia_window.refresh
  end
  #--------------------------------------------------------------------------
  # * on_actor_change
  #--------------------------------------------------------------------------
  def on_actor_change
    @equip_window.actor  = @actor
    @status_window.actor = @actor
    @item_window.refresh
    @materia_window.refresh
    @equip_window.activate
  end
  #--------------------------------------------------------------------------
  # * on_item_ok
  #--------------------------------------------------------------------------
  def on_item_ok
    Sound.play_equip
    if @item_window.materia
      @actor.equip_materia(@equip_window.equip, @equip_window.index,
        @item_window.index)
    else
      @actor.unequip_materia(@equip_window.equip, @equip_window.index)
    end
    @item_window.refresh
    @equip_window.refresh
    @status_window.refresh
    @materia_window.refresh
    @equip_window.activate
    @item_window.unselect
  end
  #--------------------------------------------------------------------------
  # * on_item_cancel
  #--------------------------------------------------------------------------
  def on_item_cancel
    @equip_window.activate
    @item_window.unselect
  end
end

#==============================================================================
# ** Scene_ItemBase
#------------------------------------------------------------------------------
#  This class performs common processing for the item screen and skill screen.
#==============================================================================

class Scene_ItemBase < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Overwrite method: determine_item
  #--------------------------------------------------------------------------
  def determine_item
    if item.for_friend?
      show_sub_window(@actor_window)
      for_all = item.for_all? || (@actor && @actor.for_all?(item))
      @actor_window.select_for_item(item, for_all)
    else
      use_item
      activate_item_window
    end
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: item_target_actors
  #--------------------------------------------------------------------------
  def item_target_actors
    if !item.for_friend?
      []
    elsif item.for_all? || (@actor && @actor.for_all?(item))
      $game_party.members
    else
      [$game_party.members[@actor_window.index]]
    end
  end
end

#==============================================================================
# ** Scene_MateriaShop
#------------------------------------------------------------------------------
#  This class performs materia shop screen processing.
#==============================================================================

class Scene_MateriaShop < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * prepare
  #--------------------------------------------------------------------------
  def prepare(goods)
    @goods = goods
    @goods.delete_if {|m| m[0] != 2 || !$data_armors[m[1]].materia? }
  end
  #--------------------------------------------------------------------------
  # * start
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_gold_window
    create_command_window
    create_dummy_window
    create_status_window
    create_buy_window
    create_sell_window
  end
  #--------------------------------------------------------------------------
  # * create_help_window
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_Help.new(1)
    @help_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # * create_gold_window
  #--------------------------------------------------------------------------
  def create_gold_window
    @gold_window = Window_Gold.new
    @gold_window.viewport = @viewport
    @gold_window.x = Graphics.width - @gold_window.width
    @gold_window.y = @help_window.height
  end
  #--------------------------------------------------------------------------
  # * create_command_window
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_ShopCommand.new(@gold_window.x, false)
    @command_window.viewport = @viewport
    @command_window.y = @help_window.height
    @command_window.set_handler(:buy,    method(:command_buy))
    @command_window.set_handler(:sell,   method(:command_sell))
    @command_window.set_handler(:cancel, method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # * create_dummy_window
  #--------------------------------------------------------------------------
  def create_dummy_window
    wy = @command_window.y + @command_window.height
    wh = Graphics.height - wy
    @dummy_window = Window_Base.new(0, wy, Graphics.width, wh)
    @dummy_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # * create_status_window
  #--------------------------------------------------------------------------
  def create_status_window
    wy = @command_window.y + @command_window.height
    ww = 312 + [Graphics.width - 544, 0].max
    wh = Graphics.height - wy
    @status_window   = Window_MateriaInfo.new(ww, wh, true)
    @status_window.x = Graphics.width - @status_window.width
    @status_window.y = wy
    @status_window.viewport = @viewport
    @status_window.hide
  end
  #--------------------------------------------------------------------------
  # * create_buy_window
  #--------------------------------------------------------------------------
  def create_buy_window
    wy = @command_window.y + @command_window.height
    ww = Graphics.width  - @status_window.width
    wh = Graphics.height - wy
    @buy_window = Window_MateriaShop.new(wy, ww, wh, @goods)
    @buy_window.viewport = @viewport
    @buy_window.help_window = @help_window
    @buy_window.materia_window = @status_window
    @buy_window.hide
    @buy_window.set_handler(:ok,     method(:on_buy_ok))
    @buy_window.set_handler(:cancel, method(:on_buy_cancel))
  end
  #--------------------------------------------------------------------------
  # * create_sell_window
  #--------------------------------------------------------------------------
  def create_sell_window
    wy = @command_window.y + @command_window.height
    ww = Graphics.width  - @status_window.width
    wh = Graphics.height - wy
    @sell_window = Window_MateriaShop.new(wy, ww, wh)
    @sell_window.viewport = @viewport
    @sell_window.help_window = @help_window
    @sell_window.materia_window = @status_window
    @sell_window.hide
    @sell_window.set_handler(:ok,     method(:on_sell_ok))
    @sell_window.set_handler(:cancel, method(:on_sell_cancel))
  end
  #--------------------------------------------------------------------------
  # * activate_buy_window
  #--------------------------------------------------------------------------
  def activate_buy_window
    @buy_window.money = money
    @buy_window.show.activate
    @status_window.show
  end
  #--------------------------------------------------------------------------
  # * activate_sell_window
  #--------------------------------------------------------------------------
  def activate_sell_window
    @sell_window.money = money
    @sell_window.show.activate
    @status_window.show
  end
  #--------------------------------------------------------------------------
  # * command_buy
  #--------------------------------------------------------------------------
  def command_buy
    @dummy_window.hide
    activate_buy_window
  end
  #--------------------------------------------------------------------------
  # * command_sell
  #--------------------------------------------------------------------------
  def command_sell
    @dummy_window.hide
    activate_sell_window
  end
  #--------------------------------------------------------------------------
  # * on_buy_ok
  #--------------------------------------------------------------------------
  def on_buy_ok
    Sound.play_shop
    @item = @buy_window.materia
    $game_party.lose_gold(buying_price)
    $game_party.gain_item(@item, 1)
    activate_buy_window
    refresh_windows
  end
  #--------------------------------------------------------------------------
  # * on_buy_cancel
  #--------------------------------------------------------------------------
  def on_buy_cancel
    @command_window.activate
    @dummy_window.show
    @buy_window.hide
    @status_window.hide
    @help_window.clear
  end
  #--------------------------------------------------------------------------
  # * on_sell_ok
  #--------------------------------------------------------------------------
  def on_sell_ok
    Sound.play_shop
    @item = @sell_window.materia
    $game_party.gain_gold(selling_price)
    $game_party.lose_materia(@sell_window.index)
    activate_sell_window
    index = @sell_window.index
    @sell_window.select([[index, @sell_window.item_max - 1].min, 0].max)
    refresh_windows
  end
  #--------------------------------------------------------------------------
  # * on_sell_cancel
  #--------------------------------------------------------------------------
  def on_sell_cancel
    @command_window.activate
    @dummy_window.show
    @status_window.hide
    @sell_window.hide
    @help_window.clear
  end
  #--------------------------------------------------------------------------
  # * refresh_windows
  #--------------------------------------------------------------------------
  def refresh_windows
    @gold_window.refresh
    @status_window.refresh
  end
  #--------------------------------------------------------------------------
  # * money
  #--------------------------------------------------------------------------
  def money
    @gold_window.value
  end
  #--------------------------------------------------------------------------
  # * currency_unit
  #--------------------------------------------------------------------------
  def currency_unit
    @gold_window.currency_unit
  end
  #--------------------------------------------------------------------------
  # * buying_price
  #--------------------------------------------------------------------------
  def buying_price
    @buy_window.price(@item)
  end
  #--------------------------------------------------------------------------
  # * selling_price
  #--------------------------------------------------------------------------
  def selling_price
    @item.sell_price
  end
end

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Overwrite method: on_skill_ok
  #--------------------------------------------------------------------------
  alias :on_skill_ok_ve_materia_system :on_skill_ok
  def on_skill_ok
    @skill = @skill_window.item
    actor  = BattleManager.actor
    if actor.for_all?(@skill) &&  !$imported[:ve_target_arrow]
      actor.input.set_skill(@skill.id)
      actor.last_skill.object = @skill
      @skill_window.hide
      next_command
    else
      on_skill_ok_ve_materia_system
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: battle_start
  #--------------------------------------------------------------------------
  alias :battle_start_ve_materia_system :battle_start
  def battle_start
    battle_start_ve_materia_system
    reset_materia_all
  end
  #--------------------------------------------------------------------------
  # * Alias method: pre_terminate
  #--------------------------------------------------------------------------
  alias :pre_terminate_ve_materia_system :pre_terminate
  def pre_terminate
    pre_terminate_ve_materia_system
    reset_materia_all
  end
  #--------------------------------------------------------------------------
  # * New method: reset_materia_all
  #--------------------------------------------------------------------------
  def reset_materia_all
    $game_party.members.each do |actor|
      actor.all_materias.compact.each {|materia| materia.reset_times }
    end
  end
end