
module CraftBook

  module NBT

    ##
    # Represents a IEEE-754 double-precision floating point number (NaN possible).
    class DoubleTag < ValueTag

      ##
      # @!attribute [rw] value
      #   @return [Numeric] the value of the tag.

      ##
      # Creates a new instance of the {DoubleTag} class.
      #
      # @param name [String,NilClass] The name of the tag, or `nil` when unnamed.
      # @param value [Numeric] The value of the tag.
      def initialize(name, value = 0.0)
        super(TYPE_DOUBLE, name, value)
      end

      def value=(value)
        @value = Float(value)
      end

      ##
      # @return [String] the NBT tag as a formatted and human-readable string.
      def to_s
        "TAG_Double(#{@name ? "\"#{@name}\"" : 'None'}): #{@value}"
      end

      ##
      # @return [String] the NBT tag as an SNBT string.
      def stringify
        "#{snbt_prefix}#{@value}"
      end
    end
  end
end