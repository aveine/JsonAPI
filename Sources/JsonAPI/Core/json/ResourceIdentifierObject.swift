extension Document {
    /**
     Identifies an individual resource
     */
    public struct ResourceIdentifierObject: Equatable {
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
         Non-standard meta-information about the resource
         */
        public let meta: Meta?
        
        /**
         Constructor
         
         - Parameter json: JSON object from which to build the resource identifier object
         - Throws: `DocumentError.missingKey` if `id` or `lid`,  and/or `type` attributes are missing
         */
        public init(json: JsonObject) throws {
            self.id = json["id"] as? String
            self.lid = json["lid"] as? String

            if self.id == nil && self.lid == nil {
                throw DocumentError.missingKey(key: "id or lid")
            }
            
            if let type = json["type"] as? String {
                self.type = type
            } else {
                throw DocumentError.missingKey(key: "type")
            }
            
            self.meta = json["meta"] as? Meta
        }
        
        /**
         Constructor
         
         - Parameter id: Resource's id
         - Parameter lid: Resource's local id
         - Parameter type: Resource's type
         - Parameter meta: Non-standard meta-information about the resource
         - Throws: `DocumentError.missingKey` if `id` or `lid`,  and/or `type` attributes are missing
         */
        public init(id: String?, lid: String?, type: String, meta: Meta?) throws {
            self.id = id
            self.lid = lid
            if self.id == nil && self.lid == nil {
                throw DocumentError.missingKey(key: "id or lid")
            }

            self.type = type
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
            json["type"] = self.type
            if let meta = self.meta {
                json["meta"] = meta
            }
            
            return json
        }
        
        /**
         Equality is based on `id`, `lid` and `type`
         */
        public static func == (lhs: Document.ResourceIdentifierObject, rhs: Document.ResourceIdentifierObject) -> Bool {
            let idEquals: Bool = {
                return lhs.id == rhs.id
            }()

            let lidEquals: Bool = {
                return lhs.lid == rhs.lid
            }()

            let typeEquals: Bool = {
                return lhs.type == rhs.type
            }()

            return idEquals && lidEquals && typeEquals
        }
    }
}
