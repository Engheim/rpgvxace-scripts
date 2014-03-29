#==============================================================================
# ** Victor Engine - MP Level
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.03.15 > First relase
#  v 1.01 - 2012.03.17 > Compatibility with Tech Points
#  v 1.02 - 2012.05.20 > Fixed bug with MP recovering items
#  v 1.03 - 2012.07.17 > Added notetags to change max MP level
#                      > Added comment calls to control MP level
#  v 1.04 - 2012.08.02 > Added max MP tags for classes
#                      > Added max MP plus tags
#                      > Compatibility with Basic Module 1.27
#  v 1.05 - 2012.08.18 > Compatibility with Custom Hit Formula
#------------------------------------------------------------------------------
#  This script allows to setup a new cost mechanic for skill: MP divided in
# levels, a system similar to the first Final Fantasy, Suikoden and Grandia.
# Each skill consume MP from pre determined levels.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.27 or higher
#   If used with 'Victor Engine - Custom Hit Formula' place this bellow it.
#
# * Alias methods
#   class Game_BattlerBase
#     def refresh
#     def skill_cost_payable?(skill)
#     def pay_skill_cost(skill)
#     def recover_all
#
#   class Game_Battler < Game_BattlerBase
#     def item_apply(user, item)
#
#   class Game_Actor < Game_Battler
#     def setup(actor_id)
#
#   class Game_Enemy < Game_Battler
#     def initialize(index, enemy_id)
#
#   class Window_Base < Window
#     def draw_actor_mp(actor, x, y, width = 124)
#     def draw_actor_tp(actor, x, y, width = 124)
#
#   class Window_SkillList < Window_Selectable
#     def draw_skill_cost(rect, skill)
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
#  <infinite mp level>
#   The battler will ignore MP Level cost and will be able to use the skill
#   freely
#  
#  <max mp plus x: +y>
#  <max mp plus x: -y>
#   Change the max mp level by a set value
#     x : mp level
#     y : max mp change
#
#------------------------------------------------------------------------------
# Actors, Classes, Weapons, Armors, States and Enemies note tags:
#   Tags to be used on the Actors, Classes, Weapons, Armors, States and Enemies
#   note box in the database.
#
#  <max mp levels: x>
#   Setup the number of MP Levels available
#     x : number of levels
#
#  <mp growth x: y>
#   Set a custom max MP growth for level x.
#     x : mp level
#     y : custom growth, a string that is evaluted, you can use any valid
#         stat for battlers.
#
#  <mp limit x: y>
#   Set a custom max MP limit value for level x.
#     x : mp level
#     y : max mp limit
#
#------------------------------------------------------------------------------
# Skills note tags:
#   Tags to be used on the Skill note box in the database
#
#  <mp level cost x: y>
#   Setup the MP Level cost for the skill
#     x : mp level
#     y : cost
#
#------------------------------------------------------------------------------
# Skills and Items note tags:
#   Tags to be used on the Skills and Items note box in the database
#
#  <change mp level x: +y>
#  <change mp level x: -y>
#   Set a item or skill to change the current mp value for level x.
#     x : mp level
#     y : changed value
#
#  <change max mp level x: +y>
#  <change max mp level x: -y>
#   Set a item or skill to change the max mp value for level x.
#     x : mp level
#     y : changed value
#
#------------------------------------------------------------------------------
# Comment calls note tags:
#  Tags to be used in events comment box, works like a script call.
# 
#  <change mp level x: y, +z>
#  <change mp level x: y, -z>
#   Change the current mp value for actor x to the level y.
#     x : actor id
#     y : mp level
#     z : changed value
# 
#  <change max mp level x: y, +z>
#  <change max mp level x: y, -z>
#   Change the max mp value for actor x to the level y.
#     x : actor id
#     y : mp level
#     z : changed value
# 
#  <recover mp level: x>
#   Recover all mp levels for the actor id x
#     x : actor id
# 
#  <recover all mp level>
#   Recover all mp level for the whole party
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#  The default MP Levels display is quite simple, to edit them it would be
#  needed to edit the code itself, those with some script knowledge can do it
#  by editing the method 'def draw_actor_mp_level(actor, x, y, width)'
#  I won't provide support on this.
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Set the default number of levels
  #   This is the default number of levels available
  #--------------------------------------------------------------------------
  VE_DEFAULT_MAX_LEVEL = 4
  #--------------------------------------------------------------------------
  # * Set the display of MP levels by replacing MP or TP default display
  #   This DO NOT replace the MP or TP on mechanics, it just remove their
  #   display. MP and TP will still exist even if not displayed.
  #   leave nil if you don't want to replace them.
  #     :mp : replace default MP display with the MP Levels display
  #     :tp : replace default TP display with the MP Levels display
  #--------------------------------------------------------------------------
  VE_REPLACE_DISPLAY = :mp
  #--------------------------------------------------------------------------
  # * Name displayed for the MP level stat
  #--------------------------------------------------------------------------
  VE_MP_LEVEL_NAME = "MP"
  #--------------------------------------------------------------------------
  # * Set the mp growth and max mp for each level
  #   The growth value is a string that is evaluted, you can use any valid
  #   stat for battlers (level, mmh, mmp, atk, def, mat, mdf, agi, luk)
  #   and any valid method for Game_Battlers (as long they return numbers)
  #--------------------------------------------------------------------------
  VE_DEFAULT_MP_SETTING = {
    1 => {max: 9, growth: "1 + mmp / 100"},  # MP for level 1 Magics
    2 => {max: 9, growth: "0 + mmp / 150"},  # MP for level 2 Magics
    3 => {max: 9, growth: "-1 + mmp / 200"}, # MP for level 3 Magics
    4 => {max: 9, growth: "-2 + mmp / 250"}, # MP for level 4 Magics
  }  
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
$imported[:ve_mp_level] = 1.05
Victor_Engine.required(:ve_mp_level, :ve_basic_module, 1.27, :above)
Victor_Engine.required(:ve_mp_level, :ve_techs_points, 1.00, :bellow)

