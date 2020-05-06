extension Document {
    /**
     Represent links
     */
    public struct LinksObject {
        /**
         Represent the different forms of a link
         */
        public enum Link {
            /**
             Represent a link with meta-information
             
             - Parameter href: Link's URL
             - Parameter meta: A meta object containing non-standard meta-information about the link
             */
            case linkObject(href: String?, meta: Meta?)
            
            /**
             Represent a link
             
             - Parameter url: Link's URL
             */
            case string(url: String)
        }
        
        /**
         The link that generated the current response document
         */
        public let _self: Link?
        
        /**
         A link that leads to further details about this particular occurrence of the problem
         */
        public let about: Link?
        
        /**
         Provides access to resource objects linked in a relationship
         */
        public let related: Link?
        
        /**
         The first page of data for pagination
         */
        public let first: Link?
        
        /**
         The previous page of data for pagination
         */
        public let prev: Link?
        
        /**
         The next page of data for pagination
         */
        public let next: Link?
        
        /**
         The last page of data for pagination
         */
        public let last: Link?
        
        /**
         Constructor
         
         - Parameter json: JSON from which to build the links object
         */
        public init(json: JsonObject) {
            if let _self = json["self"] as? JsonObject {
                self._self = Link.linkObject(href: _self["href"] as? String, meta: _self["meta"] as? JsonObject)
            } else if let _self = json["self"] as? String {
                self._self = Link.string(url: _self)
            } else {
                self._self = nil
            }
            
            if let about = json["about"] as? JsonObject {
                self.about = Link.linkObject(href: about["href"] as? String, meta: about["meta"] as? JsonObject)
            } else if let about = json["about"] as? String {
                self.about = Link.string(url: about)
            } else {
                self.about = nil
            }
            
            if let related = json["related"] as? JsonObject {
                self.related = Link.linkObject(href: related["href"] as? String, meta: related["meta"] as? JsonObject)
            } else if let related = json["related"] as? String {
                self.related = Link.string(url: related)
            } else {
                self.related = nil
            }
            
            if let first = json["first"] as? JsonObject {
                self.first = Link.linkObject(href: first["href"] as? String, meta: first["meta"] as? JsonObject)
            } else if let first = json["first"] as? String {
                self.first = Link.string(url: first)
            } else {
                self.first = nil
            }
            
            if let last = json["last"] as? JsonObject {
                self.last = Link.linkObject(href: last["href"] as? String, meta: last["meta"] as? JsonObject)
            } else if let last = json["last"] as? String {
                self.last = Link.string(url: last)
            } else {
                self.last = nil
            }
            
            if let prev = json["prev"] as? JsonObject {
                self.prev = Link.linkObject(href: prev["href"] as? String, meta: prev["meta"] as? JsonObject)
            } else if let prev = json["prev"] as? String {
                self.prev = Link.string(url: prev)
            } else {
                self.prev = nil
            }
            
            if let next = json["next"] as? JsonObject {
                self.next = Link.linkObject(href: next["href"] as? String, meta: next["meta"] as? JsonObject)
            } else if let next = json["next"] as? String {
                self.next = Link.string(url: next)
            } else {
                self.next = nil
            }
        }
        
        /**
         Constructor
         
         - Parameter _self: The link that generated the current response document
         - Parameter about: A link that leads to further details about this particular occurrence of the problem
         - Parameter related: Provides access to resource objects linked in a relationship
         - Parameter first: The first page of data for pagination
         - Parameter prev: The previous page of data for pagination
         - Parameter next: The next page of data for pagination
         - Parameter last: The last page of data for pagination
         */
        public init(_self: Link?, about: Link?, related: Link?, first: Link?, prev: Link?, next: Link?, last: Link?) {
            self._self = _self
            self.about = about
            self.related = related
            self.first = first
            self.prev = prev
            self.next = next
            self.last = last
        }
        
        /**
         Serialize to JSON format
         
         - Returns: JSON representation of the instance
         */
        public func toJson() -> JsonObject {
            var json: JsonObject = [:]
            
            if let _self = self._self {
                switch _self {
                case .string(let url):
                    json["self"] = url
                case .linkObject(let href, let meta):
                    var linkObject: JsonObject = [:]
                    if let href = href {
                        linkObject["href"] = href
                    }
                    if let meta = meta {
                        linkObject["meta"] = meta
                    }
                    json["self"] = linkObject
                }
            }
            
            if let about = self.about {
                switch about {
                case .string(let url):
                    json["about"] = url
                case .linkObject(let href, let meta):
                    var linkObject: JsonObject = [:]
                    if let href = href {
                        linkObject["href"] = href
                    }
                    if let meta = meta {
                        linkObject["meta"] = meta
                    }
                    json["about"] = linkObject
                }
            }
            
            if let related = self.related {
                switch related {
                case .string(let url):
                    json["related"] = url
                case .linkObject(let href, let meta):
                    var linkObject: JsonObject = [:]
                    if let href = href {
                        linkObject["href"] = href
                    }
                    if let meta = meta {
                        linkObject["meta"] = meta
                    }
                    json["related"] = linkObject
                }
            }
            
            if let first = self.first {
                switch first {
                case .string(let url):
                    json["first"] = url
                case .linkObject(let href, let meta):
                    var linkObject: JsonObject = [:]
                    if let href = href {
                        linkObject["href"] = href
                    }
                    if let meta = meta {
                        linkObject["meta"] = meta
                    }
                    json["first"] = linkObject
                }
            }
            
            if let prev = self.prev {
                switch prev {
                case .string(let url):
                    json["prev"] = url
                case .linkObject(let href, let meta):
                    var linkObject: JsonObject = [:]
                    if let href = href {
                        linkObject["href"] = href
                    }
                    if let meta = meta {
                        linkObject["meta"] = meta
                    }
                    json["prev"] = linkObject
                }
            }
            
            if let next = self.next {
                switch next {
                case .string(let url):
                    json["next"] = url
                case .linkObject(let href, let meta):
                    var linkObject: JsonObject = [:]
                    if let href = href {
                        linkObject["href"] = href
                    }
                    if let meta = meta {
                        linkObject["meta"] = meta
                    }
                    json["next"] = linkObject
                }
            }
            
            if let last = self.last {
                switch last {
                case .string(let url):
                    json["last"] = url
                case .linkObject(let href, let meta):
                    var linkObject: JsonObject = [:]
                    if let href = href {
                        linkObject["href"] = href
                    }
                    if let meta = meta {
                        linkObject["meta"] = meta
                    }
                    json["last"] = linkObject
                }
            }
            
            return json
        }
    }
}
