#==============================================================================
# ** Victor Engine - Custom Description
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.01.09 > First release
#  v 1.01 - 2012.08.02 > Compatibility with Basic Module 1.27
#------------------------------------------------------------------------------
#  This script allows to change the descriptions for actors, items, equipment
# and skills during the game. The changes are stored on the save file, so
# it do not affect differente saves.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v1.27 or higher
#
# * Overwrite methods
#   class Game_Actor < Game_Battler
#     def description
#
#   class Window_Help < Window_Base
#     def set_item(item)
#
# * Alias methods
#   class << DataManager
#     def setup_new_game
#     def create_game_objects
#     def make_save_contents
#     def extract_save_contents(contents)
#
#   class Game_Interpreter
#     def comment_call
#
#------------------------------------------------------------------------------
# Comment calls note tags:
#  Tags to be used in events comment box, works like a script call.
#
#  <x change description: id>
#  string
#  </x change description>
#   The new description text, the string is the text, to add a break line
#   use \\n.
#     x  : type of the object (actor, item, weapon, armor or skill)
#     id : ID of the actor, item, weapon, armor or skill
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
$imported[:ve_custom_descriptions] = 1.01
Victor_Engine.required(:ve_custom_descriptions, :ve_basic_module, 1.27, :above)

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
  alias :setup_new_game_ve_custom_descriptions :setup_new_game
  def setup_new_game
    setup_new_game_ve_custom_descriptions
    create_custom_descriptions
  end
  #--------------------------------------------------------------------------
  # * Alias method: create_game_objects
  #--------------------------------------------------------------------------
  alias :create_game_objects_ve_custom_descriptions :create_game_objects
  def create_game_objects
    create_game_objects_ve_custom_descriptions
    create_custom_descriptions
  end
  #--------------------------------------------------------------------------
  # * Alias method: make_save_contents
  #--------------------------------------------------------------------------
  alias :make_save_contents_ve_custom_descriptions :make_save_contents
  def make_save_contents
    contents = make_save_contents_ve_custom_descriptions
    contents[:itm_description_ve] = $game_itm_description
    contents[:arm_description_ve] = $game_arm_description
    contents[:wpn_description_ve] = $game_wpn_description
    contents[:skl_description_ve] = $game_skl_description
    contents
  end
  #--------------------------------------------------------------------------
  # * Alias method: extract_save_contents
  #--------------------------------------------------------------------------
  alias :extract_save_contents_ve_custom_descriptions :extract_save_contents
  def extract_save_contents(contents)
    extract_save_contents_ve_custom_descriptions(contents)
    $game_itm_description = contents[:itm_description_ve]
    $game_arm_description = contents[:arm_description_ve]
    $game_wpn_description = contents[:wpn_description_ve]
    $game_skl_description = contents[:skl_description_ve]
  end
  #--------------------------------------------------------------------------
  # * New method: create_custom_descriptions
  #--------------------------------------------------------------------------
  def create_custom_descriptions
    $game_itm_description = {}
    $game_arm_description = {}
    $game_wpn_description = {}
    $game_skl_description = {}
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
  # * Overwrite method: description
  #--------------------------------------------------------------------------
  def description
    @description ? @description : actor.description
  end
  #--------------------------------------------------------------------------
  # * New method: description=
  #--------------------------------------------------------------------------
  def description=(n)
    @description = n
  end
end

#==============================================================================
# ** Window_Help
#------------------------------------------------------------------------------
#  This window shows skill and item explanations along with actor status.
#==============================================================================

class Window_Help < Window_Base
  #--------------------------------------------------------------------------
  # * Overwrite method: set_item
  #--------------------------------------------------------------------------
  def set_item(item)
    custom = custom_description(item)
    set_text(custom ? custom : item ? item.description : "")
  end
  #--------------------------------------------------------------------------
  # * New method: custom_description
  #--------------------------------------------------------------------------
  def custom_description(item)
    case item
    when RPG::Item   then $game_itm_description[item.id]
    when RPG::Armor  then $game_arm_description[item.id]
    when RPG::Weapon then $game_wpn_description[item.id]
    when RPG::Skill  then $game_skl_description[item.id]
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
  # * Alias method: comment_call
  #--------------------------------------------------------------------------
  alias :comment_call_ve_custom_descriptions :comment_call
  def comment_call
    call_change_description("ACTOR")
    call_change_description("ITEM")
    call_change_description("ARMOR")
    call_change_description("WEAPON")
    call_change_description("SKILL")
    comment_call_ve_custom_descriptions
  end
  #--------------------------------------------------------------------------
  # * New method: call_change_description
  #--------------------------------------------------------------------------
  def call_change_description(type)
    value  = "#{type} CHANGE DESCRIPTION"
    regexp = get_all_values("#{value}: (\\d+)", value)
    note.scan(regexp) do |id, text|
      text.gsub!(/\r\n/) { "" }
      text.gsub!(/\\n/)  { "\r\n|" }
      set_custom_description(type, id.to_i, text)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_custom_description
  #--------------------------------------------------------------------------
  def set_custom_description(type, id, text)
    return if type.upcase == "ACTOR" && !$game_actors[id]
    case type.upcase
    when "ACTOR"  then $game_actors[id].description = text
    when "ITEM"   then $game_itm_description[id] = text
    when "ARMOR"  then $game_arm_description[id] = text
    when "WEAPON" then $game_wpn_description[id] = text
    when "SKILL"  then $game_skl_description[id] = text
    end
  end
end