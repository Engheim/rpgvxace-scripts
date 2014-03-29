#==============================================================================
# ** Victor Engine - Fog and Overlay
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2011.12.19 > First release
#  v 1.01 - 2011.12.30 > Faster Regular Expressions
#  v 1.02 - 2012.01.02 > Fixed fog dispose when changing maps
#  v 1.03 - 2012.01.04 > Fixed load fail when fog ON
#  v 1.04 - 2012.01.10 > Fixed fog movement y bug
#  v 1.05 - 2012.01.14 > Fixed the positive sign on some Regular Expressions
#  v 1.06 - 2012.01.15 > Fixed the Regular Expressions problem with "" and “”
#  v 1.07 - 2012.01.15 > Fixed fog position in maps with loop
#  v 1.08 - 2012.05.21 > Compatibility with Map Turn Battle
#  v 1.09 - 2012.05.24 > Fixed initial fog position
#  v 1.10 - 2012.07.02 > Fixed initial fog position with Map Turn Battle
#  v 1.11 - 2012.08.02 > Compatibility with Basic Module 1.27
#  v 1.12 - 2012.12.13 > Fixed fog movement during battles
#------------------------------------------------------------------------------
#  This script allows to add varied of effects and overlays to the maps.
# Differently from pictures the fog follows the map movement instead of the
# screen (this behavior can be changed). You can add various fogs and/or 
# overlays to the map.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.27 or higher
# 
# * Alias methods
#   class Game_Screen
#     def initialize
#     def clear
#     def update
#
#   class Game_Map
#     def setup(map_id)
#     def scroll_down(distance)
#     def scroll_left(distance)
#     def scroll_right(distance)
#     def scroll_up(distance)
#
#   class Spriteset_Map
#     def initialize
#     def dispose
#     def update
#
#   class Game_Interpreter
#     def comment_call
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#  The images must be placed on the folder "Graphics/Fogs". Create a folder
#  named "Fogs" on the Graphics folder.
#
#------------------------------------------------------------------------------
# Maps and Comment calls note tags:
#  Tags to be used on the Maps note box in the database or in events
#  comment box, works like a script call
#
#  <fog effect>
#  settings
#  </fog effect>
#   Create a fog effect on the map, add the following values to the info
#   the ID and name must be added, other values are optional.
#     id: x      : fog ID
#     name: "x"  : fog graphic filename ("filename")
#     opacity: x : fog opacity (0-255)
#     move: x    : fog screen movement (32 = fog follows the map)
#     zoom: x    : fog zoom (100 = default size)
#     hue: x     : fog hue (0-360)
#     blend: x   : fog blend type (0: normal, 1: add, 2: subtract)
#     depth: x   : fog Z axis (300 = default value)
#
#  <fog opacity id: o, d>
#   This tag allows to change the fog opacity gradually
#     id : fog ID
#     o  : new opacity (0-255)
#     d  : wait until complete change (60 frames = 1 second)
#
#  <fog move id: x, y>
#   This tag adds fog continuous movement
#     id : fog ID
#     x  : horizontal movement, can be positive or negative
#     y  : vertical movement, can be positive or negative
#
#  <fog  tone id: r, g, b, y, d>
#   This tag allows to change the fog opacity gradually
#     id : fog ID
#     r  : red tone   (0-255, can be negative)
#     g  : green tone (0-255, can be negative)
#     b  : blue tone  (0-255, can be negative)
#     y  : gray tone  (0-255)
#     d  : wait until complete change (60 frames = 1 second)
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#   Map note tags commands are called right when enters the map, comment calls
#   are called during the event process.
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Set fogs visibility on battle
  #    When true, fogs are visible on battle
  #--------------------------------------------------------------------------
  VE_BATTLE_FOGS = true
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
$imported[:ve_fog_and_overlay] = 1.12
Victor_Engine.required(:ve_fog_and_overlay, :ve_basic_module, 1.27, :above)

