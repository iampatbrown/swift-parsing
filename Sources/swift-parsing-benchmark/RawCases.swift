import Benchmark
import Foundation
import Parsing

let rawCasesSuite = BenchmarkSuite(name: "String Abstractions") { suite in
//
//  let input = "100"
//
//  enum EnumString: String {
//    case ten = "10"
//    case one = "1"
//    case two = "2"
//  }
//
//  suite.benchmark("String") {
//    var input = input[...].utf8
//    let output = StringRepresentableCaseParser(in: [EnumString.ten, EnumString.two])
//      .parse(&input)
//    precondition(output! == .ten && input.elementsEqual("0"[...].utf8))
//  }
//
//  enum EnumInt: Int {
//    case ten = 10
//    case one = 1
//    case negativeOne = -1
//  }
//
//  suite.benchmark("Int") {
//    var input = input[...].utf8
//    let output = FixedWidthIntegerRepresentableCaseParser(in: [EnumInt.ten, EnumInt.one, EnumInt.negativeOne])
//      .parse(&input)
//    precondition(output! == .one && input.elementsEqual("00"[...].utf8))
//  }
//
//  let negativeInput = "-100"
//  suite.benchmark("Negative Int") {
//    var input = negativeInput[...].utf8
//    let output = FixedWidthIntegerRepresentableCaseParser(in: [EnumInt.ten, EnumInt.one, EnumInt.negativeOne])
//      .parse(&input)
//
//    precondition(output! == .negativeOne && input.elementsEqual("00"[...].utf8))
//  }
//
//  enum EnumCharacter: Character {
//    case one = "1"
//    case chicken = "🐥"
//  }
//
//  suite.benchmark("Character") {
//    var input = input[...].utf8
//    let output = CharacterRepresentableCaseParser(in: [EnumCharacter.one, EnumCharacter.chicken])
//      .parse(&input)
//    precondition(output! == .one && input.elementsEqual("00"[...].utf8))
//  }
//
//  let chickenInput = "🐥100"
//  suite.benchmark("Chicken") {
//    var input = chickenInput[...].utf8
//    let output = CharacterRepresentableCaseParser(in: [EnumCharacter.one, EnumCharacter.chicken])
//      .parse(&input)
//    precondition(output! == .chicken && input.elementsEqual("100"[...].utf8))
//  }
//
//
//
//  suite.benchmark("StartsWithChicken") {
//    var input = chickenInput[...].utf8
//    let output = StartsWith("🐥".utf8)
//      .parse(&input)
//    precondition(output! == () && input.elementsEqual("100"[...].utf8))
//  }

  struct Thing: Equatable {
    var type_a: TypeA
    var type_b: TypeB
  }

  enum TypeA: String, CaseIterable {
    case one
  }

  enum TypeB: String, CaseIterable {
    case two
  }

  let input = "thing:one:two"

  func digits(for n: Int) -> [Int] {
    var digits: [Int] = []
    var n = n
    digits.append(n % 10)
    while n >= 10 || n <= -10 { // TODO: Fix this
      n = n / 10
      digits.append(n % 10)
    }

    return digits.reversed()
  }

  func digitsString(for n: Int) -> [Int] {
    String(describing: n).compactMap { Int(String($0)) }
  }

  func pow (_ base:Int, _ power:UInt) -> Int {
    var answer : Int = 1
    for _ in 0..<power { answer *= base }
    return answer
  }

  let bigNumber = Int(Array(repeating: "1", count: 10).joined())!
  struct WrappedInt: RawRepresentable {
    var rawValue: Int

    static let input = Self(rawValue: Int(Array(repeating: "1", count: 10).joined())!)
  }
  print(WrappedInt.input.rawValue)

  let nInput = Array(repeating: "1", count: 100).joined() + "A"
  suite.benchmark("digits") {
//    var input = nInput[...].utf8
//    print(input)

    let _ = digits(for: bigNumber)
//    let output = WrappedInt.parser(possibleCases: [.input]).parse(&input)
//    precondition(output! == .input)
  }

  suite.benchmark("digitsString") {
    let _ = digitsString(for: bigNumber)
//    let output = WrappedInt.parser(possibleCases: [.input]).parse(&input)
//    precondition(output! == .input)
  }
}
