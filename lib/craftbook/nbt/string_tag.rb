
module CraftBook

  module NBT

    ##
    # Represents a UTF-8 encoded string.
    class StringTag < ValueTag

      ##
      # @!attribute [rw] value
      #   @return [String] the value of the tag.

      ##
      # Creates a new instance of the {StringTag} class.
      #
      # @param name [String,NilClass] The name of the tag, or `nil` when unnamed.
      # @param value [String,NilClass] The value of the tag.
      def initialize(name, value = '')
        super(TYPE_STRING, name, value)
      end

      def value=(value)
        @value = String(value)
      end

      ##
      # @return [String] the NBT tag as a formatted and human-readable string.
      def to_s
        "TAG_String(#{@name ? "\"#{@name}\"" : 'None'}): \"#{@value}\""
      end

      ##
      # @return [String] the NBT tag as an SNBT string.
      def stringify
        "#{snbt_prefix}\"#{@value}\""
      end
    end
  end
end