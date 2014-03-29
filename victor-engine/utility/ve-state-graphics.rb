#==============================================================================
# ** Victor Engine - State Graphics
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.12.13 > First relase
#  v 1.01 - 2012.12.15 > Fixed issue with Defend skill
#------------------------------------------------------------------------------
#  This script allows to setup states that changes the battler graphic when
# the battle is under certain states. You can use that to create transformation
# states, such as the 'Toad' state from the Final Fantasy series.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.30 or higher
#   If used with 'Victor Engine - Animated Battle' place this bellow it.
#   If used with 'Victor Engine - Actors Battlers' place this bellow it.
#
# * Overwrite methods
#   class Game_Actor < Game_Battler
#     def battler_name
#     def character_name
#     def character_index
#
#   class Game_Enemy < Game_Battler
#     def battler_name
#     def character_name
#
# * Alias methods
#   class Game_BattlerBase
#     def erase_state(state_id)
#
#   class Game_Battler < Game_BattlerBase
#     def add_new_state(state_id)
#
#   class Game_Enemy < Game_Battler
#     def character_index
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# States note tags:
#   Tags to be used on the States note box in the database
#
#  <state graphic replace: x>
#  <state graphic replace: x, y>
#   Adding this tag on the state will make the battle, charset and face graphic
#   to be directly replaced by the one set with this tag
#     x : character filename
#     y : character index (for 8 charset files)
#
#  <state graphic extension: x>
#   Adding this tag on the state will make the battle, charset and face graphic
#   to be replaced by one with the same filename + the extension
#     x : character filename extension
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#  The <state graphic replace: x>/ <state graphic replace: x, y> tag uses 
#  always the same graphic no matter who is the state target.
#  This will also change the face index to the same index as the charset
# 
#  The <state graphic extension: x> allows to setup different graphics based
#  on the target. The graphic must have the same filename + the extension.
#  The charset index will not be changed using this tag.
#  Ex.: A battler with a graphic named 'Actor1' when inflicted with a state with
#       the tag <state graphic extension: [toad]> will need a filename
#       named 'Actor1[toad].
#  This sufix must be the first one when used together with the Animated Battle
#  sufixes.
#  This doesn't change the index for faces and charsets, so the new file must
#  have a matching graphic for that index.
#
#  If the battler state graphic don't exist the graphic will not be changed.
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Change Map Graphic
  #   When true, the on map charset will be changed when under states that
  #   change the graphic. If false, only in battle graphics will be changed.
  #     Note: if using the Animated Battle with charset template, this option
  #     must be set true, since the battlers are actually map charsets.
  #--------------------------------------------------------------------------
  Change_Map_Graphic = true
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
$imported[:ve_state_graphics] = 1.00
Victor_Engine.required(:ve_state_graphics, :ve_basic_module, 1.30, :above)

#==============================================================================
# ** RPG::State
#------------------------------------------------------------------------------
#  This is the data class for states
#==============================================================================

class RPG::State < RPG::BaseItem
  #--------------------------------------------------------------------------
  # * New method: graphic_replace
  #--------------------------------------------------------------------------
  def graphic_replace
    regexp = /<STATE GRAPHIC REPLACE: ([^><,]*)(?:, *(\d+))?>/i
    note   =~ regexp ? [$1.to_s, $2 ? $2.to_i - 1 : 0] : nil
  end
  #--------------------------------------------------------------------------
  # * New method: graphic_extension
  #--------------------------------------------------------------------------
  def graphic_extension
    note =~ /<STATE GRAPHIC EXTENSION: ([^><]*)>/i ? $1.to_s : nil
  end
  #--------------------------------------------------------------------------
  # * New method: state_graphic?
  #--------------------------------------------------------------------------
  def state_graphic?
    graphic_replace || graphic_extension
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
  # * Alias method: erase_state
  #--------------------------------------------------------------------------
  alias :erase_state_ve_state_graphic :erase_state
  def erase_state(state_id)
    erase_state_ve_state_graphic(state_id)
    $game_player.refresh if $data_states[state_id].state_graphic? && actor?
  end
  #--------------------------------------------------------------------------
  # * New method: check_state_extension
  #--------------------------------------------------------------------------
  def check_state_extension
    list  = states.sort {|a,b| b.priority <=> a.priority }
    list.each {|st| return st.graphic_extension if st.graphic_extension }
    return nil
  end
  #--------------------------------------------------------------------------
  # * New method: check_state_replace
  #--------------------------------------------------------------------------
  def check_state_replace
    list  = states.sort {|a,b| b.priority <=> a.priority }
    list.each {|st| return st.graphic_replace if st.graphic_replace }
    return nil
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
  # * Alias method: add_new_state
  #--------------------------------------------------------------------------
  alias :add_new_state_ve_state_graphic :add_new_state
  def add_new_state(state_id)
    add_new_state_ve_state_graphic(state_id)
    $game_player.refresh if $data_states[state_id].state_graphic? && actor?
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
  # * Overwrite method: battler_name
  #--------------------------------------------------------------------------
  def battler_name
    @battler_name = actor_battler_name
    extension = check_state_extension
    replace = check_state_replace
    name    = @battler_name + extension if extension
    name    = replace.first if replace
    @battler_name = name if name && battler_exist?(name)
    @battler_name
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: face_name
  #--------------------------------------------------------------------------
  def face_name
    face_name = @face_name
    extension = check_state_extension
    replace   = check_state_replace
    name      = face_name + extension if extension
    name      = replace.first if replace
    face_name = name if name && character_exist?(name)
    face_name
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: character_name
  #--------------------------------------------------------------------------
  def character_name
    character_name = @character_name
    extension = check_state_extension
    replace   = check_state_replace
    name      = character_name + extension if extension
    name      = replace.first if replace
    character_name = name if name && character_exist?(name)
    character_name
  end  
  #--------------------------------------------------------------------------
  # * Overwrite method: character_index
  #--------------------------------------------------------------------------
  def character_index
    character_index = @character_index
    replace   = check_state_replace
    index     = replace.last if replace
    character_index = index  if index
    character_index
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: face_index
  #--------------------------------------------------------------------------
  def face_index
    face_index = @face_index
    replace    = check_state_replace
    index      = replace.last if replace
    face_index = index  if index
    face_index
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
  # * Overwrite method: battler_name
  #--------------------------------------------------------------------------
  def battler_name
    @battler_name = enemy.battler_name
    extension = check_state_extension
    replace   = check_state_replace
    name      = @battler_name + extension if extension
    name      = replace.first if replace
    @battler_name = name if name && battler_exist?(name)
    @battler_name
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: character_name
  #--------------------------------------------------------------------------
  def character_name
    @character_name = battler_name
    extension = check_state_extension
    replace   = check_state_replace
    name      = @character_name + extension if extension
    name      = replace.first  if replace
    @character_name = name if name && character_exist?(name)
    @character_name
  end
  #--------------------------------------------------------------------------
  # * Alias method: character_index
  #--------------------------------------------------------------------------
  alias :character_index_ve_state_graphic :character_index if $imported[:ve_animated_battle]
  def character_index
    @character_index = character_index_ve_state_graphic
    replace   = check_state_replace
    name      = replace.last if replace
    @character_index = index  if index
    @character_index
  end
end