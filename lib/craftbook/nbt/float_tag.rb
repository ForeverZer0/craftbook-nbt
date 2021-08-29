
module CraftBook

  module NBT

    ##
    # Represents a IEEE-754 single-precision floating point number (NaN possible).
    class FloatTag < ValueTag

      ##
      # @!attribute [rw] value
      #   @return [Numeric] the value of the tag.

      def initialize(name, value = 0.0)
        super(TYPE_FLOAT, name, value)
      end

      def value=(value)
        @value = Float(value)
      end

      ##
      # @return [String] the NBT tag as a formatted and human-readable string.
      def to_s
        "TAG_Float(#{@name ? "\"#{@name}\"" : 'None'}): #{@value}"
      end

      ##
      # @return [String] the NBT tag as an SNBT string.
      def stringify
        "#{snbt_prefix}#{@value}F"
      end
    end
  end
end