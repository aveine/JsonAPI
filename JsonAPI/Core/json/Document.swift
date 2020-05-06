/**
 Represent a JSON API document
 */
public struct Document {
    public typealias JsonObject = [String: Any?]
    public typealias RelationshipObjects = [String: RelationshipObject]
    public typealias Meta = JsonObject
    
    /**
     Represent the forms that the document primary data can take
     Resource and Resource Identifier are quite the same and can been see as inheritance, so we handle only the most flexible case
     */
    public enum PrimaryData {
        /**
         Single data resource
         
         - Parameter resource: Single data resource
         */
        case single(resource: ResourceObject)
        
        /**
         Multiple data resources
         
         - Parameter resources: Multiple data resources
         */
        case collection(resources: [ResourceObject])
    }
    
    /**
     Primary data
     */
    public let data: PrimaryData?
    
    /**
     Errors
     */
    public let errors: [ErrorObject]?
    
    /**
     Non-standard meta-information
     */
    public let meta: Meta?
    
    /**
     Describe the server’s implementation
     */
    public let jsonapi: JsonApiObject?
    
    /**
     Links related to the primary data
     */
    public let links: LinksObject?
    
    /**
     Resource object that are related to the primary data and/or each other
     */
    public let included: [ResourceObject]?
    
    /**
     Constructor
     
     - Parameter json: JSON object from which to build the JSON API document
     - Throws:
     - `DocumentError.emptyDocument`:  If neither data or errors or meta are set
     - `DocumentError.includedWithoutData`: If included is set without data
     - `DocumentError.dataAndError`:  If data and errors are set
     - `DocumentError.missingKey`:  If `type` attribute is missing in resource(s)
     - `DocumentError.emptyRelationshipObject`: If neither links or data or meta are set in resource(s) relationship(s)
     - `DocumentError.missingKey`:  If `id` and/or `type` attribute are missing in resource(s) relationship(s) indentifier(s)
     */
    public init(json: JsonObject) throws {
        if let data = json["data"] as? JsonObject {
            let resource = try ResourceObject(json: data)
            self.data = PrimaryData.single(resource: resource)
        } else if let data = json["data"] as? [JsonObject] {
            let resources = try data.map {try ResourceObject(json: $0)}
            self.data = PrimaryData.collection(resources: resources)
        } else {
            self.data = nil
        }
        
        if let errors = json["errors"] as? [JsonObject] {
            self.errors = errors.map { ErrorObject(json: $0) }
        } else {
            self.errors = nil
        }
        
        self.meta = json["meta"] as? Meta
        
        if let jsonapi = json["jsonapi"] as? JsonObject {
            self.jsonapi = JsonApiObject(json: jsonapi)
        } else {
            self.jsonapi = nil
        }
        
        if let links = json["links"] as? JsonObject {
            self.links = LinksObject(json: links)
        } else {
            self.links = nil
        }
        
        if let included = json["included"] as? [JsonObject] {
            self.included = try included.map { try ResourceObject(json: $0) }
        } else {
            self.included = nil
        }
        
        if self.data == nil && self.included != nil {
            throw DocumentError.includedWithoutData
        } else if self.data == nil && self.errors == nil && self.meta == nil {
            throw DocumentError.emptyDocument
        } else if self.data != nil && self.errors != nil {
            throw DocumentError.dataAndError
        }
    }
    
    /**
     Constructor
     
     - Parameter data: Primary data
     - Parameter errors: Errors
     - Parameter meta: Non-standard meta-information
     - Parameter jsonapi: Describe the server’s implementation
     - Parameter links: Links related to the primary data
     - Parameter included: Resource object that are related to the primary data and/or each other
     - Throws:
     - `DocumentError.emptyDocument`:  If neither data or errors or meta are set
     - `DocumentError.includedWithoutData`: If included is set without data
     - `DocumentError.dataAndError`:  If data and errors are set
     */
    public init(data: PrimaryData?, errors: [ErrorObject]?, meta: Meta?, jsonapi: JsonApiObject?, links: LinksObject?, included: [ResourceObject]?) throws {
        self.data = data
        self.errors = errors
        self.meta = meta
        self.jsonapi = jsonapi
        self.links = links
        self.included = included
        
        if self.data == nil && self.included != nil {
            throw DocumentError.includedWithoutData
        } else if self.data == nil && self.errors == nil && self.meta == nil {
            throw DocumentError.emptyDocument
        } else if self.data != nil && self.errors != nil {
            throw DocumentError.dataAndError
        }
    }
    
    /**
     Serialize to JSON format
     
     - Returns: JSON representation of the instance
     */
    public func toJson() -> JsonObject {
        var json: JsonObject = [:]
        
        if let data = self.data {
            switch data {
            case .single(let resource):
                json["data"] = resource.toJson()
            case .collection(let resources):
                json["data"] = resources.map { $0.toJson() }
            }
        }
        if let errors = self.errors {
            json["errors"] = errors.map { $0.toJson() }
        }
        if let meta = self.meta {
            json["meta"] = meta
        }
        if let jsonapi = self.jsonapi {
            json["jsonapi"] = jsonapi.toJson()
        }
        if let links = self.links {
            json["links"] = links.toJson()
        }
        if let included = self.included {
            json["included"] = included.map { $0.toJson() }
        }
        
        return json
    }
    
    /**
     Different errors that can be throwed when manipulating `Document` and the sub-objects
     */
    public enum DocumentError: Error, Equatable {
        case emptyDocument
        case includedWithoutData
        case dataAndError
        case missingKey(key: String)
        case emptyRelationshipObject
    }
    
}
