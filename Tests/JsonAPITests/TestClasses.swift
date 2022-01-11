import JsonAPI

class AResource: Resource {}

class ComplexResource: Resource {
    var optionalString: String?
    
    var optionalNumber: Double?    

    var optionalBool: Bool?
    
    var optionalArray: [Any]?
    
    var optionalObject: [String: Any]?
    
    var optionalRelationship: AResource?
    
    var optionalRelationships: [AResource]?
    
    var string: String = "string"
    
    var number: Int = 42
    
    var bool: Bool = true
    
    var array: [Any] = [
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
    ]
    
    var object: [String: Any] = [
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
    
    var relationship: AResource = {
        let resource = AResource()
        resource.id = "1" // Without id, no serialization
        return resource
    }()
    
    var relationships: [AResource] = {
        let resource = AResource()
        resource.id = "1" // Without id, no serialization
        return [resource]
    }()
}

class ExcludedResource: Resource {
    var title: String?
    
    var body: String?
    
    override class var resourceExcludedAttributes: [String] {
        return [
            "body"
        ]
    }
}

class Article : Resource {
    var title: String?
    
    var body: String?
    
    var author: Person?
    
    var coAuthors: [Person]?
    
    override class var resourceAttributesKeys: [String : String] {
        return [
            "coauthors": "coAuthors"
        ]
    }
    
    override class var resourceType: String {
        "articles"
    }
}

class Person: Resource {
    var name: String?
    
    var favoriteArticle: Article?
    
    override class var resourceType: String {
        "persons"
    }
}

class Contact: Person {

  var email: String?

  override class var resourceType: String {
    "contacts"
  }
}

class ContactList: Resource {
  var name: String?

  var contacts: [Contact]?

  override class var resourceType: String {
    "contactlists"
  }
}
