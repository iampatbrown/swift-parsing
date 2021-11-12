public struct ElementsEqual<Input>: Parser
  where
  Input: Collection,
  Input.SubSequence == Input
{
  public let elements: AnyCollection<Input.Element>
  public let areEquivalent: (Input.Element, Input.Element) -> Bool

  @inlinable
  public init<Elements>(
    _ elements: Elements,
    by areEquivalent: @escaping (Input.Element, Input.Element) -> Bool
  )
    where
    Elements: Collection,
    Elements.Element == Input.Element
  {
    self.elements = AnyCollection(elements)
    self.areEquivalent = areEquivalent
  }

  @inlinable
  public func parse(_ input: inout Input) -> Void? {
    guard input.elementsEqual(self.elements, by: self.areEquivalent)
    else { return nil }
    input.removeFirst(input.count)
    return ()
  }
}

extension ElementsEqual where Input.Element: Equatable {
  @inlinable
  public init<Elements>(_ elements: Elements)
    where
    Elements: Collection,
    Elements.Element == Input.Element
  {
    self.init(elements, by: ==)
  }
}

extension ElementsEqual: Printer where Input: RangeReplaceableCollection {
  public func print(_ output: Void) -> Input? {
    Input(self.elements)
  }
}
