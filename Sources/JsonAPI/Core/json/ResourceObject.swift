import Foundation

extension Document {
    /**
     Represent a resource
     */
    public struct ResourceObject: Equatable {
        /**
         Resource's id
         */
        public let id: String?
        
        /**
         Resource's local id
         */
        public let lid: String?

        /**
         Resource's type
         */
        public let type: String
        
        /**
         Resource’s data
         */
        public let attributes: JsonObject?
        
        /**
         Relationships between the resource and other resources
         */
        public let relationships: RelationshipObjects?
        
        /**
         Links related to the resource
         */
        public let links: LinksObject?
        
        /**
         Non-standard meta-information about the resource that can not be represented as an attribute or relationship
         */
        public let meta: Meta?
        
        /**
         Constructor
         
         - Parameter json: JSON object from which to build the resource
         - Throws:
         - `DocumentError.missingKey`:  If `type` attribute is missing
         - `DocumentError.emptyRelationshipObject`: If neither links or data or meta are set in relationship(s)
         - `DocumentError.missingKey`:  If `id` and/or `type` attribute are missing in relationship(s) indentifier(s)
         */
        public init(json: JsonObject) throws {
            self.id = json["id"] as? String
            self.lid = json["lid"] as? String
            
            if let type = json["type"] as? String {
                self.type = type
            } else {
                throw DocumentError.missingKey(key: "type")
            }
            
            self.attributes = json["attributes"] as? JsonObject
            
            if let relationships = json["relationships"] as? [String: JsonObject] {
                self.relationships = RelationshipObjects(uniqueKeysWithValues: try relationships.map { try ($0.key, RelationshipObject(json: $0.value)) })
            } else {
                self.relationships = nil
            }
            
            if let links = json["links"] as? JsonObject {
                self.links = LinksObject(json: links)
            } else {
                self.links = nil
            }
            
            self.meta = json["meta"] as? Meta
        }
        
        /**
         Constructor
         
         - Parameter id: Resource's id
         - Parameter lid: Resource's local id
         - Parameter type: Resource's type
         - Parameter attributes: Resource’s data
         - Parameter relationships: Relationships between the resource and other resources
         - Parameter links: Links related to the resource
         - Parameter meta: Non-standard meta-information about the resource that can not be represented as an attribute or relationship
         */
        public init(id: String?, lid: String?, type: String, attributes: JsonObject?, relationships: RelationshipObjects?, links: LinksObject?, meta: Meta?) {
            self.id = id
            self.lid = lid
            self.type = type
            self.attributes = attributes
            self.relationships = relationships
            self.links = links
            self.meta = meta
        }
        
        /**
         Serialize to JSON format
         
         - Returns: The  JSON representation of the instance
         */
        public func toJson() -> JsonObject {
            var json: JsonObject = [:]
            
            if let id = self.id {
                json["id"] = id
            } else if let lid = self.lid {
                json["lid"] = lid
            }
            json["type"] = type
            if let attributes = self.attributes {
                json["attributes"] = attributes
            }
            if let relationships = self.relationships {
                json["relationships"] = Dictionary(uniqueKeysWithValues: relationships.map { ($0.key, $0.value.toJson()) })
            }
            if let links = self.links {
                json["links"] = links.toJson()
            }
            if let meta = self.meta {
                json["meta"] = meta
            }
            
            return json
        }
        
        /**
         Equality is based on `id`,  `lid`, `type`, `attributes` and `relationships`
         */
        public static func == (lhs: Document.ResourceObject, rhs: Document.ResourceObject) -> Bool {
            let idEquals: Bool = {
                return lhs.id == rhs.id
            }()
            
            let lidEquals: Bool = {
                return lhs.lid == rhs.lid
            }()

            let typeEquals: Bool = {
                return lhs.type == rhs.type
            }()

            let attributesEquals: Bool = {
                let lhsAttributes = lhs.attributes ?? [:]
                let rhsAttributes = rhs.attributes ?? [:]
                
                return NSDictionary(dictionary: lhsAttributes as [AnyHashable : Any]) == NSDictionary(dictionary: rhsAttributes as [AnyHashable : Any])
            }()
            
            let relationshipsEquals: Bool = {
                return lhs.relationships == rhs.relationships
            }()
            
            return idEquals && lidEquals && typeEquals && attributesEquals && relationshipsEquals
        }
    }
}
