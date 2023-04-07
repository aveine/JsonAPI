import XCTest
import JsonAPI

class DocumentTests: XCTestCase {
    static let documentSingleJson: Document.JsonObject = [
        "data": resourceJson,
        "included": [
            resourceJson
        ],
        "links": linksStringJson,
        "jsonapi": jsonApiJson,
        "meta": [
            "foo": "bar"
        ]
    ]
    
    static let documentArrayJson: Document.JsonObject = [
        "data": [
            resourceJson,
            resourceJson
        ],
        "included": [
            resourceJson
        ],
        "links": linksStringJson,
        "jsonapi": jsonApiJson,
        "meta": [
            "foo": "bar"
        ]
    ]
    
    static let documentErrorJson: Document.JsonObject = [
        "errors": [
            errorJson
        ]
    ]
    
    static let resourceJson: Document.JsonObject = [
        "id": "1",
        "type": "articles",
        "attributes": [
            "title": "Title",
            "body": "Body"
        ],
        "relationships": [
            "author": relationshipSingleJson
        ],
        "links": [
            "self": "/articles/1"
        ],
        "meta": [
            "foo": "bar"
        ]
    ]
    
    static let relationshipSingleJson: Document.JsonObject = [
        "data": [
            "id":"1",
            "type": "persons",
            "meta": [
                "foo": "bar"
            ]
        ],
        "links": [
            "self": "/articles/1/author",
            "related": "/articles/1"
        ],
        "meta": [
            "foo": "bar"
        ]
    ]
    
    static let relationshipArrayJson: Document.JsonObject = [
        "data": [
            [
                "id":"1",
                "type": "persons",
                "meta": [
                    "foo": "bar"
                ]
            ]
        ],
        "links": [
            "self": "/articles/1/author",
            "related": "/articles/1"
        ],
        "meta": [
            "foo": "bar"
        ]
    ]
    
    static let resourceIdentifierIdOnlyJson: Document.JsonObject = [
        "id": "2",
        "type": "persons",
        "meta": [
            "foo": "bar"
        ]
    ]

    static let resourceIdentifierLidOnlyJson: Document.JsonObject = [
        "lid": "3",
        "type": "persons",
        "meta": [
            "foo": "bar"
        ]
    ]

    static let resourceIdentifierJson: Document.JsonObject = [
        "id": "2",
        "lid": "3",
        "type": "persons",
        "meta": [
            "foo": "bar"
        ]
    ]
    
    static let linksStringJson: Document.JsonObject = [
        "self": "http://example.com/articles?page[number]=3&page[size]=1",
        "about": "http://example.com",
        "related": "http://example.com/articles",
        "first": "http://example.com/articles?page[number]=1&page[size]=1",
        "prev": "http://example.com/articles?page[number]=2&page[size]=1",
        "next": "http://example.com/articles?page[number]=4&page[size]=1",
        "last": "http://example.com/articles?page[number]=13&page[size]=1"
    ]
    
    static let linksObjectJson: Document.JsonObject = [
        "self": [
            "href": "http://example.com/articles?page[number]=3&page[size]=1",
            "meta": [
                "foo": "bar"
            ]
        ],
        "about": [
            "href": "http://example.com",
            "meta": [
                "foo": "bar"
            ]
        ],
        "related": [
            "href": "http://example.com/articles",
            "meta": [
                "foo": "bar"
            ]
        ],
        "first": [
            "href": "http://example.com/articles?page[number]=1&page[size]=1",
            "meta": [
                "foo": "bar"
            ]
        ],
        "prev": [
            "href": "http://example.com/articles?page[number]=2&page[size]=1",
            "meta": [
                "foo": "bar"
            ]
        ],
        "next": [
            "href": "http://example.com/articles?page[number]=4&page[size]=1",
            "meta": [
                "foo": "bar"
            ]
        ],
        "last": [
            "href": "http://example.com/articles?page[number]=13&page[size]=1",
            "meta": [
                "foo": "bar"
            ]
        ]
    ]
    
    static let jsonApiJson: Document.JsonObject = [
        "version": "1.0",
        "meta": [
            "foo": "bar"
        ]
    ]
    
    static let errorJson: Document.JsonObject = [
        "id": "1",
        "links": [
            "about": "somewhere.com"
        ],
        "status": "422",
        "code": "kb-422",
        "title": "Title error",
        "detail": "Detail error",
        "source": [
            "pointer": "/data/attributes/title",
            "parameter": "title"
        ],
        "meta": [
            "foo": "bar"
        ]
    ]
    
