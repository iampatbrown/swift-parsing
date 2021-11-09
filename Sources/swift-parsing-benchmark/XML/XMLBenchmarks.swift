import Benchmark
import Parsing

let xmlSuite = BenchmarkSuite(name: "XML") { suite in
  let noteXml = #"""
  <?xml version="1.0" encoding="utf-8"?>
  <note>
  <to>Tove</to>
  <from>Jani</from>
  <heading>Reminder</heading>
  <body>Don't forget me this weekend!</body>
  </note>
  """#
  var output: [XML] = []
  suite.benchmark(
    name: "Parser",
    run: {
      output = xml.parse(noteXml)!
    },
    tearDown: {
      if case .element("note", _, _) = output.dropFirst().first! {
      } else {
        preconditionFailure()
      }
    }
  )
}

// MARK: - XML Type

public enum XML {
  public typealias Parameters = [String: String]
  case doctype(Parameters)
  indirect case element(String, Parameters, [XML])
  case text(String)
  case comment(String)
}

extension XML: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .doctype(parameters):
      return ".doctype(\(parameters))"
    case let .element(type, parameters, content):
      return ".element(\(type), \(parameters), [\(content)])"
    case let .text(string):
      return string
    case let .comment(comment):
      return "<!--\(comment)-->"
    }
  }
}

extension XML: Equatable {
  public static func == (lhs: XML, rhs: XML) -> Bool {
    switch (lhs, rhs) {
    case
      let (.doctype(lhsAttributes), .doctype(rhsAttributes)):
      return lhsAttributes == rhsAttributes
    case
      let (.comment(lhs), .comment(rhs)),
      let (.text(lhs), .text(rhs)):
      return lhs == rhs
    case let (
      .element(lhsTag, lhsParameters, lhsChildren),
      .element(rhsTag, rhsParameters, rhsChildren)
    ):
      return lhsTag == rhsTag
        && lhsParameters == rhsParameters
        && lhsChildren == rhsChildren
    default:
      return false
    }
  }
}

// MARK: - Parser

private typealias Input = Substring.UTF8View

// private let tag = "<".utf8
//  .take(Prefix { $0 != .init(ascii: ">") })
//  .skip(">".utf8)

private let tag = Parse {
  "<".utf8
  Prefix { $0 != .init(ascii: ">") }
  ">".utf8
}

//private let stringLiteral = Skip("\"".utf8)
//  .take(Prefix { $0 != .init(ascii: "\"") })
//  .skip("\"".utf8)
//  .map { String(decoding: $0, as: UTF8.self) }

 private let stringLiteral = Parse {
  "\"".utf8
  Prefix { $0 != .init(ascii: "\"") }
  "\"".utf8
 }.map { String(decoding: $0, as: UTF8.self) }

//private let parameter = Prefix<Input> { $0 != .init(ascii: "=") }.map { String(decoding: $0, as: UTF8.self) }
//  .skip("=".utf8)
//  .take(stringLiteral)
//  .map { (key: $0, value: $1) }

 private let parameter = Parse {
  Prefix { $0 != .init(ascii: "=") }.map { String(decoding: $0, as: UTF8.self) }
  "=".utf8
  stringLiteral
 }.map { (key: $0, value: $1) }

//private let parameters = Many(parameter, atLeast: 1, separator: Whitespace()).map { parameters in
//  parameters.reduce(into: [:]) { $0[$1.0] = $1.1 }
//}

 private let parameters = Many(parameter, into: XML.Parameters(), atLeast: 1) { parameters, parameter in
  parameters[parameter.key] = parameter.value
 }

//private let doctypeHead = "?xml".utf8
//  .skip(Whitespace<Input>())
//  .take(parameters)
//  .skip("?".utf8)
//  .map { parameters in
//    XML.doctype(parameters)
//  }

 private let doctypeHead = Parse {
  "?xml".utf8
  Skip { Whitespace() }
  parameters
  "?".utf8
 }.map(XML.doctype)

private let doctype = tag.pipe(doctypeHead) // Will leave the same

//private let comment = "<!--".utf8
//  .take(PrefixUpTo("-->".utf8).skip("-->".utf8))
//  .map { XML.comment(String(decoding: $0, as: UTF8.self)) }
//  .skip(Optional.parser(of: Newline().skip(Whitespace())))

 private let comment = Parse {
  "<!--".utf8
  PrefixUpTo("-->".utf8).map { String(decoding: $0, as: UTF8.self) }
  "-->".utf8
  Skip { Whitespace() }
 }.map(XML.comment)

//private let closingSlash = Optional.parser(of: "/".utf8).map { $0 != nil ? true : false }

 private let closingSlash = OneOf {
  "/".utf8.map { true }
  Always(false)
 }

// covers the following tag layouts
// <tag1 param1="value1">
// <tag2 param2="value2"/>
// <tag3 param3="value3" />
// private let tagHeadWithParameters = Prefix<Input> { $0 != .init(ascii: " ") }
//  .map { String(decoding: $0, as: UTF8.self) }
//  .skip(Whitespace())
//  .take(parameters)
//  .skip(Whitespace())
//  .take(closingSlash)
//  .skip(End())
//  .eraseToAnyParser()

private let tagHeadWithParameters = Parse {
  Prefix { $0 != .init(ascii: " ") }.map { String(decoding: $0, as: UTF8.self) }
  Skip { Whitespace() }
  parameters
  Skip { Whitespace() }
  closingSlash
  Skip { End() }
}

// covers the following tag layouts
// <tag1>
// <tag2/>
// <tag3 />
// private let tagHeadNoParameters = Prefix<Input> { $0 != .init(ascii: " ") && $0 != .init(ascii: "/") }
//  .skip(Whitespace()).take(closingSlash)

private let tagHeadNoParameters = Parse {
  Prefix { $0 != .init(ascii: " ") && $0 != .init(ascii: "/") }
  Skip { Whitespace() }
  closingSlash
}

// private let tagHead = tagHeadWithParameters
//  .orElse(tagHeadNoParameters.map { tagName, hasClosingSlash in
//    (String(decoding: tagName, as: UTF8.self), [:], hasClosingSlash)
//  })

private let tagHead = OneOf {
  tagHeadWithParameters
  tagHeadNoParameters.map { tagName, hasClosingSlash in
    (String(decoding: tagName, as: UTF8.self), XML.Parameters(), hasClosingSlash)
  }
}

private let fullTag = tag.pipe(tagHead) // Will leave the same
//
// private let singleXMLTag = fullTag
//  .flatMap { tagName, parameters, single in
//    single == true
//      ? Conditional.first(Always(XML.element(tagName, parameters, [])))
//      : Conditional.second(Fail())
//  }.skip(Optional.parser(of: Newline().skip(Whitespace())))

private let singleXMLTag = fullTag.flatMap { tagName, parameters, single in
  if single {
    Always(XML.element(tagName, parameters, []))
  }
  Skip { Whitespace() }
}

// private let containerXMLTagBody: (String) -> AnyParser<Input, Input> = { tagName in
//  let tag = "</\(tagName)>".utf8
//  return PrefixUpTo(tag)
//    .skip(tag)
//    .skip(Optional.parser(of: Newline().skip(Whitespace())))
//    .eraseToAnyParser()
// }

private let containerXMLTagBody: (String) -> AnyParser<Input, Input> = { tagName in
  Parse {
    PrefixUpTo("</\(tagName)>".utf8)
    Skip { "</\(tagName)>".utf8 }
    Skip { Whitespace() }
  }.eraseToAnyParser()
}

// private let containerXMLTag = fullTag
//  .flatMap { tagName, parameters, single in
//    single == false
//      ? Conditional.first(
//        containerXMLTagBody(tagName)
//          .pipe(Lazy { xmlBody }.skip(End()))
//          .map { xml in
//            return XML.element(tagName, parameters, xml)
//          }
//      )
//      : Conditional.second(Fail())
//  }

private let containerXMLTag = fullTag.flatMap { tagName, parameters, single in
  if !single {
    containerXMLTagBody(tagName).pipe {
      Parse {
        Lazy { xmlBody }
        Skip { End() }
      }
    }.map { xml in
      XML.element(tagName, parameters, xml)
    }
  }
}

// kan ge let worden geen erase
// private var text: AnyParser<Input, XML> {
//  Optional.parser(of: End()).flatMap {
//    $0 != nil
//      ? Conditional.first(Fail())
//      : Conditional.second(
//        Prefix<Input> { $0 != .init(ascii: "<") && $0 != .init(ascii: "\n") }
//          .map { XML.text(String(decoding: $0, as: UTF8.self)) }
//      )
//  }.skip(Optional.parser(of: Newline().skip(WhitespaceNoNewline())))
//    .eraseToAnyParser()
// }

private var text: AnyParser<Input, XML> {
  Parse {
    Prefix(1...) {
      $0 != .init(ascii: "<") && $0 != .init(ascii: "\n")
    }.map { XML.text(String(decoding: $0, as: UTF8.self)) }
    Skip {
      Whitespace()
    }
  }.eraseToAnyParser()
}

//private var xmlBody: AnyParser<Input, [XML]> {
//  Skip(Whitespace())
//    .take(
//      Many(
//        singleXMLTag
//          .orElse(containerXMLTag)
//          .orElse(comment)
//          .orElse(text)
//      )
//    )
//    .skip(Whitespace())
//    .skip(End())
//    .eraseToAnyParser()
//}

 private var xmlBody: AnyParser<Input, [XML]> {
  Parse {
    Skip {
      Whitespace()
    }
    Many {
      OneOf {
        singleXMLTag
        containerXMLTag
        comment
        text
      }
    }
    Skip {
      Whitespace()
    }
    Skip {
      End()
    }
  }.eraseToAnyParser()
 }

// kan nog beter

//private var xml: AnyParser<Substring.UTF8View, [XML]> {
//  doctype
//    .skip(Newline())
//    .take(xmlBody).map {
//      Array([[$0], $1].joined())
//    }.eraseToAnyParser()
//}

 private var xml: AnyParser<Substring.UTF8View, [XML]> {
  Parse {
    doctype
    Skip { Newline() }
    xmlBody
  }
  .map { Array([[$0], $1].joined()) }
  .eraseToAnyParser()
 }

/// A parser that consumes all ASCII whitespace from the beginning of the input except for newlines
private struct WhitespaceNoNewline<Input>: Parser
  where
  Input: Collection,
  Input.SubSequence == Input,
  Input.Element == UTF8.CodeUnit
{
  @inlinable
  public init() {}

  @inlinable
  public func parse(_ input: inout Input) -> Input? {
    let output = input.prefix(while: { (byte: UTF8.CodeUnit) in
      byte == .init(ascii: " ")
        || byte == .init(ascii: "\r")
        || byte == .init(ascii: "\t")
    })
    input.removeFirst(output.count)
    return output
  }
}
