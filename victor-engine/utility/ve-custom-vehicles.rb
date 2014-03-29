#==============================================================================
# ** Victor Engine - Custom Vehicles
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2011.12.30 > First relase
#  v 1.01 - 2011.12.30 > Battleback2 fix
#  v 1.02 - 2012.01.08 > Added move and idle sound while riding
#  v 1.03 - 2012.01.15 > Fixed the Regular Expressions problem with "" and “”
#  v 1.04 - 2012.02.24 > Fixed update_stop error
#  v 1.05 - 2012.03.17 > Fixed floor damage while on flying custom vehicle
#                      > Improved passability blocks
#  v 1.06 - 2012.05.29 > Compatibility with Pixel Movement
#  v 1.07 - 2012.08.18 > Fixed issue with Pixel Movement and Vehicles
#------------------------------------------------------------------------------
#  This scripts allow the creation of new vehicle types with a new set of
# options available
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.09 or higher
# 
# * Overwrite methods (Default)
#   class Game_Map
#     def vehicle(type)
#
#   class Game_Player < Game_Character
#     def get_on_vehicle
#     def get_off_vehicle
#     def in_airship?
#
# * Alias methods (Default)
#   class Game_Map
#     def create_vehicles
#    
#   class Game_CharacterBase
#     def collide_with_vehicles?(x, y)
#
#   class Game_Player < Game_Character
#     def update_vehicle_get_off
#     def collide_with_characters?(x, y)
#     def encounter_progress_value
#     def map_passable?(x, y, d)
#     def on_damage_floor?
#
#   class Game_Vehicle < Game_Character
#     def land_ok?(x, y, d)
#
#   class Spriteset_Battle
#     def overworld_battleback1_name
#     def overworld_battleback2_name
#
#   class Spriteset_Map
#     def update_shadow
#
# * Alias methods (Basic Module)
#   class Game_Interpreter
#     def comment_call
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
#  <move vehicle type: id, x, y> 
#   This tag allows to move the vehicle to a specif postion in a map.
#     type : vehicle type
#     id   : map ID
#     x    : coodinate X
#     y    : coodinate Y
#
#------------------------------------------------------------------------------
# Script settings:
#  The settings works very like the note tags, except they're set on the
#  script, just add the tags between " ". Any setting here can be 
#  omitted.
#
#  <character name: x>
#    Vehicle character graphic filename. Althogh it can be omitted, by doing so
#    the vehicle will have no graphic.
#      x : character filename
#  
#  <character index: x>
#    Vehicle character index. Needed when using 8 characters charsets to set
#    wich graphic use. Not needed for single charsets (with $ in the name)
#      x : index (0-7)
#
#  <step animation>
#   This tag makes the vehicle display the "walking" animation even when
#   not moving while riding.
#
#  <character above>
#   With this tag the chacter needs to step above the vehicle to ride it.
#   Without it, you can't step above it, and must face it to ride.
#
#  <altitude x>
#   This tag will make the vehicle fly while diring the drive.
#     x : flight height
#
#  <passability: x>
#    Makes the vehicle inherit the passability settings of the player, boat,
#    ship or airship. if not set, the vehicle will have NO passability
#    beside the terrain and region passability. This only the basic setting
#    and can be changed with the terrains and regison.
#      x : type (player, boat, ship, airship)
#
#  <pass terrain: x>
#  <pass terrain: x, x>
#   Set the terrain IDs that is passable when boarding the vehicle. Any tile
#   with this terrain ID is passable unless blocked by anoterh setting.
#     x : terrain ID (0-7)
#
#  <pass region: x>
#  <pass region: x, x>
#   Set the region IDs that is passable when boarding the vehicle. Any tile
#   with this region ID is passable unless blocked by anoterh setting.
#     x : region ID (1-64)
#
#  <land terrain: x>
#  <land terrain: x, x>
#   Set the terrain IDs that is landable when boarding the vehicle. You can
#   only land o valid tiles.
#     x : terrain ID (0-7)
#
#  <land region: x>
#  <land region: x, x>
#   Set the region IDs that is passable when boarding the vehicle. You can
#   only land o valid tiles.
#     x : region ID (1-64)
#
#  <block terrain: x>
#  <block terrain: x, x>
#   Set the terrain IDs that is blocked when boarding the vehicle, this
#   setting have priority over passablity and landing.
#     x : terrain ID (0-7)
#
#  <block region: x>
#  <block region: x, x>
#   Set the region IDs that is blocked when boarding the vehicle, this
#   setting have priority over passablity and landing.
#     x : region ID (1-64)
#
#  <speed: x>
#   Character movement speed when driving the vehicle
#     x : speed (1-6)
#
#  <init map: x> 
#   Inital map where the vehicle will be at the start of a new game.
#   You must also set the <init pos: x, y> .
#     x : map ID
#
#  <init pos: x, y> 
#   Inital map coodinate X and Y where the vehicle will be at the start of
#   a new game. You must also set the <init map: x> .
#     x : map coodinate X
#     y : map coodinate Y
#
#  <music: 'name', x, y>
#   Set the music played when riding the vehicle.
#     name : BGM filename. ('filename')
#
#  <battleback 1: x>
#   Set a specicf floor battleback when riding the vehicle
#     x : battleback filename
#
#  <battleback 2: x>
#   Set a specicf backgroun battleback when riding the vehicle
#     x : battleback filename
#
#  <encounter rate: x%>
#   Change the encounter rate when riding the vehicle in a % value.
#   100% normal encounter rate, 0% no encounter.
#     x : encounter rate modifier
#
#  <idle sound: x, y, z, w>
#   Plays the sound effect continuously while ilde on vehicle.
#     x : sound effect filename ("filename")
#     y : sound effect volume (0-100, default = 100)
#     z : sound effect pitch (50-150, default = 100)
#     w : sound replay wait (numeric, the higher, the slower)
#
#  <move sound: x, y, z, w>
#   Plays the sound effect continuously while moving on vehicle.
#     x : sound effect filename ("filename")
#     y : sound effect volume (0-100, default = 100)
#     z : sound effect pitch (50-150, default = 100)
#     w : sound replay wait (numeric, the higher, the slower)
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#  The names boat, ship, airship and walk are reserved for the default 
#  setting and can't be set as a vehicle type name. 
# 
#  Remember that the terrain condition must always be met, if not set it's 
#  considered 0 . the region setting is ignored if not set, but if set,
#  both region and terrain must met the settings.
#  The default terrain and region is 0.
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * VEHICLE SETTINGS
  #   You can add here the settings for the custom vehicles following this
  #   pattern:
  #     name: "<setting> <setting>",
  #      Don't forget the dots after name (name:) and the coma (,) in the end.
  #--------------------------------------------------------------------------
  VE_VEHICLE_SETTING = {
    # The horse is a fast mount, while on it the chance of encounter is lowered
    # but it doesn't enter into forests.
    horse: "<speed: 5> <init map: 1> <init pos: 12, 3>
            <character name: Animal> <character index: 5>
            <music: 'Scene4', 100, 100> <passability: player>
            <block region: 1> <encounter rate: 25>",
            
    # The ballon can only land in forests and can't fly above deserts and
    # tundras. The battleback is changed 
    ballon: "<speed: 5> <init map: 6> <init pos: 11, 5>
             <character name: Vehicle> <character index: 2>
             <music: 'Scene4', 100, 100> <altitude: 24>
             <land region: 1> <pass terrain: 0> 
             <block region: 2, 3> <encounter rate: 50>
             <battleback 1: Clouds> <battleback 2: Clouds>
             <idle sound: 'Evasion1', 50, 100>
             <move sound: 'Evasion1', 50, 100>",
  } # Don't remove
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
$imported[:ve_custom_vehicles] = 1.07
Victor_Engine.required(:ve_custom_vehicles, :ve_basic_module, 1.09, :above)
Victor_Engine.required(:ve_custom_vehicles, :ve_pixel_movement, 1.00, :bellow)