#==============================================================================
# ** Cache
#------------------------------------------------------------------------------
#  This module loads each of graphics, creates a Bitmap object, and retains it.
# To speed up load times and conserve memory, this module holds the created
# Bitmap object in the internal hash, allowing the program to return
# preexisting objects when the same bitmap is requested again.
#==============================================================================

module Cache
  #--------------------------------------------------------------------------
  # * New method: fogs
  #--------------------------------------------------------------------------
  def self.fogs(filename)
    self.load_bitmap('Graphics/Fogs/', filename)
  end
end

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
  alias :setup_new_game_fog_and_overlay :setup_new_game
  def setup_new_game
    setup_new_game_fog_and_overlay
    $game_battle_fogs = VE_BATTLE_FOGS
  end
  #--------------------------------------------------------------------------
  # * Alias method: setup_battle_test
  #--------------------------------------------------------------------------
  alias :setup_battle_test_fog_and_overlay :setup_battle_test
  def setup_battle_test
    setup_battle_test_fog_and_overlay
    $game_battle_fogs = VE_BATTLE_FOGS
  end
  #--------------------------------------------------------------------------
  # * Alias method: create_game_objects
  #--------------------------------------------------------------------------
  alias :create_game_objects_fog_and_overlay :create_game_objects
  def create_game_objects
    create_game_objects_fog_and_overlay
    $game_battle_fogs = VE_BATTLE_FOGS
  end
  #--------------------------------------------------------------------------
  # * Alias method: make_save_contents
  #--------------------------------------------------------------------------
  alias :make_save_contents_fog_and_overlay  :make_save_contents
  def make_save_contents
    contents = make_save_contents_fog_and_overlay
    contents[:battle_fogs] = $game_battle_fogs
    contents
  end
  #--------------------------------------------------------------------------
  # * Alias method: extract_save_contents
  #--------------------------------------------------------------------------
  alias :extract_save_contents_fog_and_overlay :extract_save_contents
  def extract_save_contents(contents)
    extract_save_contents_fog_and_overlay(contents)
    $game_battle_fogs = contents[:battle_fogs]
  end
end

#==============================================================================
# ** Game_Screen
#------------------------------------------------------------------------------
#  This class handles screen maintenance data, such as change in color tone,
# flashes, etc. It's used within the Game_Map and Game_Troop classes.
#==============================================================================

class Game_Screen
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :fogs
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_fog_and_overlay :initialize
  def initialize
    @fogs = Game_Fogs.new
    initialize_ve_fog_and_overlay
  end
  #--------------------------------------------------------------------------
  # * Alias method: clear
  #--------------------------------------------------------------------------
  alias :clear_ve_fog_and_overlay :clear
  def clear
    clear_ve_fog_and_overlay
    clear_fogs
  end
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :update_ve_fog_and_overlay :update
  def update
    update_ve_fog_and_overlay
    update_fogs
  end
  #--------------------------------------------------------------------------
  # * New method: fogs
  #--------------------------------------------------------------------------
  def fogs
    @fogs ||= Game_Fogs.new
  end
  #--------------------------------------------------------------------------
  # * New method: clear_fogs
  #--------------------------------------------------------------------------
  def clear_fogs
    fogs.each {|fog| fog.erase }
  end
  #--------------------------------------------------------------------------
  # * New method: update_fogs
  #--------------------------------------------------------------------------
  def update_fogs
    fogs.each {|fog| fog.update }
  end
  #--------------------------------------------------------------------------
  # * New method: create_fog
  #--------------------------------------------------------------------------
  def create_fog(*args)
    fogs[args.first].show(*args)
  end
  #--------------------------------------------------------------------------
  # * New method: set_fog_move
  #--------------------------------------------------------------------------
  def set_fog_move(id, sx, sy)
    fogs[id].start_movement(sx, sy)
  end
  #--------------------------------------------------------------------------
  # * New method: set_fog_tone
  #--------------------------------------------------------------------------
  def set_fog_tone(id, red, green, blue, gray, duration = 0)
    tone = Tone.new(red, green, blue, gray)
    fogs[id].start_tone_change(tone, duration)
  end
  #--------------------------------------------------------------------------
  # * New method: set_fog_opacity
  #--------------------------------------------------------------------------
  def set_fog_opacity(id, opacity, duration = 0)
    fogs[id].start_opacity_change(opacity, duration)
  end
