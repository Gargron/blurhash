module Blurhash
  # :stopdoc:
  module Ruby
    class ThreeDArray
      def initialize(y, x, z)
        @y = y
        @x = x
        @z = z
        @list = Array.new(y * x * z)
      end

      def set(y, x, z, val)
        i = z + (x * @z) + (y * @z * @x)
        @list[i] = val
      end

      def get(y, x, z)
        i = z + (x * @z) + (y * @z * @x)
        @list[i]
      end

      def [](i)
        @list.fetch(i)
      end
    end

    class Buffer
      attr_reader :pos

      def initialize(size)
        @pos = 0
        @buf = "\0".b * size
      end

      def putc(c)
        @buf.setbyte(@pos, c)
        @pos += 1
      end

      def [](from, len)
        @buf[from, len]
      end
    end

    CHARACTERS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz#$%*+,-.:;=?@[]^_{|}~".bytes

    def self.sRGBToLinear(value)
      v = value.to_f / 255
      if v <= 0.04045
        v / 12.92
      else
        ((v + 0.055) / 1.055) ** 2.4
      end
    end

    def self.multiplyBasisFunction(xComponent, yComponent, width, height, rgb, bytesPerRow, factors)
      r = g = b = 0.0
      normalisation = (xComponent == 0 && yComponent == 0) ? 1 : 2

      height.times do |y|
        y_coef = Math.cos(Math::PI * yComponent * y / height)

        width.times do |x|
          basis = Math.cos(Math::PI * xComponent * x / width) * y_coef

          r += basis * sRGBToLinear(rgb[3 * x + 0 + y * bytesPerRow]);
          g += basis * sRGBToLinear(rgb[3 * x + 1 + y * bytesPerRow]);
          b += basis * sRGBToLinear(rgb[3 * x + 2 + y * bytesPerRow]);
        end
      end

      scale = normalisation.to_f / (width * height)
      factors.set(yComponent, xComponent, 0, r * scale)
      factors.set(yComponent, xComponent, 1, g * scale)
      factors.set(yComponent, xComponent, 2, b * scale)
    end


    def self.encode_int(value, length, destination)
      divisor = 83 ** (length - 1)

      length.times do |i|
        digit = (value / divisor) % 83
        divisor /= 83
        destination.putc CHARACTERS[digit]
      end
    end

    def self.linearTosRGB(value)
      v = max(0, min(1, value))
      if v <= 0.0031308
        (v * 12.92 * 255 + 0.5).to_i
      else
        ((1.055 * (v ** (1 / 2.4)) - 0.055) * 255 + 0.5).to_i
      end
    end

    def self.encodeDC(r, g, b)
      roundedR = linearTosRGB(r)
      roundedG = linearTosRGB(g)
      roundedB = linearTosRGB(b)
      (roundedR << 16) + (roundedG << 8) + roundedB
    end

    def self.max(a, b)
      [a, b].max
    end

    def self.min(a, b)
      [a, b].min
    end

    def self.signPow(value, exp)
      pow = value.abs ** exp
      value < 0 ? -pow : pow
    end

    def self.encodeAC(r, g, b, maximumValue)
      quantR = max(0, min(18, (signPow(r / maximumValue, 0.5) * 9 + 9.5).floor))
      quantG = max(0, min(18, (signPow(g / maximumValue, 0.5) * 9 + 9.5).floor))
      quantB = max(0, min(18, (signPow(b / maximumValue, 0.5) * 9 + 9.5).floor))

      quantR * 19 * 19 + quantG * 19 + quantB;
    end

    def blurHashForPixels(xComponents, yComponents, width, height, rgb, bytesPerRow)
      return if xComponents < 1 || xComponents > 9
      return if yComponents < 1 || yComponents > 9

      factors = ThreeDArray.new(yComponents, xComponents, 3)
      ptr = Buffer.new(2 + 4 + (9 * 9 - 1) * 2 + 1)

      yComponents.times do |y|
        xComponents.times do |x|
          multiplyBasisFunction(x, y, width, height, rgb, bytesPerRow, factors)
        end
      end

      acCount = xComponents * yComponents - 1
      sizeFlag = (xComponents - 1) + (yComponents - 1) * 9
      encode_int(sizeFlag, 1, ptr)

      if acCount > 0
        actualMaximumValue = 0.0
        (acCount * 3).times do |i|
          actualMaximumValue = max(actualMaximumValue, factors[i + 3].abs)
        end
        quantisedMaximumValue = max(0, min(82, (actualMaximumValue * 166 - 0.5).floor))
        maximumValue = (quantisedMaximumValue.to_f + 1) / 166
        encode_int(quantisedMaximumValue, 1, ptr)
      else
        maximumValue = 1;
        encode_int(0, 1, ptr)
      end

      encode_int(encodeDC(factors[0], factors[1], factors[2]), 4, ptr)

      acCount.times do |i|
        encode_int(
          encodeAC(factors[i * 3 + 3], factors[i * 3 + 4], factors[i * 3 + 5], maximumValue),
          2,
          ptr)
      end

      ptr[0, ptr.pos]
    end
    module_function :blurHashForPixels
  end
  # :startdoc:
end