#==============================================================================
# ** RPG::UsableItem
#------------------------------------------------------------------------------
#  This is the superclass for skills and items.
#==============================================================================

class RPG::UsableItem < RPG::BaseItem
  #--------------------------------------------------------------------------
  # * New method: change_mp_level
  #--------------------------------------------------------------------------
  def change_mp_level(lvl)
    note =~ /<CHANGE MP LEVEL #{lvl}: ([+-]?\d+)>/i ? $1.to_i : 0
  end
  #--------------------------------------------------------------------------
  # * New method: change_mp_level
  #--------------------------------------------------------------------------
  def change_max_mp_level(lvl)
    note =~ /<CHANGE MAX MP LEVEL #{lvl}: ([+-]?\d+)>/i ? $1.to_i : 0
  end
end

#==============================================================================
# ** RPG::Skill
#------------------------------------------------------------------------------
#  This is the data class for skills.
#==============================================================================

class RPG::Skill < RPG::UsableItem
  #--------------------------------------------------------------------------
  # * New method: mp_level_cost
  #--------------------------------------------------------------------------
  def mp_level_cost(lvl)
    note =~ /<MP LEVEL COST #{lvl}: (\d+)>/i ? $1.to_i : 0
  end
  #--------------------------------------------------------------------------
  # * New method: is_mp_level?
  #--------------------------------------------------------------------------
  def is_mp_level?
    note =~ /<MP LEVEL COST (\d+): (\d+)>/i
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
  # * Alias method: refresh
  #--------------------------------------------------------------------------
  alias :refresh_ve_mp_level :refresh
  def refresh
    refresh_mp_level
    refresh_ve_mp_level
  end
  #--------------------------------------------------------------------------
  # * Alias method: skill_cost_payable?
  #--------------------------------------------------------------------------
  alias :skill_cost_payable_ve_mp_level? :skill_cost_payable?
  def skill_cost_payable?(skill)
    skill_cost_payable_ve_mp_level?(skill) && skill_mp_cost_payable?(skill)
  end
  #--------------------------------------------------------------------------
  # * Alias method: pay_skill_cost
  #--------------------------------------------------------------------------
  alias :pay_skill_cost_ve_mp_level :pay_skill_cost
  def pay_skill_cost(skill)
    pay_skill_cost_ve_mp_level(skill)
    max_mp_level.times {|i| pay_mp_level_cost(i + 1, skill) }
  end
  #--------------------------------------------------------------------------
  # * Alias method: recover_all
  #--------------------------------------------------------------------------
  alias :recover_all_ve_mp_level :recover_all
  def recover_all
    recover_all_ve_mp_level
    setup_mp_level
  end
  #--------------------------------------------------------------------------
  # * New method: skill_mp_cost_payable?
  #--------------------------------------------------------------------------
  def skill_mp_cost_payable?(skill)
    return true if get_all_notes =~ /<INFINITE MP LEVEL>/i
    max_mp_level.times {|i| return false if mp_level_cost(i + 1, skill) }
    return true
  end
  #--------------------------------------------------------------------------
  # * New method: max_mp_level
  #--------------------------------------------------------------------------
  def max_mp_level
     note =~ /<MAX MP LEVELS: (\d+)>/i ? $1.to_i : VE_DEFAULT_MAX_LEVEL
  end
  #--------------------------------------------------------------------------
  # * New method: pay_mp_level_cost
  #--------------------------------------------------------------------------
  def pay_mp_level_cost(lvl, skill)
    return if get_all_notes =~ /<INFINITE MP LEVEL>/i
    change_mp_level(lvl, -skill.mp_level_cost(lvl))
  end
  #--------------------------------------------------------------------------
  # * New method: change_mp_level
  #--------------------------------------------------------------------------
  def change_mp_level(lvl, value)
    @mp_level[lvl][:now] += value
    refresh_mp_level
  end
  #--------------------------------------------------------------------------
  # * New method: change_max_mp_level
  #--------------------------------------------------------------------------
  def change_max_mp_level(lvl, value)
    @mp_points[lvl] ||= 0
    @mp_points[lvl] += value
    refresh_mp_level
  end
  #--------------------------------------------------------------------------
  # * New method: mp_level
  #--------------------------------------------------------------------------
  def mp_level(lvl)
    @mp_level[lvl][:now] rescue 0
  end
  #--------------------------------------------------------------------------
  # * New method: mmp_level
  #--------------------------------------------------------------------------
  def mmp_level(lvl)
    @mp_level[lvl][:max] rescue 0
  end
  #--------------------------------------------------------------------------
  # * New method: mp_level_cost
  #--------------------------------------------------------------------------
  def mp_level_cost(lvl, skill)
    mp_level(lvl) < skill.mp_level_cost(lvl)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_mp_level
  #--------------------------------------------------------------------------
  def setup_mp_level
    @mp_level = {}
    max_mp_level.times do |i|
      value = mp_level_value(i + 1)
      @mp_level[i + 1] = {now: value, max: value}
    end
  end
  #--------------------------------------------------------------------------
  # * New method: mp_level_value
  #--------------------------------------------------------------------------
  def mp_level_value(lvl)
    regexp1 = /<MP GROWTH #{lvl}: ([^>]+)>/i
    regexp2 = /<MP LIMIT #{lvl}: (\d+)>/i
    regexp3 = /<MAX MP PLUS #{lvl}: (\d+)>/i
    notes = get_all_notes.dup
    now   = notes.scan(regexp1).collect { eval($1) }.max
    max   = notes.scan(regexp2).collect { $1.to_i  }.max
    now ||= eval(VE_DEFAULT_MP_SETTING[lvl][:growth])
    max ||= VE_DEFAULT_MP_SETTING[lvl][:max]
    now += notes.scan(regexp3).collect { $1.to_i }.sum
    now += @mp_points[lvl] if @mp_points[lvl]
    [[now, 0].max, max].min
  end
  #--------------------------------------------------------------------------
  # * New method: refresh_mp_level
  #--------------------------------------------------------------------------
  def refresh_mp_level
    @mp_level.keys.each do |lvl|
      max = mmp_level(lvl)
      now = [[@mp_level[lvl][:now], 0].max, max].min
      @mp_level[lvl] = {now: now, max: max}
    end
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
  # * Alias method: item_apply
  #--------------------------------------------------------------------------
  alias :item_apply_ve_mp_level :item_apply
  def item_apply(user, item)
    item_apply_ve_mp_level(user, item)
    item_mp_level_effect(user, item) if @result.hit?
  end
  #--------------------------------------------------------------------------
  # * New method: item_mp_level_effect
  #--------------------------------------------------------------------------
  def item_mp_level_effect(user, item)
    max_mp_level.times do |i|
      change_mp_level(i + 1, item.change_mp_level(i + 1))
      change_max_mp_level(i + 1, item.change_max_mp_level(i + 1))
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
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_mp_level :initialize
  def initialize(actor_id)
    @mp_level  = {}
    @mp_points = {}
    initialize_ve_mp_level(actor_id)
  end
  #--------------------------------------------------------------------------
  # * Alias method: setup
  #--------------------------------------------------------------------------
  alias :setup_ve_mp_level :setup
  def setup(actor_id)
    setup_ve_mp_level(actor_id)
    setup_mp_level
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
  alias :initialize_ve_mp_level :initialize
  def initialize(index, enemy_id)
    @mp_level  = {}
    @mp_points = {}
    initialize_ve_mp_level(index, enemy_id)
    setup_mp_level
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
  alias :comment_call_ve_mp_level :comment_call
  def comment_call
    call_mp_level_change
    call_max_mp_level_change
    call_recover_mp_level
    call_recover_all_mp_level
    comment_call_ve_mp_level
  end
  #--------------------------------------------------------------------------
  # * New method: call_mp_level_change
  #--------------------------------------------------------------------------
  def call_mp_level_change
    regexp = /<CHANGE MP LEVEL (\d+): (\d+), *([+-]\d+)>/i
    note.scan(regexp) do
      actor = $game_actors[$1.to_i]
      actor.change_mp_level($2.to_i, $3.to_i) if actor
    end
  end
  #--------------------------------------------------------------------------
  # * New method: call_mp_level_change
  #--------------------------------------------------------------------------
  def call_max_mp_level_change
    regexp = /<CHANGE MAX MP LEVEL (\d+): (\d+), *([+-]\d+)>/i
    note.scan(regexp) do
      actor = $game_actors[$1.to_i]
      actor.change_max_mp_level($2.to_i, $3.to_i) if actor
    end
  end
  #--------------------------------------------------------------------------
  # * New method: call_recover_mp_level
  #--------------------------------------------------------------------------
  def call_recover_mp_level
    regexp = /<RECOVER MP LEVEL:(\d+)>/i
    note.scan(regexp) do
      actor = $game_actors[$1.to_i]
      actor.setup_mp_level if actor
    end
  end
  #--------------------------------------------------------------------------
  # * New method: call_recover_all_mp_level
  #--------------------------------------------------------------------------
  def call_recover_all_mp_level
    regexp = /<RECOVER ALL TECH POINTS>/i
    $game_party.members.each {|actor| actor.setup_mp_level }
  end