#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  This class handles maps. It includes scrolling and passage determination
# functions. The instance of this class is referenced by $game_map.
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # * Overwrite method: vehicle
  #--------------------------------------------------------------------------
  def vehicle(type)
    @vehicles.each {|vehicle| return vehicle if vehicle.type == type }
    return nil
  end
  #--------------------------------------------------------------------------
  # * Alias method: create_vehicles
  #--------------------------------------------------------------------------
  alias :create_vehicles_ve_custom_vehicles :create_vehicles
  def create_vehicles
    create_vehicles_ve_custom_vehicles
    VE_VEHICLE_SETTING.keys.each do |type|
      next if [:boat, :ship, :airship, :walk].include?(type)
      @vehicles.push(Game_Custom_Vehicle.new(type))
    end
  end
  #--------------------------------------------------------------------------
  # * New method: land_vehicles
  #--------------------------------------------------------------------------
  def land_vehicles
    @vehicles.select {|vehicle| !vehicle.above? }.collect {|vehicle| vehicle }
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
  # * Alias method: collide_with_vehicles?
  #--------------------------------------------------------------------------
  alias :collide_with_vehicles_ve_custom_vehicles? :collide_with_vehicles?
  def collide_with_vehicles?(x, y)
    collision = collide_with_vehicles_ve_custom_vehicles?(x, y)
    $game_map.land_vehicles.each do |obj|
      collision |= obj.pos_nt?(x, y) unless obj == self
    end
    collision
  end
  #--------------------------------------------------------------------------
  # * New method: above_vehicles?
  #--------------------------------------------------------------------------
  def above_vehicles?(x, y, vehicle)
    collision = false
    $game_map.vehicles.each do |obj|
      collision |= obj.pos_nt?(x, y) if vehicle != obj
    end
    collision
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
  attr_reader   :stop_count
  attr_reader   :vehicle_type
  #--------------------------------------------------------------------------
  # * Overwrite method: get_on_vehicle
  #--------------------------------------------------------------------------
  def get_on_vehicle
    setup_vehicle
    enter_vehicle if vehicle
    @vehicle_getting_on
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: get_off_vehicle
  #--------------------------------------------------------------------------
  def get_off_vehicle
    if vehicle.land_ok?(@x, @y, @direction)
      set_direction(2) if in_airship?
      @followers.synchronize(@x, @y, @direction)
      vehicle.get_off
      @getting_off = !in_airship?
      @vehicle_getting_off = true
      @move_speed = 4
      make_encounter_count
    end
    @vehicle_getting_off
  end  
  #--------------------------------------------------------------------------
  # * Overwrite method: in_airship?
  #--------------------------------------------------------------------------
  def in_airship?
    vehicle && vehicle.above?
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_vehicle_get_off
  #--------------------------------------------------------------------------
  alias :update_vehicle_get_off_ve_custom_vehicles :update_vehicle_get_off
  def update_vehicle_get_off
    if vehicle.altitude == 0 and @getting_off
      force_move_forward
      @transparent = false
      @followers.gather
      @getting_off = false
      @through = $imported[:ve_pixel_movement]
    end
    update_vehicle_get_off_ve_custom_vehicles
  end
  #--------------------------------------------------------------------------
  # * Alias method: collide_with_characters?
  #--------------------------------------------------------------------------
  alias :collide_with_characters_ve_custom_vehicles? :collide_with_characters?
  def collide_with_characters?(x, y)
    return false if vehicle && vehicle.is_custom? && !vehicle.pass_type
    collide_with_characters_ve_custom_vehicles?(x, y)
  end
  #--------------------------------------------------------------------------
  # * Alias method: encounter_progress_value
  #--------------------------------------------------------------------------
  alias :encounter_progress_value_ve_custom_vehicles :encounter_progress_value
  def encounter_progress_value
    value = encounter_progress_value_ve_custom_vehicles
    value *= vehicle.encounter_rate if vehicle && vehicle.is_custom?
    value
  end
  #--------------------------------------------------------------------------
  # * Alias method: map_passable?
  #--------------------------------------------------------------------------
  alias :map_passable_ve_custom_vehicles? :map_passable?
  def map_passable?(x, y, d)
    if vehicle && vehicle.is_custom?
      passable_vehicles?(x, y, d)
    else
      map_passable_ve_custom_vehicles?(x, y, d)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: on_damage_floor?
  #--------------------------------------------------------------------------
  alias :on_damage_floor_ve_custom_vehicles? :on_damage_floor?
  def on_damage_floor?
    on_damage_floor_ve_custom_vehicles? && !aerial?
  end
  #--------------------------------------------------------------------------
  # * New method: aerial?
  #--------------------------------------------------------------------------
  def aerial?
    vehicle && vehicle.aerial?
  end
  #--------------------------------------------------------------------------
  # * New method: passable_vehicles?
  #--------------------------------------------------------------------------
  def passable_vehicles?(x, y, d)
    case vehicle.pass_type
    when :player
      map_passable_ve_custom_vehicles?(x, y, d) && pass_terrain?(x, y, d)
    when :boat
      $game_map.boat_passable?(x, y) && pass_terrain?(x, y, d)
    when :ship
      $game_map.ship_passable?(x, y)
    else
      pass_terrain?(x, y, d)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: pass_terrain?
  #--------------------------------------------------------------------------
  def pass_terrain?(x, y, d)
    x2 = $game_map.round_x_with_direction(x, d)
    y2 = $game_map.round_y_with_direction(y, d)
    valid     = $game_map.valid?(x2, y2)
    passable  = vehicle.pass_terrain?(x2, y2)
    collision = vehicle.vehicle_collision?(x2, y2)
    block     = vehicle.block_terrain?(x2, y2)
    valid && passable && !collision && !block
  end
  #--------------------------------------------------------------------------
  # * New method: get_on_vehicle
  #--------------------------------------------------------------------------
  def setup_vehicle
    x = $game_map.round_x_with_direction(@x, @direction)
    y = $game_map.round_y_with_direction(@y, @direction)
    $game_map.vehicles.compact.each do |object|
      if (object.above? && object.pos?(@x, @y) ||
         !object.above? && object.pos?(x, y))
        @vehicle_type = object.type 
      end
      break if vehicle
    end
  end
  #--------------------------------------------------------------------------
  # * New method: get_on_vehicle
  #--------------------------------------------------------------------------
  def enter_vehicle
    @vehicle_getting_on = true
    force_move_forward unless in_airship?
    @through = $imported[:ve_pixel_movement]
    @followers.gather
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
  # * Alias method: land_ok?
  #--------------------------------------------------------------------------
  alias :land_ok_ve_custom_vehicles? :land_ok?
  def land_ok?(x, y, d)
    return false if above_vehicles?(x, y, self)
    return land_ok_ve_custom_vehicles?(x, y, d)
  end
  #--------------------------------------------------------------------------
  # * New method: enter_vechicle?
  #--------------------------------------------------------------------------
  def enter_vechicle?(x, y, x2, y2, d)
    (above? && pos?(x2, y2)) || (!above? && pos?(x, y))
  end
  #--------------------------------------------------------------------------
  # * New method: is_custom?
  #--------------------------------------------------------------------------
  def is_custom?
    return false
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
  alias :comment_call_ve_custom_vehicles :comment_call
  def comment_call
    comment_call_ve_custom_vehicles
    call_change_vehicle_position
  end  
  #--------------------------------------------------------------------------
  # * New method: call_change_vehicle_position
  #--------------------------------------------------------------------------
  def call_change_vehicle_position
    regexp = /<MOVE VEHICLE (\w+): (\d+) *, *(\d+) *, *(\d+)>/i
    note.scan(regexp) do |type, id, x, y|
      symbol = eval(":#{type}")
      $game_map.vehicle(symbol).set_location(id.to_i, x.to_i, y.to_i)
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
  # * Alias method: overworld_battleback1_name
  #--------------------------------------------------------------------------
  alias :overworld_battleback1_ve_custom_vehicles :overworld_battleback1_name
  def overworld_battleback1_name
    battleback1 = overworld_battleback1_ve_custom_vehicles
    vehicle_battleback1 ? vehicle_battleback1 : battleback1
  end
  #--------------------------------------------------------------------------
  # * Alias method: overworld_battleback2_name
  #--------------------------------------------------------------------------
  alias :overworld_battleback2_ve_custom_vehicles :overworld_battleback2_name
  def overworld_battleback2_name
    battleback2 = overworld_battleback2_ve_custom_vehicles
    vehicle_battleback2 ? vehicle_battleback2 : battleback2
  end
  #--------------------------------------------------------------------------
  # * New method: vehicle_battleback1
  #--------------------------------------------------------------------------
  def vehicle_battleback1
    return nil unless $game_player.vehicle && $game_player.vehicle.is_custom?
    $game_player.vehicle.vehicle_battleback1_name
  end
  #--------------------------------------------------------------------------
  # * New method: vehicle_battleback2
  #--------------------------------------------------------------------------
  def vehicle_battleback2
    return nil unless $game_player.vehicle && $game_player.vehicle.is_custom?
    $game_player.vehicle.vehicle_battleback2_name
  end
