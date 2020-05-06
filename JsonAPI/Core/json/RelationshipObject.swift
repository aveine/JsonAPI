extension Document {
    /**
     Identifies a relationship
     */
    public struct RelationshipObject {
        /**
         Allows a client to link together all of the included resource objects
         */
        public enum ResourceLinkage {
            /**
             To-one relationship
             
             - Parameter identifier: Identifier for the to-one relationship
             */
            case single(identifier: ResourceIdentifierObject?)
            
            /**
             To-many relationships
             
             - Parameter identifiers: Collection of identifiers for the to-many relationships
             */
            case collection(identifiers: [ResourceIdentifierObject])
        }
        
        /**
         A links object containing the following members:
         self: a link for the relationship itself (a “relationship link”)
         related: a related resource link
         */
        public let links: LinksObject?
        
        /**
         Allows a client to link together all of the included resource objects
         */
        public let data: ResourceLinkage?
        
        /**
         Non-standard meta-information about the relationship
         */
        public let meta: Meta?
        
        /**
         Constructor
         
         - Parameter json: JSON object from which to build the relationships
         - Throws:
         - `DocumentError.emptyRelationshipObject`: If neither links or data or meta are set
         - `DocumentError.missingKey`:  If `id` and/or `type` attribute are missing in indentifier(s)
         */
        public init(json: JsonObject) throws {
            if let links = json["links"] as? JsonObject {
                self.links = LinksObject(json: links)
            } else {
                self.links = nil
            }
            
            if let data = json["data"] as? JsonObject {
                let identifier = try ResourceIdentifierObject(json: data)
                self.data = ResourceLinkage.single(identifier: identifier)
            } else if let data = json["data"] as? [JsonObject] {
                let identifiers = try data.map {try ResourceIdentifierObject(json: $0)}
                self.data = ResourceLinkage.collection(identifiers: identifiers)
            } else if let data = json["data"], data == nil {
                self.data = ResourceLinkage.single(identifier: nil)
            } else {
                self.data = nil
            }
            
            self.meta = json["meta"] as? Meta
            
            if self.links == nil && self.data == nil && self.meta == nil {
                throw DocumentError.emptyRelationshipObject
            }
        }
        
        /**
         Constructor
         
         - Parameter links: A links object containing the following members:
         - self: a link for the relationship itself (a “relationship link”)
         - related: a related resource link
         - Parameter data: Allows a client to link together all of the included resource objects
         - Parameter meta: Non-standard meta-information about the relationship
         - Throws: `DocumentError.emptyRelationshipObject` if neither links or data or meta are set
         */
        public init(links: LinksObject?, data: ResourceLinkage?, meta: Meta?) throws {
            self.links = links
            self.data = data
            self.meta = meta
            
            if self.links == nil && self.data == nil && self.meta == nil {
                throw DocumentError.emptyRelationshipObject
            }
        }
        
        /**
         Serialize to JSON format
         
         - Returns: The  JSON representation of the instance
         */
        public func toJson() -> JsonObject {
            var json: JsonObject = [:]
            
            if let links = self.links {
                json["links"] = links.toJson()
            }
            if let data = self.data {
                switch data {
                case .single(let identifier):
                    if let identifier = identifier {
                        json["data"] = identifier.toJson()
                    } else {
                        json.updateValue(nil, forKey: "data")
                    }
                case .collection(let identifiers):
                    json["data"] = identifiers.map { $0.toJson() }
                }
            }
            if let meta = self.meta {
                json["meta"] = meta
            }
            
            return json
        }
    }
}
