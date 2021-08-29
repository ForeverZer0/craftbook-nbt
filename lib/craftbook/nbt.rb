# frozen_string_literal: true

require 'json'
require 'stringio'
require 'zlib'

require_relative 'nbt/version'
require_relative 'nbt/tag'
require_relative 'nbt/value_tag'
require_relative 'nbt/enumerable_tag'
require_relative 'nbt/container_tag'
require_relative 'nbt/byte_tag'
require_relative 'nbt/short_tag'
require_relative 'nbt/int_tag'
require_relative 'nbt/long_tag'
require_relative 'nbt/float_tag'
require_relative 'nbt/double_tag'
require_relative 'nbt/string_tag'
require_relative 'nbt/byte_array_tag'
require_relative 'nbt/int_array_tag'
require_relative 'nbt/long_array_tag'
require_relative 'nbt/list_tag'
require_relative 'nbt/compound_tag'
require_relative 'nbt/tag_builder'

##
# Top-level namespace for the CraftBook API.
module CraftBook

  ##
  # Top-level namespace for the independent Named Binary Tag (NBT) module of the CraftBook API, providing classes and
  # for reading and writing NBT tags used by the Java editions of Minecraft.
  #
  # @api NBT
  # @author Eric "ForeverZer0" Freed
  module NBT

    ##
    # Exception class used for errors relating to parsing and invalid formats.
    class ParseError < StandardError
    end

    ##
    # The encoding used for all strings.
    ENCODING = Encoding::UTF_8

    ##
    # Serializes and writes the specified {Tag} to an IO-like object.
    #
    # @param io [IO,#write] An IO-like object that responds to `#write`
    # @param tag [Tag] A {Tag} instance to write. If `io` represents a file stream, the specification expects this to
    #   be a {CompoundTag}.
    #
    # @return [Integer] The number of bytes written.
    def self.write(io, tag)
      unless io.is_a?(IO) || io.respond_to?(:write)
        raise(ArgumentError, "object must be an IO instance or respond to #write")
      end
      write_tag(io, tag, false)
    end

    ##
    # Serializes and writes the specified {Tag} to a file at the specified `path`. If file already exists at that
    # location, it will be overwritten.
    #
    # @param path [String] The path to the file to write to.
    # @param compound_tag [Tag] A {CompoundTag} instance to write.
    # @param opts [Hash{Symbol => Symbol}] Options hash.
    #
    # @option opts [Symbol] :compression (:gzip) The type of compression to use when writing, if any.
    #   Valid values include:
    #   <ul>
    #   <li><code>:none</code> No compression</li>
    #   <li><code>:gzip</code> GZip compression</li>
    #   <li><code>:zlib</code> ZLib compression (DEFLATE with 2 byte header and post-fixed CRC checksum)</li>
    #   </ul>
    # @option opts [Symbol] :level (:default) The level of compression to use, ignored when no compression is specified.
    #   Valid values include:
    #   <ul>
    #   <li><code>:default</code> The default compression employed by the specified algorithm.</li>
    #   <li><code>:none</code> No compression. Compressions formats will still include their additional meta-data.</li>
    #   <li><code>:optimal</code> Favor high compression-rate over speed.</li>
    #   <li><code>:fastest</code> Favor speed over compression-rate.</li>
    #   </ul>
    #
    # @return [Integer] The number of bytes written.
    def self.write_file(path, compound_tag, **opts)

      compression = opts[:compression] || :gzip
      level = case opts[:level]
      when nil then Zlib::DEFAULT_COMPRESSION
      when :default then Zlib::DEFAULT_COMPRESSION
      when :none then Zlib::NO_COMPRESSION
      when :optimal then Zlib::BEST_COMPRESSION
      when :fastest then Zlib::BEST_SPEED
      else raise(ArgumentError, "invalid compression level specified: #{opts[:level]}")
      end

      written = 0
      File.open(path, 'wb') do |io|

        case compression
        when :none then written = write(io, compound_tag)
        when :gzip
          gzip = Zlib::GzipWriter.new(io, level)
          #noinspection RubyMismatchedParameterType
          written = write(gzip, compound_tag)
          gzip.finish
        when :zlib
          buffer = StringIO.new
          #noinspection RubyMismatchedParameterType
          write(buffer, compound_tag)
          compressed = Zlib::Deflate.deflate(buffer.string, level)
          written = io.write(compressed)
        else
          raise(ArgumentError, "invalid compression specified: #{compression}")
        end
      end

      written
    end

    ##
    # Deserializes a {Tag} instance from the specified IO-like object.
    # @param io [IO,#read] A IO-like object that responds to `#read`.
    #
    # @return [Tag] The deserialized tag object.
    def self.read(io)
      unless io.is_a?(IO) || io.respond_to?(:read)
        raise(ArgumentError, "object must be an IO instance or respond to #read")
      end
      type = io.readbyte
      read_type(io, type, read_string(io))
    end

    ##
    # Reads and deserializes a {Tag} from a file stored at the specified `path`.
    # @param path [String] The path to a file to read from.
    #
    # @note Compression formats supported by the specification (GZip, ZLib) will be detected and handled automatically.
    #
    # @return [Tag] The deserialized tag object.
    def self.read_file(path)

      File.open(path, 'rb') do |io|
        byte = io.readbyte
        io.seek(0, IO::SEEK_SET)

        stream = case byte
        when 0x78 then StringIO.new(Zlib::Inflate.inflate(io.read))
        when 0x1F then Zlib::GzipReader.new(io)
        when 0x0A then io
        else raise(ParseError, 'invalid NBT format')
        end
        read(stream)
      end
    end

    private

    def self.write_tag(io, tag, list_child = false)

      written = 0
      unless list_child
        written += io.write([tag.type].pack('C'))
        written += write_string(io, tag.name)
        written
      end

      written += case tag.type
      when Tag::TYPE_END then io.write("\0")
      when Tag::TYPE_BYTE then io.write([tag.value].pack('c'))
      when Tag::TYPE_SHORT then io.write([tag.value].pack('s>'))
      when Tag::TYPE_INT then io.write([tag.value].pack('l>'))
      when Tag::TYPE_LONG then io.write([tag.value].pack('q>'))
      when Tag::TYPE_FLOAT then io.write([tag.value].pack('g'))
      when Tag::TYPE_DOUBLE then io.write([tag.value].pack('G'))
      when Tag::TYPE_BYTE_ARRAY
        written += io.write([tag.size].pack('l>'))
        io.write(tag.to_a.pack('c*'))
      when Tag::TYPE_STRING then write_string(io, tag.value)
      when Tag::TYPE_LIST
        written += io.write([tag.child_type].pack('C'))
        written += io.write([tag.size].pack('l>'))
        tag.map { |child| write_tag(io, child, true) }.sum
      when Tag::TYPE_COMPOUND
        tag.each { |child| written += write_tag(io, child, false) }
        io.write("\0")
      when Tag::TYPE_INT_ARRAY
        written += io.write([tag.size].pack('l>'))
        io.write(tag.to_a.pack('l>*'))
      when Tag::TYPE_LONG_ARRAY
        written += io.write([tag.size].pack('l>'))
        io.write(tag.to_a.pack('q>*'))
      else
        raise(RuntimeError, sprintf("invalid type specifier: 0x%X2", tag.type))
      end

      written
    end

    def self.write_string(io, str)
      count = 0
      if str
        if str.encoding != ENCODING
          str = str.encode(ENCODING)
          warn("invalid UTF-8 characters in string") unless str.valid_encoding?
        end
        count += io.write([str.bytesize].pack('S>'))
        count += io.write(str)
      else
        count += io.write([0].pack('S>'))
      end
      count
    end

    ##
    # @param io [IO]
    # @param type [Integer]
    # @param name [String,NilClass]
    def self.read_type(io, type, name)
      case type
      when Tag::TYPE_BYTE then read_value_tag(io, ByteTag, name, 'c', 1)
      when Tag::TYPE_SHORT then read_value_tag(io, ShortTag, name, 's>', 2)
      when Tag::TYPE_INT then read_value_tag(io, IntTag, name, 'l>', 4)
      when Tag::TYPE_LONG then read_value_tag(io, LongTag, name, 'q>', 8)
      when Tag::TYPE_FLOAT then read_value_tag(io, FloatTag, name, 'g', 4)
      when Tag::TYPE_DOUBLE then read_value_tag(io, DoubleTag, name, 'G', 8)
      when Tag::TYPE_BYTE_ARRAY then read_array_tag(io, ByteArrayTag, name, 'c*', 1)
      when Tag::TYPE_STRING then StringTag.new(name, read_string(io))
      when Tag::TYPE_LIST then read_list_tag(io, name)
      when Tag::TYPE_COMPOUND then read_compound_tag(io, name)
      when Tag::TYPE_INT_ARRAY then read_array_tag(io, IntArrayTag, name, 'l>*', 4)
      when Tag::TYPE_LONG_ARRAY then read_array_tag(io, LongArrayTag, name, 'q>*', 8)
      else raise(ParseError, 'invalid type specifier, likely due to incorrect stream position')
      end
    end

    ##
    # @param io [IO]
    # @param klass [Class]
    # @param name [String,NilClass]
    # @param unpack [String]
    # @param size [Integer]
    def self.read_value_tag(io, klass, name, unpack, size)
      #noinspection RubyNilAnalysis
      value = io.read(size).unpack1(unpack)
      #noinspection RubyArgCount
      klass.new(name, value)
    end

    #
    # @param io [IO]
    # @param klass [Class]
    # @param name [String,NilClass]
    # @param unpack [String]
    # @param size [Integer]
    def self.read_array_tag(io, klass, name, unpack, size)
      #noinspection RubyNilAnalysis
      count = io.read(4).unpack1('l>')
      #noinspection RubyNilAnalysis
      values = io.read(count * size).unpack(unpack)
      tag = klass.new(name)
      tag.instance_variable_set(:@values, values)
      tag
    end

    ##
    # @return [String]
    def self.read_string(io)
      length = io.read(2).unpack1('S>')
      #noinspection RubyResolve
      length.zero? ? '' : io.read(length).force_encoding(ENCODING)
    end

    def self.read_list_tag(io, name)
      child_type = io.readbyte
      count = io.read(4).unpack1('l>')
      list = ListTag.new(name, child_type)
      values = (0...count).map { read_type(io, child_type, nil) }
      list.instance_variable_set(:@values, values)
      list
    end

    def self.read_compound_tag(io, name)
      compound = CompoundTag.new(name)
      loop do
        type = io.readbyte
        break if type == Tag::TYPE_END
        child_name = read_string(io)
        compound.push(read_type(io, type, child_name))
      end
      compound
    end

  end
end
