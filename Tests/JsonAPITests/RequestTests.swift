import XCTest
import JsonAPI

class RequestTests: XCTestCase {
    class MockClient: Client {
        static let resourceData: Document.JsonObject = [
            "id": "1",
            "type": "articles",
            "attributes": [
                "title": "Title",
                "body": "Body"
            ],
            "relationships": [
                "author": [
                    "data": [
                        "id":"1",
                        "type": "persons"
                    ]
                ],
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
                ]
            ]
        ]
        
        static let resourcesData: [Document.JsonObject] = [
            [
                "id": "1",
                "type": "articles",
                "attributes": [
                    "title": "Title",
                    "body": "Body"
                ],
                "relationships": [
                    "author": [
                        "data": [
                            "id":"1",
                            "type": "persons"
                        ]
                    ],
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
                    ]
                ]
            ],
            [
                "id": "2",
                "type": "articles",
                "attributes": [
                    "title": "Another Title",
                    "body": "Another Body"
                ],
                "relationships": [
                    "author": [
                        "data": [
                            "id":"1",
                            "type": "persons"
                        ]
                    ],
                    "coauthors": [
                        "data": [
                            [
                                "id":"2",
                                "type": "persons"
                            ],
                            [
                                "id":"3",
                                "type": "persons"
                            ],
                            [
                                "id":"1",
                                "type": "unknown"
                            ]
                        ]
                    ],
                    "unknown": [
                        "meta": [
                            "foo": "bar"
                        ]
                    ]
                ]
            ]
        ]
        
        static let included: [Document.JsonObject] = [
            [
                "id": "1",
                "type": "persons",
                "attributes": [
                    "name": "Aron"
                ],
                "relationships": [
                    "favoriteArticle": [
                        "data": [
                            "id":"1",
                            "type":"articles"
                        ]
                    ]
                ]
            ],
            [
                "id": "2",
                "type": "persons",
                "attributes": [
                    "name": "Glupan"
                ],
                "relationships": [
                    "favoriteArticle": [
                        "data": [
                            "id":"1",
                            "type":"articles"
                        ]
                    ]
                ]
            ],
            [
                "id": "3",
                "type": "persons",
                "attributes": [
                    "name": "Debil"
                ],
                "relationships": [
                    "favoriteArticle": [
                        "data": [
                            "id":"2",
                            "type":"articles"
                        ]
                    ]
                ]
            ],
            [
                "id": "1",
                "type": "unknown",
                "attributes": [
                    "name": "Aron"
                ],
                "relationships": [
                    "favoriteArticle": [
                        "data": [
                            "id":"1",
                            "type":"articles"
                        ]
                    ]
                ]
            ]
        ]
        
        static let resourceDocument: Document.JsonObject = [
            "data": MockClient.resourceData
        ]
        
        static let resourceWithIncludedDocument: Document.JsonObject = [
            "data": MockClient.resourceData,
            "included": MockClient.included
        ]
        
        static let resourcesDocument: Document.JsonObject = [
            "data": MockClient.resourcesData
        ]
        
        static let resourcesWithIncludedDocument: Document.JsonObject = [
            "data": MockClient.resourcesData,
            "included": MockClient.included
        ]
        
        static let noDataDocument: Document.JsonObject = [
            "meta": [
                "foo": "bar"
            ]
        ]
        
        static let errorDocument: Document.JsonObject = [
            "errors": [
                [
                    "id": "1",
                    "status": "422",
                    "code": "kb-422",
                    "title": "Title error",
                    "detail": "Detail error"
                ]
            ]
        ]
        
        static let randomData: Data = Data.init(repeating: 10, count: 10)

        static let resourceWithIncludedInheritedResourceDocument: Document.JsonObject = [
            "data": [
                "id": "1",
                "type": "contactlists",
                "attributes": [
                    "name": "List"
                ],
                "relationships": [
                    "contacts": [
                        "data": [
                            [
                                "id":"2",
                                "type": "contacts"
                            ]
                        ]
                    ]
                ]
            ],
            "included": [
                [
                    "id": "2",
                    "type": "contacts",
                    "attributes": [
                        "name": "Contact",
                        "email": "Email"
                    ]

                ]
            ]
        ];
        
        func executeRequest(path: String, method: HttpMethod, queryItems: [URLQueryItem]?, body: Document.JsonObject?, success: @escaping ClientSuccessBlock, failure: @escaping ClientFailureBlock, userInfo: [String : Any]?) {
            if queryItems?.contains(URLQueryItem(name: "error", value: "true")) ?? false {
                if queryItems?.contains(URLQueryItem(name: "notJsonFormat", value: "true")) ?? false {
                    failure(nil, MockClient.randomData)
                } else if queryItems?.contains(URLQueryItem(name: "noResult", value: "true")) ?? false {
                    failure(nil, nil)
                } else {
                    failure(nil, try! JSONSerialization.data(withJSONObject: MockClient.errorDocument))
                }
            } else if queryItems?.contains(URLQueryItem(name: "notJsonFormat", value: "true")) ?? false {
                success(nil, MockClient.randomData)
            } else if queryItems?.contains(URLQueryItem(name: "resourceSerialization", value: "true")) ?? false {
                success(nil, try! JSONSerialization.data(withJSONObject: body!))
            } else if queryItems?.contains(URLQueryItem(name: "resource", value: "true")) ?? false {
                if queryItems?.contains(URLQueryItem(name: "include", value: "author.favoriteArticle")) ?? false {
                    success(nil, try! JSONSerialization.data(withJSONObject: MockClient.resourceWithIncludedDocument))
                } else {
                    success(nil, try! JSONSerialization.data(withJSONObject: MockClient.resourceDocument))
                }
            } else if queryItems?.contains(URLQueryItem(name: "resources", value: "true")) ?? false {
                if queryItems?.contains(URLQueryItem(name: "include", value: "author.favoriteArticle")) ?? false {
                    success(nil, try! JSONSerialization.data(withJSONObject: MockClient.resourcesWithIncludedDocument))
                } else {
                    success(nil, try! JSONSerialization.data(withJSONObject: MockClient.resourcesDocument))
                }
            } else if queryItems?.contains(URLQueryItem(name: "noData", value: "true")) ?? false {
                success(nil, try! JSONSerialization.data(withJSONObject: MockClient.noDataDocument))
            } else if queryItems?.contains(URLQueryItem(name: "emptyDocument", value: "true")) ?? false {
                success(nil, try! JSONSerialization.data(withJSONObject: []))
            } else if queryItems?.contains(URLQueryItem(name: "includeInherited", value: "true")) ?? false {
                success(nil, try! JSONSerialization.data(withJSONObject: MockClient.resourceWithIncludedInheritedResourceDocument))
            }
        }
    }
    
    let client = MockClient()
    
    
    func testRequestQueryItems() {
        let resultQueryItem = [
            URLQueryItem(name: "foo", value: "bar"),
            URLQueryItem(name: "baz", value: "qux")
        ]
        
        let resourceRequest = ResourceRequest<Article>(path: "", method: HttpMethod.get, client: self.client, resource: nil)
            .queryItems(resultQueryItem)
        resourceRequest.queryItems.forEach { XCTAssert(resultQueryItem.contains($0)) }
        
        let resourceCollectionRequest = ResourceCollectionRequest<Article>(path: "", method: HttpMethod.get, client: self.client, resource: nil)
            .queryItems(resultQueryItem)
        resourceCollectionRequest.queryItems.forEach { XCTAssert(resultQueryItem.contains($0)) }
    }
    
    func testRequestQueryField() {
        let fields = ["article": ["title", "body"], "author": ["name"]]
        let resultQueryItem = [
            URLQueryItem(name: "fields[article]", value: fields["article"]!.joined(separator: ",")),
            URLQueryItem(name: "fields[author]", value: fields["author"]!.joined(separator: ","))
        ]
        
        let resourceRequest = ResourceRequest<Article>(path: "", method: HttpMethod.get, client: self.client, resource: nil)
            .fields(fields)
        resourceRequest.queryItems.forEach { XCTAssert(resultQueryItem.contains($0)) }
        
        let resourceCollectionRequest = ResourceCollectionRequest<Article>(path: "", method: HttpMethod.get, client: self.client, resource: nil)
            .fields(fields)
        resourceCollectionRequest.queryItems.forEach { XCTAssert(resultQueryItem.contains($0)) }
    }
    
    func testRequestQueryInclude() {
        let include = ["author.favoriteArticle"]
        let resultQueryItem = [
            URLQueryItem(name: "include", value: include.joined(separator: ","))
        ]
        
        let resourceRequest = ResourceRequest<Article>(path: "", method: HttpMethod.get, client: self.client, resource: nil)
            .include(include)
        resourceRequest.queryItems.forEach { XCTAssert(resultQueryItem.contains($0)) }
        
        let resourceCollectionRequest = ResourceCollectionRequest<Article>(path: "", method: HttpMethod.get, client: self.client, resource: nil)
            .include(include)
        resourceCollectionRequest.queryItems.forEach { XCTAssert(resultQueryItem.contains($0)) }
    }
    
    func testRequestQuerySort() {
        let sort: [Sort] = [Sort.ascending("title"), Sort.descending("body")]
        
        let resultQueryItem = [
            URLQueryItem(name: "sort", value: sort.map { type in
                switch type {
                case .ascending(let criteria):
                    return criteria
                case .descending(let criteria):
                    return "-" + criteria
                }
            }.joined(separator: ","))
        ]
        
        let resourceCollectionRequest = ResourceCollectionRequest<Article>(path: "", method: HttpMethod.get, client: self.client, resource: nil)
            .sort(sort)
        resourceCollectionRequest.queryItems.forEach { XCTAssert(resultQueryItem.contains($0)) }
    }
    
    
    func testResourceRequestResource() {
        let expectation = XCTestExpectation(description: "Answer from the mock client")
        
        ResourceRequest<Article>(path: "", method: HttpMethod.get, client: self.client, resource: nil)
            .queryItems([URLQueryItem(name: "resource", value: "true")])
            .result({ (resource, document) in
                expectation.fulfill()
                
                guard let resource = resource else {
                    XCTFail("Resource should not be empty")
                    return
                }
                guard let document = document else {
                    XCTFail("Document should not be empty")
                    return
                }
                
                XCTAssertEqual(resource.toResourceObject().toJson() as NSDictionary, MockClient.resourceDocument["data"] as? NSDictionary)
                XCTAssertEqual(document.toJson() as NSDictionary, MockClient.resourceDocument as NSDictionary)
            }, { (_, _) in
                expectation.fulfill()
                XCTFail("Request should not fail")
            })
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testResourceRequestResources() {
        let expectation = XCTestExpectation(description: "Answer from the mock client")
        
        ResourceRequest<Article>(path: "", method: HttpMethod.get, client: self.client, resource: nil)
            .queryItems([URLQueryItem(name: "resources", value: "true")])
            .result({ (resource, document) in
                expectation.fulfill()
                XCTFail("Request should fail")
            }, { (error, document) in
                expectation.fulfill()
                
                guard let error = error else {
                    XCTFail("Error should not be empty")
                    return
                }
                guard let document = document else {
                    XCTFail("Document should not be empty")
                    return
                }
                
                if let error = error as? RequestError, error != RequestError.notSingleData {
                    XCTFail("Not the expected error")
                }
                XCTAssertEqual(document.toJson() as NSDictionary, MockClient.resourcesDocument as NSDictionary)
            })
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testResourceRequestNoData() {
        let expectation = XCTestExpectation(description: "Answer from the mock client")
        
        ResourceRequest<Article>(path: "", method: HttpMethod.get, client: self.client, resource: nil)
            .queryItems([URLQueryItem(name: "noData", value: "true")])
            .result({ (resource, document) in
                expectation.fulfill()
                
                XCTAssertNil(resource)
                guard let document = document else {
                    XCTFail("Document should not be empty")
                    return
                }
                
                XCTAssertEqual(document.toJson() as NSDictionary, MockClient.noDataDocument as NSDictionary)
            }, { (_, _) in
                expectation.fulfill()
                XCTFail("Request should not fail")
            })
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testResourceRequestEmptyDocument() {
        let expectation = XCTestExpectation(description: "Answer from the mock client")
        
        ResourceRequest<Article>(path: "", method: HttpMethod.get, client: self.client, resource: nil)
            .queryItems([URLQueryItem(name: "emptyDocument", value: "true")])
            .result({ (resource, document) in
                expectation.fulfill()
                
                XCTAssertNil(resource)
                XCTAssertNil(document)
            }, { (_, _) in
                expectation.fulfill()
                XCTFail("Request should not fail")
            })
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    func testResourcesRequestResource() {
        let expectation = XCTestExpectation(description: "Answer from the mock client")
        
        ResourceCollectionRequest<Article>(path: "", method: HttpMethod.get, client: self.client, resource: nil)
            .queryItems([URLQueryItem(name: "resource", value: "true")])
            .result({ (_, _) in
                expectation.fulfill()
                XCTFail("Request should fail")
            }, { (error, document) in
                expectation.fulfill()
                
                guard let error = error else {
                    XCTFail("Error should not be empty")
                    return
                }
                guard let document = document else {
                    XCTFail("Document should not be empty")
                    return
                }
                
                if let error = error as? RequestError, error != RequestError.notCollectionData {
                    XCTFail("Not the expected error")
                }
                XCTAssertEqual(document.toJson() as NSDictionary, MockClient.resourceDocument as NSDictionary)
            })
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testResourcesRequestResources() {
        let expectation = XCTestExpectation(description: "Answer from the mock client")
        
        ResourceCollectionRequest<Article>(path: "", method: HttpMethod.get, client: self.client, resource: nil)
            .queryItems([URLQueryItem(name: "resources", value: "true")])
            .result({ (resources, document) in
                expectation.fulfill()
            }, { (_, _) in
                expectation.fulfill()
                XCTFail("Request should not fail")
            })
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testResourcesRequestNoData() {
        let expectation = XCTestExpectation(description: "Answer from the mock client")
        
        ResourceCollectionRequest<Article>(path: "", method: HttpMethod.get, client: self.client, resource: nil)
            .queryItems([URLQueryItem(name: "noData", value: "true")])
            .result({ (_, _) in
                expectation.fulfill()
                XCTFail("Request should fail")
            }, { (error, document) in
                expectation.fulfill()
                
                guard let error = error else {
                    XCTFail("Error should not be empty")
                    return
                }
                guard let document = document else {
                    XCTFail("Document should not be empty")
                    return
                }
                
                if let error = error as? RequestError, error != RequestError.noData {
                    XCTFail("Not the expected error")
                }
                XCTAssertEqual(document.toJson() as NSDictionary, MockClient.noDataDocument as NSDictionary)
            })
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testResourcesRequestEmptyDocument() {
        let expectation = XCTestExpectation(description: "Answer from the mock client")
        
        ResourceCollectionRequest<Article>(path: "", method: HttpMethod.get, client: self.client, resource: nil)
            .queryItems([URLQueryItem(name: "emptyDocument", value: "true")])
            .result({ (_, _) in
                expectation.fulfill()
                XCTFail("Request should fail")
            }, { (error, document) in
                expectation.fulfill()
                
                guard let error = error else {
                    XCTFail("Error should not be empty")
                    return
                }
                XCTAssertNil(document)
                
                if let error = error as? RequestError, error != RequestError.emptyResponse {
                    XCTFail("Not the expected error")
                }
            })
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    func testResourceRequestIncluded() {
        let expectation = XCTestExpectation(description: "Answer from the mock client")
        
        ResourceRequest<Article>(path: "", method: HttpMethod.get, client: self.client, resource: nil)
            .queryItems([URLQueryItem(name: "resource", value: "true")])
            .include(["author.favoriteArticle"])
            .result({ (article: Article?, document: Document?) in
                expectation.fulfill()
                
                // Article
                XCTAssertEqual(article?.id, "1")
                XCTAssertEqual(article?.type, "articles")
                XCTAssertEqual(article?.title, "Title")
                XCTAssertEqual(article?.body, "Body")
                
                // Article author
                let author: Person? = article?.author
                XCTAssertEqual(author?.id, "1")
                XCTAssertEqual(author?.type, "persons")
                XCTAssertEqual(author?.name, "Aron")
                XCTAssertEqual(author?.favoriteArticle, article)
                XCTAssertEqual(author?.favoriteArticle?.author, article?.author) // Bidirectionnel
                
                // First article coAuthor
                let firstCoAuthor: Person? = article?.coAuthors?.first
                XCTAssertEqual(firstCoAuthor?.id, "2")
                XCTAssertEqual(firstCoAuthor?.type, "persons")
                XCTAssertEqual(firstCoAuthor?.name, "Glupan")
                XCTAssert((firstCoAuthor?.favoriteArticle?.coAuthors?.contains(firstCoAuthor!))!) // Bidirectionnel
                XCTAssertEqual(firstCoAuthor?.favoriteArticle, article)
                
                // Last article coAuthor
                let lastCoAuthor: Person? = article?.coAuthors?.last
                XCTAssertEqual(lastCoAuthor?.id, "3")
                XCTAssertEqual(lastCoAuthor?.type, "persons")
                XCTAssertEqual(lastCoAuthor?.name, "Debil")
                
                // Last article coAuthor favorite article
                let lastCoAuthorFavoriteArticle = lastCoAuthor?.favoriteArticle
                XCTAssertEqual(lastCoAuthorFavoriteArticle?.id, "2")
                XCTAssertEqual(lastCoAuthorFavoriteArticle?.type, "articles")
            }, { (_, _) in
                expectation.fulfill()
                XCTFail("Mock client should not fail this request")
            })
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testResourcesRequestIncluded() {
        let expectation = XCTestExpectation(description: "Answer from the mock client")
        
        ResourceCollectionRequest<Article>(path: "", method: HttpMethod.get, client: self.client, resource: nil)
            .queryItems([URLQueryItem(name: "resources", value: "true")])
            .include(["author.favoriteArticle"])
            .result({ (articles: [Article], document: Document?) in
                expectation.fulfill()
                
                for article in articles {
                    // Article author
                    let author: Person? = article.author
                    XCTAssertEqual(author?.id, "1")
                    XCTAssertEqual(author?.type, "persons")
                    XCTAssertEqual(author?.name, "Aron")
                    XCTAssertEqual(author?.favoriteArticle?.id, "1")
                    XCTAssertEqual(author?.favoriteArticle?.author, article.author) // Bidirectionnel
                    
                    // First article coAuthor
                    let firstCoAuthor: Person? = article.coAuthors?.first
                    XCTAssertEqual(firstCoAuthor?.id, "2")
                    XCTAssertEqual(firstCoAuthor?.type, "persons")
                    XCTAssertEqual(firstCoAuthor?.name, "Glupan")
                    XCTAssert((firstCoAuthor?.favoriteArticle?.coAuthors?.contains(firstCoAuthor!))!) // Bidirectionnel
                    XCTAssertEqual(firstCoAuthor?.favoriteArticle?.id, "1")
                    
                    // Last article coAuthor
                    let lastCoAuthor: Person? = article.coAuthors?.last
                    XCTAssertEqual(lastCoAuthor?.id, "3")
                    XCTAssertEqual(lastCoAuthor?.type, "persons")
                    XCTAssertEqual(lastCoAuthor?.name, "Debil")
                    
                    // Last article coAuthor favorite article
                    let lastCoAuthorFavoriteArticle = lastCoAuthor?.favoriteArticle
                    XCTAssertEqual(lastCoAuthorFavoriteArticle?.id, "2")
                    XCTAssertEqual(lastCoAuthorFavoriteArticle?.type, "articles")
                    XCTAssertEqual(lastCoAuthorFavoriteArticle?.title, "Another Title")
                    XCTAssertEqual(lastCoAuthorFavoriteArticle?.body, "Another Body")
                    XCTAssertEqual(lastCoAuthorFavoriteArticle?.author?.id, "1")
                }
            }, { (_, _) in
                expectation.fulfill()
                XCTFail("Mock client should not fail this request")
            })
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testResourceSerialization() {
        let article = Article()
        article.id = "serialization"
        
        let expectation = XCTestExpectation(description: "Answer from the mock client")
        
        ResourceRequest<Article>(path: "", method: HttpMethod.get, client: self.client, resource: article)
            .queryItems([URLQueryItem(name: "resourceSerialization", value: "true")])
            .result({ (resource, document) in
                expectation.fulfill()
                
                guard let resource = resource else {
                    XCTFail("Resource should not be empty")
                    return
                }
                guard let document = document else {
                    XCTFail("Document should not be empty")
                    return
                }
                
                XCTAssertEqual(resource.id, article.id)
                XCTAssertEqual(["data": resource.toResourceObject().toJson()] as NSDictionary, document.toJson() as NSDictionary)
            }, { (_, _) in
                expectation.fulfill()
                XCTFail("Request should not fail")
            })
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    func testNotJsonFormat() {
        let expectation = XCTestExpectation(description: "Answer from the mock client")
        
        ResourceRequest<Article>(path: "", method: HttpMethod.get, client: self.client, resource: nil)
            .queryItems([URLQueryItem(name: "notJsonFormat", value: "true")])
            .result({ (_, _) in
                expectation.fulfill()
                XCTFail("Request should fail")
            }, { (error, document) in
                expectation.fulfill()
                
                if let error = error as NSError?, error.code != 3840 {
                    XCTFail("Not the expected error")
                }
                XCTAssertNil(document)
            })
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testError() {
        let expectation = XCTestExpectation(description: "Answer from the mock client")
        
        ResourceRequest<Article>(path: "", method: HttpMethod.get, client: self.client, resource: nil)
            .queryItems([URLQueryItem(name: "error", value: "true")])
            .result({ (_, _) in
                expectation.fulfill()
                XCTFail("Request should fail")
            }, { (error, document) in
                expectation.fulfill()
                
                XCTAssertNil(error)
                guard let document = document else {
                    XCTFail("Document should not be empty")
                    return
                }
                
                XCTAssertEqual(document.toJson() as NSDictionary, MockClient.errorDocument as NSDictionary?)
            })
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testErrorNoResult() {
        let expectation = XCTestExpectation(description: "Answer from the mock client")
        
        ResourceRequest<Article>(path: "", method: HttpMethod.get, client: self.client, resource: nil)
            .queryItems([URLQueryItem(name: "error", value: "true"), URLQueryItem(name: "noResult", value: "true")])
            .result({ (_, _) in
                expectation.fulfill()
                XCTFail("Request should fail")
            }, { (error, document) in
                expectation.fulfill()
                
                XCTAssertNil(error)
                XCTAssertNil(document)
            })
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testErrorNotJsonFormat() {
        let expectation = XCTestExpectation(description: "Answer from the mock client")
        
        ResourceRequest<Article>(path: "", method: HttpMethod.get, client: client, resource: nil)
            .queryItems([URLQueryItem(name: "error", value: "true"), URLQueryItem(name: "notJsonFormat", value: "true")])
            .result({ (_, _) in
                expectation.fulfill()
                XCTFail("Request should fail")
            }, { (error, document) in
                expectation.fulfill()
                
                guard let error = error else {
                    XCTFail("Error should not be empty")
                    return
                }
                XCTAssertNil(document)
                
                if let error = error as NSError?, error.code != 3840 {
                    XCTFail("Not the expected error")
                }
            })
        
        wait(for: [expectation], timeout: 1.0)
    }

    func testResourceRequestInheritedIncluded() {
        let expectation = XCTestExpectation(description: "Answer from the mock client")

        ResourceRequest<ContactList>(path: "", method: HttpMethod.get, client: self.client, resource: nil)
            .queryItems([URLQueryItem(name: "includeInherited", value: "true")])
            .result({ (list: ContactList?, document: Document?) in
                expectation.fulfill()

                    // ContactList
                XCTAssertEqual(list?.id, "1")
                XCTAssertEqual(list?.type, "contactlists")
                XCTAssertEqual(list?.name, "List")

                    // First list contact
                let firstContact: Contact? = list?.contacts?.first
                XCTAssertEqual(firstContact?.id, "2")
                XCTAssertEqual(firstContact?.type, "contacts")
                XCTAssertEqual(firstContact?.name, "Contact")
                XCTAssertEqual(firstContact?.email, "Email")

            }, { (_, _) in
                expectation.fulfill()
                XCTFail("Mock client should not fail this request")
            })

        wait(for: [expectation], timeout: 1.0)
    }


}
