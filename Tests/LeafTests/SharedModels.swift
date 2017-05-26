@testable import Leaf

#if Xcode
    private var workDir: String {
        let parent = #file.characters.split(separator: "/").map(String.init).dropLast().joined(separator: "/")
        let path = "/\(parent)/../../Resources/"
        return path
    }
#else
    private let workDir = "./Resources/"
#endif

let file = DataFile(workDir: workDir)
let stem = Stem(file)

class Test: Tag {
    let name: String
    let value: Node?
    let shouldRender: Bool

    init(name: String, value: Node?, shouldRender: Bool) {
        self.name = name
        self.value = value
        self.shouldRender = shouldRender
    }

    func run(tagTemplate: TagTemplate, arguments: ArgumentList) throws -> Node? {
        return value
    }

    func shouldRender(tagTemplate: TagTemplate, arguments: ArgumentList, value: Node?) -> Bool {
        return shouldRender
    }
}
