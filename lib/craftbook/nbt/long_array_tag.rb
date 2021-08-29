
module CraftBook
  module NBT
    ##
    # cRepresents a contiguous collection of signed 64-bit integers in the range of `-9223372036854775808`
    # and `9223372036854775807` inclusive.
    class LongArrayTag < EnumerableTag

      ##
      # Creates a new instance of the {LongArrayTag} class.
      #
      # @param name [String,NilClass] The name of the tag, or `nil` when unnamed.
      # @param values [Array<Numeric>] Zero or more values to add during initialization.
      def initialize(name, *values)
        super(TYPE_LONG_ARRAY, name, *values)
      end

      ##
      # @return [Hash{Symbol => Object}] the hash-representation of this object.
      def to_h
        { name: @name, type: @type, values: @values }
      end

      ##
      # @return [String] the NBT tag as a formatted and human-readable string.
      def to_s
        "TAG_Long_Array(#{@name ? "\"#{@name}\"" : 'None'}): #{size} #{size == 1 ? 'item' : 'items'}"
      end

      ##
      # @return [String] the NBT tag as an SNBT string.
      def stringify
        "#{snbt_prefix}[L;#{to_a.join(',')}]"
      end
    end
  end
end