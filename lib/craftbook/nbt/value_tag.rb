
module CraftBook

  module NBT
    ##
    # @abstract
    # Abstract base class for tags that can contain a single primitive value.
    class ValueTag < Tag

      ##
      # @!attribute [rw] value
      #   @return [Object] the value of the tag.

      attr_reader :value

      ##
      # Creates a new instance of the {ValueTag} class.
      #
      # @param name [String,NilClass] The name of the tag, or `nil` when unnamed.
      # @param value [Object] The value of the tag.
      def initialize(type, name, value)
        super(type, name)
        self.value = value
      end

      def value=(value)
        @value = value
      end

      ##
      # @return [Hash{Symbol => Object}] the hash-representation of this object.
      def to_h
        { name: @name, type: @type, value: @value }
      end

      protected

      def validate(value, min, max)
        raise(TypeError, 'value cannot be nil') unless value
        return value if value.between?(min, max)
        raise(ArgumentError, sprintf("value must be between 0x%X and 0x%X inclusive", min, max))
      end

      protected

      def parse_hash(hash)
        self.value = hash[:value]
      end
    end
  end
end