    func testDocumentSingleUnserialization() {
        let json = DocumentTests.documentSingleJson
        
        let document = try! Document(json: json)
        
        let dictionnary = json as NSDictionary
        let data = dictionnary["data"] as? Document.JsonObject
        let included = dictionnary["included"] as? [Document.JsonObject]
        let links = dictionnary["links"] as? Document.JsonObject
        let jsonApi = dictionnary["jsonapi"] as? Document.JsonObject
        let meta = dictionnary["meta"] as? Document.JsonObject
        
        switch document.data {
        case .single(let resource):
            XCTAssertEqual(resource.toJson() as NSDictionary?, data as NSDictionary?)
        case .collection(_):
            XCTFail("Data should be a collection")
        case .none:
            break
        }
        XCTAssertEqual(document.included?.map { $0.toJson() } as [NSDictionary]?, included as [NSDictionary]?)
        XCTAssertEqual(document.links?.toJson() as NSDictionary?, links as NSDictionary?)
        XCTAssertEqual(document.jsonapi?.toJson() as NSDictionary?, jsonApi as NSDictionary?)
        XCTAssertEqual(document.meta as NSDictionary?, meta as NSDictionary?)
        
        XCTAssertEqual(document.toJson() as NSDictionary, dictionnary)
    }
    
    func testDocumentSingleSerialization() {
        let json = DocumentTests.documentSingleJson
        
        let dictionnary = json as NSDictionary
        let data = dictionnary["data"] as? Document.JsonObject
        let included = dictionnary["included"] as? [Document.JsonObject]
        let links = dictionnary["links"] as? Document.JsonObject
        let jsonApi = dictionnary["jsonapi"] as? Document.JsonObject
        let meta = dictionnary["meta"] as? Document.JsonObject
        
        let document = try! Document(
            data: data != nil ? Document.PrimaryData.single(resource: try! Document.ResourceObject(json: data!)) : nil,
            errors: nil,
            meta: meta,
            jsonapi: jsonApi != nil ? Document.JsonApiObject(json: jsonApi!) : nil,
            links: links != nil ? Document.LinksObject(json: links!) : nil,
            included: included != nil ? included!.map { try! Document.ResourceObject(json: $0) } : nil
        )
        
        XCTAssertEqual(document.toJson() as NSDictionary, dictionnary)
    }
    
    func testDocumentArrayUnserialization() {
        let json = DocumentTests.documentArrayJson
        
        let document = try! Document(json: json)
        
        let dictionnary = json as NSDictionary
        let data = dictionnary["data"] as? [Document.JsonObject]
        let included = dictionnary["included"] as? [Document.JsonObject]
        let links = dictionnary["links"] as? Document.JsonObject
        let jsonApi = dictionnary["jsonapi"] as? Document.JsonObject
        let meta = dictionnary["meta"] as? Document.JsonObject
        
        switch document.data {
        case .single(_):
            XCTFail("Data should be single")
        case .collection(let resources):
            XCTAssertEqual(resources.map { $0.toJson() } as [NSDictionary]?, data as [NSDictionary]?)
        case .none:
            break
        }
        XCTAssertEqual(document.included?.map { $0.toJson() } as [NSDictionary]?, included as [NSDictionary]?)
        XCTAssertEqual(document.links?.toJson() as NSDictionary?, links as NSDictionary?)
        XCTAssertEqual(document.jsonapi?.toJson() as NSDictionary?, jsonApi as NSDictionary?)
        XCTAssertEqual(document.meta as NSDictionary?, meta as NSDictionary?)
        
        XCTAssertEqual(document.toJson() as NSDictionary, dictionnary)
    }
    
    func testDocumentArraySerialization() {
        let json = DocumentTests.documentArrayJson
        
        let dictionnary = json as NSDictionary
        let data = dictionnary["data"] as? [Document.JsonObject]
        let included = dictionnary["included"] as? [Document.JsonObject]
        let links = dictionnary["links"] as? Document.JsonObject
        let jsonApi = dictionnary["jsonapi"] as? Document.JsonObject
        let meta = dictionnary["meta"] as? Document.JsonObject
        
        let document = try! Document(
            data: data != nil ? Document.PrimaryData.collection(resources: data!.map { try! Document.ResourceObject(json: $0) }) : nil,
            errors: nil,
            meta: meta,
            jsonapi: jsonApi != nil ? Document.JsonApiObject(json: jsonApi!) : nil,
            links: links != nil ? Document.LinksObject(json: links!) : nil,
            included: included != nil ? included!.map { try! Document.ResourceObject(json: $0) } : nil
        )
        
        XCTAssertEqual(document.toJson() as NSDictionary, dictionnary)
    }
    
