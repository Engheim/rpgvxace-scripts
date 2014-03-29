#==============================================================================
# ** Victor Engine - Actors Battlers
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2011.12.19 > First release
#  v 1.01 - 2011.12.30 > Faster Regular Expressions
#  v 1.02 - 2012.01.15 > Compatibility with Target Arrow
#  v 1.03 - 2012.01.28 > Compatibility with Animated Battle
#  v 1.04 - 2012.03.11 > Added position distance settings
#  v 1.05 - 2012.03.17 > Fixed battle test glitch
#  v 1.06 - 2012.05.20 > Compatibility with Map Turn Battle
#  v 1.07 - 2012.12.13 > Compatibility with State Graphics
#  v 1.08 - 2012.12.30 > Compatibility with Leap Attack
#  v 1.09 - 2013.01.07 > Fixed issue with custom formation and big parties
#------------------------------------------------------------------------------
#  This script adds visible battler graphics for the party actors actors
# during combat. With the visible battlers, new options will be available
# like setting actor's battlers positions and attack animations.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.11 or higher.
#   If used with 'Victor Engine - Animated Battle' place this bellow it.
# 
# * Overwrite methods
#   class Spriteset_Battle
#      def create_actors
#     def update_actors
#
#   class Scene_Battle < Scene_Base
#     def show_attack_animation(targets)
#
# * Alias methods 
#   class << DataManager
#     def setup_new_game
#     def create_game_objects
#     def make_save_contents
#     def extract_save_contents(contents)
#
#   class Game_Actor < Game_Battler
#     def setup(actor_id)
#
#   class Game_Interpreter
#     def comment_call
#
#   class Scene_Battle < Scene_Base
#     def start
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
#  <battler name id: x>
#   This tag allows to change the actor battler graphic.
#    id : actor ID
#    x  : battler graphic filename
#
#  <battler hue id: x>
#   This tag allows to change the actor battler graphic.
#    id : actor ID
#    x  : battler graphic hue (0-360)
#
#  <battler position i: x, y>
#   This tag allows to change the battler position during combat.
#   only valid if VE_BATTLE_FORMATION = :custom
#     i : position index
#     x : new coorditante X
#     y : new coorditante X
#
#------------------------------------------------------------------------------
# Actors and Enemies note tags:
#   Tags to be used on the Actors and Enemies note box in the database
#
#  <battler name: x>
#   This tag allows to set the initial battler graphic filename for the actor.
#    x : battler graphic filename
#
#  <battler hue: x>
#   This tag allows to set the initial battler graphic hur for the actor.
#    x : battler graphic hue (0-360)
#
#------------------------------------------------------------------------------
# Enemies note tags:
#   Tags to be used on the Enemies note box in the database
#
#  <attack animation: x>
#   This tag allows to set the normal attack animation for the enemy
#    x : animation ID
#  
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Set the battle formation
  #    Choose here how the actors battlers will be placed on the combat.
  #    :front  : horizontal placement
  #    :side   : vertical placement
  #    :iso    : isometric placement
  #    :custom : custom placement
  #--------------------------------------------------------------------------
  VE_BATTLE_FORMATION = :side
  #--------------------------------------------------------------------------
  # * Set battler centralization
  #    When true, battlers are centralized automatically.
  #    Not valid if VE_BATTLE_FORMATION = :custom
  #--------------------------------------------------------------------------
  VE_BATTLE_CENTRALIZE = false
  #--------------------------------------------------------------------------
  # * Set battlers custom positions
  #    Only if VE_BATTLE_FORMATION = :custom, allows to set the position of
  #    all party actors, don't forget to add values for all positions
  #    available if using a party bigger than the default.
  #--------------------------------------------------------------------------
  VE_CUSTOM_POSITION = {
  # Position
    1 => {x: 420, y: 182}, # Position for the first actor.
    2 => {x: 424, y: 218}, # Position for the second actor.
    3 => {x: 428, y: 254}, # Position for the thrid actor.
    4 => {x: 432, y: 290}, # Position for the fourth actor.
  } # Don't remove
  #--------------------------------------------------------------------------
  # * Actors battlers position adjust
  #    Used to adjust the position of all actors battlers.
  #--------------------------------------------------------------------------
  VE_POSITION_ADJUST = {x: 0, y: 0}
  #--------------------------------------------------------------------------
  # * Actors battlers position adjust
  #    Used to adjust the position of all actors battlers.
  #--------------------------------------------------------------------------
  VE_DISTANCE_ADJUST = {x: 8, y: 24}
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
$imported[:ve_actor_battlers] = 1.09
Victor_Engine.required(:ve_actor_battlers, :ve_basic_module, 1.11, :above)
Victor_Engine.required(:ve_actor_battlers, :ve_map_battle, 1.00, :bellow)
Victor_Engine.required(:ve_actor_battlers, :ve_state_graphics, 1.00, :bellow)

