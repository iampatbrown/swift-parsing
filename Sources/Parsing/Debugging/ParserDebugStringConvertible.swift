import Foundation

public protocol ParserDebugStringConvertible {
  var parserDebugDescription: String { get }
}

func parserDebug(for subject: Any) -> String {
  if let subject = subject as? ParserDebugStringConvertible {
    return subject.parserDebugDescription
  } else {
    return String(describing: subject)
  }
}

func rangeDescription(min: Int, max: Int?) -> String {
  switch (min, max) {
  case (_, min): return "\(min)"
  case (0, nil): return ""
  case let (0, .some(max)): return "...\(max)"
  case (_, nil): return "\(min)..."
  case let (_, .some(max)): return "\(min)...\(max)"
  }
}

extension TracedParser: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "\(parserDebug(for: self.upstream))"
  }
}

extension Always: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "Always<\(Input.self), \(Output.self)>(\(self.output))"
  }
}

extension AnyParser: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "AnyParser<\(Input.self), \(Output.self)>"
  }
}

extension Parsers.BoolParser: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "BoolParser<\(Input.self)>"
  }
}

extension Parsers.CompactMap: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "CompactMap<\(parserDebug(for: self.upstream)), \(Output.self)>"
  }
}

extension Conditional: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "Conditional<\(Input.self), \(Output.self)>"
  }
}

extension Parsers.DoubleParser: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "DoubleParser<\(Input.self)>"
  }
}

extension End: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "End<\(Input.self)>"
  }
}

extension Fail: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "Fail<\(Input.self), \(Output.self)>"
  }
}

extension Parsers.Filter: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "Filter<\(parserDebug(for: self.upstream))>"
  }
}

extension First: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "First<\(Input.self)>"
  }
}

extension Parsers.FlatMap: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "FlatMap<\(parserDebug(for: self.upstream)), \(Output.self)>"
  }
}

extension FromSubstring: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "FromSubstring<\(parserDebug(for: self.substringParser))>"
  }
}

extension FromUnicodeScalarView: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "FromUnicodeScalarView<\(parserDebug(for: self.unicodeScalarParser))>"
  }
}

extension FromUTF8View: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "FromUTF8View<\(parserDebug(for: self.utf8Parser))>"
  }
}

extension InfixOperator: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "InfixOperator<\(parserDebug(for: self.operator)), \(parserDebug(for: self.expression)))>(associativity: \(self.associativity)"
  }
}

extension Parsers.IntParser: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "IntParser<\(Input.self)>(isSigned: \(self.isSigned), radix: \(self.radix))"
  }
}

extension Lazy: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "Lazy<\(self.lazyParser != nil ? parserDebug(for: self.lazyParser!) : "\(LazyParser.Input.self), \(LazyParser.Output.self)")>"
  }
}

extension String.UnicodeScalarView: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    String(self)
  }
}

extension Substring.UTF8View: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    String(decoding: self, as: UTF8.self)
  }
}

extension String.UTF8View: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    String(decoding: self, as: UTF8.self)
  }
}

extension Many: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "Many<\(parserDebug(for: self.upstream))>"
      + "(\(rangeDescription(min: self.minimum, max: self.maximum))"
      + "\(self.separator != nil ? ", separatedBy: \(parserDebug(for: self.separator!))" : ""))"
  }
}

extension Parsers.Map: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "Map<\(parserDebug(for: self.upstream)), \(Output.self)>"
  }
}

extension Newline: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "Newline<\(Input.self)>"
  }
}

extension Parse: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "\(parserDebug(for: self.upstream))"
  }
}

extension Parsers.OneOf: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "OneOf<\(Input.self), \(Output.self)>(\(parserDebug(for: self.a)), \(parserDebug(for: self.b)))"
  }
}

extension OneOfMany: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "OneOfMany<\(Input.self), \(Output.self)>(\(self.parsers.map(parserDebug).joined(separator: ", ")))"
  }
}

extension OneOf: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "\(parserDebug(for: self.upstream))"
  }
}

extension Optionally: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "Optionally { \(parserDebug(for: self.upstream)) }"
  }
}

extension Parsers.OptionalParser: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "Optionally { \(parserDebug(for: self.upstream)) }"
  }
}

extension Parsers.Pipe: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "Pipe<\(parserDebug(for: self.upstream)), \(parserDebug(for: self.downstream))>"
  }
}

extension Prefix: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    let range = rangeDescription(min: self.minLength, max: self.maxLength)
    return "Prefix<\(Input.self)>("
      + "\(range)\(self.predicate != nil ? "\(!range.isEmpty ? ", " : "")while:" : ""))"
  }
}

extension PrefixUpTo: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "PrefixUpTo<\(Input.self)>(\(parserDebug(for: self.possibleMatch)))"
  }
}

extension PrefixThrough: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "PrefixThrough<\(Input.self)>(\(parserDebug(for: self.possibleMatch)))"
  }
}

extension Parsers.Pullback: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "Pullback<\(Input.self), \(parserDebug(for: self.downstream))>"
  }
}

extension Rest: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "Rest<\(Input.self)>"
  }
}

extension Skip: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "Skip { \(parserDebug(for: self.upstream)) }"
  }
}

extension StartsWith: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "StartsWith<\(Input.self)>(\(self.possiblePrefix.map(parserDebug).joined()))" // TODO: not really going to work
  }
}

extension Parsers.Stream: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "Stream<\(parserDebug(for: self.upstream))>"
  }
}

// TODO: Take?

extension Whitespace: ParserDebugStringConvertible {
  public var parserDebugDescription: String {
    "Whitespace<\(Input.self)>"
  }
}