    func testDocumentErrorUnserialization() {
        let json = DocumentTests.documentErrorJson
        
        let document = try! Document(json: json)
        
        let dictionnary = json as NSDictionary
        let errors = dictionnary["errors"] as? [Document.JsonObject]
        
        XCTAssertEqual(document.errors?.map { $0.toJson() } as [NSDictionary]?, errors as [NSDictionary]?)
        
        XCTAssertEqual(document.toJson() as NSDictionary, dictionnary)
    }
    
    func testDocumentErrorSerialization() {
        let json = DocumentTests.documentErrorJson
        
        let dictionnary = json as NSDictionary
        let errors = dictionnary["errors"] as? [Document.JsonObject]
        let error = errors?.first
        
        let document = try! Document(
            data: nil,
            errors: error != nil ? [Document.ErrorObject(json: error!)] : nil,
            meta: nil,
            jsonapi: nil,
            links: nil,
            included: nil
        )
        
        XCTAssertEqual(document.toJson() as NSDictionary, dictionnary)
    }
    
    func testWrongDocument() {
        XCTAssertThrowsError(try Document(json: [:])) { error in
            XCTAssertEqual(error as! Document.DocumentError, Document.DocumentError.emptyDocument)
        }
        XCTAssertThrowsError(try Document(data: nil, errors: nil, meta: nil, jsonapi: nil, links: nil, included: nil)) { error in
            XCTAssertEqual(error as! Document.DocumentError, Document.DocumentError.emptyDocument)
        }
        
        XCTAssertThrowsError(try Document(json: ["included": [DocumentTests.resourceJson]])) { error in
            XCTAssertEqual(error as! Document.DocumentError, Document.DocumentError.includedWithoutData)
        }
        XCTAssertThrowsError(try Document(data: nil, errors: nil, meta: nil, jsonapi: nil, links: nil, included: [Document.ResourceObject(json: DocumentTests.resourceJson)])) { error in
            XCTAssertEqual(error as! Document.DocumentError, Document.DocumentError.includedWithoutData)
        }
        
        XCTAssertThrowsError(try Document(json: ["data": DocumentTests.resourceJson, "errors": [DocumentTests.errorJson]])) { error in
            XCTAssertEqual(error as! Document.DocumentError, Document.DocumentError.dataAndError)
        }
        XCTAssertThrowsError(try Document(data: Document.PrimaryData.single(resource: Document.ResourceObject(json: DocumentTests.resourceJson)), errors: [Document.ErrorObject(json: DocumentTests.errorJson)], meta: nil, jsonapi: nil, links: nil, included: nil)) { error in
            XCTAssertEqual(error as! Document.DocumentError, Document.DocumentError.dataAndError)
        }
    }
    
    func testResourceUnserialization() {
        let json = DocumentTests.resourceJson
        
        let resourceObject = try! Document.ResourceObject(json: json)
        
        let dictionnary = json as NSDictionary
        let id = dictionnary.value(forKeyPath: "id") as? String
        let type = dictionnary.value(forKeyPath: "type") as! String
        let attributes = dictionnary["attributes"] as? Document.JsonObject
        let relationships = dictionnary["relationships"] as? Document.JsonObject
        let links = dictionnary["links"] as? Document.JsonObject
        let meta = dictionnary["meta"] as? Document.JsonObject
        
        XCTAssertEqual(resourceObject.id, id)
        XCTAssertEqual(resourceObject.type, type)
        XCTAssertEqual(resourceObject.attributes as NSDictionary?, attributes as NSDictionary?)
        XCTAssertEqual(resourceObject.relationships?.first?.value.toJson() as NSDictionary?, relationships?.first?.value as? NSDictionary)
        XCTAssertEqual(resourceObject.links?.toJson() as NSDictionary?, links as NSDictionary?)
        XCTAssertEqual(resourceObject.meta as NSDictionary?, meta as NSDictionary?)
        
        XCTAssertEqual(resourceObject.toJson() as NSDictionary, dictionnary)
    }
    
