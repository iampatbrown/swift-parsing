import Benchmark
import Foundation
import Parsing

// MARK: - Parser

private typealias Input = Substring.UTF8View

// MARK: - Document

// https://www.w3.org/TR/xml/#NT-document
// [1]     document     ::=     prolog element Misc*

private struct Document {
  var prolog: Prolog
  var root: Element
  var misc: [Misc]
}

private let document = Parse {
  prolog
  element
  Many { misc }
}.map(Document.init)

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

// TODO: What's the preferred way to do this? maybe add atLeast: atMost: or I could do let whiteSpace =
private let atLeastOneWhiteSpace = Whitespace().filter { !$0.isEmpty }

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

// [6]     Names     ::=     Name (#x20 Name)*

private let names = Many(atLeast: 1) {
  name
} separatedBy: {
  " ".utf8
}

// [7]     Nmtoken     ::=     (NameChar)+
private let nameToken = UTF8.prefix(1..., whileScalar: isNameCharacter)

// [8]     Nmtokens     ::=     Nmtoken (#x20 Nmtoken)*
private let nameTokens = Many(atLeast: 1) {
  nameToken
} separatedBy: {
  " ".utf8
}

// MARK: - Literals

// https://www.w3.org/TR/xml/#NT-EntityValue

// [9]     EntityValue     ::=     '"' ([^%&"] | PEReference | Reference)* '"' |  "'" ([^%&'] | PEReference | Reference)* "'"

private let entityValue = OneOf {
  doubleQuoted {
    Many {
      OneOf {
        UTF8.prefix { isEntityValueCharacter($0) && $0 != "\"" }
        parameterEntityReference
        reference
      }
    }
  }
  singleQuoted {
    Many {
      OneOf {
        UTF8.prefix { isEntityValueCharacter($0) && $0 != "'" }
        parameterEntityReference
        reference
      }
    }
  }
}

private func isEntityValueCharacter(_ s: UnicodeScalar) -> Bool {
  s != "%" && s != "&"
}

// [10]     AttValue     ::=     '"' ([^<&"] | Reference)* '"' |  "'" ([^<&'] | Reference)* "'"
// private let attributeValue = OneOf {
//  doubleQuotedLiteral(scalar: isAttributeValueCharacter)
//  singleQuotedLiteral(scalar: isAttributeValueCharacter)
// }

