import XCTest
import JsonAPI

class ResourceTests: XCTestCase {
    func testUnserialization() {
        let json: Document.JsonObject = [
            "id": "1",
            "type": "articles",
            "attributes": [
                "title": "Title",
                "body": "Body",
                "keyThatDoesntExists": true
            ],
            "relationships": [
                "coauthors": [
                    "data": [
                        [
                            "id":"2",
                            "type": "persons"
                        ],
                        [
                            "id":"2",
                            "type": "unknown"
                        ],
                        [
                            "id":"3",
                            "type": "persons"
                        ]
                    ]
                ],
                "author": [
                    "data": [
                        "id":"1",
                        "type": "persons"
                    ]
                ],
                "unknown": [
                    "data": [
                        "id":"1",
                        "type": "unknown"
                    ]
                ]
            ]
        ]
        let dictionnary = json as NSDictionary
        
        let resourceObject = try! Document.ResourceObject(json: json)
        let article = Article(resourceObject: resourceObject)
        XCTAssertEqual(article.id, dictionnary["id"] as? String)
        XCTAssertEqual(article.type, dictionnary["type"] as? String)
        XCTAssertEqual(article.title, dictionnary.value(forKeyPath: "attributes.title") as? String)
        XCTAssertEqual(article.body, dictionnary.value(forKeyPath: "attributes.body") as? String)
        
        XCTAssertEqual(article.author?.id, dictionnary.value(forKeyPath: "relationships.author.data.id") as? String)
        XCTAssertEqual(article.author?.type, dictionnary.value(forKeyPath: "relationships.author.data.type") as? String)
        
        XCTAssertEqual(article.coAuthors?.first?.id, (dictionnary.value(forKeyPath: "relationships.coauthors.data") as? [NSDictionary])?.first?.value(forKeyPath: "id") as? String)
        XCTAssertEqual(article.coAuthors?.first?.type, (dictionnary.value(forKeyPath: "relationships.coauthors.data") as? [NSDictionary])?.first?.value(forKeyPath: "type") as? String)
        
        XCTAssertEqual(article.coAuthors?.last?.id, (dictionnary.value(forKeyPath: "relationships.coauthors.data") as? [NSDictionary])?.last?.value(forKeyPath: "id") as? String)
        XCTAssertEqual(article.coAuthors?.last?.type, (dictionnary.value(forKeyPath: "relationships.coauthors.data") as? [NSDictionary])?.last?.value(forKeyPath: "type") as? String)
    }
    
    func testSerialization() {
        let article = Article()
        article.id = "1"
        article.title = "Title"
        article.body = "Body"
        
        let author = Person()
        author.id = "1"
        article.author = author
        
        let firstCoAuthor = Person()
        firstCoAuthor.id = "2"
        let secondCoAuthor = Person()
        secondCoAuthor.id = "3"
        let thirdCoAuthor = Person() //No id, should not be serialized
        article.coAuthors = [firstCoAuthor, secondCoAuthor, thirdCoAuthor]
        
        let json: Document.JsonObject = [
            "id": "1",
            "type": "articles",
            "attributes": [
                "title": "Title",
                "body": "Body"
            ],
            "relationships": [
                "coauthors": [
                    "data": [
                        [
                            "id":"2",
                            "type": "persons"
                        ],
                        [
                            "id":"3",
                            "type": "persons"
                        ]
                    ]
                ],
                "author": [
                    "data": [
                        "id":"1",
                        "type": "persons"
                    ]
                ]
            ]
        ]
        XCTAssertEqual(article.toResourceObject().toJson() as NSDictionary?, json as NSDictionary?)
    }
    
    func testSerializationNil() {
        let article = Article()
        article.id = "1"
        article.title = "Title"
        
        let json: Document.JsonObject = [
            "id": "1",
            "type": "articles",
            "attributes": [
                "title": "Title",
                "body": nil
            ],
            "relationships": [
                "coauthors": [
                    "data": []
                ],
                "author": [
                    "data": nil
                ]
            ]
        ]
        XCTAssertEqual(article.toResourceObject().toJson() as NSDictionary?, json as NSDictionary?)
    }
    
