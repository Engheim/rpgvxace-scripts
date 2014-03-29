#==============================================================================
# ** Victor Engine - Step Sound
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.01.08 > First release
#  v 1.01 - 2012.01.15 > Fixed the Regular Expressions problem with "" and “”
#  v 1.02 - 2012.05.30 > Compatibility with Pixel Movement
#  v 1.03 - 2012.08.02 > Compatibility with Basic Module 1.27
#------------------------------------------------------------------------------
#  This script allows to add sound to the step for actors and events on map.
# It's possible to set sounds based on tileset terrain tags or map regions.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.27 or higher
#
# * Alias methods
#   class Game_Map
#     def setup(map_id)
#
#   class Game_CharacterBase
#     def update_move
#     def update_stop
#
#   class Game_Player < Game_Character
#     def update
# 
#   class Game_Event < Game_Character
#     def clear_starting_flag
#
#   class Game_Follower < Game_Character
#     def update
#
#   class Game_Vehicle < Game_Character
#     def update
#
#------------------------------------------------------------------------------
# Maps and Tilests note tags:
#   Tags to be used on Maps and Tilests note boxes.
# 
#  <step sound>
#  settings
#  </step sound>
#   Set the sound effect played when steping on a tile with terrain or region
#   set, add the following values to the settings. The ID and file name 
#   must be added, other values are optional. 
#     id: x     : region ID or terrain ID
#     name: "x" : sound effect filename ("filename)
#     volume: x : sound effect volume (0-100, default = 100)
#     pitch: x  : sound effect pitch (50-150, default = 100)
#
#------------------------------------------------------------------------------
# Actors, Classes, States, Weapons, Armors and Comment Boxes note tags:
#   Tags to be used on Actors, Classes, States, Weapons, Armors note boxes
#   and Events Comment boxes. The comment boxes are different from the comment
#   call, they're called always the even refresh.
# 
#  <no step sound>
#   The actor or event won't play any sound when walking on tiles with sound.
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
$imported[:ve_step_sound] = 1.03
Victor_Engine.required(:ve_step_sound, :ve_basic_module, 1.27, :above)

#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  This class handles maps. It includes scrolling and passage determination
# functions. The instance of this class is referenced by $game_map.
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader :terrain_sounds
  attr_reader :regions_sounds
  #--------------------------------------------------------------------------
  # * Alias method: battle_start
  #--------------------------------------------------------------------------
  alias :setup_ve_step_sound :setup
  def setup(map_id)
    setup_ve_step_sound(map_id)
    setup_step_sound
  end
  #--------------------------------------------------------------------------
  # * New method: setup_step_sound
  #--------------------------------------------------------------------------
  def setup_step_sound
    @terrain_sounds = setup_sound_settings(tileset.note)
    @regions_sounds = setup_sound_settings(note)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_sound_settings
  #--------------------------------------------------------------------------  
  def setup_sound_settings(note)
    settings = {}
    regexp   = get_all_values("STEP SOUND")
    note.scan(regexp) do
      value  = $1.dup
      name   = value =~ /NAME: #{get_filename}/i ? $1 : ""
      id     = value =~ /ID: (\d+)/i     ? $1.to_i : 0
      volume = value =~ /VOLUME: (\d+)/i ? $1.to_i : 100
      pitch  = value =~ /PITCH: (\d+)/i  ? $1.to_i : 100
      settings[id] = RPG::SE.new(name, volume, pitch)
    end
    settings.dup
  end
end

#==============================================================================
# ** Game_CharacterBase
#------------------------------------------------------------------------------
#  This class deals with characters. Common to all characters, stores basic
# data, such as coordinates and graphics. It's used as a superclass of the
# Game_Character class.
#==============================================================================

