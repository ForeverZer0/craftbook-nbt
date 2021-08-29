
module CraftBook

  module NBT

    ##
    # Represents a signed 64-bit integer in the range of `-9223372036854775808` and `9223372036854775807` inclusive.
    class LongTag < ValueTag

      ##
      # The minimum permissible value for this type.
      MIN = -0x8000000000000000

      ##
      # The maximum permissible value for this type.
      MAX =  0x7FFFFFFFFFFFFFFF

      ##
      # @!attribute [rw] value
      #   @return [Numeric] the value of the tag.


      ##
      # Creates a new instance of the {LongTag} class.
      #
      # @param name [String,NilClass] The name of the tag, or `nil` when unnamed.
      # @param value [Numeric] The value of the tag.
      def initialize(name, value = 0)
        super(TYPE_LONG, name, value)
      end

      def value=(value)
        validate(value, MIN, MAX)
        @value = Integer(value)
      end

      ##
      # @return [String] the NBT tag as a formatted and human-readable string.
      def to_s
        "TAG_Long(#{@name ? "\"#{@name}\"" : 'None'}): #{@value}"
      end

      ##
      # @return [String] the NBT tag as an SNBT string.
      def stringify
        "#{snbt_prefix}#{@value}L"
      end
    end
  end
end