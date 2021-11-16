@resultBuilder
public enum RouterBuilder {
  @inlinable
  public static func buildBlock<RouteParser, Route>(
    _ routing: Routing<RouteParser, Route>
  ) -> Router<Route>
    where RouteParser: Printer
  {
    Router(parse: routing.parse, print: routing.print)
  }
}

extension RouterBuilder {
  @inlinable public static func buildBlock<R0, R1, Route>(
    _ r0: Routing<R0, Route>,
    _ r1: Routing<R1, Route>
  ) -> Router<Route>
    where
    R0: Printer,
    R1: Printer
  {
    Router(
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

extension RouterBuilder {
  @inlinable public static func buildBlock<R0, R1, R2, Route>(
    _ r0: Routing<R0, Route>,
    _ r1: Routing<R1, Route>,
    _ r2: Routing<R2, Route>
  ) -> Router<Route>
    where
    R0: Printer,
    R1: Printer,
    R2: Printer
  {
    Router(
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

extension RouterBuilder {
  @inlinable public static func buildBlock<R0, R1, R2, R3, Route>(
    _ r0: Routing<R0, Route>,
    _ r1: Routing<R1, Route>,
    _ r2: Routing<R2, Route>,
    _ r3: Routing<R3, Route>
  ) -> Router<Route>
    where
    R0: Printer,
    R1: Printer,
    R2: Printer,
    R3: Printer
  {
    Router(
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

extension RouterBuilder {
  @inlinable public static func buildBlock<R0, R1, R2, R3, R4, Route>(
    _ r0: Routing<R0, Route>,
    _ r1: Routing<R1, Route>,
    _ r2: Routing<R2, Route>,
    _ r3: Routing<R3, Route>,
    _ r4: Routing<R4, Route>
  ) -> Router<Route>
    where
    R0: Printer,
    R1: Printer,
    R2: Printer,
    R3: Printer,
    R4: Printer
  {
    Router(
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

extension RouterBuilder {
  @inlinable public static func buildBlock<R0, R1, R2, R3, R4, R5, Route>(
    _ r0: Routing<R0, Route>,
    _ r1: Routing<R1, Route>,
    _ r2: Routing<R2, Route>,
    _ r3: Routing<R3, Route>,
    _ r4: Routing<R4, Route>,
    _ r5: Routing<R5, Route>
  ) -> Router<Route>
    where
    R0: Printer,
    R1: Printer,
    R2: Printer,
    R3: Printer,
    R4: Printer,
    R5: Printer
  {
    Router(
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

extension RouterBuilder {
  @inlinable public static func buildBlock<R0, R1, R2, R3, R4, R5, R6, Route>(
    _ r0: Routing<R0, Route>,
    _ r1: Routing<R1, Route>,
    _ r2: Routing<R2, Route>,
    _ r3: Routing<R3, Route>,
    _ r4: Routing<R4, Route>,
    _ r5: Routing<R5, Route>,
    _ r6: Routing<R6, Route>
  ) -> Router<Route>
    where
    R0: Printer,
    R1: Printer,
    R2: Printer,
    R3: Printer,
    R4: Printer,
    R5: Printer,
    R6: Printer
  {
    Router(
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

extension RouterBuilder {
  @inlinable public static func buildBlock<R0, R1, R2, R3, R4, R5, R6, R7, Route>(
    _ r0: Routing<R0, Route>,
    _ r1: Routing<R1, Route>,
    _ r2: Routing<R2, Route>,
    _ r3: Routing<R3, Route>,
    _ r4: Routing<R4, Route>,
    _ r5: Routing<R5, Route>,
    _ r6: Routing<R6, Route>,
    _ r7: Routing<R7, Route>
  ) -> Router<Route>
    where
    R0: Printer,
    R1: Printer,
    R2: Printer,
    R3: Printer,
    R4: Printer,
    R5: Printer,
    R6: Printer,
    R7: Printer
  {
    Router(
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

extension RouterBuilder {
  @inlinable public static func buildBlock<R0, R1, R2, R3, R4, R5, R6, R7, R8, Route>(
    _ r0: Routing<R0, Route>,
    _ r1: Routing<R1, Route>,
    _ r2: Routing<R2, Route>,
    _ r3: Routing<R3, Route>,
    _ r4: Routing<R4, Route>,
    _ r5: Routing<R5, Route>,
    _ r6: Routing<R6, Route>,
    _ r7: Routing<R7, Route>,
    _ r8: Routing<R8, Route>
  ) -> Router<Route>
    where
    R0: Printer,
    R1: Printer,
    R2: Printer,
    R3: Printer,
    R4: Printer,
    R5: Printer,
    R6: Printer,
    R7: Printer,
    R8: Printer
  {
    Router(
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
