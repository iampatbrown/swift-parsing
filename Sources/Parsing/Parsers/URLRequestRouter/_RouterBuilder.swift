@resultBuilder
public enum _RouterBuilder {
  @inlinable
  public static func buildBlock<Route>(
    _ routing: _Routing<Route>
  ) -> _Router<Route> {
    _Router(parse: routing.parse, print: routing.print)
  }
}

extension _RouterBuilder {
  @inlinable public static func buildBlock<Route>(
    _ r0: _Routing<Route>,
    _ r1: _Routing<Route>
  ) -> _Router<Route> {
    _Router(
      parse: { input in
        if let output = r0.parse(&input) { return output }
        if let output = r1.parse(&input) { return output }
        return nil
      },
      print: { output in
        if let input = r0.print(output) { return input }
        if let input = r1.print(output) { return input }
        return nil
      }
    )
  }
}

extension _RouterBuilder {
  @inlinable public static func buildBlock<Route>(
    _ r0: _Routing<Route>,
    _ r1: _Routing<Route>,
    _ r2: _Routing<Route>
  ) -> _Router<Route> {
    _Router(
      parse: { input in
        if let output = r0.parse(&input) { return output }
        if let output = r1.parse(&input) { return output }
        if let output = r2.parse(&input) { return output }
        return nil
      },
      print: { output in
        if let input = r0.print(output) { return input }
        if let input = r1.print(output) { return input }
        if let input = r2.print(output) { return input }
        return nil
      }
    )
  }
}

extension _RouterBuilder {
  @inlinable public static func buildBlock<Route>(
    _ r0: _Routing<Route>,
    _ r1: _Routing<Route>,
    _ r2: _Routing<Route>,
    _ r3: _Routing<Route>
  ) -> _Router<Route> {
    _Router(
      parse: { input in
        if let output = r0.parse(&input) { return output }
        if let output = r1.parse(&input) { return output }
        if let output = r2.parse(&input) { return output }
        if let output = r3.parse(&input) { return output }
        return nil
      },
      print: { output in
        if let input = r0.print(output) { return input }
        if let input = r1.print(output) { return input }
        if let input = r2.print(output) { return input }
        if let input = r3.print(output) { return input }
        return nil
      }
    )
  }
}

extension _RouterBuilder {
  @inlinable public static func buildBlock<Route>(
    _ r0: _Routing<Route>,
    _ r1: _Routing<Route>,
    _ r2: _Routing<Route>,
    _ r3: _Routing<Route>,
    _ r4: _Routing<Route>
  ) -> _Router<Route> {
    _Router(
      parse: { input in
        if let output = r0.parse(&input) { return output }
        if let output = r1.parse(&input) { return output }
        if let output = r2.parse(&input) { return output }
        if let output = r3.parse(&input) { return output }
        if let output = r4.parse(&input) { return output }
        return nil
      },
      print: { output in
        if let input = r0.print(output) { return input }
        if let input = r1.print(output) { return input }
        if let input = r2.print(output) { return input }
        if let input = r3.print(output) { return input }
        if let input = r4.print(output) { return input }
        return nil
      }
    )
  }
}

extension _RouterBuilder {
  @inlinable public static func buildBlock<Route>(
    _ r0: _Routing<Route>,
    _ r1: _Routing<Route>,
    _ r2: _Routing<Route>,
    _ r3: _Routing<Route>,
    _ r4: _Routing<Route>,
    _ r5: _Routing<Route>
  ) -> _Router<Route> {
    _Router(
      parse: { input in
        if let output = r0.parse(&input) { return output }
        if let output = r1.parse(&input) { return output }
        if let output = r2.parse(&input) { return output }
        if let output = r3.parse(&input) { return output }
        if let output = r4.parse(&input) { return output }
        if let output = r5.parse(&input) { return output }
        return nil
      },
      print: { output in
        if let input = r0.print(output) { return input }
        if let input = r1.print(output) { return input }
        if let input = r2.print(output) { return input }
        if let input = r3.print(output) { return input }
        if let input = r4.print(output) { return input }
        if let input = r5.print(output) { return input }
        return nil
      }
    )
  }
}

