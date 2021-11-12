import Parsing
import XCTest

final class MapTests: XCTestCase {
  func testSuccess() {
    var input = "42 Hello, world!"[...].utf8
    XCTAssertEqual("42", Int.parser().map(String.init).parse(&input))
    XCTAssertEqual(" Hello, world!", Substring(input))
  }

  func testOverloadArray() {
    let array = [1].map { "\($0)" }
    XCTAssert(type(of: array) == [String].self)
  }

  func testOverloadString() {
    let array = "abc".map { "\($0)" }
    XCTAssert(type(of: array) == [String].self)
  }

  func testOverloadUnicodeScalars() {
    let array = "abc".unicodeScalars.map { "\($0)" }
    XCTAssert(type(of: array) == [String].self)
  }

  func testOverloadUTF8View() {
    let array = "abc".utf8.map { "\($0)" }
    XCTAssert(type(of: array) == [String].self)
  }

  func testMapViaParser() {
    struct Thing: RawRepresentable, CaseIterable, Equatable {
      var rawValue: String

      static let a = Self(rawValue: "a")
      static let ab = Self(rawValue: "ab")
      static let abc = Self(rawValue: "abc")

      static let allCases: [Thing] = [a, ab, abc]
    }

    XCTAssertEqual(Thing.fromRawCase.parse("a")!, .a)
    XCTAssertEqual(Thing.fromRawCase.parse("ab")!, .ab)
    XCTAssertEqual(Thing.fromRawCase.parse("abc")!, .abc)
    XCTAssertEqual(Thing.fromRawCase.print(.a)!, "a")
    XCTAssertEqual(Thing.fromRawCase.print(.ab)!, "ab")
    XCTAssertEqual(Thing.fromRawCase.print(.abc)!, "abc")

  }
}