    func testResourceSerialization() {
        let json = DocumentTests.resourceJson
        
        let dictionnary = json as NSDictionary
        let id = dictionnary.value(forKeyPath: "id") as? String
        let type = dictionnary.value(forKeyPath: "type") as! String
        let attributes = dictionnary["attributes"] as? Document.JsonObject
        let relationships = dictionnary["relationships"] as? Document.JsonObject
        let links = dictionnary["links"] as? Document.JsonObject
        let meta = dictionnary["meta"] as? Document.JsonObject
        
        let relationshipObjects: Document.RelationshipObjects? = {
            if let relationships = relationships {
                return Document.RelationshipObjects(uniqueKeysWithValues: relationships.map { ($0.key, try! Document.RelationshipObject(json: $0.value as! Document.JsonObject)) })
            }
            return nil
        }()
        
        let resourceObject = Document.ResourceObject(
            id: id,
            lid: nil,
            type: type,
            attributes: attributes,
            relationships: relationshipObjects,
            links: links != nil ? Document.LinksObject(json: links!) : nil,
            meta: meta
        )
        
        XCTAssertEqual(resourceObject.toJson() as NSDictionary, dictionnary)
    }
    
    func testWrongResource() {
        XCTAssertThrowsError(try Document.ResourceObject(json: [:])) { error in
            XCTAssertEqual(error as! Document.DocumentError, Document.DocumentError.missingKey(key: "type"))
        }
    }
    
    func testRelationshipSingleUnserialization() {
        let json = DocumentTests.relationshipSingleJson
        
        let relationshipObject = try! Document.RelationshipObject(json: json)
        
        let dictionnary = json as NSDictionary
        let links = dictionnary["links"] as? Document.JsonObject
        let data = dictionnary["data"] as? Document.JsonObject
        let meta = dictionnary["meta"] as? Document.JsonObject
        
        XCTAssertEqual(relationshipObject.links?.toJson() as NSDictionary?, links as NSDictionary?)
        switch relationshipObject.data {
        case .single(let identifier):
            XCTAssertEqual(identifier?.id, data?["id"] as? String)
            XCTAssertEqual(identifier?.type, data?["type"] as? String)
            XCTAssertEqual(identifier?.meta as NSDictionary?, data?["meta"] as? NSDictionary)
        case .collection(_):
            XCTFail("Data should be single")
        case .none:
            break
        }
        XCTAssertEqual(relationshipObject.meta as NSDictionary?, meta as NSDictionary?)
        
        XCTAssertEqual(relationshipObject.toJson() as NSDictionary, dictionnary)
    }
    
    func testRelationshipSingleSerialization() {
        let json = DocumentTests.relationshipSingleJson
        
        let dictionnary = json as NSDictionary
        let links = dictionnary["links"] as? Document.JsonObject
        let data = dictionnary["data"] as? Document.JsonObject
        let meta = dictionnary["meta"] as? Document.JsonObject
        
        let resourceLinkage: Document.RelationshipObject.ResourceLinkage? = {
            if let object = data {
                let identifier = try! Document.ResourceIdentifierObject(json: object)
                return Document.RelationshipObject.ResourceLinkage.single(identifier: identifier)
            }
            return nil
        }()
        
        let relationshipObject = try! Document.RelationshipObject(
            links: links != nil ? Document.LinksObject(json: links!) : nil,
            data: resourceLinkage,
            meta: meta
        )
        
        XCTAssertEqual(relationshipObject.toJson() as NSDictionary, dictionnary)
    }
    
    func testRelationshipArrayUnserialization() {
        let json = DocumentTests.relationshipArrayJson
        
        let relationshipObject = try! Document.RelationshipObject(json: json)
        
        let dictionnary = json as NSDictionary
        let links = dictionnary["links"] as? Document.JsonObject
        let data = dictionnary["data"] as? [Document.JsonObject]
        let meta = dictionnary["meta"] as? Document.JsonObject
        
        XCTAssertEqual(relationshipObject.links?.toJson() as NSDictionary?, links as NSDictionary?)
        switch relationshipObject.data {
        case .single(_):
            XCTFail("Data should be an array")
        case .collection(let identifiers):
            XCTAssertEqual(identifiers.first?.id, data?.first?["id"] as? String)
            XCTAssertEqual(identifiers.first?.type, data?.first?["type"] as? String)
            XCTAssertEqual(identifiers.first?.meta as NSDictionary?, data?.first?["meta"] as? NSDictionary)
        case .none:
            break
        }
        XCTAssertEqual(relationshipObject.meta as NSDictionary?, meta as NSDictionary?)
        
        XCTAssertEqual(relationshipObject.toJson() as NSDictionary, dictionnary)
    }
    
