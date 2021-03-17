extension Document {
    /**
     Provide additional information about problems encountered while performing an operation
     */
    public struct ErrorObject : Error {
        /**
         An object containing references to the source of the error
         */
        public struct Source {
            /**
             A JSON Pointer [RFC6901](https://tools.ietf.org/html/rfc6901) to the associated entity in the request document
             */
            public let pointer: String?
            
            /**
             Indicate which URI query parameter caused the error
             */
            public let parameter: String?
            
            /**
             Constructor
             
             - Parameter json: JSON object from which to build the source
             */
            public init(_ json: JsonObject) {
                self.pointer = json["pointer"] as? String
                
                self.parameter = json["parameter"] as? String
            }
            
            /**
             Constructor
             
             - Parameter pointer: A JSON Pointer [RFC6901](https://tools.ietf.org/html/rfc6901) to the associated entity in the request document
             - Parameter parameter: Indicate which URI query parameter caused the error
             */
            public init(pointer: String?, parameter: String?) {
                self.pointer = pointer
                self.parameter = parameter
            }
        }
        
        /**
         A unique identifier for this particular occurrence of the problem
         */
        public let id: String?
        
        /**
         A links object containing the following members:
         - about: a link that leads to further details about this particular occurrence of the problem
         */
        public let links: LinksObject?
        
        /**
         The HTTP status code applicable to this problem
         */
        public let status: String?
        
        /**
         An application-specific error code
         */
        public let code: String?
        
        /**
         A short, human-readable summary of the problem that **SHOULD NOT** change from occurrence to occurrence of the problem, except for purposes of localization
         */
        public let title: String?
        
        /**
         A human-readable explanation specific to this occurrence of the problem. Like *title*, this field’s value can be localized
         */
        public let detail: String?
        
        /**
         An object containing references to the source of the error
         */
        public let source: Source?
        
        /**
         Non-standard meta-information about the error
         */
        public let meta: Meta?
        
        /**
         Constructor
         
         - Parameter json: JSON object from which to build the error
         */
        public init(json: JsonObject) {
            self.id = json["id"] as? String
            
            if let links = json["links"] as? JsonObject {
                self.links = LinksObject(json: links)
            } else {
                self.links = nil
            }
            
            self.status = json["status"] as? String
            
            self.code = json["code"] as? String
            
            self.title = json["title"] as? String
            
            self.detail = json["detail"] as? String
            
            if let source = json["source"] as? JsonObject {
                self.source = Source(source)
            } else {
                self.source = nil
            }
            
            self.meta = json["meta"] as? Meta
        }
        
        /**
         Constructor
         
         - Parameter id: A unique identifier for this particular occurrence of the problem
         - Parameter links: A links object containing the following members:
         - about: a link that leads to further details about this particular occurrence of the problem
         - Parameter status: The HTTP status code applicable to this problem
         - Parameter code: An application-specific error code
         - Parameter title: A short, human-readable summary of the problem that **SHOULD NOT** change from occurrence to occurrence of the problem, except for purposes of localization
         - Parameter detail: A human-readable explanation specific to this occurrence of the problem. Like *title*, this field’s value can be localized
         - Parameter source: An object containing references to the source of the error
         - Parameter meta: Non-standard meta-information about the error
         */
        public init(id: String?, links: LinksObject?, status: String?, code: String?, title: String?, detail: String?, source: Source?, meta: Meta?) {
            self.id = id
            self.links = links
            self.status = status
            self.code = code
            self.title = title
            self.detail = detail
            self.source = source
            self.meta = meta
        }
        
        /**
         Serialize to JSON format
         
         - Returns: JSON representation of the instance
         */
        public func toJson() -> JsonObject {
            var json: JsonObject = [:]
            
            if let id = self.id {
                json["id"] = id
            }
            if let links = self.links {
                json["links"] = links.toJson()
            }
            if let status = self.status {
                json["status"] = status
            }
            if let code = self.code {
                json["code"] = code
            }
            if let title = self.title {
                json["title"] = title
            }
            if let detail = self.detail {
                json["detail"] = detail
            }
            if let source = self.source {
                var sourceJson: JsonObject = [:]
                if let pointer = source.pointer {
                    sourceJson["pointer"] = pointer
                }
                if let parameter = source.parameter {
                    sourceJson["parameter"] = parameter
                }
                json["source"] = sourceJson
            }
            if let meta = self.meta {
                json["meta"] = meta
            }
            
            return json
        }
    }
}
