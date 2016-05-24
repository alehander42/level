require 'parslet'
require_relative 'ast'

module Level
  def self.parse(source)
    prolog = Transformer.new.apply PrologParser.new.parse(source)
    prolog.select { |p| p.class != String }
  end

  class PrologParser < Parslet::Parser
    root :program

    rule(:program) {
      (line | comment).repeat(1)
    }

    rule(:line) { 
      (rule_ | fact) >> str('.') >> str("\n").repeat
    }

    rule(:comment) {
      str('%%') >> match(/[^\n]/).repeat(1) >> str("\n")
    }

    rule(:atom) { int | name | variable | list }

    rule(:int) { match(/\d/).repeat(1).as(:int) }
    rule(:name) { match(/[a-z]/).repeat(1).as(:name) }
    rule(:variable) { (match(/[A-Z]/) >> match(/[a-z]/).repeat).as(:variable) }
    rule(:list) { str('[') >> atom.repeat(0).as(:elements) >> str(']') }

    rule(:fact) { operation | relation | atom }

    rule(:operation) {
      variable.as(:left) >>
      str(' \\= ') >>
      variable.as(:right)
    }

    rule(:relation) { 
      name.as(:name) >>
      str('(') >>
      arg.repeat.as(:args) >>
      str(')')
    }

    rule(:arg) {
      atom.as(:arg) >>
      match(/, */).maybe
    }

    rule(:rule_) { # rule is already used by the library
      relation.as(:head) >>
      str(' :- ') >>
      rule_arg.repeat.as(:goals)
    }

    rule(:rule_arg) {
      fact >>
      str(',').maybe >> 
      str(' ').maybe
    }
  end

  class Transformer < Parslet::Transform
    rule(name: simple(:value)) { Name.new value }
    rule(variable: simple(:value)) { Variable.new value }
    rule(int: simple(:value)) { Int.new value.to_i }
    rule(elements: sequence(:elts)) { List.new elements }
    rule(arg: simple(:arg)) { arg }

    rule(
      name: subtree(:value),
      args: subtree(:args)
    ) { 
      Relation.new(value, args)
    }

    rule(
      left: subtree(:left),
      right: subtree(:right)
    ) {
      Relation.new('different', [left, right])
    }

    rule(
      head: subtree(:head),
      goals: subtree(:goals)
    ) {
      Rule.new(head, goals)
    }
  end
end

