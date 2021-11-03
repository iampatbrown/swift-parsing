import Parsing

// MARK: - Parser

private typealias Input = Substring.UTF8View

// MARK: - Document

// https://www.w3.org/TR/xml/#NT-document
// [1]     document     ::=     prolog element Misc*

private struct Document: Equatable {
  var header: Void // Prolog
  var root: Void // Element
  var misc: Void // Misc
}

private let document = ()

private let prolog = ()

private let element = ()

// MARK: - Character Range

// https://www.w3.org/TR/xml/#dt-character
// [2]     Char     ::=     #x9 | #xA | #xD | [#x20-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]
// any Unicode character, excluding the surrogate blocks, FFFE, and FFFF

private func isLegalCharacter(_ s: UnicodeScalar) -> Bool {
  s != "\u{fffe}" && s != "\u{ffff}"
}

// MARK: - White Space

// https://www.w3.org/TR/xml/#NT-S
// [3]     S     ::=     (#x20 | #x9 | #xD | #xA)+

// S == WhiteSpace()

// MARK: - Names and Tokens

// https://www.w3.org/TR/xml/#NT-NameStartChar
// [4]     NameStartChar     ::=     ":" | [A-Z] | "_" | [a-z] | [#xC0-#xD6] | [#xD8-#xF6] | [#xF8-#x2FF] | [#x370-#x37D] | [#x37F-#x1FFF] | [#x200C-#x200D] | [#x2070-#x218F] | [#x2C00-#x2FEF] | [#x3001-#xD7FF] | [#xF900-#xFDCF] | [#xFDF0-#xFFFD] | [#x10000-#xEFFFF]

private func isNameStartCharacter(_ s: UnicodeScalar) -> Bool {
  switch s {
  case "_", ":", "\u{2c00}"..."\u{2fef}", "\u{37f}"..."\u{1fff}", "\u{200c}"..."\u{200d}", "\u{370}"..."\u{37d}",
       "\u{2070}"..."\u{218f}", "\u{3001}"..."\u{d7ff}", "\u{10000}"..."\u{effff}", "\u{c0}"..."\u{d6}",
       "\u{d8}"..."\u{f6}", "\u{f8}"..."\u{2ff}", "\u{f900}"..."\u{fdcf}", "\u{fdf0}"..."\u{fffd}", "a"..."z",
       "A"..."Z": return true
  default: return false
  }
}

// [4a]     NameChar     ::=     NameStartChar | "-" | "." | [0-9] | #xB7 | [#x0300-#x036F] | [#x203F-#x2040]
private func isNameCharacter(_ s: UnicodeScalar) -> Bool {
  if isNameStartCharacter(s) { return true }
  switch s {
  case "-", ".", "\u{203f}"..."\u{2040}", "\u{0300}"..."\u{036f}", "\u{b7}", "0"..."9": return true
  default: return false
  }
}

// [5]     Name     ::=     NameStartChar (NameChar)*
private let name = Parse {
  UTF8.prefix(1, whileScalar: isNameStartCharacter)
  UTF8.prefix(whileScalar: isNameCharacter)
}.map(+)

// TODO: Will do these when/if needed
// [6]     Names     ::=     Name (#x20 Name)*
// [7]     Nmtoken     ::=     (NameChar)+
// [8]     Nmtokens     ::=     Nmtoken (#x20 Nmtoken)*

// MARK: - Literals

// https://www.w3.org/TR/xml/#NT-EntityValue
// [9]     EntityValue     ::=     '"' ([^%&"] | PEReference | Reference)* '"' |  "'" ([^%&'] | PEReference | Reference)* "'"

// TODO: References

private let entityValue = OneOf {
  doubleQuotedLiteral(scalar: isEntityValueCharacter)
  singleQuotedLiteral(scalar: isEntityValueCharacter)
}

private func isEntityValueCharacter(_ s: UnicodeScalar) -> Bool {
  s != "%" && s != "&"
}

// [10]     AttValue     ::=     '"' ([^<&"] | Reference)* '"' |  "'" ([^<&'] | Reference)* "'"
private let attributeValue = OneOf {
  doubleQuotedLiteral(scalar: isAttributeValueCharacter)
  singleQuotedLiteral(scalar: isAttributeValueCharacter)
}