class Game_CharacterBase
  #--------------------------------------------------------------------------
  # * Alias method: update_move
  #--------------------------------------------------------------------------
  alias :update_move_ve_step_sound :update_move
  def update_move
    update_move_ve_step_sound
    update_step_sound if moving? || @moved
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_stop
  #--------------------------------------------------------------------------
  alias :update_stop_ve_step_sound :update_stop
  def update_stop
    update_stop_ve_step_sound 
    @step_update = 0 if @stop_count > 1 || @locked
  end
  #--------------------------------------------------------------------------
  # * New method: update_step_sound
  #--------------------------------------------------------------------------
  def update_step_sound
    return if @no_step_sound
    @step_update ||= 0
    play_step_sound if @step_update == 0
    @step_update += 10
    @step_update = 0 if @step_update > ((8 - real_move_speed) * 40)
  end
  #--------------------------------------------------------------------------
  # * New method: play_step_sound
  #--------------------------------------------------------------------------
  def play_step_sound
    if $game_map.terrain_sounds[terrain_tag]
      sound = $game_map.terrain_sounds[terrain_tag].clone
    elsif $game_map.regions_sounds[region_id]
      sound = $game_map.regions_sounds[region_id].clone
    end
    return unless sound
    sound.volume *= step_volume
    sound.play
  end
  #--------------------------------------------------------------------------
  # * New method: step_volume
  #--------------------------------------------------------------------------
  def step_volume
    sx = distance_x_from($game_player.x).abs
    sy = distance_y_from($game_player.y).abs
    [[(100 - (sx + sy - 2) * 5), 0].max, 100].min / 100.0
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_player_step_sound
  #--------------------------------------------------------------------------
  def update_player_step_sound
    return unless actor
    if @step_info != [actor.equips, actor.states, actor.class]
      @step_info = [actor.equips, actor.states, actor.class]
      @no_step_sound_player = actor.note =~ /<NO STEP SOUND>/i
      actor.equips.compact.each do |equip|
        @no_step_sound_player |= equip.note =~ /<NO STEP SOUND>/i
      end
      actor.states.each do |state|
        @no_step_sound_player |= state.note =~ /<NO STEP SOUND>/i
      end
      @no_step_sound_player |= actor.class.note =~ /<NO STEP SOUND>/i
    end
  end  
end

#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
#  This class handles the player.
# The instance of this class is referenced by $game_map.
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :vehicle_getting_on
  attr_reader   :vehicle_getting_off
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :update_ve_step_sound :update
  def update
    update_player_step_sound
    @no_step_sound = vehicle && vehicle.altitude > 0 || @no_step_sound_player
    update_ve_step_sound
  end
end

#==============================================================================
# ** Game_Event
#------------------------------------------------------------------------------
#  This class deals with events. It handles functions including event page 
# switching via condition determinants, and running parallel process events.
# It's used within the Game_Map class.
#==============================================================================

class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # * Alias method: clear_starting_flag
  #--------------------------------------------------------------------------
  alias :clear_starting_flag_ve_step_sound :clear_starting_flag
  def clear_starting_flag
    clear_starting_flag_ve_step_sound
    @no_step_sound = note =~ /<NO STEP SOUND>/i if @page
  end
end

#==============================================================================
# ** Game_Follower
#------------------------------------------------------------------------------
#  This class handles the followers. Followers are the actors of the party
# that follows the leader in a line. It's used within the Game_Followers class.
#==============================================================================

class Game_Follower < Game_Character
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :update_ve_step_sound :update
  def update
    update_player_step_sound
    @no_step_sound = no_step_follower || @no_step_sound_player
    update_ve_step_sound
  end
  #--------------------------------------------------------------------------
  # * New method: no_step_follower
  #--------------------------------------------------------------------------
  def no_step_follower
    !visible? || ($game_player.vehicle && (!$game_player.vehicle_getting_on &&
    !$game_player.vehicle_getting_off))
  end
end

#==============================================================================
# ** Game_Vehicle
#------------------------------------------------------------------------------
#  This class handles vehicles. It's used within the Game_Map class. If there
# are no vehicles on the current map, the coordinates is set to (-1,-1).
#==============================================================================

class Game_Vehicle < Game_Character
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :update_ve_step_sound :update
  def update
    @no_step_sound = true
    update_ve_step_sound
  end
end