
module CraftBook

  module NBT

    ##
    # Represents a collection of **named** tags, order not guaranteed.
    class CompoundTag < ContainerTag

      ##
      # Creates a new instance of the {CompoundTag} class.
      #
      # @param name [String,NilClass] The name of the tag, or `nil` when unnamed.
      # @param values [Array<Tag>] Zero or more values to add during initialization.
      def initialize(name, *values)
        super(TYPE_COMPOUND, name, *values)
      end

      ##
      # @return [String] the NBT tag as a formatted and human-readable string.
      def to_s
        "TAG_Compound(#{@name ? "\"#{@name}\"" : 'None'}): #{size} #{size == 1 ? 'child' : 'children'}"
      end

      ##
      # @return [String] the NBT tag as an SNBT string.
      def stringify
        "{#{snbt_prefix}{#{map(&:stringify).join(',')}}"
      end
    end
  end
end