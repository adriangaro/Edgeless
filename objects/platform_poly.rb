require 'gosu'
require 'chipmunk'
require 'RMagick'
require 'rubygems'

require_relative '../utility/utility'
require_relative 'obj'

class PlatformPoly < Obj
  def initialize(window, vertices)
    @window = window
    @shapes = []
    @bodies = []
    @image = polygon_image(vertices)
    @vertices = vertices
    @should_draw = true

    create_bodies
    add_shapes
    set_shapes_prop
  end

  def add_shapes
    @shapes << CP::Shape::Poly.new(@bodies[0], @vertices, vec2(0, 0))
  end

  def set_shapes_prop
    @shapes.each do |shape|
      shape.body.p = vec2 0.0, 0.0
      shape.body.v = vec2 0.0, 0.0
      shape.e = 0
      shape.body.a = 3 * Math::PI / 2.0
      shape.collision_type = Type::PLATFORM
      shape.group = Group::PLATFORM
      shape.layers = Layer::PLATFORM
    end
  end

  def create_bodies
    @bodies << CP::Body.new(Float::INFINITY, Float::INFINITY)
  end

  def polygon_image(vertices)
    maxx = vertices.map { |v| v.x.abs }.max
    maxy = vertices.map { |v| v.y.abs }.max
    box_image = Magick::Image.new(maxy + 1,
                                  maxx + 1) { self.background_color = 'transparent' }
    d = Magick::Draw.new
    d.stroke '#7171aa'
    d.fill '#7171aa'
    draw_vertices = vertices.map { |v| [v.y, v.x.abs] }.flatten
    d.polygon(*draw_vertices)
    d.draw box_image
    Gosu::Image.new @window, box_image
  end

  def draw(offsetx, offsety)
    if(@should_draw)
      offsetsx = [offsetx]
      offsetsy = [offsety]
      offsetsy << level_enter_animation_do
      x = @bodies[0].p.x - draw_offsets(offsetsx, offsetsy).x
      y = @bodies[0].p.y - draw_offsets(offsetsx, offsetsy).y
      a = @bodies[0].a.radians_to_gosu
      @image.draw_rot(x, y, 1, a, 0, 0, 1, 1, Gosu::Color.new(@fade_in_level, 255, 255, 255))
    else
      level_enter_animation_init
    end
  end
end