end

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
  attr_accessor :fog_x
  attr_accessor :fog_y
  #--------------------------------------------------------------------------
  # * Alias method: setup
  #--------------------------------------------------------------------------
  alias :setup_ve_fog_and_overlay :setup
  def setup(map_id)
    setup_ve_fog_and_overlay(map_id)
    setup_fogs_effect
  end
  #--------------------------------------------------------------------------
  # * Alias method: scroll_down
  #--------------------------------------------------------------------------
  alias :scroll_down_ve_fog_and_overlay :scroll_down
  def scroll_down(distance)
    last_y = @display_y
    scroll_down_ve_fog_and_overlay(distance)
    @fog_y += loop_vertical? ? distance : @display_y - last_y
  end
  #--------------------------------------------------------------------------
  # * Alias method: scroll_left
  #--------------------------------------------------------------------------
  alias :scroll_left_ve_fog_and_overlay :scroll_left
  def scroll_left(distance)
    last_x = @display_x
    scroll_left_ve_fog_and_overlay(distance)
    @fog_x += loop_horizontal? ? -distance : @display_x - last_x
  end
  #--------------------------------------------------------------------------
  # * Alias method: scroll_right
  #--------------------------------------------------------------------------
  alias :scroll_right_ve_fog_and_overlay :scroll_right
  def scroll_right(distance)
    last_x = @display_x
    scroll_right_ve_fog_and_overlay(distance)
    @fog_x += loop_horizontal? ? distance : @display_x - last_x
  end
  #--------------------------------------------------------------------------
  # * Alias method: scroll_up
  #--------------------------------------------------------------------------
  alias :scroll_up_ve_fog_and_overlay :scroll_up
  def scroll_up(distance)
    last_y = @display_y
    scroll_up_ve_fog_and_overlay(distance)
    @fog_y += loop_vertical? ?  -distance : @display_y - last_y
  end
  #--------------------------------------------------------------------------
  # * New method: setup_fogs_effect
  #--------------------------------------------------------------------------
  def setup_fogs_effect
    @fog_x = 0
    @fog_y = 0
    create_fog(note)
    set_fog_opacity(note)
    set_fog_move(note)
    set_fog_tone(note)
  end
  #--------------------------------------------------------------------------
  # * New method: create_fog
  #--------------------------------------------------------------------------
  def create_fog(note)
    regexp = get_all_values("FOG EFFECT")
    note.scan(regexp) { setup_fog($1) }
  end
  #--------------------------------------------------------------------------
  # * New method: set_fog_opacity
  #--------------------------------------------------------------------------
  def set_fog_opacity(note)
    regexp = /<FOG OPACITY (\d+): (\d+) *, *(\d+)>/i
    note.scan(regexp) do  |id, o, d|
      @screen.set_fog_opacity(id.to_i, o.to_i, d.to_i)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_fog_move
  #--------------------------------------------------------------------------
  def set_fog_move(note)
    regexp = /<FOG MOVE (\d+): ([+-]?\d+) *, *([+-]?\d+)>/i
    note.scan(regexp) do |id, sx, sy|
      @screen.set_fog_move(id.to_i, sx.to_i, sy.to_i)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_fog_tone
  #--------------------------------------------------------------------------
  def set_fog_tone(note)
    values = "(\\d+) *, *(\\d+) *, *(\\d+) *, *(\\d+)(?: *, *(\\d+))?"
    regexp = /<FOG TONE (\d+): #{values}>/i
    note.scan(regexp) do |i, r, g, b, a, d|
      info = [i.to_i, r.to_i, g.to_i, b.to_i, a.to_i, d ? d.to_i : 0]
      @screen.set_fog_tone(*info)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: setup_fog
  #--------------------------------------------------------------------------
  def setup_fog(info)
    id    = info =~ /ID: (\d+)/i       ? $1.to_i : 0
    name  = info =~ /NAME: #{get_filename}/i  ? $1.dup  : ""
    op    = info =~ /OPACITY: (\d+)/i  ? $1.to_i : 192
    move  = info =~ /MOVE: (\d+)/i     ? $1.to_i : 32
    zoom  = info =~ /ZOOM: (\d+)/i     ? $1.to_f : 100.0
    hue   = info =~ /HUE: (\d+)/i      ? $1.to_i : 0
    blend = info =~ /BLEND: (\d+)/i    ? $1.to_i : 0
    depth = info =~ /DEPTH: ([+-]?\d+)/i ? $1.to_i : 300
    @screen.create_fog(id, name, op, move, zoom, hue, blend, depth)
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
  alias :comment_call_ve_fog_and_overlay :comment_call
  def comment_call
    call_create_fog_effect
    comment_call_ve_fog_and_overlay
  end
  #--------------------------------------------------------------------------
  # * New method: call_create_fog_effect
  #--------------------------------------------------------------------------
  def call_create_fog_effect
    $game_map.create_fog(note)
    $game_map.set_fog_opacity(note)
    $game_map.set_fog_move(note)
    $game_map.set_fog_tone(note)
  end
