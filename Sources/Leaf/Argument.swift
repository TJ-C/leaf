/**
    Concrete representation of a parameter
*/
public enum Argument {
    /**
        - parameter path: path declared for variable
        - parameter value: found value in given scope
    */
    case variable(path: [String], value: Node?)

    /**
        - parameter value: the value for a given constant. Declared w/ `""`
    */
    case constant(Leaf)
}

extension Argument {
    public func value(with stem: Stem, in context: Context) -> Node? {
        switch self {
        case let .constant(leaf):
            guard let rendered = try? stem.render(leaf, with: context) else { return nil }
            let string = rendered.makeString()
            return .string(string)
        case let .variable(path: _, value: value):
            return value
        }
    }
}

public struct ArgumentList {
    public let list: [Argument]
    public let stem: Stem
    public let context: Context

    public var isEmpty: Bool { return list.isEmpty }
    public var count: Int { return list.count }

    public var first: Node? {
        return self[0]
    }

    public var last: Node? {
        let last = list.count - 1
        return self[last]
    }

    public init(list: [Argument], stem: Stem, context: Context) {
        self.list = list
        self.stem = stem
        self.context = context
    }

    public subscript(idx: Int) -> Node? {
        guard idx < list.count else { return nil }
        return list[idx].value(with: stem, in: context)
    }
}