    func testRelationshipArraySerialization() {
        let json = DocumentTests.relationshipArrayJson
        
        let dictionnary = json as NSDictionary
        let links = dictionnary["links"] as? Document.JsonObject
        let data = dictionnary["data"] as? [Document.JsonObject]
        let meta = dictionnary["meta"] as? Document.JsonObject
        
        let resourceLinkage: Document.RelationshipObject.ResourceLinkage? = {
            if let objects = data {
                let identifiers = objects.map { try! Document.ResourceIdentifierObject(json: $0) }
                return Document.RelationshipObject.ResourceLinkage.collection(identifiers: identifiers)
            }
            return nil
        }()
        
        let relationshipObject = try! Document.RelationshipObject(
            links: links != nil ? Document.LinksObject(json: links!) : nil,
            data: resourceLinkage,
            meta: meta
        )
        
        XCTAssertEqual(relationshipObject.toJson() as NSDictionary, dictionnary)
    }
    
    func testWrongRelationship() {
        XCTAssertThrowsError(try Document.RelationshipObject(json: [:])) { error in
            XCTAssertEqual(error as! Document.DocumentError, Document.DocumentError.emptyRelationshipObject)
        }
        
        XCTAssertThrowsError(try Document.RelationshipObject(links: nil, data: nil, meta: nil)) { error in
            XCTAssertEqual(error as! Document.DocumentError, Document.DocumentError.emptyRelationshipObject)
        }
    }

    func testResourceIdentiferIdOnlyUnserialization() {
        let json = DocumentTests.resourceIdentifierIdOnlyJson

        let resourceIdentifierObject = try! Document.ResourceIdentifierObject(json: json)

        let dictionnary = json as NSDictionary
        let id = dictionnary["id"] as! String
        let type = dictionnary["type"] as! String
        let meta = dictionnary["meta"] as? Document.JsonObject

        XCTAssertEqual(resourceIdentifierObject.id, id)
        XCTAssertEqual(resourceIdentifierObject.type, type)
        XCTAssertEqual(resourceIdentifierObject.meta as NSDictionary?, meta as NSDictionary?)

        XCTAssertEqual(resourceIdentifierObject.toJson() as NSDictionary, dictionnary)
    }

    func testResourceIdentifierIdOnlySerialization() {
        let json = DocumentTests.resourceIdentifierIdOnlyJson

        let dictionnary = json as NSDictionary
        let id = dictionnary["id"] as! String
        let type = dictionnary["type"] as! String
        let meta = dictionnary["meta"] as? Document.JsonObject

        let resourceIdentifierObject = try! Document.ResourceIdentifierObject(
            id: id,
            lid: nil,
            type: type,
            meta: meta
        )

        XCTAssertEqual(resourceIdentifierObject.toJson() as NSDictionary, dictionnary)
    }

    func testResourceIdentiferLidOnlyUnserialization() {
        let json = DocumentTests.resourceIdentifierLidOnlyJson

        let resourceIdentifierObject = try! Document.ResourceIdentifierObject(json: json)

        let dictionnary = json as NSDictionary
        let lid = dictionnary["lid"] as! String
        let type = dictionnary["type"] as! String
        let meta = dictionnary["meta"] as? Document.JsonObject

        XCTAssertEqual(resourceIdentifierObject.lid, lid)
        XCTAssertEqual(resourceIdentifierObject.type, type)
        XCTAssertEqual(resourceIdentifierObject.meta as NSDictionary?, meta as NSDictionary?)

        XCTAssertEqual(resourceIdentifierObject.toJson() as NSDictionary, dictionnary)
    }

    func testResourceIdentifierLidOnlySerialization() {
        let json = DocumentTests.resourceIdentifierLidOnlyJson

        let dictionnary = json as NSDictionary
        let lid = dictionnary["lid"] as! String
        let type = dictionnary["type"] as! String
        let meta = dictionnary["meta"] as? Document.JsonObject

        let resourceIdentifierObject = try! Document.ResourceIdentifierObject(
            id: nil,
            lid: lid,
            type: type,
            meta: meta
        )

        XCTAssertEqual(resourceIdentifierObject.toJson() as NSDictionary, dictionnary)
    }