end

#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  This is a superclass of all windows in the game.
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Alias method: draw_actor_mp
  #--------------------------------------------------------------------------
  alias :draw_actor_mp_ve_mp_level :draw_actor_mp
  def draw_actor_mp(actor, x, y, width = 124)
    if VE_REPLACE_DISPLAY == :mp
      draw_actor_mp_level(actor, x, y, width)
    else
      draw_actor_mp_ve_mp_level(actor, x, y, width)
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: draw_actor_tp
  #--------------------------------------------------------------------------
  alias :draw_actor_tp_ve_mp_level :draw_actor_tp
  def draw_actor_tp(actor, x, y, width = 124)
    if VE_REPLACE_DISPLAY == :tp
      draw_actor_mp_level(actor, x, y, width)
    else
      draw_actor_tp_ve_mp_level(actor, x, y, width)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: draw_actor_mp_level
  #--------------------------------------------------------------------------
  def draw_actor_mp_level(actor, x, y, width = 124)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::mp_a) if width > 96
    change_color(normal_color)
    position = width / 2 - (width > 96 ? 12 : 24)
    contents.font.size = Font.default_size - 6
    actor.max_mp_level.times do |i|
      px  = x + i * 20 + position
      draw_text(px - 30, y + 4, 32, line_height, actor.mp_level(i + 1).to_s, 2)
      draw_text(px, y + 4, 24, line_height, "/") if i + 1 != actor.max_mp_level
    end
    contents.font.size = Font.default_size
  end