end

#==============================================================================
# ** Spriteset_Map
#------------------------------------------------------------------------------
#  Esta classe reune os sprites da tela de mapa e tilesets. Esta classe é
# usada internamente pela classe Scene_Map. 
#==============================================================================

class Spriteset_Map
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_fog_and_overlay :initialize
  def initialize
    create_fogs
    initialize_ve_fog_and_overlay
  end
  #--------------------------------------------------------------------------
  # * Alias method: dispose
  #--------------------------------------------------------------------------
  alias :dispose_ve_fog_and_overlay :dispose
  def dispose
    dispose_ve_fog_and_overlay
    dispose_fogs
  end
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :update_ve_fog_and_overlay :update
  def update
    update_ve_fog_and_overlay
    update_fogs
  end
  #--------------------------------------------------------------------------
  # * New method: create_fogs
  #--------------------------------------------------------------------------
  def create_fogs
    @fog_sprites = []
  end
  #--------------------------------------------------------------------------
  # * New method: dispose_fogs
  #--------------------------------------------------------------------------
  def dispose_fogs
    if @fog_sprites
      @fog_sprites.compact.each {|sprite| sprite.dispose }
      @fog_sprites.clear
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_fogs
  #--------------------------------------------------------------------------
  def update_fogs
    $game_map.screen.fogs.each do |fog|
      @fog_sprites[fog.id] ||= Sprite_Fog.new(@viewport1, fog)
      @fog_sprites[fog.id].update
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
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_fog_and_overlay :initialize
  def initialize
    create_fogs if $game_battle_fogs
    initialize_ve_fog_and_overlay
  end
  #--------------------------------------------------------------------------
  # * Alias method: dispose
  #--------------------------------------------------------------------------
  alias :dispose_ve_fog_and_overlay :dispose
  def dispose
    dispose_fogs if $game_battle_fogs
    dispose_ve_fog_and_overlay
  end
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :update_ve_fog_and_overlay :update
  def update
    update_fogs if $game_battle_fogs
    update_ve_fog_and_overlay
  end
  #--------------------------------------------------------------------------
  # * New method: create_fogs
  #--------------------------------------------------------------------------
  def create_fogs
    @fog_sprites = []
  end
  #--------------------------------------------------------------------------
  # * New method: dispose_fogs
  #--------------------------------------------------------------------------
  def dispose_fogs
    if @fog_sprite
      $game_map.screen.fogs.clear
      @fog_sprites.compact.each {|sprite| sprite.dispose }
      @fog_sprites.clear
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_fogs
  #--------------------------------------------------------------------------
  def update_fogs
    $game_map.screen.update_fogs
    $game_map.screen.fogs.each do |fog|
      @fog_sprites[fog.id] ||= Sprite_Fog.new(@viewport1, fog)
      @fog_sprites[fog.id].update
    end
  end