    func testResourceIdentiferUnserialization() {
        var json = DocumentTests.resourceIdentifierJson

        let resourceIdentifierObject = try! Document.ResourceIdentifierObject(json: json)

        let id = json["id"] as! String
        let lid = json["lid"] as! String
        let type = json["type"] as! String
        let meta = json["meta"] as? Document.JsonObject

        XCTAssertEqual(resourceIdentifierObject.id, id)
        XCTAssertEqual(resourceIdentifierObject.lid, lid)
        XCTAssertEqual(resourceIdentifierObject.type, type)
        XCTAssertEqual(resourceIdentifierObject.meta as NSDictionary?, meta as NSDictionary?)

        json.removeValue(forKey: "lid")
        XCTAssertEqual(resourceIdentifierObject.toJson() as NSDictionary, (json as NSDictionary))
    }

    func testResourceIdentifierSerialization() {
        var json = DocumentTests.resourceIdentifierJson

        let id = json["id"] as! String
        let lid = json["lid"] as! String
        let type = json["type"] as! String
        let meta = json["meta"] as? Document.JsonObject

        let resourceIdentifierObject = try! Document.ResourceIdentifierObject(
            id: id,
            lid: lid,
            type: type,
            meta: meta
        )

        json.removeValue(forKey: "lid")
        XCTAssertEqual(resourceIdentifierObject.toJson() as NSDictionary, (json as NSDictionary))
    }

    func testWrongResourceIdentifer() {
        XCTAssertThrowsError(try Document.ResourceIdentifierObject(json: [:])) { error in
            XCTAssertEqual(error as! Document.DocumentError, Document.DocumentError.missingKey(key: "id or lid"))
        }

        XCTAssertThrowsError(try Document.ResourceIdentifierObject(id: nil, lid: nil, type: "persons", meta: nil)) { error in
            XCTAssertEqual(error as! Document.DocumentError, Document.DocumentError.missingKey(key: "id or lid"))
        }

        XCTAssertThrowsError(try Document.ResourceIdentifierObject(json: ["id": "1"])) { error in
            XCTAssertEqual(error as! Document.DocumentError, Document.DocumentError.missingKey(key: "type"))
        }
    }
    
    func testLinksStringUnserialization() {
        let json = DocumentTests.linksStringJson
        
        let linksObject = Document.LinksObject(json: json)
        
        let dictionnary = json as NSDictionary
        let _self = dictionnary["self"] as? String
        let about = dictionnary["about"] as? String
        let related = dictionnary["related"] as? String
        let first = dictionnary["first"] as? String
        let prev = dictionnary["prev"] as? String
        let next = dictionnary["next"] as? String
        let last = dictionnary["last"] as? String
        
        switch linksObject._self {
        case .string(let url):
            XCTAssertEqual(url, _self)
        case .linkObject(_, _):
            XCTFail("Self link should be a simple url")
        case .none:
            break
        }
        switch linksObject.about {
        case .string(let url):
            XCTAssertEqual(url, about)
        case .linkObject(_, _):
            XCTFail("About link should be a simple url")
        case .none:
            break
        }
        switch linksObject.related {
        case .string(let url):
            XCTAssertEqual(url, related)
        case .linkObject(_, _):
            XCTFail("Related link should be a simple url")
        case .none:
            break
        }
        switch linksObject.first {
        case .string(let url):
            XCTAssertEqual(url, first)
        case .linkObject(_, _):
            XCTFail("First link should be a simple url")
        case .none:
            break
        }
        switch linksObject.prev {
        case .string(let url):
            XCTAssertEqual(url, prev)
        case .linkObject(_, _):
            XCTFail("Prev link should be a simple url")
        case .none:
            break
        }
        switch linksObject.next {
        case .string(let url):
            XCTAssertEqual(url, next)
        case .linkObject(_, _):
            XCTFail("Next link should be a simple url")
        case .none:
            break
        }
        switch linksObject.last {
        case .string(let url):
            XCTAssertEqual(url, last)
        case .linkObject(_, _):
            XCTFail("Last link should be a simple url")
        case .none:
            break
        }
        
        XCTAssertEqual(linksObject.toJson() as NSDictionary, dictionnary)
    }
    