#==============================================================================
# ** DataManager
#------------------------------------------------------------------------------
#  This module handles the game and database objects used in game.
# Almost all global variables are initialized on this module
#==============================================================================

class << DataManager
  #--------------------------------------------------------------------------
  # * Alias method: setup_new_game
  #--------------------------------------------------------------------------
  alias :setup_new_game_ve_actor_battlers :setup_new_game
  def setup_new_game
    setup_new_game_ve_actor_battlers
    $game_custom_positions = VE_CUSTOM_POSITION.dup
    $game_custom_formation = VE_BATTLE_FORMATION
    $game_position_adjust  = VE_POSITION_ADJUST.dup
  end
  #--------------------------------------------------------------------------
  # * Alias method: setup_battle_test
  #--------------------------------------------------------------------------
  alias :setup_battle_test_ve_actor_battlers :setup_battle_test
  def setup_battle_test
    setup_battle_test_ve_actor_battlers
    $game_custom_positions = VE_CUSTOM_POSITION.dup
    $game_custom_formation = VE_BATTLE_FORMATION
    $game_position_adjust  = VE_POSITION_ADJUST.dup
  end
  #--------------------------------------------------------------------------
  # * Alias method: create_game_objects
  #--------------------------------------------------------------------------
  alias :create_game_objects_ve_actor_battlers :create_game_objects
  def create_game_objects
    create_game_objects_ve_actor_battlers
    $game_custom_positions = {}
    $game_custom_formation = VE_BATTLE_FORMATION
    $game_position_adjust  = VE_POSITION_ADJUST.dup
  end
  #--------------------------------------------------------------------------
  # * Alias method: make_save_contents
  #--------------------------------------------------------------------------
  alias :make_save_contents_ve_actor_battlers  :make_save_contents
  def make_save_contents
    contents = make_save_contents_ve_actor_battlers
    contents[:positions_ve]  = $game_custom_positions
    contents[:formation_ve]  = $game_custom_formation
    contents[:pos_adjust_ve] = $game_position_adjust
    contents
  end
  #--------------------------------------------------------------------------
  # * Alias method: extract_save_contents
  #--------------------------------------------------------------------------
  alias :extract_save_contents_ve_actor_battlers :extract_save_contents
  def extract_save_contents(contents)
    extract_save_contents_ve_actor_battlers(contents)
    $game_custom_positions = contents[:positions_ve]
    $game_custom_formation = contents[:formation_ve]
    $game_position_adjust  = contents[:pos_adjust_ve]
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
  attr_accessor :screen_x                 # Coordenada X na tela
  attr_accessor :screen_y                 # Coordenada Y na tela
  #--------------------------------------------------------------------------
  # * Alias method: setup
  #--------------------------------------------------------------------------
  alias :setup_ve_actor_battlers :setup
  def setup(actor_id)
    setup_ve_actor_battlers(actor_id)
    @battler_name = actor_battler_name
    @battler_hue  = actor_battler_hue
  end
  #--------------------------------------------------------------------------
  # * Aquisição do índice do herói
  #--------------------------------------------------------------------------
  def index
    $game_party.members.index($game_actors[@actor_id])
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: use_sprite?
  #--------------------------------------------------------------------------
  def use_sprite?
    return true
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: screen_z
  #--------------------------------------------------------------------------
  def screen_z
    return 100
  end
  #--------------------------------------------------------------------------
  # * New method: actor_battler_name
  #--------------------------------------------------------------------------
  def actor_battler_name
    actor.note =~ /<BATTLER NAME: ([^><]*)>/i ? $1.to_s : ""
  end
  #--------------------------------------------------------------------------
  # * New method: actor_battler_hue
  #--------------------------------------------------------------------------
  def actor_battler_hue
    actor.note =~ /<BATTLER HUE: (\d+)>/i ? $1.to_i : 0
  end
  #--------------------------------------------------------------------------
  # * New method: battler_name
  #--------------------------------------------------------------------------
  def battler_name=(name)
    @battler_name = name if name.is_a?(String)
  end
  #--------------------------------------------------------------------------
  # * New method: battler_hue
  #--------------------------------------------------------------------------
  def battler_hue=(hue)
    @battler_hue = hue if hue.numeric?
  end
  #--------------------------------------------------------------------------
  # * New method: screen_x
  #--------------------------------------------------------------------------
  def screen_x
    setup_x
  end
  #--------------------------------------------------------------------------
  # * New method: screen_y
  #--------------------------------------------------------------------------
  def screen_y
    setup_y
  end
  #--------------------------------------------------------------------------
  # * New method: setup_x
  #--------------------------------------------------------------------------
  def setup_x
    case $game_custom_formation
    when :front  then position = get_frontal_x
    when :side   then position = get_sideview_x
    when :iso    then position = get_isometric_x
    when :custom then position = $game_custom_positions[index + 1][:x]
    end
    position + $game_position_adjust[:x]
  end
  #--------------------------------------------------------------------------
  # * New method: setup_y
  #--------------------------------------------------------------------------
  def setup_y
    case $game_custom_formation
    when :front  then position = get_frontal_y
    when :side   then position = get_sideview_y
    when :iso    then position = get_isometric_y
    when :custom then position = $game_custom_positions[index + 1][:y]
    end
    position + $game_position_adjust[:y]
  end
  #--------------------------------------------------------------------------
  # * New method: get_frontal_x
  #--------------------------------------------------------------------------
  def get_frontal_x
    if VE_BATTLE_CENTRALIZE
      size = $game_party.battle_members.size
      position = (index + 1) * Graphics.width / (size + 1)
    else
      size = $game_party.max_battle_members
      position = index * Graphics.width / size + 64
    end
    position
  end
  #--------------------------------------------------------------------------
  # * New method: get_frontal_y
  #--------------------------------------------------------------------------
  def get_frontal_y
    Graphics.height - 16
  end
  #--------------------------------------------------------------------------
  # * New method: get_sideview_x
  #--------------------------------------------------------------------------
  def get_sideview_x
    if VE_BATTLE_CENTRALIZE
      size = $game_party.max_battle_members
      x    = dist[:x] / 8
      position = -index * (index * x - x * size) + Graphics.width - 160
    else
      position = index * dist[:x] + Graphics.width - 192
    end
    position
  end
  #--------------------------------------------------------------------------
  # * New method: get_sideview_y
  #--------------------------------------------------------------------------
  def get_sideview_y
    if VE_BATTLE_CENTRALIZE
      size   = $game_party.battle_members.size
      height = Graphics.height
      position = (index - size) * dist[:y] + size * dist[:y] / 2 + height - 160
    else
      position = index * dist[:y] +  Graphics.height - 200
    end
    position
  end
  #--------------------------------------------------------------------------
  # * New method: get_isometric_x
  #--------------------------------------------------------------------------
  def get_isometric_x
    if VE_BATTLE_CENTRALIZE
      position = -index * (index * dist[:x] - 32) + Graphics.width - 160
    else
      position = index * dist[:x] +  Graphics.width - 192
    end
    position
  end
  #--------------------------------------------------------------------------
  # * New method: get_isometric_y
  #--------------------------------------------------------------------------
  def get_isometric_y
    if VE_BATTLE_CENTRALIZE
      position = index * (dist[:y] - index * 6) + Graphics.height - 160
    else
      position = Graphics.height - 96 - index * dist[:y]
    end
    position
  end
  #--------------------------------------------------------------------------
  # * New method: dist
  #--------------------------------------------------------------------------
  def dist
    VE_DISTANCE_ADJUST
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
  alias :initialize_ve_actor_battlers :initialize
  def initialize(index, enemy_id)
    initialize_ve_actor_battlers(index, enemy_id)
    @battler_name = enemy_battler_name if enemy_battler_name
    @battler_hue  = enemy_battler_hue  if enemy_battler_hue
  end
  #--------------------------------------------------------------------------
  # * New method: enemy_battler_name
  #--------------------------------------------------------------------------
  def enemy_battler_name
    enemy.note =~ /<BATTLER NAME: ([^><]*)>/i ? $1.to_s : nil
  end
  #--------------------------------------------------------------------------
  # * New method: enemy_battler_hue
  #--------------------------------------------------------------------------
  def enemy_battler_hue
    enemy.note =~ /<BATTLER HUE: (\d+)>/i ? $1.to_i : nil
  end
  #--------------------------------------------------------------------------
  # * New method: atk_animation_id1
  #--------------------------------------------------------------------------
  def atk_animation_id1
    enemy.note =~ /<ATTACK ANIM(?:ATION): (\d+)>/i ? $1.to_i : 1
  end
  #--------------------------------------------------------------------------
  # * New method: atk_animation_id2
  #--------------------------------------------------------------------------
  def atk_animation_id2
    return 0
  end