private let attributeValue = OneOf {
  doubleQuoted {
    Many {
      OneOf {
        UTF8.prefix(1...) { isAttributeValueCharacter($0) && $0 != "\"" }
        reference
      }
    }.map { $0.joined() }
  }
  singleQuoted {
    Many {
      OneOf {
        UTF8.prefix(1...) { isAttributeValueCharacter($0) && $0 != "'" }
        reference
      }
    }.map { $0.joined() }
  }
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
private let publicIdLiteral = OneOf {
  doubleQuotedLiteral(scalar: isPublicIdCharacter)
  singleQuotedLiteral(scalar: isPublicIdCharacter)
}

private func isPublicIdCharacter(_ s: UnicodeScalar) -> Bool {
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
  .filter { !$0.isEmpty }

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

private struct Prolog {
  var xmlDeclaration: XMLDeclaration?
  var documentTypeDeclaration: DocumentTypeDeclaration?
  var misc: [Misc] = []
}

private let prolog = Parse {
  Optionally { xmlDeclaration }
  Many { misc }
  Optionally { documentTypeDeclaration }
  Many { misc } // should be [] if there's no documentTypeDeclaration
}.map {
  Prolog(xmlDeclaration: $0, documentTypeDeclaration: $2, misc: $1 + $3)
}

//  [23]     XMLDecl     ::=     '<?xml' VersionInfo EncodingDecl? SDDecl? S? '?>'

private struct XMLDeclaration {
  var version: String
  var encodingType: String?
  var isStandalone: Bool?
}

private let xmlDeclaration = Parse {
  "<?xml".utf8
  versionInfo
  Optionally { encodingDeclaration }
  Optionally { standaloneDocumentDeclaration }
  Skip { Whitespace() }
  "?>".utf8
}.map(XMLDeclaration.init)

//  [24]     VersionInfo     ::=     S 'version' Eq ("'" VersionNum "'" | '"' VersionNum '"')

private let versionInfo = Parse {
  Skip { atLeastOneWhiteSpace }
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
  UTF8.prefix(1..., whileScalar: isDigit)
}.map(+) // just keeping as string for now

private func isDigit(_ s: UnicodeScalar) -> Bool {
  "0"..."9" ~= s // ("0"..."9").contains(s) TODO: Is there a preference here?
}

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

private struct DocumentTypeDeclaration {
  var name: String
  var externalId: ExternalID?
  var internalSubsets: [InternalSubset]?
}

private let documentTypeDeclaration = Parse {
  "<!DOCTYPE".utf8
  Parse { // TODO: Extra Variadic or just extract it?
    Skip { atLeastOneWhiteSpace }
    name
    Optionally {
      Skip { atLeastOneWhiteSpace }
      externalId
    }
    Skip { Whitespace() }
    Optionally {
      "[".utf8
      internalSubset
      "]".utf8
      Skip { Whitespace() }
    }
  }
  ">".utf8
}.map(DocumentTypeDeclaration.init)

// [28a]     DeclSep     ::=     PEReference | S  [WFC: PE Between Declarations]
private let declarationSeparator = OneOf {
  parameterEntityReference.map(DeclarationSeparator.parameterEntityReference)
  atLeastOneWhiteSpace.map { _ in DeclarationSeparator.whiteSpace }
}

private enum DeclarationSeparator {
  case parameterEntityReference(String)
  case whiteSpace
}

// [28b]     intSubset     ::=     (markupdecl | DeclSep)*

private let internalSubset = Many(into: [InternalSubset]()) { intSubset, content in
  switch content {
  case .whiteSpace:
    return
  case .markup, .parameterEntityReference:
    intSubset.append(content)
  }
} forEach: {
  OneOf {
    markupDeclaration.map(InternalSubset.markup)
    declarationSeparator.map(InternalSubset.from(separator:))
  }
}

private enum InternalSubset {
  case markup(MarkupDeclaration)
  case parameterEntityReference(String)
  case whiteSpace

  static func from(separator: DeclarationSeparator) -> Self {
    switch separator {
    case let .parameterEntityReference(ref): return .parameterEntityReference(ref)
    case .whiteSpace: return .whiteSpace
    }
  }
}

// [29]     markupdecl     ::=     elementdecl | AttlistDecl | EntityDecl | NotationDecl | PI | Comment
// [VC: Proper Declaration/PE Nesting] [WFC: PEs in Internal Subset]

private let markupDeclaration = OneOf {
  elementDeclaration.map(MarkupDeclaration.element)
  attributeListDeclaration.map(MarkupDeclaration.attributeList)
  entityDeclaration.map(MarkupDeclaration.entity)
  notationDeclaration.map(MarkupDeclaration.notation)
  processingInstructions.map(MarkupDeclaration.processingInstructions)
  comment.map(MarkupDeclaration.comment)
}

private enum MarkupDeclaration {
  case element(ElementDeclaration)
  case attributeList(AttributeListDeclaration)
  case entity(EntityDeclaration)
  case notation(NotationDeclaration)
  case processingInstructions(ProcessingInstructions)
  case comment(String)
}

// MARK: - External Subset

// TODO: Implement when neeeded
// [30]     extSubset     ::=     TextDecl? extSubsetDecl
// [31]     extSubsetDecl     ::=     ( markupdecl | conditionalSect | DeclSep)*

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

// (Productions 33 through 38 have been removed.)

// MARK: - Logical Structures

// [39]     element     ::=     EmptyElemTag | STag content ETag  [WFC: Element Type Match] [VC: Element Valid]

private var element: AnyParser<Input, Element> {
  Parse {
    OneOf {
      emptyElement // also includes STag ETag
      nonEmptyElement
    }
  }.eraseToAnyParser()
}

private let emptyElement = OneOf {
  emptyElementTag
    .map { Element(name: $0.name, attributes: $0.attributes) }
  Parse {
    startTag
    endTag
  }
  .compactMap { $0.name == $1.name ? Element(name: $0.name, attributes: $0.attributes) : nil }
}

private var nonEmptyElement: AnyParser<Input, Element> {
  Parse {
    startTag
    Lazy { content }
    endTag
  }
  .compactMap { $0.name == $2.name ? Element(name: $0.name, attributes: $0.attributes, content: $1) : nil }
  .eraseToAnyParser()
}

private struct Element {
  var name: String
  var attributes: [Attribute] = []
  var content: [Content] = []
}

private enum ElementTag {
  case empty(name: String, attributes: [Attribute])
  case start(name: String, attributes: [Attribute])
  case end(name: String)

  var name: String {
    switch self {
    case let .empty(name, _), let .end(name), let .start(name, _): return name
    }
  }

  var attributes: [Attribute] {
    switch self {
    case let .empty(_, attributes), let .start(_, attributes): return attributes
    case .end: return []
    }
  }
}

// [40]     STag     ::=     '<' Name (S Attribute)* S? '>'  [WFC: Unique Att Spec]

private let startTag = Parse {
  "<".utf8
  name
  Many {
    Skip { atLeastOneWhiteSpace }
    attribute
  }
  Skip { Whitespace() }
  ">".utf8
}.map(ElementTag.start)

// [41]     Attribute     ::=     Name Eq AttValue  [VC: Attribute Value Type] [WFC: No External Entity References] [WFC: No < in Attribute Values]
private let attribute = Parse {
  name
  equalSign
  attributeValue
}.map(Attribute.init)

private struct Attribute {
  var name: String
  var value: String
}

// [42]     ETag     ::=     '</' Name S? '>'

private let endTag = Parse {
  "</".utf8
  name
  Skip { Whitespace() }
  ">".utf8
}.map(ElementTag.end)

// [43]     content     ::=     CharData? ((element | Reference | CDSect | PI | Comment) CharData?)*

private enum Content {
  case text(String)
  case element(Element)
  case reference(String)
  case cDataSection(String)
  case processingInstructions(ProcessingInstructions)
  case comment(String)
}

private let content = Many {
  Skip { Whitespace() }
  OneOf {
    characterData.map(Content.text)
    Lazy { element }.map(Content.element)
    reference.map(Content.reference)
    cDataSection.map(Content.cDataSection)
    processingInstructions.map(Content.processingInstructions)
    comment.map(Content.comment)
  }
  Skip { Whitespace() }
}

// [44]     EmptyElemTag     ::=     '<' Name (S Attribute)* S? '/>'  [WFC: Unique Att Spec]

private let emptyElementTag = Parse {
  "<".utf8
  name
  Many {
    Skip { atLeastOneWhiteSpace }
    attribute
  }
  Skip { Whitespace() }
  "/>".utf8
}.map(ElementTag.empty)

// MARK: - Element Type Declarations

// https://www.w3.org/TR/xml/#NT-elementdecl

// [45]     elementdecl     ::=     '<!ELEMENT' S Name S contentspec S? '>'  [VC: Unique Element Type Declaration]
// [46]     contentspec     ::=     'EMPTY' | 'ANY' | Mixed | children

private struct ElementDeclaration {
  var name: String
  var contentSpecification: ContentSpecification
}

private let elementDeclaration = Parse {
  "<!ELEMENT".utf8
  Parse {
    Skip { atLeastOneWhiteSpace }
    name
    Skip { atLeastOneWhiteSpace }
    contentSpecification
    Skip { Whitespace() }
  }
  ">".utf8
}.map(ElementDeclaration.init)

private let contentSpecification = OneOf {
  "EMPTY".utf8.map { ContentSpecification.empty }
  "ANY".utf8.map { ContentSpecification.any }
  mixed
  children
}

private enum ContentSpecification {
  case empty
  case any
  case mixed(elementNames: [String])
  case children(ContentParticle)
}

// MARK: - Element Content

// https://www.w3.org/TR/xml/#NT-children

// [47]     children     ::=     (choice | seq) ('?' | '*' | '+')?

private let children = Parse {
  OneOf {
    oneOfElements.map(ContentParticle.Element.oneOf)
    orderedElements.map(ContentParticle.Element.ordered)
  }
  particleCount
}
.map(ContentParticle.init)
.map(ContentSpecification.children)

// [48]     cp     ::=     (Name | choice | seq) ('?' | '*' | '+')?

private var contentParticle: AnyParser<Input, ContentParticle> {
  Parse {
    OneOf {
      name.map(ContentParticle.Element.named)
      oneOfElements.map(ContentParticle.Element.oneOf)
      orderedElements.map(ContentParticle.Element.ordered)
    }
    particleCount
  }
  .map(ContentParticle.init)
  .eraseToAnyParser()
}

private let particleCount = OneOf {
  "?".utf8.map { ContentParticle.Count.zeroOrOne }
  "*".utf8.map { ContentParticle.Count.zeroOrMore }
  "+".utf8.map { ContentParticle.Count.oneOrMore }
  Always(ContentParticle.Count.one) // TODO: Which would you do Always, nil coalescing or optional init?
}

private struct ContentParticle {
  init(element: ContentParticle.Element, count: ContentParticle.Count) {
    self.element = element
    self.count = count
  }

  var element: Element
  var count: Count

  enum Element {
    case named(String)
    indirect case oneOf([ContentParticle]) // should be at least 2
    indirect case ordered([ContentParticle]) // at least one
  }

  enum Count {
    case one
    case oneOrMore // +
    case zeroOrMore // *
    case zeroOrOne // ?
  }
}

// [49]     choice     ::=     '(' S? cp ( S? '|' S? cp )+ S? ')'  [VC: Proper Group/PE Nesting]
private let oneOfElements = Parse {
  "(".utf8
  Many(atLeast: 2) {
    Skip { Whitespace() }
    Lazy { contentParticle }
    Skip { Whitespace() }
  } separatedBy: {
    "|".utf8
  }
  ")".utf8
}

// [50]     seq     ::=     '(' S? cp ( S? ',' S? cp )* S? ')'  [VC: Proper Group/PE Nesting]
private let orderedElements = Parse {
  "(".utf8
  Many(atLeast: 1) {
    Skip { Whitespace() }
    Lazy { contentParticle }
    Skip { Whitespace() }
  } separatedBy: {
    ",".utf8
  }
  ")".utf8
}

// MARK: - Mixed Content

// https://www.w3.org/TR/xml/#NT-Mixed

// [51]     Mixed     ::=     '(' S? '#PCDATA' (S? '|' S? Name)* S? ')*' | '(' S? '#PCDATA' S? ')'
// [VC: Proper Group/PE Nesting] [VC: No Duplicate Types]

private let mixed = OneOf {
  Parse {
    "(".utf8
    Skip { atLeastOneWhiteSpace }
    "#PCDATA".utf8
    Many {
      Skip { atLeastOneWhiteSpace }
      "|".utf8
      Skip { atLeastOneWhiteSpace }
      name
    }
    Skip { atLeastOneWhiteSpace }
    ")*".utf8
  }.map(ContentSpecification.mixed)
  Parse {
    "(".utf8
    Skip { atLeastOneWhiteSpace }
    "#PCDATA".utf8
    Skip { atLeastOneWhiteSpace }
    ")".utf8
  }.map { ContentSpecification.mixed(elementNames: []) }
}

// MARK: - Attribute-List Declarations

// https://www.w3.org/TR/xml/#NT-AttlistDecl

// [52]     AttlistDecl     ::=     '<!ATTLIST' S Name AttDef* S? '>'

private struct AttributeListDeclaration {
  var elementName: String
  var attributeDefinitions: [AttributeDefinition]
}

private let attributeListDeclaration = Parse {
  "<!ATTLIST".utf8
  Skip { atLeastOneWhiteSpace }
  name
  Many { attributeDefinition }
  Skip { Whitespace() }
  ">".utf8
}.map(AttributeListDeclaration.init)

// [53]     AttDef     ::=     S Name S AttType S DefaultDecl

private struct AttributeDefinition {
  var name: String
  var type: AttributeType
  var defaults: AttributeDefaults
}

private let attributeDefinition = Parse {
  Skip { atLeastOneWhiteSpace }
  name
  Skip { atLeastOneWhiteSpace }
  attributeType
  Skip { atLeastOneWhiteSpace }
  attributeDefaults
}.map(AttributeDefinition.init)

// MARK: - Attribute Types

// https://www.w3.org/TR/xml/#NT-AttType

//  [54]     AttType     ::=     StringType | TokenizedType | EnumeratedType

private let attributeType = OneOf {
  "CDATA".utf8.map { AttributeType.string }
  tokenizedType.map(AttributeType.tokenized)
  enumeratedType.map(AttributeType.enumerated)
}

private enum AttributeType {
  case string
  case tokenized(TokenizedType)
  case enumerated(EnumeratedType)
}

//  [55]     StringType     ::=     'CDATA'
//  [56]     TokenizedType     ::=
// 'ID'  [VC: ID] [VC: One ID per Element Type] [VC: ID Attribute Default]
//  | 'IDREF'  [VC: IDREF]
//  | 'IDREFS'  [VC: IDREF]
//  | 'ENTITY'  [VC: Entity Name]
//  | 'ENTITIES'  [VC: Entity Name]
//  | 'NMTOKEN'  [VC: Name Token]
//  | 'NMTOKENS'  [VC: Name Token]

private let tokenizedType = OneOf {
  "ID".utf8.map { TokenizedType.id }
  "IDREF".utf8.map { TokenizedType.idRef }
  "IDREFS".utf8.map { TokenizedType.idRefs }
  "ENTITY".utf8.map { TokenizedType.entity }
  "ENTITIES".utf8.map { TokenizedType.entities }
  "NMTOKEN".utf8.map { TokenizedType.nameToken }
  "NMTOKENS".utf8.map { TokenizedType.nameTokens }
}

private enum TokenizedType {
  case id
  case idRef
  case idRefs
  case entity
  case entities
  case nameToken
  case nameTokens
}

// MARK: - Enumerated Attribute Types

// https://www.w3.org/TR/xml/#NT-EnumeratedType

// [57]     EnumeratedType     ::=     NotationType | Enumeration

private let enumeratedType = OneOf {
  notationType
  enumeration
}

private enum EnumeratedType {
  case notation([String])
  case enumeration([String])
}

// [58]     NotationType     ::=     'NOTATION' S '(' S? Name (S? '|' S? Name)* S? ')'
// [VC: Notation Attributes] [VC: One Notation Per Element Type] [VC: No Notation on Empty Element] [VC: No Duplicate Tokens]

private let notationType = Parse {
  "NOTATION".utf8
  Skip { atLeastOneWhiteSpace }
  "(".utf8
  Many(atLeast: 1) {
    Skip { Whitespace() }
    name
    Skip { Whitespace() }
  } separatedBy: {
    "|".utf8
  }
  ")".utf8
}.map(EnumeratedType.notation)

// [59]     Enumeration     ::=     '(' S? Nmtoken (S? '|' S? Nmtoken)* S? ')'
// [VC: Enumeration] [VC: No Duplicate Tokens]

private let enumeration = Parse {
  "(".utf8
  Many(atLeast: 1) {
    Skip { Whitespace() }
    nameToken
    Skip { Whitespace() }
  } separatedBy: {
    "|".utf8
  }
  ")".utf8
}.map(EnumeratedType.enumeration)

// MARK: - Attribute Defaults

// https://www.w3.org/TR/xml/#NT-DefaultDecl

// [60]     DefaultDecl     ::=     '#REQUIRED' | '#IMPLIED' | (('#FIXED' S)? AttValue)
// [VC: Required Attribute] [VC: Attribute Default Value Syntactically Correct] [WFC: No < in Attribute Values] [VC: Fixed Attribute Default] [WFC: No External Entity References]

private let attributeDefaults = OneOf {
  "#REQUIRED".utf8.map { AttributeDefaults.required }
  "#IMPLIED".utf8.map { AttributeDefaults.implied }
  fixedDefaultValue.map(AttributeDefaults.fixed)
  attributeValue.map(AttributeDefaults.default)
}

private let fixedDefaultValue = Parse {
  "#FIXED".utf8
  Skip { atLeastOneWhiteSpace }
  attributeValue
}

private enum AttributeDefaults {
  case required
  case implied
  case fixed(String)
  case `default`(String)
}

// TODO: Condition Sections

// [61]     conditionalSect     ::=     includeSect | ignoreSect
// [62]     includeSect     ::=     '<![' S? 'INCLUDE' S? '[' extSubsetDecl ']]>'  [VC: Proper Conditional Section/PE Nesting]
// [63]     ignoreSect     ::=     '<![' S? 'IGNORE' S? '[' ignoreSectContents* ']]>'  [VC: Proper Conditional Section/PE Nesting]
// [64]     ignoreSectContents     ::=     Ignore ('<![' ignoreSectContents ']]>' Ignore)*
// [65]     Ignore     ::=     Char* - (Char* ('<![' | ']]>') Char*)

// MARK: - Entity Reference

// https://www.w3.org/TR/xml/#NT-CharRef

// [66]     CharRef     ::=     '&#' [0-9]+ ';' | '&#x' [0-9a-fA-F]+ ';'  [WFC: Legal Character]

private let characterReference = OneOf {
  Parse {
    "&#".utf8
    UTF8.prefix(1..., whileScalar: isDigit)
    ";".utf8
  }
  Parse {
    "&#x".utf8
    UTF8.prefix(1..., whileScalar: isHexDigit)
    ";".utf8
  }
}

private func isHexDigit(_ s: UnicodeScalar) -> Bool {
  isDigit(s) || "A"..."F" ~= s || "a"..."f" ~= s
}

// [67]    Reference    ::=     EntityRef | CharRef

private let reference = OneOf {
  entityReference
  characterReference
}

// [68]     EntityRef     ::=     '&' Name ';'  [WFC: Entity Declared] [VC: Entity Declared] [WFC: Parsed Entity] [WFC: No Recursion]

private let entityReference = Parse {
  "&".utf8
  name
  ";".utf8
}

// [69]     PEReference     ::=     '%' Name ';'  [VC: Entity Declared] [WFC: No Recursion] [WFC: In DTD]

private let parameterEntityReference = Parse {
  "%".utf8
  name
  ";".utf8
}

// MARK: - Entity Declarations

// https://www.w3.org/TR/xml/#NT-EntityDecl

// [70]     EntityDecl     ::=     GEDecl | PEDecl
// [71]     GEDecl     ::=     '<!ENTITY' S Name S EntityDef S? '>'
// [72]     PEDecl     ::=     '<!ENTITY' S '%' S Name S PEDef S? '>'

private enum EntityDeclaration {
  case general(String, EntityDefinition)
  case parameter(String, ParameterEntityDefinition)
}

private let entityDeclaration = Parse {
  "<!ENTITY".utf8
  Skip { atLeastOneWhiteSpace }
  OneOf {
    generalEntityDeclaration.map(EntityDeclaration.general)
    parameterEntityDeclaration.map(EntityDeclaration.parameter)
  }
  Skip { Whitespace() }
  ">".utf8
}

private let generalEntityDeclaration = Parse {
  name
  Skip { atLeastOneWhiteSpace }
  entityDefinition
}

private let parameterEntityDeclaration = Parse {
  "%".utf8
  Skip { atLeastOneWhiteSpace }
  name
  Skip { atLeastOneWhiteSpace }
  parameterEntityDefinition
}

// [73]     EntityDef     ::=     EntityValue | (ExternalID NDataDecl?)

private enum EntityDefinition {
  case `internal`([String])
  case external(ExternalID, String?)
}

private let entityDefinition = OneOf {
  entityValue.map(EntityDefinition.internal)
  Parse {
    externalId
    Optionally { notationDataDeclaration }
  }.map(EntityDefinition.external)
}

// [74]     PEDef     ::=     EntityValue | ExternalID

private enum ParameterEntityDefinition {
  case `internal`([String])
  case external(ExternalID)
}

private let parameterEntityDefinition = OneOf {
  entityValue.map(ParameterEntityDefinition.internal)
  externalId.map(ParameterEntityDefinition.external)
}

// MARK: - External Entity Declaration

// https://www.w3.org/TR/xml/#NT-ExternalID

// [75]     ExternalID     ::=     'SYSTEM' S SystemLiteral | 'PUBLIC' S PubidLiteral S SystemLiteral

private enum ExternalID {
  case system(String)
  case `public`(String, String)
}

private let externalId = OneOf {
  Parse {
    "SYSTEM".utf8
    Skip { atLeastOneWhiteSpace }
    systemLiteral
  }.map(ExternalID.system)
  Parse {
    "PUBLIC".utf8
    Skip { atLeastOneWhiteSpace }
    publicIdLiteral
    Skip { atLeastOneWhiteSpace }
    systemLiteral
  }.map(ExternalID.public)
}

// [76]     NDataDecl     ::=     S 'NDATA' S Name  [VC: Notation Declared]

private let notationDataDeclaration = Parse {
  Skip { atLeastOneWhiteSpace }
  "NDATA".utf8
  Skip { atLeastOneWhiteSpace }
  name
}

// TODO: Parsed Entities
// [77]     TextDecl     ::=     '<?xml' VersionInfo? EncodingDecl S? '?>'
// [78]     extParsedEnt     ::=     TextDecl? content

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

// MARK: - Notation Declarations

// https://www.w3.org/TR/xml/#NT-NotationDecl

// [82]     NotationDecl     ::=     '<!NOTATION' S Name S (ExternalID | PublicID) S? '>'  [VC: Unique Notation Name]

private struct NotationDeclaration {
  var name: String
  var id: ID

  enum ID {
    case external(ExternalID)
    case `public`(String)
  }
}

private let notationDeclaration = Parse {
  "<!NOTATION".utf8
  Skip { atLeastOneWhiteSpace }
  name
  Skip { atLeastOneWhiteSpace }
  OneOf {
    externalId.map(NotationDeclaration.ID.external)
    publicId.map(NotationDeclaration.ID.public)
  }
  ">".utf8
}.map(NotationDeclaration.init)

// [83]     PublicID     ::=     'PUBLIC' S PubidLiteral
private let publicId = Parse {
  "PUBLIC".utf8
  Skip { atLeastOneWhiteSpace }
  publicIdLiteral
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
    _ length: PartialRangeFrom<Int>,
    whileScalar predicate: @escaping (UnicodeScalar) -> Bool
  ) -> AnyParser<Substring.UTF8View, String> {
    prefix(minLength: length.lowerBound, whileScalar: predicate)
  }

  fileprivate static func prefix(
    whileScalar predicate: @escaping (UnicodeScalar) -> Bool,
    orUpTo possibleMatch: String.UTF8View
  ) -> AnyParser<Substring.UTF8View, String> {
    AnyParser { input in
      var utf8Decoder = Unicode.UTF8()
      var bytesIterator = input.makeIterator()
      var count = 0

      Decode: while !bytesIterator.starts(with: possibleMatch) {
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

// MARK: - Benchmarks

let xmlSuite = BenchmarkSuite(name: "XML") { suite in
  let input = """
  <note>
    <to>Tove</to>
    <from>Jani</from>
    <heading>Reminder</heading>x
    <body>Don't forget me this weekend!</body>
  </note>
  """

  suite.benchmark("Parser") {
    let xml = document.parse(input)
  }

  suite.benchmark("XMLParser") {
    let xml = try! XMLDocument(xmlString: input)
  }
}
