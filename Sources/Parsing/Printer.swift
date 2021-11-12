public protocol Printer {
  associatedtype Input
  associatedtype Output

  func print(_ output: Output) -> Input?
}


//public protocol Path {
//  associatedtype Root
//  associatedtype Value
//  func extract(from root: Root) -> Value?
//  func set(into root: inout Root, _ value: Value)
//}
