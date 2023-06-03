# frozen_string_literal: true

require 'blurhash/version'
require 'blurhash_ext'

module Blurhash
  def self.encode(width, height, pixels, x_comp: 4, y_comp: 3)
    p = pixels.pack("C#{pixels.size}")
    Unstable.blurHashForPixels(x_comp, y_comp, width, height, p)
  end

  # Decodes a blurhash into a matrix of pixels.
  # Returns an array of arrays of arrays,
  # This can be passed directly to MiniMagick to create an image.
  def self.decode(blurhash, width, height, punch: 1)
    raise ArgumentError, "BlurHash must be at least 6 characters long." if blurhash.length < 6

    size_flag = Base83.decode83(blurhash[0])
    size_x = (size_flag % 9) + 1
    size_y = (size_flag / 9.0).floor + 1
    size = size_x * size_y

    quant_max_value = Base83.decode83(blurhash[1])
    real_max_value = ((quant_max_value + 1).to_f / 166.0) * punch

    raise "Invalid BlurHash length." if blurhash.length != 4 + 2 * size_x * size_y

    dc_value = Base83.decode83(blurhash[2...6])

    colors = [[srgb_to_linear(dc_value >> 16), srgb_to_linear((dc_value >> 8) & 255), srgb_to_linear(dc_value & 255)]]

    (1..size).each do |component|
      ac_value = Base83.decode83(blurhash[(4 + component * 2)...(4 + (component + 1) * 2)])
      colors << [
        sign_pow(((ac_value / (19 * 19)).to_i.to_f - 9.0) / 9.0, 2.0) * real_max_value,
        sign_pow((((ac_value / 19).to_i % 19).to_f - 9.0) / 9.0, 2.0) * real_max_value,
        sign_pow(((ac_value % 19).to_f - 9.0) / 9.0, 2.0) * real_max_value
      ]
    end

    pixels = []
    height.times do |h|
      row = []
      width.times do |w|
        pixel = [0.0, 0.0, 0.0]
        size_y.times do |y|
          size_x.times do |x|
            basis = Math.cos((Math::PI * w * x) / width.to_f) * Math.cos((Math::PI * h * y) / height.to_f)
            color = colors[x + y * size_x]
            pixel[0] += color[0] * basis
            pixel[1] += color[1] * basis
            pixel[2] += color[2] * basis
          end
        end
        row << [linear_to_srgb(pixel[0]), linear_to_srgb(pixel[1]), linear_to_srgb(pixel[2])]
      end
      pixels << row
    end
    pixels
  end

  def self.srgb_to_linear(value)
    v = value.to_f / 255.0
    return v / 12.92 if v <= 0.04045

    ((v + 0.055) / 1.055)**2.4
  end

  def self.linear_to_srgb(value)
    v = [0.0, [1.0, value].min].max
    return (v * 12.92 * 255 + 0.5).to_i if v <= 0.0031308

    ((1.055 * (v**(1 / 2.4)) - 0.055) * 255 + 0.5).to_i
  end

  def self.sign(n)
    n < 0 ? -1 : 1
  end

  def self.sign_pow(val, exp)
    sign(val) * (val.abs**exp)
  end

  def self.components(str)
    size_flag = Base83.decode83(str[0])
    y_comp    = (size_flag / 9) + 1
    x_comp    = (size_flag % 9) + 1

    return if str.size != 4 + 2 * x_comp * y_comp

    [x_comp, y_comp]
  end

  module Base83
    DIGIT_CHARACTERS = %w(
      0 1 2 3 4 5 6 7 8 9
      A B C D E F G H I J
      K L M N O P Q R S T
      U V W X Y Z a b c d
      e f g h i j k l m n
      o p q r s t u v w x
      y z # $ % * + , - .
      : ; = ? @ [ ] ^ _ {
      | } ~
    ).freeze

    def self.decode83(str)
      value = 0

      str.each_char.with_index do |c, i|
        digit = DIGIT_CHARACTERS.find_index(c)
        value = value * 83 + digit
      end

      value
    end
  end

  private_constant :Unstable
end
