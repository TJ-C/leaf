import Foundation
import XCTest
@testable import Leaf

class LoopTests: XCTestCase {
    static let allTests = [
        ("testBasicLoop", testBasicLoop),
        ("testComplexLoop", testComplexLoop),
        ("testNumberThrow", testNumberThrow),
        ("testInvalidSignature1", testInvalidSignature1),
        ("testInvalidSignature2", testInvalidSignature2),
        ("testSkipNil", testSkipNil),
        ("testFuzzySingle", testFuzzySingle),
        ("testNestedLoop", testNestedLoop),
    ]

    func testBasicLoop() throws {
        let template = try stem.spawnLeaf(at: "basic-loop")

        let context = try Node(node: [
            "friends": [
                "asdf",
                "🐌",
                "8###z0-1",
                12
            ]
            ])
        let loadable = Context(context)
        let expectation = "Hello, asdf\nHello, 🐌\nHello, 8###z0-1\nHello, 12"
        let rendered = try stem.render(template, with: loadable).makeString()
        XCTAssert(rendered == expectation, "have: \(rendered), want: \(expectation)")
    }

    func testComplexLoop() throws {
        let context = try Node(node: [
            "friends": [
                [
                    "name": "Venus",
                    "age": 12345
                ],
                [
                    "name": "Pluto",
                    "age": 888
                ],
                [
                    "name": "Mercury",
                    "age": 9000
                ]
            ]
            ])

        let template = try stem.spawnLeaf(at: "complex-loop")
        let loadable = Context(context)
        let rendered = try stem.render(template, with: loadable).makeString()
        let expectation = "<li><b>Venus</b>: 12345</li>\n<li><b>Pluto</b>: 888</li>\n<li><b>Mercury</b>: 9000</li>"
        XCTAssert(rendered == expectation, "have: \(rendered) want: \(expectation)")
    }

    func testNumberThrow() throws {
        let leaf = try stem.spawnLeaf(raw: "#loop(too, many, arguments)")
        let context = Context(["too": "", "many": "", "arguments": ""])
        do {
            _ = try stem.render(leaf, with: context).makeString()
            XCTFail("Should throw")
        } catch Loop.Error.expectedTwoArguments { }
    }

    func testInvalidSignature1() throws {
        let leaf = try stem.spawnLeaf(raw: "#loop(\"invalid\", \"signature\")")
        let context = Context([:])
        do {
            _ = try stem.render(leaf, with: context).makeString()
            XCTFail("Should throw")
        } catch Loop.Error.expectedVariable { }
    }

    func testInvalidSignature2() throws {
        let leaf = try stem.spawnLeaf(raw: "#loop(invalid, signature)")
        let context = Context([:])
        do {
            _ = try stem.render(leaf, with: context).makeString()
            XCTFail("Should throw")
        } catch Loop.Error.expectedConstant { }
    }

    func testSkipNil() throws {
        let leaf = try stem.spawnLeaf(raw: "#loop(find-nil, \"inner-name\") { asdfasdfasdfsdf }")
        let context = Context([:])
        let rendered = try stem.render(leaf, with: context).makeString()
        XCTAssert(rendered == "")
    }

    func testFuzzySingle() throws {
        // single => array
        let leaf = try stem.spawnLeaf(raw: "#loop(names, \"name\") { Hello, #(name)! }")
        let context = Context(["names": "Rick"])
        let rendered = try stem.render(leaf, with: context).makeString()
        XCTAssert(rendered == "Hello, Rick!")
    }

    func testNestedLoop() throws {
        let raw = "#loop(data, \"each\") { type: #(each.type)\n#loop(each.sub, \"sub\") { Hello, #(sub)\n } }"
        let leaf = try stem.spawnLeaf(raw: raw)
        let context = Context(["data": [["type": "foo", "sub": ["a", "b", "c"]], ["type": "bar"]]])
        let rendered = try stem.render(leaf, with: context).makeString()

        var expectation = ""
        expectation += "type: foo\n"
        expectation += "Hello, a\n"
        expectation += "Hello, b\n"
        expectation += "Hello, c\n"
        expectation += "type: bar\n"
        XCTAssertEqual(expectation, rendered)
    }
}