    func testLinksStringSerialization() {
        let json = DocumentTests.linksStringJson
        
        let dictionnary = json as NSDictionary
        let _self = dictionnary["self"] as? String
        let about = dictionnary["about"] as? String
        let related = dictionnary["related"] as? String
        let first = dictionnary["first"] as? String
        let prev = dictionnary["prev"] as? String
        let next = dictionnary["next"] as? String
        let last = dictionnary["last"] as? String
        
        let linksObject = Document.LinksObject(
            _self: _self != nil ? Document.LinksObject.Link.string(url: _self!) : nil,
            about: about != nil ? Document.LinksObject.Link.string(url: about!) : nil,
            related: related != nil ? Document.LinksObject.Link.string(url: related!) : nil,
            first: first != nil ? Document.LinksObject.Link.string(url: first!) : nil,
            prev: prev != nil ? Document.LinksObject.Link.string(url: prev!) : nil,
            next: next != nil ? Document.LinksObject.Link.string(url: next!) : nil,
            last: last != nil ? Document.LinksObject.Link.string(url: last!) : nil
        )
        
        XCTAssertEqual(linksObject.toJson() as NSDictionary, dictionnary)
    }
    
    func testLinksObjectUnserialization() {
        let json = DocumentTests.linksObjectJson
        
        let linksObject = Document.LinksObject(json: json)
        
        let dictionnary = json as NSDictionary
        let _self = dictionnary["self"] as? Document.JsonObject
        let about = dictionnary["about"] as? Document.JsonObject
        let related = dictionnary["related"] as? Document.JsonObject
        let first = dictionnary["first"] as? Document.JsonObject
        let prev = dictionnary["prev"] as? Document.JsonObject
        let next = dictionnary["next"] as? Document.JsonObject
        let last = dictionnary["last"] as? Document.JsonObject
        
        switch linksObject._self {
        case .linkObject(let href, let meta):
            XCTAssertEqual(href, _self?["href"] as? String)
            XCTAssertEqual(meta as NSDictionary?, _self?["meta"] as? NSDictionary)
        case .string(_):
            XCTFail("Self link should be a link object")
        case .none:
            break
        }
        switch linksObject.about {
        case .linkObject(let href, let meta):
            XCTAssertEqual(href, about?["href"] as? String)
            XCTAssertEqual(meta as NSDictionary?, about?["meta"] as? NSDictionary)
        case .string(_):
            XCTFail("About link should be a link object")
        case .none:
            break
        }
        switch linksObject.related {
        case .linkObject(let href, let meta):
            XCTAssertEqual(href, related?["href"] as? String)
            XCTAssertEqual(meta as NSDictionary?, related?["meta"] as? NSDictionary)
        case .string(_):
            XCTFail("Related link should be a link object")
        case .none:
            break
        }
        switch linksObject.first {
        case .linkObject(let href, let meta):
            XCTAssertEqual(href, first?["href"] as? String)
            XCTAssertEqual(meta as NSDictionary?, first?["meta"] as? NSDictionary)
        case .string(_):
            XCTFail("First link should be a link object")
        case .none:
            break
        }
        switch linksObject.prev {
        case .linkObject(let href, let meta):
            XCTAssertEqual(href, prev?["href"] as? String)
            XCTAssertEqual(meta as NSDictionary?, prev?["meta"] as? NSDictionary)
        case .string(_):
            XCTFail("Prev link should be a link object")
        case .none:
            break
        }
        switch linksObject.next {
        case .linkObject(let href, let meta):
            XCTAssertEqual(href, next?["href"] as? String)
            XCTAssertEqual(meta as NSDictionary?, next?["meta"] as? NSDictionary)
        case .string(_):
            XCTFail("Next link should be a link object")
        case .none:
            break
        }
        switch linksObject.last {
        case .linkObject(let href, let meta):
            XCTAssertEqual(href, last?["href"] as? String)
            XCTAssertEqual(meta as NSDictionary?, last?["meta"] as? NSDictionary)
        case .string(_):
            XCTFail("Last link should be a link object")
        case .none:
            break
        }
        
        XCTAssertEqual(linksObject.toJson() as NSDictionary, dictionnary)
    }
    
