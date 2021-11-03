import Parsing

// MARK: - Parser

private typealias Input = Substring.UTF8View

// MARK: - Document

// https://www.w3.org/TR/xml/#NT-document
// [1]     document     ::=     prolog element Misc*

private struct Document: Equatable {
  var header: String // Prolog
  var root: String // Element
  var misc: String // Misc
}

private let document = "document"


private let element = "element"

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
private let systemLiteral = OneOf {
  doubleQuotedLiteral()
  singleQuotedLiteral()
}

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

private func doubleQuoted<P: Parser>(
  @ParserBuilder _ build: () -> P
) -> AnyParser<P.Input, P.Output> where P.Input == Input {
  let upstream = build()
  return Parse {
    "\"".utf8
    upstream
    "\"".utf8
  }.eraseToAnyParser()
}

private func doubleQuotedLiteral(
  scalar predicate: @escaping (UnicodeScalar) -> Bool = { _ in true }
) -> AnyParser<Input, String> {
  doubleQuoted {
    UTF8.prefix { predicate($0) && $0 != "\"" }
  }
}

private func singleQuoted<P: Parser>(
  @ParserBuilder _ build: () -> P
) -> AnyParser<P.Input, P.Output> where P.Input == Input {
  let upstream = build()
  return Parse {
    "'".utf8
    upstream
    "'".utf8
  }.eraseToAnyParser()
}

private func singleQuotedLiteral(
  scalar predicate: @escaping (UnicodeScalar) -> Bool = { _ in true }
) -> AnyParser<Input, String> {
  singleQuoted {
    UTF8.prefix { predicate($0) && $0 != "'" }
  }
}

// MARK: - Character Data and Markup

// https://www.w3.org/TR/xml/#NT-CharData

// [14]     CharData     ::=     [^<&]* - ([^<&]* ']]>' [^<&]*)

private let characterData = UTF8.prefix(whileScalar: isCharacterDataCharacter, orUpTo: "]]>".utf8)

private func isCharacterDataCharacter(_ s: UnicodeScalar) -> Bool {
  s != "<" && s != "&"
}

// MARK: - Comments

// https://www.w3.org/TR/xml/#NT-Comment

// [15]     Comment     ::=     '<!--' ((Char - '-') | ('-' (Char - '-')))* '-->'
private let comment = Parse {
  "<!--".utf8
  UTF8.prefix(whileScalar: isLegalCharacter, orUpTo: "--".utf8)
  "-->".utf8
}

// MARK: - Processing Instructions

// https://www.w3.org/TR/xml/#NT-PI

// [16]     PI     ::=     '<?' PITarget (S (Char* - (Char* '?>' Char*)))? '?>'
// [17]     PITarget     ::=     Name - (('X' | 'x') ('M' | 'm') ('L' | 'l'))

private struct ProcessingInstructions: Equatable {
  var target: String
  var instructions: String?
}

private let processingInstructions = Parse {
  "<?".utf8
  piTarget
  Optionally {
    Skip { atLeastOneWhiteSpace }
    UTF8.prefix(whileScalar: isLegalCharacter, orUpTo: "?>".utf8)
  }
  "?>".utf8
}.map(ProcessingInstructions.init)

private let piTarget = name.filter { $0.lowercased() != "xml" }

// TODO: What's the preferred way to do this? maybe add atLeast: atMost: or I could do let whiteSpace =
private let atLeastOneWhiteSpace = Whitespace().filter { !$0.isEmpty }

// MARK: - CDATA Sections

// https://www.w3.org/TR/xml/#dt-cdsection

// [18]     CDSect     ::=     CDStart CData CDEnd
// [19]     CDStart     ::=     '<![CDATA['
// [20]     CData     ::=     (Char* - (Char* ']]>' Char*))
// [21]     CDEnd     ::=     ']]>'

private let cDataSection = Parse {
  "<![CDATA[".utf8
  UTF8.prefix(whileScalar: isLegalCharacter, orUpTo: "]]>".utf8)
  "]]>".utf8
}

// MARK: - Prolog and Document Type Declaration

// https://www.w3.org/TR/xml/#sec-prolog-dtd

