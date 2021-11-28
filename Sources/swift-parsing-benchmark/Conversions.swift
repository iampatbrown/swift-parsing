import Benchmark
import Parsing

struct User: Equatable {
  var id: Int
  var name: String
  var isAdmin: Bool
}

let user = Parse {
  Int.parser()
  ","
  Prefix { $0 != "," }.pipe { String.parser() }
  ","
  Bool.parser()
}

extension Conversion where Input == (Int, String, Bool) {
  static var user: Conversion<Input, User> {
    .init(apply: User.init(id:name:isAdmin:), unapply: { ($0.id, $0.name, $0.isAdmin) })
  }
}

let conversionsSuite = BenchmarkSuite(name: "Conversions") { suite in

  let input = "1,Blob,true"

  let expected = User(id: 1, name: "Blob", isAdmin: true)
  let printed = input
  do {
    let parser = user.convert(apply: User.init(id:name:isAdmin:), unapply: { ($0.id, $0.name, $0.isAdmin) })

    suite.benchmark("Covert apply:unapply:") {
      var input = input[...]
      let output = parser.parse(&input)!
      precondition(output == expected)
      let printOutput = parser.print(output)
      precondition(printOutput == printed[...])
    }
  }

  do {
    let conversion = Conversion<(Int, String, Bool), User>(
      apply: User.init(id:name:isAdmin:), unapply: { ($0.id, $0.name, $0.isAdmin) }
    )
    let parser = user.convert(conversion)

    suite.benchmark("Covert conversion") {
      var input = input[...]
      let output = parser.parse(&input)!
      precondition(output == expected)
      let printOutput = parser.print(output)
      precondition(printOutput == printed[...])
    }
  }

  do {
    let parser = user.convert(.user)

    suite.benchmark("Covert conversion") {
      var input = input[...]
      let output = parser.parse(&input)!
      precondition(output == expected)
      let printOutput = parser.print(output)
      precondition(printOutput == printed[...])
    }
  }

  do {
    let parser = user.pipe { UnsafeBitCast(User.init(id:name:isAdmin:)) }

    suite.benchmark("UnsafeBitCast") {
      var input = input[...]
      let output = parser.parse(&input)!
      precondition(output == expected)
      let printOutput = parser.print(output)
      precondition(printOutput == printed[...])
    }
  }
}
