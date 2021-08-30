module CraftBook
module NBT
class Tokenizer

macro
  nl          \n|\r\n|\r|\f
  w           [\s]*
  num         -?([0-9]+|[0-9]*\.[0-9]+)
  l_bracket   \[
  r_bracket   \]
  l_brace     \{
  r_brace     \}

  integer     -?([0-9]+)
  decimal     -?[0-9]*\.[0-9]+
  escape    {unicode}|\\[^\n\r\f0-9A-Fa-f]
  id [A-Za-z0-9-_]
rule
    \{{w}                { [:COMPOUND_BEGIN] }
    {w}\}                { [:COMPOUND_END] }

    ".+?"(?=:)      { [:IDENTIFIER, text.gsub!(/\A"|"\Z/, '') ] }
    '.+?'(?=:)      { [:IDENTIFIER, text.gsub!(/\A'|'\Z/, '') ] }
    [A-Za-z0-9_-]+?(?=:)        { [:IDENTIFIER, text] }
    ".*?"        { [:STRING, text.gsub!(/\A"|"\Z/, '') ] }
    '.*?'        { [:STRING, text.gsub!(/\A'|'\Z/, '') ] }

    # Control Characters
    {w}:{w}                { [:SEPARATOR, text] }
    {w},{w}                { [:COMMA, text] }

    # Collection Types

    {l_bracket}B;{w}?    { [:BYTE_ARRAY, text] }
    {l_bracket}I;{w}?    { [:INT_ARRAY, text]  }
    {l_bracket}L;{w}?    { [:LONG_ARRAY, text] }
    \[{w}?               { [:LIST_ARRAY, text] }
    {w}\]                { [:END_ARRAY, text]  }

    # Numeric Types
    {decimal}[Ff]    { [:FLOAT,  text.chop.to_f         ] }
    {decimal}[Dd]?   { [:DOUBLE, text.tr('Dd', '').to_f ] }
    {integer}[Bb]    { [:BYTE,   text.chop.to_i         ] }
    {integer}[Ss]    { [:SHORT,  text.chop.to_i         ] }
    {integer}[Ll]    { [:LONG,   text.chop.to_i         ] }
    {integer}        { [:INT,    text.to_i              ] }

    [\s]+            { [:WHITESPACE, text] }
    [\S]+            { [:STRING, text] }
    .                { [:CHAR, text] }

inner

  Token = Struct.new(:type, :value)

  def tokenize(code)
    scan_setup(code)
    if block_given?
      while token = next_token
        yield Token.new(*token)
      end
      return self
    end
    tokens = []
    while token = next_token
      tokens << Token.new(*token)
    end
    tokens
  end
end

end
end
end