import Benchmark
import Foundation
import Parsing

let readmeExampleSuite = BenchmarkSuite(name: "README Example") { suite in
  let input = """
  1,Blob,true
  2,Blob Jr.,false
  3,Blob Sr.,true
  """
  let expectedOutput = [
    User(id: 1, name: "Blob", isAdmin: true),
    User(id: 2, name: "Blob Jr.", isAdmin: false),
    User(id: 3, name: "Blob Sr.", isAdmin: true),
  ]
  var output: [User]!

  struct User: Equatable {
    var id: Int
    var name: String
    var isAdmin: Bool
  }

  do {
    let user = Parse {
      Int.parser()
      ","
      Prefix { $0 != "," }
      ","
      Bool.parser()
    }
    .map { User(id: $0, name: String($1), isAdmin: $2) }
    let users = Many {
      user
    } separatedBy: {
      "\n"
    }

    suite.benchmark(
      name: "Parser: Substring",
      run: {
        var input = input[...]
        output = users.parse(&input)!
      },
      tearDown: {
        precondition(output == expectedOutput)
      }
    )
  }

  do {
    let user = Parse {
      Int.parser()
      ","
      Prefix { $0 != "," }
      ","
      Bool.parser()
    }
    .map { User(id: $0, name: String($1), isAdmin: $2) }

    let userParserPrinter = user.withPrinter { "\($0.id),\($0.name),\($0.isAdmin)"[...] }

    let users = Many {
      userParserPrinter
    } separatedBy: {
      "\n"
    }

    suite.benchmark(
      name: "ParserPrinter.parse: Substring",
      run: {
        var input = input[...]
        output = users.parse(&input)!
      },
      tearDown: {
        precondition(output == expectedOutput)
      }
    )

    var printed: Substring!
    suite.benchmark(
      name: "ParserPrinter.print: Substring",
      run: {
        printed = users.print(expectedOutput)!
      },
      tearDown: {
        precondition(String(printed) == input)
      }
    )
  }

  do {
    let user = Parse {
      Int.parser()
      ",".utf8
      Prefix { $0 != .init(ascii: ",") }
      ",".utf8
      Bool.parser()
    }
    .map { User(id: $0, name: String(Substring($1)), isAdmin: $2) }
    let users = Many {
      user
    } separatedBy: {
      "\n".utf8
    }

    suite.benchmark(
      name: "Parser: UTF8",
      run: {
        var input = input[...].utf8
        output = users.parse(&input)!
      },
      tearDown: {
        precondition(output == expectedOutput)
      }
    )
  }

  do {
    let user = Parse {
      Int.parser()
      ",".utf8
      Prefix { $0 != .init(ascii: ",") }
      ",".utf8
      Bool.parser()
    }
    .map { User(id: $0, name: String(Substring($1)), isAdmin: $2) }

    let userParserPrinter = user.withPrinter { "\($0.id),\($0.name),\($0.isAdmin)"[...].utf8 }

    let users = Many {
      userParserPrinter
    } separatedBy: {
      "\n".utf8
    }

    suite.benchmark(
      name: "ParserPrinter.parse: UTF8",
      run: {
        var input = input[...].utf8
        output = users.parse(&input)!
      },
      tearDown: {
        precondition(output == expectedOutput)
      }
    )

    var printed: Substring.UTF8View!
    suite.benchmark(
      name: "ParserPrinter.print: UTF8",
      run: {
        printed = users.print(expectedOutput)!
      },
      tearDown: {
        precondition(String(printed) == input)
      }
    )
  }

  suite.benchmark(
    name: "Adhoc",
    run: {
      output =
        input
          .split(separator: "\n")
          .compactMap { row -> User? in
            let fields = row.split(separator: ",")
            guard
              fields.count == 3,
              let id = Int(fields[0]),
              let isAdmin = Bool(String(fields[2]))
            else { return nil }

            return User(id: id, name: String(fields[1]), isAdmin: isAdmin)
          }
    },
    tearDown: {
      precondition(output == expectedOutput)
    }
  )

  if #available(macOS 10.15, *) {
    let scanner = Scanner(string: input)
    suite.benchmark(
      name: "Scanner",
      setUp: { scanner.currentIndex = input.startIndex },
      run: {
        output = []
        while scanner.currentIndex != input.endIndex {
          guard
            let id = scanner.scanInt(),
            let _ = scanner.scanString(","),
            let name = scanner.scanUpToString(","),
            let _ = scanner.scanString(","),
            let isAdmin = scanner.scanBool()
          else { break }

          output.append(User(id: id, name: name, isAdmin: isAdmin))
          _ = scanner.scanString("\n")
        }
      },
      tearDown: {
        precondition(output == expectedOutput)
      }
    )
  }
}

extension Scanner {
  @available(macOS 10.15, *)
  func scanBool() -> Bool? {
    self.scanString("true").map { _ in true }
      ?? self.scanString("false").map { _ in false }
  }
}
