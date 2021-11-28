public struct Join<Input>: ParserPrinter
  where
  Input: AppendableCollection,
  Input.Element: AppendableCollection
{
  public let separator: Input.Element.Element?

  public init(separator: Input.Element.Element? = nil) {
    self.separator = separator
  }

  @inlinable
  public func parse(_ input: inout Input) -> Input.Element? {
    var output = Input.Element()
    for chunk in input {
      output.append(contentsOf: chunk)
      if let separator = self.separator {
        output.append(contentsOf: [separator])
      }
    }
    return output
  }

  @inlinable
  public func print(_ output: Input.Element) -> Input? {
    Input(output.map { .init([$0]) })
  }
}
