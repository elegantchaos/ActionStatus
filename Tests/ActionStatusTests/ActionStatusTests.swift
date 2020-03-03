//
//  GithubStatusTests.swift
//  GithubStatusTests
//
//  Created by Developer on 05/02/2020.
//  Copyright © 2020 Elegant Chaos. All rights reserved.
//

import XCTest
import DictionaryCoding
@testable import ActionStatus

class ActionStatusTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    var version1: [String:Any] = [
        "name": "Name",
        "workflow": "Test",
        "state": 1,
        "branches": [ "master" ],
        "owner": "Owner",
        "id": "DBDD302B-B50A-47DC-AA5E-4FAF2FF8A01A",
        "settings": [
            "options": [ "test" ]
        ]
    ]

    func outputRepo() {
        let settings = WorkflowSettings(options: ["test"])
        let repo = Repo("Name", owner: "Owner", workflow: "Test", id: UUID(), state: .passing, branches: ["master"], settings: settings)
        let encoder = DictionaryEncoder()
        if let dictionary: [String:Any] = try? encoder.encode(repo) {
            let data = try! JSONSerialization.data(withJSONObject: dictionary, options: [.prettyPrinted])
            let json = String(data: data, encoding: .utf8)!
            print(json)
        }
    }
    
    func testLoadVersion1Repo() {
        typealias LocalPathDictionary = [String:String]
        
        let decoder = DictionaryDecoder()
        let defaults: [String:Any] = [
            String(describing: LocalPathDictionary.self): LocalPathDictionary()
        ]
            
        decoder.missingValueDecodingStrategy = .useDefault(defaults: defaults)
        
        do {
            let repo = try decoder.decode(Repo.self, from: version1)
            XCTAssertEqual(repo.name, "Name")
            XCTAssertEqual(repo.owner, "Owner")
            XCTAssertEqual(repo.workflow, "Test")
            XCTAssertEqual(repo.state, .passing)
            XCTAssertEqual(repo.branches, [ "master" ])
            XCTAssertEqual(repo.id, UUID(uuidString: "DBDD302B-B50A-47DC-AA5E-4FAF2FF8A01A"))
        } catch {
            XCTFail("couldn't decode: \(error)")
        }
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