//  [22]     prolog     ::=     XMLDecl? Misc* (doctypedecl Misc*)?
private let prolog = Parse {
  Optionally { xmlDeclaration }
  Many { misc } separatedBy: { "utf8".utf8 }

}

//  [23]     XMLDecl     ::=     '<?xml' VersionInfo EncodingDecl? SDDecl? S? '?>'

private let xmlDeclaration = Parse {
  "<?xml".utf8
  versionInfo
  Optionally { encodingDeclaration }
  Optionally { standaloneDocumentDeclaration }
  Skip { Whitespace() }
  "?>".utf8
}

//  [24]     VersionInfo     ::=     S 'version' Eq ("'" VersionNum "'" | '"' VersionNum '"')

private let versionInfo = Parse {
  Skip {    atLeastOneWhiteSpace  }
  "version".utf8
  equalSign
  OneOf {
    singleQuoted { versionNumber }
    doubleQuoted { versionNumber }
  }
}

//  [25]     Eq     ::=     S? '=' S?

private let equalSign = Parse {
  Skip { Whitespace() }
  "=".utf8
  Skip { Whitespace() }
}

//  [26]     VersionNum     ::=     '1.' [0-9]+

private let versionNumber = Parse {
  "1.".utf8.map { "1." }
  UTF8.prefix { "0"..."9" ~= $0 }
}.map(+) // just keeping as string for now

//  [27]     Misc     ::=     Comment | PI | S
private enum Misc {
  case comment(String)
  case pi(ProcessingInstructions)
  case whiteSpace
}

private let misc = OneOf {
  comment.map(Misc.comment)
  processingInstructions.map(Misc.pi)
  atLeastOneWhiteSpace.map { _ in Misc.whiteSpace }
}


// MARK: - Document Type Definition
// https://www.w3.org/TR/xml/#NT-doctypedecl


// [28]     doctypedecl     ::=     '<!DOCTYPE' S Name (S ExternalID)? S? ('[' intSubset ']' S?)? '>' [VC: Root Element Type], [WFC: External Subset]
// [28a]     DeclSep     ::=     PEReference | S  [WFC: PE Between Declarations]
// [28b]     intSubset     ::=     (markupdecl | DeclSep)*
// [29]     markupdecl     ::=     elementdecl | AttlistDecl | EntityDecl | NotationDecl | PI | Comment  [VC: Proper Declaration/PE Nesting] [WFC: PEs in Internal Subset]


// MARK: - Standalone Document Declaration
// https://www.w3.org/TR/xml/#NT-SDDecl

// [32]     SDDecl     ::=     S 'standalone' Eq (("'" ('yes' | 'no') "'") | ('"' ('yes' | 'no') '"'))
// Constraint: [VC: Standalone Document Declaration]

private let standaloneDocumentDeclaration = Parse {
  Skip { atLeastOneWhiteSpace }
  "standalone".utf8
  equalSign
  OneOf {
    singleQuoted { isStandalone }
    doubleQuoted { isStandalone }
  }
}

private let isStandalone = OneOf {
  "yes".utf8.map { true }
  "no".utf8.map { false }
}



// MARK: - Encoding Declaration
// https://www.w3.org/TR/xml/#NT-EncodingDecl

// [80]     EncodingDecl     ::=     S 'encoding' Eq ('"' EncName '"' | "'" EncName "'" )

private let encodingDeclaration = Parse {
  Skip { atLeastOneWhiteSpace }
  "encoding".utf8
  equalSign
  OneOf {
    doubleQuoted { encodingName }
    singleQuoted { encodingName }
  }
}

// [81]     EncName     ::=     [A-Za-z] ([A-Za-z0-9._] | '-')*  /* Encoding name contains only Latin characters */
private let encodingName = Parse {
  UTF8.prefix(1, whileScalar: isEncodingNameStartCharacter)
  UTF8.prefix(whileScalar: isEncodingNameCharacter)
}.map(+)

private func isEncodingNameStartCharacter(_ s: UnicodeScalar) -> Bool {
  "A"..."Z" ~= s || "a"..."z" ~= s
}

private func isEncodingNameCharacter(_ s: UnicodeScalar) -> Bool {
  if isEncodingNameStartCharacter(s) { return true }
  switch s {
  case "_", "-", ".", "0"..."9": return true
  default: return false
  }
}

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
