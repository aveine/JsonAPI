extension Document {
    /**
     Identifies an individual resource
     */
    public struct ResourceIdentifierObject: Equatable {
        /**
         Resource's id
         */
        public let id: String
        
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
         - Throws: `DocumentError.missingKey` if `id` and/or `type` attribute are missing
         */
        public init(json: JsonObject) throws {
            if let id = json["id"] as? String {
                self.id = id
            } else {
                throw DocumentError.missingKey(key: "id")
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
         - Parameter type: Resource's type
         - Parameter meta: Non-standard meta-information about the resource
         */
        public init(id: String, type: String, meta: Meta?) {
            self.id = id
            self.type = type
            self.meta = meta
        }
        
        /**
         Serialize to JSON format
         
         - Returns: The  JSON representation of the instance
         */
        public func toJson() -> JsonObject {
            var json: JsonObject = [:]
            
            json["id"] = self.id
            json["type"] = self.type
            if let meta = self.meta {
                json["meta"] = meta
            }
            
            return json
        }
        
        /**
         Equality is based on `id` and `type`
         */
        public static func == (lhs: Document.ResourceIdentifierObject, rhs: Document.ResourceIdentifierObject) -> Bool {
            return lhs.id == rhs.id && lhs.type == rhs.type
        }
    }
}
