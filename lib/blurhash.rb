# frozen_string_literal: true

require 'blurhash/version'
require 'ffi'

module Blurhash
  def self.encode(width, height, pixels, x_comp: 4, y_comp: 3)
    FFI::MemoryPointer.new(:uint8, pixels.size) do |p|
      p.write_array_of_uint8(pixels)
      return Unstable.blurHashForPixels(x_comp, y_comp, width, height, p, width * 3)
    end
  end

  def self.components(str)
    size_flag = Base83.decode83(str[0])
    y_comp    = (size_flag / 9) + 1
    x_comp    = (size_flag % 9) + 1

    return if str.size != 4 + 2 * x_comp * y_comp

    [x_comp, y_comp]
  end

  module Unstable
    extend FFI::Library
    ffi_lib File.join(File.expand_path(File.dirname(__FILE__)), '..', 'ext', 'blurhash', 'encode.' + RbConfig::CONFIG['DLEXT'])
    attach_function :blurHashForPixels, %i(int int int int pointer size_t), :string
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