end

#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
#  This class performs the map screen processing.
#==============================================================================

class Scene_Map
  #--------------------------------------------------------------------------
  # * Alias method: pre_transfer
  #--------------------------------------------------------------------------
  alias :pre_transfer_ve_fog_and_overlay :pre_transfer
  def pre_transfer
    pre_transfer_ve_fog_and_overlay
    if $game_player.new_map_id != $game_map.map_id
      @spriteset.dispose_fogs
      $game_map.screen.clear_fogs
      $game_map.screen.fogs.clear
    end
  end
end

#==============================================================================
# ** Game_Fog
#------------------------------------------------------------------------------
#  This class handles fog data. This class is used within the Game_Fogs class.
#==============================================================================

class Game_Fog
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :id
  attr_reader   :name
  attr_reader   :hue
  attr_reader   :sx
  attr_reader   :sy
  attr_reader   :ox
  attr_reader   :oy
  attr_reader   :depth
  attr_reader   :move
  attr_reader   :zoom_x
  attr_reader   :zoom_y
  attr_reader   :opacity
  attr_reader   :blend_type
  attr_reader   :tone
  #--------------------------------------------------------------------------
  # * initialize
  #--------------------------------------------------------------------------
  def initialize(id)
    @id = id
    init_basic
    init_target
    init_tone
  end
  #--------------------------------------------------------------------------
  # * init_basic
  #--------------------------------------------------------------------------
  def init_basic
    @name    = ""
    @depth   = 300
    @zoom_x  = 1.0
    @zoom_y  = 1.0
    @move    = 32
    @opacity = 255.0
    @blend_type = 1
    @sx  = 0
    @sy  = 0
    @ox  = 0
    @oy  = 0
    @hue = 0
    @opacity_duration = 0
    @tone_duration    = 0
  end
  #--------------------------------------------------------------------------
  # * init_target
  #--------------------------------------------------------------------------
  def init_target
    @target_x = @x
    @target_y = @y
    @target_zoom_x  = @zoom_x
    @target_zoom_y  = @zoom_y
    @target_opacity = @opacity
  end
  #--------------------------------------------------------------------------
  # * init_tone
  #--------------------------------------------------------------------------
  def init_tone
    @tone        = Tone.new
    @tone_target = Tone.new
    @tone_duration = 0
  end
  #--------------------------------------------------------------------------
  # * show
  #--------------------------------------------------------------------------
  def show(id, name, opacity, move, zoom, hue, blend, depth)
    @id      = id
    @name    = name
    @move    = move
    @zoom_x  = zoom.to_f
    @zoom_y  = zoom.to_f
    @depth   = depth
    @opacity = opacity.to_f
    @blend_type = blend
    @ox  = 0
    @oy  = 0
    init_target
    init_tone
  end
  #--------------------------------------------------------------------------
  # * start_movement
  #--------------------------------------------------------------------------
  def start_movement(sx, sy)
    @sx = sx
    @sy = sy
  end
  #--------------------------------------------------------------------------
  # * start_tone_change
  #--------------------------------------------------------------------------
  def start_tone_change(tone, duration)
    @tone_target   = tone.clone
    @tone_duration = [duration.to_i, 0].max
    @tone = @tone_target.clone if @tone_duration == 0
  end
  #--------------------------------------------------------------------------
  # * start_opacity_change
  #--------------------------------------------------------------------------
  def start_opacity_change(opacity, duration)
    @opacity_target   = opacity
    @opacity_duration = [duration.to_i, 0].max
    @opacity = @opacity_target if @opacity_duration == 0
  end
  #--------------------------------------------------------------------------
  # * erase
  #--------------------------------------------------------------------------
  def erase
    @name = ""
  end
  #--------------------------------------------------------------------------
  # * update
  #--------------------------------------------------------------------------
  def update
    update_move
    update_tone
    update_opacity
  end
  #--------------------------------------------------------------------------
  # * update_move
  #--------------------------------------------------------------------------
  def update_move
    @ox -= @sx / 16.0
    @oy -= @sy / 16.0
  end
  #--------------------------------------------------------------------------
  # * update_opacity
  #--------------------------------------------------------------------------
  def update_opacity
    return if @opacity_duration == 0
    d = @opacity_duration
    @opacity = (@opacity * (d - 1) + @opacity_target) / d
    @opacity_duration -= 1
  end
  #--------------------------------------------------------------------------
  # * update_tone
  #--------------------------------------------------------------------------
  def update_tone
    return if @tone_duration == 0
    d = @tone_duration
    @tone.red   = (@tone.red   * (d - 1) + @tone_target.red)   / d
    @tone.green = (@tone.green * (d - 1) + @tone_target.green) / d
    @tone.blue  = (@tone.blue  * (d - 1) + @tone_target.blue)  / d
    @tone.gray  = (@tone.gray  * (d - 1) + @tone_target.gray)  / d
    @tone_duration -= 1
  end
