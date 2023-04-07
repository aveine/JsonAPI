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
    
    func testNestedUnserialization() {
        let json: Document.JsonObject = [
            "id": "1",
            "type": "contacts",
            "attributes": [
                "name": "Name",
                "email": "Email",
                "count": 42,
                "rating": 4.2,
                "mainAddress": [
                    "street": "Street 1",
                    "town": "City 1",
                    "country": "Country 1",
                    "coordinates": [
                        "id": "1",
                        "latitude": 1.0,
                        "longitude": 2.0
                    ],
                    "geometricArea": [
                        [
                            "id": "3",
                            "latitude": 1.0,
                            "longitude": 1.0
                        ],
                        [
                            "id": "4",
                            "latitude": 1.0,
                            "longitude": 2.0
                        ]
                    ]
                ],
                "addresses": [
                    [
                        "street": "Street 1",
                        "town": "City 1",
                        "country": "Country 1",
                        "coordinates": [
                            "id": "1",
                            "latitude": 1.0,
                            "longitude": 2.0
                        ],
                        "geometricArea": [
                            [
                                "id": "3",
                                "latitude": 1.0,
                                "longitude": 1.0
                            ],
                            [
                                "id": "4",
                                "latitude": 1.0,
                                "longitude": 2.0
                            ]
                        ]
                    ],
                    [
                        "street": "Street 2",
                        "town": "City 2",
                        "country": "Country 2",
                        "coordinates": [
                            "id": "2",
                            "latitude": -1.0,
                            "longitude": -2.0
                        ],
                        "geometricArea": [
                            [
                                "id": "5",
                                "latitude": -1.0,
                                "longitude": -1.0
                            ],
                            [
                                "id": "6",
                                "latitude": -1.0,
                                "longitude": -2.0
                            ]
                        ]
                    ]
                ]
            ]
        ]
        let dictionnary = json as NSDictionary
        
        let resourceObject = try! Document.ResourceObject(json: json)
        let contact = Contact(resourceObject: resourceObject)
        XCTAssertEqual(contact.id, dictionnary["id"] as? String)
        XCTAssertEqual(contact.type, dictionnary["type"] as? String)
        XCTAssertEqual(contact.email, dictionnary.value(forKeyPath: "attributes.email") as? String)
        XCTAssertEqual(contact.count, dictionnary.value(forKeyPath: "attributes.count") as? Int)
        XCTAssertEqual(contact.rating, dictionnary.value(forKeyPath: "attributes.rating") as? Double)
        
        let mainAddress = dictionnary.value(forKeyPath: "attributes.mainAddress") as? NSDictionary
        XCTAssertEqual(contact.mainAddress?.street, mainAddress?.value(forKeyPath: "street") as? String)
        XCTAssertEqual(contact.mainAddress?.city, mainAddress?.value(forKeyPath: "town") as? String)
        XCTAssertEqual(contact.mainAddress?.country, mainAddress?.value(forKeyPath: "country") as? String)
        XCTAssertEqual(contact.mainAddress?.coordinates.id, mainAddress?.value(forKeyPath: "coordinates.id") as? String)
        XCTAssertEqual(contact.mainAddress?.coordinates.latitude, mainAddress?.value(forKeyPath: "coordinates.latitude") as? Double)
        XCTAssertEqual(contact.mainAddress?.coordinates.longitude, mainAddress?.value(forKeyPath: "coordinates.longitude") as? Double)
        let mainAddressGeometricArea = mainAddress?.value(forKey: "geometricArea") as? [NSDictionary]
        XCTAssertEqual(contact.mainAddress?.geometricArea.first?.id, mainAddressGeometricArea?.first?.value(forKeyPath: "id") as? String)
        XCTAssertEqual(contact.mainAddress?.geometricArea.first?.latitude, mainAddressGeometricArea?.first?.value(forKeyPath: "latitude") as? Double)
        XCTAssertEqual(contact.mainAddress?.geometricArea.first?.longitude, mainAddressGeometricArea?.first?.value(forKeyPath: "longitude") as? Double)
        XCTAssertEqual(contact.mainAddress?.geometricArea.last?.id, mainAddressGeometricArea?.last?.value(forKeyPath: "id") as? String)
        XCTAssertEqual(contact.mainAddress?.geometricArea.last?.latitude, mainAddressGeometricArea?.last?.value(forKeyPath: "latitude") as? Double)
        XCTAssertEqual(contact.mainAddress?.geometricArea.last?.longitude, mainAddressGeometricArea?.last?.value(forKeyPath: "longitude") as? Double)
        
        let addresses = dictionnary.value(forKeyPath: "attributes.addresses") as? [NSDictionary]
        
        XCTAssertEqual(contact.addresses?.first?.street, addresses?.first?.value(forKeyPath: "street") as? String)
        XCTAssertEqual(contact.addresses?.first?.city, addresses?.first?.value(forKeyPath: "town") as? String)
        XCTAssertEqual(contact.addresses?.first?.country, addresses?.first?.value(forKeyPath: "country") as? String)
        XCTAssertEqual(contact.addresses?.first?.coordinates.id, addresses?.first?.value(forKeyPath: "coordinates.id") as? String)
        XCTAssertEqual(contact.addresses?.first?.coordinates.latitude, addresses?.first?.value(forKeyPath: "coordinates.latitude") as? Double)
        XCTAssertEqual(contact.addresses?.first?.coordinates.longitude, addresses?.first?.value(forKeyPath: "coordinates.longitude") as? Double)
        let firstAddressGeometricArea = addresses?.first?.value(forKey: "geometricArea") as? [NSDictionary]
        XCTAssertEqual(contact.addresses?.first?.geometricArea.first?.id, firstAddressGeometricArea?.first?.value(forKeyPath: "id") as? String)
        XCTAssertEqual(contact.addresses?.first?.geometricArea.first?.latitude, firstAddressGeometricArea?.first?.value(forKeyPath: "latitude") as? Double)
        XCTAssertEqual(contact.addresses?.first?.geometricArea.first?.longitude, firstAddressGeometricArea?.first?.value(forKeyPath: "longitude") as? Double)
        XCTAssertEqual(contact.addresses?.first?.geometricArea.last?.id, firstAddressGeometricArea?.last?.value(forKeyPath: "id") as? String)
        XCTAssertEqual(contact.addresses?.first?.geometricArea.last?.latitude, firstAddressGeometricArea?.last?.value(forKeyPath: "latitude") as? Double)
        XCTAssertEqual(contact.addresses?.first?.geometricArea.last?.longitude, firstAddressGeometricArea?.last?.value(forKeyPath: "longitude") as? Double)
        
        XCTAssertEqual(contact.addresses?.last?.street, addresses?.last?.value(forKeyPath: "street") as? String)
        XCTAssertEqual(contact.addresses?.last?.city, addresses?.last?.value(forKeyPath: "town") as? String)
        XCTAssertEqual(contact.addresses?.last?.country, addresses?.last?.value(forKeyPath: "country") as? String)
        XCTAssertEqual(contact.addresses?.last?.coordinates.id, addresses?.last?.value(forKeyPath: "coordinates.id") as? String)
        XCTAssertEqual(contact.addresses?.last?.coordinates.latitude, addresses?.last?.value(forKeyPath: "coordinates.latitude") as? Double)
        XCTAssertEqual(contact.addresses?.last?.coordinates.longitude, addresses?.last?.value(forKeyPath: "coordinates.longitude") as? Double)
        let secondAddressGeometricArea = addresses?.last?.value(forKey: "geometricArea") as? [NSDictionary]
        XCTAssertEqual(contact.addresses?.last?.geometricArea.first?.id, secondAddressGeometricArea?.first?.value(forKeyPath: "id") as? String)
        XCTAssertEqual(contact.addresses?.last?.geometricArea.first?.latitude, secondAddressGeometricArea?.first?.value(forKeyPath: "latitude") as? Double)
        XCTAssertEqual(contact.addresses?.last?.geometricArea.first?.longitude, secondAddressGeometricArea?.first?.value(forKeyPath: "longitude") as? Double)
        XCTAssertEqual(contact.addresses?.last?.geometricArea.last?.id, secondAddressGeometricArea?.last?.value(forKeyPath: "id") as? String)
        XCTAssertEqual(contact.addresses?.last?.geometricArea.last?.latitude, secondAddressGeometricArea?.last?.value(forKeyPath: "latitude") as? Double)
        XCTAssertEqual(contact.addresses?.last?.geometricArea.last?.longitude, secondAddressGeometricArea?.last?.value(forKeyPath: "longitude") as? Double)
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

        let thirdCoAuthor = Person() // No ID is set, so LID is going to be serialized

        article.coAuthors = [firstCoAuthor, secondCoAuthor, thirdCoAuthor]
        
        let json: Document.JsonObject = [
            "id": article.id,
            "type": article.type,
            "attributes": [
                "title": article.title,
                "body": article.body
            ],
            "relationships": [
                "coauthors": [
                    "data": [
                        [
                            "id": firstCoAuthor.id!,
                            "type": firstCoAuthor.type
                        ],
                        [
                            "id": secondCoAuthor.id!,
                            "type": secondCoAuthor.type
                        ],
                        [
                            "lid": thirdCoAuthor.lid,
                            "type": thirdCoAuthor.type
                        ]
                    ]
                ],
                "author": [
                    "data": [
                        "id": author.id!,
                        "type": author.type
                    ]
                ]
            ]
        ]
        XCTAssertEqual(article.toResourceObject().toJson() as NSDictionary?, json as NSDictionary?)
    }

    func testSerializationLid() {
        let person = Person() // No ID is set, so LID is going to be serialized

        let json: Document.JsonObject = [
            "lid": person.lid,
            "type": person.type,
            "attributes": [
                "name": nil
            ],
            "relationships": [
                "favoriteArticle": [
                    "data": nil
                ]
            ]
        ]
        XCTAssertEqual(person.toResourceObject().toJson() as NSDictionary?, json as NSDictionary?)
    }
    
    func testSerializationNested() {
        let contact = Contact()
        contact.id = "2"
        contact.name = "Name"
        contact.email = "Email"
        contact.count = 42
        contact.rating = 4.2
        
        let firstAddress = Contact.Address(
            street: "Street 1",
            city: "City 1",
            country: "Country 1",
            coordinates: Contact.Address.SpatialInformation(
                id: "1",
                latitude: 1.0,
                longitude: 2.0
            ),
            geometricArea: [
                Contact.Address.SpatialInformation(
                    id: "3",
                    latitude: 1.0,
                    longitude: 1.0
                ),
                Contact.Address.SpatialInformation(
                    id: "4",
                    latitude: 1.0,
                    longitude: 2.0
                ),
            ]
        )
        let secondAddress = Contact.Address(
            street: "Street 2",
            city: "City 2",
            country: "Country 2",
            coordinates: Contact.Address.SpatialInformation(
                id: "2",
                latitude: -1.0,
                longitude: -2.0
            ),
            geometricArea: [
                Contact.Address.SpatialInformation(
                    id: "5",
                    latitude: -1.0,
                    longitude: -1.0
                ),
                Contact.Address.SpatialInformation(
                    id: "6",
                    latitude: -1.0,
                    longitude: -2.0
                ),
            ]
        )
        contact.mainAddress = firstAddress
        contact.addresses = [firstAddress, secondAddress]
        
        let json: Document.JsonObject = [
            "id": "2",
            "type": "contacts",
            "attributes": [
                "name": "Name",
                "email": "Email",
                "count": 42,
                "rating": 4.2,
                "mainAddress": [
                    "street": "Street 1",
                    "town": "City 1",
                    "country": "Country 1",
                    "coordinates": [
                        "latitude": 1.0,
                        "longitude": 2.0
                    ],
                    "geometricArea": [
                        [
                            "latitude": 1.0,
                            "longitude": 1.0
                        ],
                        [
                            "latitude": 1.0,
                            "longitude": 2.0
                        ]
                    ]
                ],
                "addresses": [
                    [
                        "street": "Street 1",
                        "town": "City 1",
                        "country": "Country 1",
                        "coordinates": [
                            "latitude": 1.0,
                            "longitude": 2.0
                        ],
                        "geometricArea": [
                            [
                                "latitude": 1.0,
                                "longitude": 1.0
                            ],
                            [
                                "latitude": 1.0,
                                "longitude": 2.0
                            ]
                        ]
                    ],
                    [
                        "street": "Street 2",
                        "town": "City 2",
                        "country": "Country 2",
                        "coordinates": [
                            "latitude": -1.0,
                            "longitude": -2.0
                        ],
                        "geometricArea": [
                            [
                                "latitude": -1.0,
                                "longitude": -1.0
                            ],
                            [
                                "latitude": -1.0,
                                "longitude": -2.0
                            ]
                        ]
                    ]
                ]
            ],
            "relationships": [
                "favoriteArticle": [
                    "data": nil
                ]
            ]
        ]
        XCTAssertEqual(contact.toResourceObject().toJson() as NSDictionary?, json as NSDictionary?)
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
                "optionalNumber": 42.0,
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
