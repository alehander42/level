module Level
  class Node
  end

  class Simple < Struct.new(:value)
  end

  class Typename < Simple; end
  class Variable < Simple; end
  class Int < Simple; end
  class String < Simple; end
  class Char < Simple; end

  class List < Struct.new(:elements)
  end

  class InitialDeclaration < Struct.new(:name, :initial)
  end

  class TypeDeclaration < Struct.new(:name, :type)
  end

  class IncludeStatement < Struct.new(:libraries)
  end

  class EnumStatement < Struct.new(:elements)
  end

  class Function < Struct.new(:annotation, :name, :params, :block)
  end

  class TypeAnnotation < Struct.new(:param_types, :return_type)
    def types
      param_types + [return_type]
    end
  end

  class Assignment < Struct.new(:slot, :value)
  end

  class Call < Struct.new(:callee, :args)
  end

  class ReturnStatement < Struct.new(:expr)
  end
end