end

#==============================================================================
# ** Spriteset_Map
#------------------------------------------------------------------------------
#  This class brings together map screen sprites, tilemaps, etc. It's used
# within the Scene_Map class.
#==============================================================================

class Spriteset_Map
  #--------------------------------------------------------------------------
  # * Alias method: update_shadow
  #--------------------------------------------------------------------------
  alias :update_shadow_ve_custom_vehicles :update_shadow
  def update_shadow
    if $game_player.vehicle && $game_player.vehicle.aerial? 
      airship = $game_player.vehicle
      @shadow_sprite.x = airship.screen_x
      @shadow_sprite.y = airship.screen_y + airship.altitude
      @shadow_sprite.opacity = airship.altitude * 8
      @shadow_sprite.update
    else
      update_shadow_ve_custom_vehicles
    end
  end
end

#==============================================================================
# ** Game_Custom_Vehicle
#------------------------------------------------------------------------------
#  This class handles custom vehicles. It's used within the Game_Map class. 
# If there are no vehicles on the current map, the coordinates is set to 
# (-1,-1).
#==============================================================================

class Game_Custom_Vehicle < Game_Vehicle
  #--------------------------------------------------------------------------
  # * initialize
  #--------------------------------------------------------------------------
  def initialize(type)
    @note = VE_VEHICLE_SETTING[type].dup
    super(type)
  end
  #--------------------------------------------------------------------------
  # * note
  #--------------------------------------------------------------------------
  def note
    @note
  end
  #--------------------------------------------------------------------------
  # * is_custom?
  #--------------------------------------------------------------------------
  def is_custom?
    return true
  end
  #--------------------------------------------------------------------------
  # * update
  #--------------------------------------------------------------------------
  def update
    super
    @stop_count = $game_player.stop_count if $game_player.vehicle_type == type
    update_airship_altitude if max_altitude > 0
    update_move_sound
  end
  #--------------------------------------------------------------------------
  # * update_move
  #--------------------------------------------------------------------------
  def update_move
    super
    update_move_sound
  end
  #--------------------------------------------------------------------------
  # * update_stop
  #--------------------------------------------------------------------------
  def update_stop
    super
    update_idle_sound if @stop_count > 1 || @locked
  end
  #--------------------------------------------------------------------------
  # * update_move_sound
  #--------------------------------------------------------------------------
  def update_move_sound
    return unless @move_sound && @driving && $game_player.moving?
    @idle_sound_update = 0
    @move_sound_update ||= 0
    @move_sound[:sound].play if @move_sound_update == 0
    @move_sound_update += 5
    @move_sound_update = 0 if @move_sound_update > [@move_sound[:wait], 60].max
  end
  #--------------------------------------------------------------------------
  # * update_idle_sound
  #--------------------------------------------------------------------------
  def update_idle_sound
    return unless @idle_sound && @driving && !$game_player.moving?
    @move_sound_update = 0
    @idle_sound_update ||= 0
    @idle_sound[:sound].play if @idle_sound_update == 0
    @idle_sound_update += 10
    @idle_sound_update = 0 if @idle_sound_update > [@idle_sound[:wait], 60].max
  end
  #--------------------------------------------------------------------------
  # * init_move_speed
  #--------------------------------------------------------------------------
  def init_move_speed
    @move_speed = note =~ /SPEED: (\d+)/i ? $1.to_i : 4
  end
  #--------------------------------------------------------------------------
  # * load_system_settings
  #--------------------------------------------------------------------------
  def load_system_settings
    init_position
    @max_altitude    = note =~ /<ALTITUDE: (\d+)>/i     ? $1.to_i : 0
    @character_name  = note =~ /<CHARACTER NAME: ([^><]*)>/i ? $1 : ""
    @character_index = note =~ /<CHARACTER INDEX: (\d+)>/i ? $1.to_i : 0
    @character_above = note =~ /<CHARACTER ABOVE>/i
    @step_animation  = note =~ /<STEP ANIMATION>/i
    @land_terrain  = get_value_list(/<LAND TERRAIN: ((?:\d+,? *)+)>/i)
    @land_regions  = get_value_list(/<LAND REGION: ((?:\d+,? *)+)>/i)
    @pass_terrain  = get_value_list(/<PASS TERRAIN: ((?:\d+,? *)+)>/i)
    @pass_regions  = get_value_list(/<PASS REGION: ((?:\d+,? *)+)>/i)
    @block_terrain = get_value_list(/<BLOCK TERRAIN: ((?:\d+,? *)+)>/i)
    @block_regions = get_value_list(/<BLOCK REGION: ((?:\d+,? *)+)>/i)
    @battleback1  = note =~ /<BATTLEBACK 1: ([^><]*)>/i ? $1 : nil
    @battleback2  = note =~ /<BATTLEBACK 2: ([^><]*)>/i ? $1 : nil
    @encounter    = note =~ /<ENCOUNTER RATE: (\d+)\%?>/i ? $1.to_i : 100
    @pass_type    = set_passability_type
    @idle_sound = set_vehicle_sound("IDLE")
    @move_sound = set_vehicle_sound("MOVE")
  end
  #--------------------------------------------------------------------------
  # * init_position
  #--------------------------------------------------------------------------
  def init_position
    return unless $game_map
    @map_id = note =~ /<INIT MAP: (\d+)>/i ? $1.to_i : 4
    @x = @y = -1
    @x, @y  = $1.to_i, $2.to_i if note =~ /<INIT POS: (\d+) *, *(\d+)>/i
  end
  #--------------------------------------------------------------------------
  # * get_value_list
  #--------------------------------------------------------------------------
  def get_value_list(regexp)
    list = []
    $1.scan(/(\d+)/i) {list.push($1.to_i)} if note =~ regexp
    list
  end
  #--------------------------------------------------------------------------
  # * set_passability_type
  #--------------------------------------------------------------------------
  def set_passability_type
    note =~ /<PASSABILITY: (\w+)>/i ? eval(":#{$1.downcase}") : nil
  end
  #--------------------------------------------------------------------------
  # * set_vehicle_sound
  #--------------------------------------------------------------------------
  def set_vehicle_sound(type)
    value = " *,? *(\d+)? *,? *(\d+)? *,? *(\d+)?"
    if note =~ /<#{type} SOUND: #{get_filename}#{value}>/im
      se = RPG::SE.new($1.to_s, $2 ? $2.to_i : 100, $3 ? $3.to_i : 100)
      sound = {sound: se, wait: $4 ? $4.to_i : 20}
    end
    sound
  end
  #--------------------------------------------------------------------------
  # * refresh
  #--------------------------------------------------------------------------
  def refresh
    super
    @priority_type = 0 if @character_above && !@driving
    @priority_type = 2 if @max_altitude > 0 && @driving
    @step_anime = @step_animation
  end
  #--------------------------------------------------------------------------
  # * get_on
  #--------------------------------------------------------------------------
  def get_on
    @driving = true
    @walk_anime = true
    @step_anime = @step_animation
    @walking_bgm = RPG::BGM.last
    if note =~ /<MUSIC: #{get_filename}(?:, *(\d+) *, *(\d+))?>/i
      bgm = RPG::BGM.new($1.to_s, $2 ? $2.to_i : 100, $3 ? $3.to_i : 100)
      bgm.play
    end
  end
  #--------------------------------------------------------------------------
  # * pass_type
  #--------------------------------------------------------------------------
  def pass_type
    @pass_type
  end
  #--------------------------------------------------------------------------
  # * max_altitude
  #--------------------------------------------------------------------------
  def max_altitude
    @max_altitude
  end
  #--------------------------------------------------------------------------
  # * aerial?
  #--------------------------------------------------------------------------
  def aerial?
    max_altitude > 0
  end 
  #--------------------------------------------------------------------------
  # * above?
  #--------------------------------------------------------------------------
  def above?
    @character_above
  end
  #--------------------------------------------------------------------------
  # * encounter_rate
  #--------------------------------------------------------------------------
  def encounter_rate
    @encounter / 100.0
  end
  #--------------------------------------------------------------------------
  # * movable?
  #--------------------------------------------------------------------------
  def movable?
    !moving? && !(@altitude < max_altitude)
  end
  #--------------------------------------------------------------------------
  # * land_ok?
  #--------------------------------------------------------------------------
  def land_ok?(x, y, d)
    x2 = $game_map.round_x_with_direction(x, d)
    y2 = $game_map.round_y_with_direction(y, d)
    return false if !$game_map.valid?(x2, y2)
    return false if not_landable?(x, y, d)
    return false if above_vehicles?(x, y, self)
    return true  if @character_above
    return false if !$game_map.passable?(x, y, reverse_dir(d))
    return false if !$game_map.passable?(x2, y2, d)
    return true
  end
  #--------------------------------------------------------------------------
  # * not_landable?
  #--------------------------------------------------------------------------
  def not_landable?(x, y, d)
    block_terrain?(x, y) || collide_with_characters?(x, y) ||
    !land_terrain?(x, y)
  end
  #--------------------------------------------------------------------------
  # * vehicle_collision?
  #--------------------------------------------------------------------------
  def vehicle_collision?(x, y)
    return false if aerial?  
    return true  if collide_with_characters?(x, y)
    return false
  end
  #--------------------------------------------------------------------------
  # * terrain_tag
  #--------------------------------------------------------------------------
  def terrain_tag(x, y)
    $game_map.terrain_tag(x, y)
  end
  #--------------------------------------------------------------------------
  # * region_id
  #--------------------------------------------------------------------------
  def region_id(x, y)
    $game_map.region_id(x, y)
  end
  #--------------------------------------------------------------------------
  # * land_terrain?
  #--------------------------------------------------------------------------
  def land_terrain?(x, y)
    (@land_terrain.include?(terrain_tag(x, y)) || @land_terrain.empty?) &&
    (@land_regions.include?(region_id(x, y))   || @land_regions.empty?)
  end
  #--------------------------------------------------------------------------
  # * pass_terrain?
  #--------------------------------------------------------------------------
  def pass_terrain?(x, y)
    (@pass_terrain.include?(terrain_tag(x, y)) || @pass_terrain.empty?) &&
    (@pass_regions.include?(region_id(x, y)) ||   @pass_regions.empty?)
  end
  #--------------------------------------------------------------------------
  # * block_terrain
  #--------------------------------------------------------------------------
  def block_terrain?(x, y)
    @block_terrain.include?(terrain_tag(x, y)) ||
    @block_regions.include?(region_id(x, y))
  end
  #--------------------------------------------------------------------------
  # * vehicle_battleback1_name
  #--------------------------------------------------------------------------
  def vehicle_battleback1_name
    @battleback1
  end
  #--------------------------------------------------------------------------
  # * vehicle_battleback2_name
  #--------------------------------------------------------------------------
  def vehicle_battleback2_name
    @battleback2
  end
end