require 'gosu'
require 'chipmunk'

require_relative '../utility/utility'
require_relative 'obj'

class JumpPad < Obj
  attr_accessor :angle
  def initialize(window, sizex = 50, angle = 0, color = Gosu::Color.new(255, 255, 255))
    @window = window
    @angle = angle
    @color = color
    @shapes = []
    @bodies = []
    @shape_vertices = [vec2(0, 0),
                      vec2(-20, 0),
                      vec2(-20, sizex),
                      vec2(0, sizex)]

    @image = polygon_image(@shape_vertices)
    @should_draw = false
    create_bodies
    add_shapes
    set_shapes_prop

    level_enter_animation_init
  end

  def add_shapes
    @shapes << CP::Shape::Poly.new(@bodies[0], @shape_vertices, vec2(0, 0))
  end

  def set_shapes_prop
    @shapes.each do |shape|
      shape.body.p = vec2 0.0, 0.0
      shape.body.v = vec2 0.0, 0.0
      shape.e = 1
      shape.body.a = 3 * Math::PI / 2.0 + angle / 180.0 * Math::PI
      shape.collision_type = Type::JUMP_PAD
      shape.group = Group::JUMP_PAD
      shape.layers = Layer::JUMP_PAD
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
    gc = Magick::Draw.new
    gc.stroke '#' + @color.red.to_s(16) + @color.green.to_s(16) + @color.blue.to_s(16)  + 255.to_s(16)
    gc.fill '#' + @color.red.to_s(16) + @color.green.to_s(16) + @color.blue.to_s(16)  + 255.to_s(16)
    gc.stroke_width 1
    draw_vertices = vertices.map { |v| [v.y.abs, v.x.abs] }.flatten
    gc.polygon(*draw_vertices)
    gc.draw box_image
    Gosu::Image.new @window, box_image
  end

  def draw
    if @should_draw
      @image.draw_rot @draw_param[0], @draw_param[1], 1, @draw_param[2], 0, 0, 1, 1, @draw_param[3]
    else
      level_enter_animation_init
    end
  end
end