end

#==============================================================================
# ** Game_Unit
#------------------------------------------------------------------------------
#  This class handles units. It's used as a superclass of the Game_Party and
# Game_Troop classes.
#==============================================================================

class Game_Unit
  #--------------------------------------------------------------------------
  # * New method: setup_in_battle
  #--------------------------------------------------------------------------
  def setup_in_battle
    @in_battle = true
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
  alias :comment_call_ve_actor_battlers :comment_call
  def comment_call
    change_battler_name
    change_battler_hue
    change_position
    comment_call_ve_actor_battlers
  end
  #--------------------------------------------------------------------------
  # * New method: change_battler_name
  #--------------------------------------------------------------------------
  def change_battler_name
    note.scan(/<BATTLER NAME (\d+): ([^><]*)>/i) do |id, name|
      $game_actors[id.to_i].battler_name = name
    end
  end
  #--------------------------------------------------------------------------
  # * New method: change_battler_hue
  #--------------------------------------------------------------------------
  def change_battler_hue
    note.scan(/<BATTLER HUE (\d+): (\d+)>/i) do |id, hue|
      $game_actors[id.to_i].battler_hue = hue
    end
  end
  #--------------------------------------------------------------------------
  # * New method: change_position
  #--------------------------------------------------------------------------
  def change_position
    regexp = /<BATTLER POSITION (\d+): (\d+) *, *(\d+)>/i
    note.scan(regexp) do |i, x, y|
      $game_custom_positions[i.to_i][:x] = x.to_i
      $game_custom_positions[i.to_i][:y] = y.to_i
    end
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
  # * Overwrite method: create_actors
  #--------------------------------------------------------------------------
  def create_actors
    @actor_sprites = $game_party.battle_members.reverse.collect do |actor|
      Sprite_Battler.new(@viewport1, actor)
    end
    @actors_party = $game_party.battle_members.dup
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: update_actors
  #--------------------------------------------------------------------------
  def update_actors
    update_party if $game_party.battle_members != @actors_party
    @actor_sprites.each {|sprite| sprite.update }
  end
  #--------------------------------------------------------------------------
  # * New method: update_party
  #--------------------------------------------------------------------------
  def update_party
    @actor_sprites.each_index do |i|
      next if $game_party.battle_members.include?(@actor_sprites[i].battler)
      @actor_sprites[i].dispose
      @actor_sprites[i] = nil
    end
    $game_party.battle_members.collect do |actor|
      next if @actors_party.include?(actor)
      @actor_sprites.push(Sprite_Battler.new(@viewport1, actor))
    end
    @actor_sprites.compact!
    @actors_party = $game_party.battle_members.dup
    $game_party.battle_members.each do |actor|
      old_position = [actor.screen_x, actor.screen_y]
      actor.default_direction if $imported[:ve_animated_battle]
      if old_position != [actor.screen_x, actor.screen_y]
        sprite(actor).start_effect(:appear) 
      end
    end
  end
end

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Alias method: start
  #--------------------------------------------------------------------------
  alias :start_ve_actor_battlers :start
  def start
    $game_party.setup_in_battle
    start_ve_actor_battlers
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: show_attack_animation
  #--------------------------------------------------------------------------
  def show_attack_animation(targets)
    show_normal_animation(targets, @subject.atk_animation_id1, false)
    show_normal_animation(targets, @subject.atk_animation_id2, true)
  end
end