private func isAttributeValueCharacter(_ s: UnicodeScalar) -> Bool {
  s != "<" && s != "&"
}

// [11]     SystemLiteral     ::=     ('"' [^"]* '"') | ("'" [^']* "'")
//private let systemLiteral = OneOf {
//  doubleQuotedLiteral()
//  singleQuotedLiteral()
//}

// [12]     PubidLiteral     ::=     '"' PubidChar* '"' | "'" (PubidChar - "'")* "'"
// [13]     PubidChar     ::=     #x20 | #xD | #xA | [a-zA-Z0-9] | [-'()+,./:=?;!*#@$_%]
private let pubidLiteral = OneOf {
  doubleQuotedLiteral(scalar: isPubidCharacter)
  singleQuotedLiteral(scalar: isPubidCharacter)
}

private func isPubidCharacter(_ s: UnicodeScalar) -> Bool {
  switch s {
  case "_", "-", ",", ";", ":", "!", "?", ".", "'", "(", ")", "@", "*", "/", "\u{20}", "\u{a}", "\u{d}", "#", "%", "+",
       "=", "$", "0"..."9", "a"..."z", "A"..."Z": return true
  default: return false
  }
}

private func doubleQuotedLiteral(
  scalar predicate: @escaping (UnicodeScalar) -> Bool // = { _ in true }
) -> AnyParser<Input, String> {
  AnyParser {
    "\"".utf8
    UTF8.prefix {
      predicate($0) && $0 != "\""
    }
    "\"".utf8
  }
}

private func singleQuotedLiteral(
  scalar predicate: @escaping (UnicodeScalar) -> Bool // = { _ in true }
) -> AnyParser<Input, String> {
  AnyParser {
    "'".utf8
    UTF8.prefix {
      predicate($0) && $0 != "'"
    }
    "'".utf8
  }
}


// MARK: - Character Data and Markup
// [14]     CharData     ::=     [^<&]* - ([^<&]* ']]>' [^<&]*)


//private let characterData = UTF8.prefix(whileScalar: isCharacterDataCharacter, orUpTo: "]]>".utf8)
//
//private func isCharacterDataCharacter(_ s: UnicodeScalar) -> Bool {
//  s != "<" && s != "&"
//}

// MARK: - Helpers

extension UTF8 {
  fileprivate static func prefix(
    minLength: Int = 0,
    maxLength: Int = .max,
    whileScalar predicate: @escaping (UnicodeScalar) -> Bool
  ) -> AnyParser<Substring.UTF8View, String> {
    AnyParser { input in
      var utf8Decoder = Unicode.UTF8()
      var bytesIterator = input.makeIterator()
      var length = 0
      var count = 0

      Decode: while length < maxLength {
        switch utf8Decoder.decode(&bytesIterator) {
        case let .scalarValue(scalar) where predicate(scalar):
          count += UTF8.width(scalar)
          length += 1
        default:
          break Decode
        }
      }

      guard length >= minLength else { return nil }
      defer { input.removeFirst(count) }
      return String(decoding: input.prefix(count), as: UTF8.self)
    }
  }

  fileprivate static func prefix(
    _ length: Int,
    whileScalar predicate: @escaping (UnicodeScalar) -> Bool
  ) -> AnyParser<Substring.UTF8View, String> {
    prefix(minLength: length, maxLength: length, whileScalar: predicate)
  }

  fileprivate static func prefix(
    whileScalar predicate: @escaping (UnicodeScalar) -> Bool,
    orUpTo possibleMatch: String.UTF8View
  ) -> AnyParser<Substring.UTF8View, String> {
    AnyParser { input in
      let maxCount = PrefixUpTo(possibleMatch).parse(input).output?.count ?? .max
      var utf8Decoder = Unicode.UTF8()
      var bytesIterator = input.makeIterator()
      var count = 0

      Decode: while count < maxCount {
        switch utf8Decoder.decode(&bytesIterator) {
        case let .scalarValue(scalar) where predicate(scalar):
          count += UTF8.width(scalar)
        default:
          break Decode
        }
      }
      defer { input.removeFirst(count) }
      return String(decoding: input.prefix(count), as: UTF8.self)
    }
  }
}