    func testLinksObjectSerialization() {
        let json = DocumentTests.linksObjectJson
        
        let dictionnary = json as NSDictionary
        let _self = dictionnary["self"] as? Document.JsonObject
        let about = dictionnary["about"] as? Document.JsonObject
        let related = dictionnary["related"] as? Document.JsonObject
        let first = dictionnary["first"] as? Document.JsonObject
        let prev = dictionnary["prev"] as? Document.JsonObject
        let next = dictionnary["next"] as? Document.JsonObject
        let last = dictionnary["last"] as? Document.JsonObject
        
        let linksObject = Document.LinksObject(
            _self: _self != nil ? Document.LinksObject.Link.linkObject(href: _self!["href"] as? String, meta: _self!["meta"] as? Document.JsonObject) : nil,
            about: about != nil ? Document.LinksObject.Link.linkObject(href: about!["href"] as? String, meta: about!["meta"] as? Document.JsonObject) : nil,
            related: related != nil ? Document.LinksObject.Link.linkObject(href: related!["href"] as? String, meta: related!["meta"] as? Document.JsonObject) : nil,
            first: first != nil ? Document.LinksObject.Link.linkObject(href: first!["href"] as? String, meta: first!["meta"] as? Document.JsonObject) : nil,
            prev: prev != nil ? Document.LinksObject.Link.linkObject(href: prev!["href"] as? String, meta: prev!["meta"] as? Document.JsonObject) : nil,
            next: next != nil ? Document.LinksObject.Link.linkObject(href: next!["href"] as? String, meta: next!["meta"] as? Document.JsonObject) : nil,
            last: last != nil ? Document.LinksObject.Link.linkObject(href: last!["href"] as? String, meta: last!["meta"] as? Document.JsonObject) : nil
        )
        
        XCTAssertEqual(linksObject.toJson() as NSDictionary, dictionnary)
    }
    
    func testJsonApiUnserialization() {
        let json = DocumentTests.jsonApiJson
        
        let jsonApiObject = Document.JsonApiObject(json: json)
        
        let dictionnary = json as NSDictionary
        let version = dictionnary["version"] as? String
        let meta = dictionnary["meta"] as? Document.JsonObject
        
        XCTAssertEqual(jsonApiObject.version, version)
        XCTAssertEqual(jsonApiObject.meta as NSDictionary?, meta as NSDictionary?)
        
        XCTAssertEqual(jsonApiObject.toJson() as NSDictionary, dictionnary)
    }
    
    func testJsonApiSerialization() {
        let json = DocumentTests.jsonApiJson
        
        let dictionnary = json as NSDictionary
        let version = dictionnary["version"] as? String
        let meta = dictionnary["meta"] as? Document.JsonObject
        
        let jsonApiObject = Document.JsonApiObject(
            version: version,
            meta: meta
        )
        
        XCTAssertEqual(jsonApiObject.toJson() as NSDictionary, dictionnary)
    }
    
    func testErrorUnserialization() {
        let json = DocumentTests.errorJson
        
        let errorObject = Document.ErrorObject(json: json)
        
        let dictionnary = json as NSDictionary
        let id = dictionnary["id"] as? String
        let links = dictionnary["links"] as? Document.JsonObject
        let status = dictionnary["status"] as? String
        let code = dictionnary["code"] as? String
        let title = dictionnary["title"] as? String
        let detail = dictionnary["detail"] as? String
        let source = dictionnary["source"] as? Document.JsonObject
        let meta = dictionnary["meta"] as? Document.JsonObject
        
        XCTAssertEqual(errorObject.id, id)
        XCTAssertEqual(errorObject.links?.toJson() as NSDictionary?, links as NSDictionary?)
        XCTAssertEqual(errorObject.status, status)
        XCTAssertEqual(errorObject.code, code)
        XCTAssertEqual(errorObject.title, title)
        XCTAssertEqual(errorObject.detail, detail)
        XCTAssertEqual(errorObject.source?.pointer, source?["pointer"] as? String)
        XCTAssertEqual(errorObject.source?.parameter, source?["parameter"] as? String)
        XCTAssertEqual(errorObject.meta as NSDictionary?, meta as NSDictionary?)
        
        XCTAssertEqual(errorObject.toJson() as NSDictionary, dictionnary)
    }
    
    func testErrorSerialization() {
        let json = DocumentTests.errorJson
        
        let dictionnary = json as NSDictionary
        let id = dictionnary["id"] as? String
        let links = dictionnary["links"] as? Document.JsonObject
        let status = dictionnary["status"] as? String
        let code = dictionnary["code"] as? String
        let title = dictionnary["title"] as? String
        let detail = dictionnary["detail"] as? String
        let source = dictionnary["source"] as? Document.JsonObject
        let meta = dictionnary["meta"] as? Document.JsonObject
        
        let errorObject = Document.ErrorObject(
            id: id,
            links: links != nil ? Document.LinksObject(json: links!) : nil,
            status: status,
            code: code,
            title: title,
            detail: detail,
            source: Document.ErrorObject.Source(
                pointer: source?["pointer"] as? String,
                parameter: source?["parameter"] as? String
            ),
            meta: meta
        )
        
        XCTAssertEqual(errorObject.toJson() as NSDictionary, dictionnary)
    }
}