end

#==============================================================================
# ** Game_Fogs
#------------------------------------------------------------------------------
#  This class handles fogs. This class is used within the Game_Screen class.
#==============================================================================

class Game_Fogs
  #--------------------------------------------------------------------------
  # * initialize
  #--------------------------------------------------------------------------
  def initialize
    @data = []
  end
  #--------------------------------------------------------------------------
  # * []
  #--------------------------------------------------------------------------
  def [](number)
    @data[number] ||= Game_Fog.new(number)
  end
  #--------------------------------------------------------------------------
  # * each
  #--------------------------------------------------------------------------
  def each
    @data.compact.each {|fog| yield fog } if block_given?
  end
  #--------------------------------------------------------------------------
  # * clear
  #--------------------------------------------------------------------------
  def clear
    @data.clear
  end
end

#==============================================================================
# ** Sprite_Fog
#------------------------------------------------------------------------------
#  This sprite is used to display fgos. It observes a instance of the
# Game_Fog class and automatically changes sprite conditions.
#==============================================================================

class Sprite_Fog < Plane
  #--------------------------------------------------------------------------
  # * initialize
  #--------------------------------------------------------------------------
  def initialize(viewport, fog)
    super(viewport)
    @fog = fog
    @x = 0
    @y = 0
    $game_map.fog_x = 0
    $game_map.fog_y = 0
    @initi_ox = $game_map.display_x * 32
    @initi_oy = $game_map.display_y * 32
    update
  end
  #--------------------------------------------------------------------------
  # * dispose
  #--------------------------------------------------------------------------
  def dispose
    bitmap.dispose if bitmap
    super
  end
  #--------------------------------------------------------------------------
  # * update
  #--------------------------------------------------------------------------
  def update
    update_bitmap
    update_position
    update_zoom
    update_other
  end
  #--------------------------------------------------------------------------
  # * update bitmap
  #--------------------------------------------------------------------------
  def update_bitmap
    if @fog_name != @fog.name
      self.bitmap = Cache.fogs(@fog.name)
      @fog_name = @fog.name.dup
    end
  end
  #--------------------------------------------------------------------------
  # * update_position
  #--------------------------------------------------------------------------
  def update_position
    self.ox = $game_map.fog_x * @fog.move + @fog.ox + @initi_ox
    self.oy = $game_map.fog_y * @fog.move + @fog.oy + @initi_oy
    self.z  = @fog.depth
  end
  #--------------------------------------------------------------------------
  # * update_zoom
  #--------------------------------------------------------------------------
  def update_zoom
    self.zoom_x = @fog.zoom_x / 100.0
    self.zoom_y = @fog.zoom_y / 100.0
  end
  #--------------------------------------------------------------------------
  # * update_other
  #--------------------------------------------------------------------------
  def update_other
    self.opacity    = @fog.opacity
    self.blend_type = @fog.blend_type
    self.tone.set(@fog.tone)
  end
end