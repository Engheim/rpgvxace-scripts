#==============================================================================
# ** Victor Engine - Sprite in Windows
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.03.22 > First relase
#  v 1.01 - 2013.02.13 > Compatibility with Animated Battle 1.21
#                      > Added method clear_all_sprites
#------------------------------------------------------------------------------
#  This script is an add on for the 'VE - Animated Battle', it's a tool for
# scripters that allows to add a animated sprite of the battler in windows.
# This script alone don't do anything, it needs the scripter to manually
# set the method that adds the animated sprite.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module'
#   Requires the script 'Victor Engine - Animated Battle'
#
# * Alias methods (Default)
#   class Window_Base < Window
#     def initialize(x, y, width, height)
#     def update
#     def dispose
#
#   class Window_MenuActor < Window_MenuStatus
#     def initialize
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow all the required scripts.
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#  To add the animated sprite, you must add the following method on the window
#  script, this isn't recomended for people without any script knowlegde.
#   draw_animated_actor(battler, x, y, dir, fade)
#     battler : the object with the battler information, it must be a valid
#       Game_Actor or Game_Enemy object.
#     x    : position x of the sprite on the window
#     y    : position y of the sprite on the window
#     dir  : string battler face direction: 'left', 'right', 'down' or 'up'
#       can be omited or nil, in that case the battler will face left. 
#     fade : fade effect when the battlers are shown, can be omited
#        if true there will be an fade effect when showing the battlers.
#
#   In windows like Window_Status, only one actor graphic is displayed
#   To avoid display bugs, it was use the method "clear_all_sprites"
#   on the refresh method of any window that have display bugs
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
  #   Get the script name base on the imported value
  #--------------------------------------------------------------------------
  def self.script_name(name, ext = "VE")
    name = name.to_s.gsub("_", " ").upcase.split
    name.collect! {|char| char == ext ? "#{char} -" : char.capitalize }
    name.join(" ")
  end
end

$imported ||= {}
$imported[:ve_sprite_in_window] = 1.01
Victor_Engine.required(:ve_sprite_in_window, :ve_basic_module, 1.00, :above)
Victor_Engine.required(:ve_sprite_in_window, :ve_animated_battle, 1.00, :above)

#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  This is a superclass of all windows in the game.
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_sprite_in_window :initialize
  def initialize(x, y, width, height)
    initialize_ve_sprite_in_window(x, y, width, height)
    @animate_battlers = {}
  end
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :update_ve_sprite_in_window :update
  def update
    update_ve_sprite_in_window
    @animate_battlers.values.each {|sprite| update_sprite(sprite) if sprite }
  end
  #--------------------------------------------------------------------------
  # * Alias method: dispose
  #--------------------------------------------------------------------------
  alias :dispose_ve_sprite_in_window :dispose
  def dispose
    dispose_ve_sprite_in_window
    @animate_battlers.values.each {|sprite| sprite.dispose if sprite }
  end
  #--------------------------------------------------------------------------
  # * New method: draw_animated_actor
  #--------------------------------------------------------------------------
  def draw_animated_actor(battler, x, y, dir = 'left', fade = nil)
    sprite = @animate_battlers[[battler.id, battler.actor?]]
    sprite.dispose if sprite && !shared_bimap(sprite)
    if !sprite || sprite.bitmap.disposed?
      viewport   = Viewport.new(0, 0, width - 32, height - 32)
      viewport.z = self.z
      sprite = Sprite_Animated_Battler.new(viewport, battler, dir, fade)
      @animate_battlers[[battler.id, battler.actor?]] = sprite
    end
    sprite.setup_position(x, y)
    update_sprite(sprite)
  end
  #--------------------------------------------------------------------------
  # * New method: clear_all_sprites
  #--------------------------------------------------------------------------
  def clear_all_sprites
    @animate_battlers.values.each {|sprite| sprite.dispose if sprite }
    @animate_battlers.clear
  end
  #--------------------------------------------------------------------------
  # * New method: update_sprite
  #--------------------------------------------------------------------------
  def update_sprite(sprite)
    sprite.update
    sprite.sprite_position(self.ox, self.oy)
    sprite.visible         = self.visible
    sprite.viewport.rect.x = self.x + 16
    sprite.viewport.rect.y = self.y + 16
  end
  #--------------------------------------------------------------------------
  # * New method: shared_bimap
  #--------------------------------------------------------------------------
  def shared_bimap(battler)
    list = @animate_battlers.values - [battler]
    list.any? {|sprite| battler.bitmap == sprite.bitmap }
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
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_sprite_in_window_menuactor :initialize
  def initialize
    initialize_ve_sprite_in_window_menuactor
    refresh
  end
end

#==============================================================================
# ** Sprite_Animated_Battler
#------------------------------------------------------------------------------
#  This sprite is used to display battlers on windows
#==============================================================================

class Sprite_Animated_Battler < Sprite_Battler
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  def initialize(viewport, battler, dir, fade)
    @fade = fade
    super(viewport, battler)
    @battler.poses.direction = setup_direction(dir)
    update
  end
  #--------------------------------------------------------------------------
  # * init_variables
  #--------------------------------------------------------------------------
  def init_variables
    @spin  = 0
    @frame = 0
    @sufix = ""
    @pose_sufix = ""
    @anim_sufix = VE_SPRITE_SUFIX
    @returning    = 0
    @frame_width  = 0
    @frame_height = 0
    @icon_list    = {}
    @throw_list   = []
    @afterimage_wait    = 0
    @afterimage_sprites = []
    if @fade
      start_effect(:appear)
    else
      self.opacity = 255
      @battler_visible = true
    end
    poses.clear_poses
    setup_positions
  end
  #--------------------------------------------------------------------------
  # * setup_position
  #--------------------------------------------------------------------------
  def setup_position(x, y)
    @x = x + 32
    @y = y + 64
  end
  #--------------------------------------------------------------------------
  # * sprite_position
  #--------------------------------------------------------------------------
  def sprite_position(ox, oy)
    self.x = @x + adjust_x - ox
    self.y = @y + adjust_y - oy
  end
  #--------------------------------------------------------------------------
  # * update_position
  #--------------------------------------------------------------------------
  def setup_direction(dir)
    case dir.downcase
    when 'down'  then 2
    when 'left'  then 4
    when 'right' then 6
    when 'up'    then 8
    else 4
    end
  end
end