    func testComplexSerialization() {
        let complexResource = ComplexResource()
        complexResource.id = "1"
        
        let json: Document.JsonObject = [
            "id": "1",
            "type": "ComplexResource",
            "attributes": [
                "optionalString": nil,
                "optionalNumber": nil,
                "optionalBool": nil,
                "optionalArray": nil,
                "optionalObject": nil,
                "string": "string",
                "number": 42,
                "bool": true,
                "array": [
                    "string",
                    42,
                    false,
                    [
                        "string",
                        42,
                        true,
                        ["string", 42, true],
                        ["string": "string", "number": 42, "bool": false, "array": ["string", 42, true]]
                    ],
                    [
                        "string": "string",
                        "number": 42,
                        "bool": true,
                        "array": ["string", 42, true],
                        "object": ["string": "string", "number": 42, "bool": false, "array": ["string", 42, true]]
                    ]
                ],
                "object": [
                    "string": "string",
                    "number": 42,
                    "bool": true,
                    "array": [
                        "string",
                        42,
                        true,
                        ["string", 42, true],
                        ["string": "string", "number": 42, "bool": false, "array": ["string", 42, true]]
                    ],
                    "object": [
                        "string": "string",
                        "number": 42,
                        "bool": true,
                        "array": ["string", 42, true],
                        "object": ["string": "string", "number": 42, "bool": false, "array": ["string", 42, true]]
                    ]
                ]
            ],
            "relationships": [
                "optionalRelationship": [
                    "data": nil
                ],
                "optionalRelationships": [
                    "data": []
                ],
                "relationships": [
                    "data": [
                        [
                            "id":"1",
                            "type": "AResource"
                        ]
                    ]
                ],
                "relationship": [
                    "data": [
                        "id":"1",
                        "type": "AResource"
                    ]
                ]
            ]
        ]
        XCTAssertEqual(complexResource.toResourceObject().toJson() as NSDictionary?, json as NSDictionary?)
    }
    
    func testComplexUnserialization() {
        let json: Document.JsonObject = [
            "id": "1",
            "type": "ComplexResource",
            "attributes": [
                "optionalString": "string",
                "optionalNumber": 42,
                "optionalBool": true,
                "optionalArray": [
                    "string",
                    42,
                    false,
                    [
                        "string",
                        42,
                        true,
                        ["string", 42, true],
                        ["string": "string", "number": 42, "bool": false, "array": ["string", 42, true]]
                    ],
                    [
                        "string": "string",
                        "number": 42,
                        "bool": true,
                        "array": ["string", 42, true],
                        "object": ["string": "string", "number": 42, "bool": false, "array": ["string", 42, true]]
                    ]
                ],
                "optionalObject": [
                    "string": "string",
                    "number": 42,
                    "bool": true,
                    "array": [
                        "string",
                        42,
                        true,
                        ["string", 42, true],
                        ["string": "string", "number": 42, "bool": false, "array": ["string", 42, true]]
                    ],
                    "object": [
                        "string": "string",
                        "number": 42,
                        "bool": true,
                        "array": ["string", 42, true],
                        "object": ["string": "string", "number": 42, "bool": false, "array": ["string", 42, true]]
                    ]
                ],
                "string": "String",
                "number": 21,
                "bool": false,
                "array": [
                    "String",
                    21,
                    true,
                    [
                        "String",
                        21,
                        false,
                        ["String", 21, false],
                        ["string": "String", "number": 21, "bool": true, "array": ["String", 21, false]]
                    ],
                    [
                        "string": "String",
                        "number": 21,
                        "bool": false,
                        "array": ["String", 21, false],
                        "object": ["string": "String", "number": 21, "bool": true, "array": ["String", 21, false]]
                    ]
                ],
                "object": [
                    "string": "String",
                    "number": 21,
                    "bool": false,
                    "array": [
                        "String",
                        21,
                        false,
                        ["String", 21, false],
                        ["string": "String", "number": 21, "bool": true, "array": ["String", 21, false]]
                    ],
                    "object": [
                        "string": "String",
                        "number": 21,
                        "bool": false,
                        "array": ["String", 21, false],
                        "object": ["string": "String", "number": 21, "bool": true, "array": ["String", 21, false]]
                    ]
                ]
            ],
            "relationships": [
                "optionalRelationships": [
                    "data": [
                        [
                            "id":"1",
                            "type": "AResource"
                        ]
                    ]
                ],
                "optionalRelationship": [
                    "data": [
                        "id":"1",
                        "type": "AResource"
                    ]
                ],
                "relationships": [
                    "data": [
                        [
                            "id":"2",
                            "type": "AResource"
                        ]
                    ]
                ],
                "relationship": [
                    "data": [
                        "id":"2",
                        "type": "AResource"
                    ]
                ]
            ]
        ]
        let dictionnary = json as NSDictionary
        
        let resourceObject = try! Document.ResourceObject(json: json)
        let complexResource = ComplexResource(resourceObject: resourceObject)
        
        XCTAssertEqual(complexResource.toResourceObject().toJson() as NSDictionary?, dictionnary)
    }
    
    func testExcludedAttributes() {
        let resource = ExcludedResource()
        resource.id = "1"
        resource.title = "title"
        resource.body = "body"
        
        XCTAssertEqual(resource.toResourceObject().attributes as NSDictionary?, ["title": "title"] as NSDictionary)
    }
    
    func testDefaultValues() {
        XCTAssertEqual(AResource.self.resourceType, String(describing: AResource.self), "By default should be the class name")
        XCTAssertEqual(AResource.self.resourceAttributesKeys, [:], "By default should be an empty dictionnary")
        XCTAssertEqual(AResource.self.resourceExcludedAttributes, [], "By default should be an empty array")
    }
}
