import Benchmark
import Parsing

/*
 This benchmark demonstrates how to parse on multiple string abstractions at once, and the costs
 of doing so. The parsers benchmarked parse a list of integers that are separated by a
 UTF8 character with multiple equivalent representations: "é" and "é".

 In the "Substring" suite we parse integers on the UTF8View abstraction and parse the separator
 on the Substring abstraction in order to take advantage of its UTF8 normalization logic.

 In the "UTF8" suite we parse both the integers and the separators on the UTF8View abstraction,
 but this means we are responsible for handling UTF8 normalization, so we have to explicitly
 handle both the "é" and "é" characters.
 */
let stringAbstractionsSuite = BenchmarkSuite(name: "String Abstractions") { suite in
  let count = 1000
  let input = (1...count)
    .reduce(into: "") { accum, int in
      accum += "\(int % Int(UInt8.max))" + (int.isMultiple(of: 2) ? "é" : "é")
    }
    .dropLast()

  suite.benchmark("Substring") {
    var input = input[...].utf8
    let output = Many {
      Int.parser()
    } separatedBy: {
      FromSubstring { "é" }
    }
    .parse(&input)
    precondition(output?.count == count)
  }

  suite.benchmark("UTF8") {
    var input = input[...].utf8
    let output = Many {
      Int.parser()
    } separatedBy: {
      OneOf {
        "é".utf8
        "é".utf8
      }
    }
    .parse(&input)
    precondition(output?.count == count)
  }

  suite.benchmark("StringSubstring") {
    var input = input[...].utf8
    let output = Many {
      UInt8.parser()
    } separatedBy: {
      FromSubstring { "é" }
    }
    .pipe { String.parser(of: [UInt8].self) }
    .parse(&input)
//    precondition(output?.count == count)
  }

  suite.benchmark("StringUTF8") {
    var input = input[...].utf8
    let output = Many {
      UInt8.parser()
    } separatedBy: {
      OneOf {
        "é".utf8
        "é".utf8
      }
    }
    .pipe { String.parser(of: [UInt8].self) }
    .parse(&input)
//    precondition(output?.count == count)
  }

  suite.benchmark("StringArraySlice") {
    var input = ArraySlice(input[...].utf8)
    let output = Many {
      Prefix(1).pipe { String.parser() }
    } separatedBy: {
      OneOf {
        Array("é".utf8)
        Array("é".utf8)
      }
    }
    .parse(&input)
//    precondition(output?.count == count)
  }
}