end

#==============================================================================
# ** Window_Skill
#------------------------------------------------------------------------------
#  This window displays a list of usable skills on the skill screen.
#==============================================================================

class Window_SkillList < Window_Selectable
  #--------------------------------------------------------------------------
  # * Alias method: draw_skill_cost
  #--------------------------------------------------------------------------
  alias :draw_skill_cost_ve_mp_level :draw_skill_cost
  def draw_skill_cost(rect, skill)
    draw_skill_cost_ve_mp_level(rect, skill)
    draw_mp_level_cost(rect, skill) if skill.is_mp_level?
  end
  #--------------------------------------------------------------------------
  # * New method: draw_mp_level_cost
  #--------------------------------------------------------------------------
  def draw_mp_level_cost(rect, skill)
    rect.x -= 32 if @actor.skill_mp_cost(skill) > 0
    rect.x -= 32 if @actor.skill_tp_cost(skill) > 0
    @actor.max_mp_level.times do |i|
      lvl = @actor.max_mp_level - i
      next if skill.mp_level_cost(lvl) == 0
      change_color(tp_cost_color, enable?(skill))
      draw_text(rect, "L#{lvl}   ", 2)
      change_color(mp_cost_color, enable?(skill))
      draw_text(rect, skill.mp_level_cost(lvl), 2)
      rect.x -= 64
    end
  end
end