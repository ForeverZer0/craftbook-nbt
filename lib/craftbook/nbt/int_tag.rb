
module CraftBook

  module NBT

    ##
    # Represents a signed 32-bit integer in the range of `-2147483648` to `2147483647` inclusive.
    class IntTag < ValueTag

      ##
      # The minimum permissible value for this type.
      MIN = -0x80000000

      ##
      # The maximum permissible value for this type.
      MAX =  0x7FFFFFFF

      ##
      # @!attribute [rw] value
      #   @return [Numeric] the value of the tag.

      ##
      # Creates a new instance of the {IntTag} class.
      #
      # @param name [String,NilClass] The name of the tag, or `nil` when unnamed.
      # @param value [Numeric] The value of the tag.
      def initialize(name, value = 0)
        super(TYPE_INT, name, value)
      end

      def value=(value)
        validate(value, MIN, MAX)
        @value = Integer(value)
      end

      ##
      # @return [String] the NBT tag as a formatted and human-readable string.
      def to_s
        "TAG_Int(#{@name ? "\"#{@name}\"" : 'None'}): #{@value}"
      end

      ##
      # @return [String] the NBT tag as an SNBT string.
      def stringify
        "#{snbt_prefix}#{@value}"
      end
    end
  end
end