module Keisan
  module AST
    def self.parse(expression)
      AST::Builder.new(string: expression).ast
    end
  end
end

module KeisanNumeric
  def to_node
    Keisan::AST::Number.new(self)
  end
end

module KeisanString
  def to_node
    Keisan::AST::String.new(self)
  end
end

module KeisanTrueClass
  def to_node
    Keisan::AST::Boolean.new(true)
  end
end

module KeisanFalseClass
  def to_node
    Keisan::AST::Boolean.new(false)
  end
end

module KeisanNilClass
  def to_node
    Keisan::AST::Null.new
  end
end

module KeisanArray
  def to_node
    Keisan::AST::List.new(map {|n| n.to_node})
  end
end

class Numeric; prepend KeisanNumeric; end
class String; prepend KeisanString; end
class TrueClass; prepend KeisanTrueClass; end
class FalseClass; prepend KeisanFalseClass; end
class NilClass; prepend KeisanNilClass; end
class Array; prepend KeisanArray; end
