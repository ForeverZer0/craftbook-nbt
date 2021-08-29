
module CraftBook
  module NBT

    ##
    # Represents a signed 16-bit integer in the range of `-32768` to `32767` inclusive.
    class ShortTag < ValueTag

      ##
      # The minimum permissible value for this type.
      MIN = -0x8000

      ##
      # The maximum permissible value for this type.
      MAX =  0x7FFF

      ##
      # @!attribute [rw] value
      #   @return [Numeric] the value of the tag.

      ##
      # Creates a new instance of the {ShortTag} class.
      #
      # @param name [String,NilClass] The name of the tag, or `nil` when unnamed.
      # @param value [Numeric] The value of the tag.
      def initialize(name, value = 0)
        super(TYPE_SHORT, name, value)
      end

      def value=(value)
        validate(value, MIN, MAX)
        @value = Integer(value)
      end

      ##
      # @return [String] the NBT tag as a formatted and human-readable string.
      def to_s
        "TAG_Short(#{@name ? "\"#{@name}\"" : 'None'}): #{@value}"
      end

      ##
      # @return [String] the NBT tag as an SNBT string.
      def stringify
        "#{snbt_prefix}#{@value}S"
      end
    end
  end
end