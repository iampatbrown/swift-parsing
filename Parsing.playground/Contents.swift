import Parsing

struct User {
  var id: Int
  var name: String
  var isAdmin: Bool
}

let user = OneOf {
  Parse {
    Int.parser()
    //FromUTF8View { Whitespace() }.preferredPrinting("")
    "\t"
    Prefix { $0 != "\t" }
    "\t"
    Bool.parser()
  }
  Parse {
    Int.parser()
    ","
    Prefix { $0 != "," }
    ","
    Bool.parser()
  }
}
//  .map { User(id: $0, name: String($1), isAdmin: $2) }

let users = Many { user } separatedBy: { "\n" }


user.parse("42,Blob,true")
user.parse("42\tBlob\ttrue")
users.parse("""
42,Blob,true
43,Blob Jr,false
44,Blob Sr,true
""")
// [(42, "Blob", true), (43, "Blob Jr", false), (44, "Blob Sr", true)]

//user.print((42, "Blob", true))

users.print([
  (42, "Blob", true),
  (43, "Blob Jr", false),
  (44, "Blob Sr", true),
])

//
//Many<
//  OneOf<
//    OneOf2<
//      Parse<
//        Zip5_OVOVO<
//          Parsers.SubstringIntParser<Int>,
//          String,
//          Prefix<Substring>,
//          String,
//          Parsers.SubstringBoolParser
//        >
//      >,
//      Parse<
//        Zip5_OVOVO<
//          Parsers.SubstringIntParser<Int>,
//          String,
//          Prefix<Substring>,
//          String,
//          Parsers.SubstringBoolParser
//        >
//      >
//    >
//  >,
//  [(Int, Substring, Bool)],
//  String
//>


11



//struct Color {
//  let red, green, blue: UInt8
//}
//
//let hexPrimary = Prefix(2)
//  .compactMap { UInt8($0, radix: 16) }
//
//let hexColor = Parse {
//  "#"
//  hexPrimary
//  hexPrimary
//  hexPrimary
//}
//.map(Color.init)
//
//do {
//  var hex = "#000000"[...]
//  print(hexColor.parse(&hex)!)
//}
//
//do {
//  var hex = "#FF0000"[...]
//  print(hexColor.parse(&hex)!)
//}
