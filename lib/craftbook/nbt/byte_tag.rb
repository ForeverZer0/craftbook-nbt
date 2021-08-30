
module CraftBook

  module NBT

    ##
    # A tag type representing an 8-bit signed integer in the range of `-128` and `127` inclusive.
    class ByteTag < ValueTag

      ##
      # The minimum permissible value for this type.
      MIN = -0x80

      ##
      # The maximum permissible value for this type.
      MAX =  0x7F

      ##
      # @!attribute [rw] value
      #   The value of the tag. Values of `true` and `false` will be converted to `1` and `0` respectfully.
      #   @return [Numeric,Boolean] the value of the tag.

      ##
      # Creates a new instance of the {DoubleTag} class.
      #
      # @param name [String,NilClass] The name of the tag, or `nil` when unnamed.
      # @param value [Numeric,Boolean] The value of the tag.
      #
      # @note Values of `true` and `false` will be converted to `1` and `0` respectfully.
      def initialize(name, value = 0)
        super(TYPE_BYTE, name, value)
      end

      def value=(value)
        @value = case value
        when TrueClass then 1
        when FalseClass then 0
        else validate(value, MIN, MAX)
        end
      end

      ##
      # @return [Boolean] the value of the tag as boolean.
      def bool
        @value != 0
      end

      ##
      # @return [String] the NBT tag as a formatted and human-readable string.
      def to_s
        "TAG_Byte(#{@name ? "\"#{@name}\"" : 'None'}): #{@value}"
      end

      ##
      # @return [String] the NBT tag as an SNBT string.
      def stringify
        "#{snbt_prefix}#{@value}B"
      end
    end
  end
end