extension Document {
    /**
     Describe the server’s implementation
     */
    public struct JsonApiObject {
        /**
         Indicate the highest JSON API version supported
         */
        public let version: String?
        
        /**
         Non-standard meta-information
         */
        public let meta: Meta?
        
        /**
         Constructor
         
         - Parameter json: JSON object from which to build the JSON API object
         */
        public init(json: JsonObject) {
            self.version = json["version"] as? String
            
            self.meta = json["meta"] as? Meta
        }
        
        /**
         Constructor
         
         - Parameter version: Indicate the highest JSON API version supported
         - Parameter meta: Non-standard meta-information
         */
        public init(version: String?, meta: Meta?) {
            self.version = version
            self.meta = meta
        }
        
        /**
         Serialize to JSON format
         
         - Returns: JSON representation of the instance
         */
        public func toJson() -> JsonObject {
            var json: JsonObject = [:]
            
            if let version = self.version {
                json["version"] = version
            }
            if let meta = self.meta {
                json["meta"] = meta
            }
            
            return json
        }
    }
}