extension _RouterBuilder {
  @inlinable public static func buildBlock<Route>(
    _ r0: _Routing<Route>,
    _ r1: _Routing<Route>,
    _ r2: _Routing<Route>,
    _ r3: _Routing<Route>,
    _ r4: _Routing<Route>,
    _ r5: _Routing<Route>,
    _ r6: _Routing<Route>
  ) -> _Router<Route> {
    _Router(
      parse: { input in
        if let output = r0.parse(&input) { return output }
        if let output = r1.parse(&input) { return output }
        if let output = r2.parse(&input) { return output }
        if let output = r3.parse(&input) { return output }
        if let output = r4.parse(&input) { return output }
        if let output = r5.parse(&input) { return output }
        if let output = r6.parse(&input) { return output }
        return nil
      },
      print: { output in
        if let input = r0.print(output) { return input }
        if let input = r1.print(output) { return input }
        if let input = r2.print(output) { return input }
        if let input = r3.print(output) { return input }
        if let input = r4.print(output) { return input }
        if let input = r5.print(output) { return input }
        if let input = r6.print(output) { return input }
        return nil
      }
    )
  }
}

extension _RouterBuilder {
  @inlinable public static func buildBlock<Route>(
    _ r0: _Routing<Route>,
    _ r1: _Routing<Route>,
    _ r2: _Routing<Route>,
    _ r3: _Routing<Route>,
    _ r4: _Routing<Route>,
    _ r5: _Routing<Route>,
    _ r6: _Routing<Route>,
    _ r7: _Routing<Route>
  ) -> _Router<Route> {
    _Router(
      parse: { input in
        if let output = r0.parse(&input) { return output }
        if let output = r1.parse(&input) { return output }
        if let output = r2.parse(&input) { return output }
        if let output = r3.parse(&input) { return output }
        if let output = r4.parse(&input) { return output }
        if let output = r5.parse(&input) { return output }
        if let output = r6.parse(&input) { return output }
        if let output = r7.parse(&input) { return output }
        return nil
      },
      print: { output in
        if let input = r0.print(output) { return input }
        if let input = r1.print(output) { return input }
        if let input = r2.print(output) { return input }
        if let input = r3.print(output) { return input }
        if let input = r4.print(output) { return input }
        if let input = r5.print(output) { return input }
        if let input = r6.print(output) { return input }
        if let input = r7.print(output) { return input }
        return nil
      }
    )
  }
}

extension _RouterBuilder {
  @inlinable public static func buildBlock<Route>(
    _ r0: _Routing<Route>,
    _ r1: _Routing<Route>,
    _ r2: _Routing<Route>,
    _ r3: _Routing<Route>,
    _ r4: _Routing<Route>,
    _ r5: _Routing<Route>,
    _ r6: _Routing<Route>,
    _ r7: _Routing<Route>,
    _ r8: _Routing<Route>
  ) -> _Router<Route> {
    _Router(
      parse: { input in
        if let output = r0.parse(&input) { return output }
        if let output = r1.parse(&input) { return output }
        if let output = r2.parse(&input) { return output }
        if let output = r3.parse(&input) { return output }
        if let output = r4.parse(&input) { return output }
        if let output = r5.parse(&input) { return output }
        if let output = r6.parse(&input) { return output }
        if let output = r7.parse(&input) { return output }
        if let output = r8.parse(&input) { return output }
        return nil
      },
      print: { output in
        if let input = r0.print(output) { return input }
        if let input = r1.print(output) { return input }
        if let input = r2.print(output) { return input }
        if let input = r3.print(output) { return input }
        if let input = r4.print(output) { return input }
        if let input = r5.print(output) { return input }
        if let input = r6.print(output) { return input }
        if let input = r7.print(output) { return input }
        if let input = r8.print(output) { return input }
        return nil
      }
    )
  }
}
