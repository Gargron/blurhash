# frozen_string_literal: true

require 'blurhash/version'
require 'ffi'

module Blurhash
  def self.encode(width, height, pixels, x_comp: 4, y_comp: 3)
    FFI::MemoryPointer.new(:u_int8_t, pixels.size) do |p|
      p.write_array_of_uint8(pixels)
      return Unstable.blurHashForPixels(x_comp, y_comp, width, height, p, width * 3)
    end
  end

  module Unstable
    extend FFI::Library
    ffi_lib File.join(File.expand_path(__dir__), 'blurhash', 'encode.' + RbConfig::CONFIG['DLEXT'])
    attach_function :blurHashForPixels, %i(int int int int pointer size_t), :string
  end

  private_constant :Unstable
end
