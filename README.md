# JsonAPI

[![platforms](https://img.shields.io/badge/platforms-iOS-333333.svg)](https://travis-ci.org/ReactiveX/RxSwift)
[![JsonAPI CI](https://github.com/aveine/JsonAPI/workflows/JsonAPI%20CI/badge.svg?branch=master)](https://github.com/aveine/JsonAPI/actions)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![pod](https://img.shields.io/cocoapods/v/JsonAPISwift.svg)](https://cocoapods.org/pods/JsonAPISwift)

JsonAPI is a Swift JSON:API standard implementation.<br>
It has been greatly inspired from another library: [Vox](https://github.com/aronbalog/Vox).

This library allows several types of use, from framework style to "raw" JSON:API object manipulation.

- [Requirements](#requirements)
- [Installation](#installation)
    - [Carthage](#carthage)
    - [CocoaPods](#cocoapods)
- [Usage](#usage)
    - [Basic](#basic)
        - [Defining a resource](#defining-a-resource)
        - [Networking](#networking)
            - [Client](#client)
            - [Data source](#data-source)
            - [Router](#router)
            - [Requests](#requests)
                - [Search a resource](#search-a-resource)
                - [Read a resource](#read-a-resource)
                - [Create a resource](#create-a-resource)
                - [Update a resource](#update-a-resource)
                - [Delete a resource](#delete-a-resource)
    - [Advanced](#advanced)
        - [API Documentation](#api-documentation)
        - [Create a request without a data source](#create-a-request-without-a-data-source)
        - [Raw JSON:API object manipulation](#raw-jsonapi-object-manipulation)

## Requirements

* Xcode 11.x
* Swift 5.x

## Installation

JsonAPI doesn't contain any external dependencies.

These are currently the supported installation options:

### [Carthage](https://github.com/Carthage/Carthage)

To integrate JsonAPI into your Xcode project using Carthage, specify it in your `Cartfile`:
```
github "Aveine/JsonAPI" ~> 1.0
```
*For usage and installation instructions, visit their website.*

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

To integrate JsonAPI into your Xcode project using CocoaPods, specify it in your `Podfile`:
```
pod 'JsonAPISwift', '~> 1.0'
```
*For usage and installation instructions, visit their website.*

### [Swift Package Manager](https://swift.org/package-manager/)

To integrate JsonAPI into your Xcode project using Swift Package Manager, specify it in your `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/aveine/JsonAPI.git", .upToNextMajor(from: "1.0.2"))
]
```
*For usage and installation instructions, visit their website.*

## Usage

### Basic

#### Defining a resource

```swift
import JsonAPI

class Article: Resource {

    /*--------------- Attributes ---------------*/
    
    var title: String?
    
    var descriptionText: String?

    var keywords: [String]?
    
    var viewsCount: Int?
    
    var isFeatured: Bool?
    
    var customObject: [String: Any]?

    /*----------- Nested Attributes ------------*/

    struct Tag: ResourceNestedAttribute {
        var name: String?

        var meta: [String: Any]?

        /*---------- Custom mechanics ----------*/

        /**
	 Override the keys expected in the JSON API resource object's attributes to match the nested object's attributes
	 Format => [resourceObjectAttributeKey: nestedObjectKey]
         */
         override class var nestedAttributesKeys: [String : String] {
            return [
                "tagName": "name"
            ]
        }

        /**
         Attributes that won't be serialized when serializing to a JSON API resource object
         */
        override class var nestedExcludedAttributes: [String] {
            return [
                "meta"
            ]
        }
    }

    var mainTag: Tag?
    var tags: [Tag]?
    
    /*------------- Relationships -------------*/
        
    var authors: [Person]?

    var editor: Person?

    /*------------- Resource type -------------*/

    // resource type should be defined, otherwise it is the class name
    override class var resourceType: String {
        return "articles"
    }

    /*------------- Custom mechanics -------------*/

    /**
     Override the keys expected in the JSON API resource object's attributes to match the model's attributes
     Format => [resourceObjectAttributeKey: modelKey]
     */
    override class var resourceAttributesKeys: [String : String] {
        return [
            "description": "descriptionText"
        ]
    }

    /**
     Attributes that won't be serialized when serializing to a JSON API resource object
     */
    override class var resourceExcludedAttributes: [String] {
        return [
            "customObject"
        ]
    }
}
```

#### Networking

##### Client

Create a client that will be used to communicate with your JSON:API server and which inherit from the following protocol `Client`:
```swift
public typealias ClientSuccessBlock = (_ response: HTTPURLResponse?, _ data: Data?) -> Void
public typealias ClientFailureBlock = (_ error: Error?, _ data: Data?) -> Void

/**
 A client using the library
 */
public protocol Client: class {
    /**
     - Parameter path: Path on which the client must execute the request
     - Parameter method: HTTP method the client must use to execute the request
     - Parameter queryItems: Potential query items the client must send along with the request
     - Parameter body: Potential body the client must send along with the request
     - Parameter success: Success block that will be called if the request successed
     - Parameter failure: Failure block that will be called if the request failed
     - Parameter userInfo: Potential meta information that the user can provide to the client
     */
    func executeRequest(path: String, method: HttpMethod, queryItems: [URLQueryItem]?, body: Document.JsonObject?, success: @escaping ClientSuccessBlock, failure: @escaping ClientFailureBlock, userInfo: [String: Any]?)
}
```
Within the `executeRequest` method use any networking library that you want.

For example with Alamofire you can create a client like this:
```swift
import JsonAPI
import Alamofire

public class AlamofireClient: Client {
    let baseUrl: URL
    
    public init() {
        self.baseUrl = URL(string: "https://api.com")!
    }
    
    func getHeaders() -> HTTPHeaders {
        return [
            "Content-Type": "application/vnd.api+json",
            "Accept": "application/vnd.api+json"
        ]
    }
    
    public func executeRequest(path: String, method: HttpMethod, queryItems: [URLQueryItem]?, body: Document.JsonObject?, success: @escaping ClientSuccessBlock, failure: @escaping ClientFailureBlock, userInfo: [String: Any]?) {
        var urlComponents = URLComponents.init(url: self.baseUrl.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = queryItems
        
        let url = try! urlComponents.asURL()
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        self.getHeaders().forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        if let body = body {
            request.httpBody = try! JSONSerialization.data(withJSONObject: body)
        }
        
        SessionManager.default
            .request(request)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/vnd.api+json"])
            .responseData { (dataResponse) in
                let response = dataResponse.response
                let data = dataResponse.data
                let error = dataResponse.error
                
                dataResponse
                    .result
                    .ifSuccess { success(response, data) }
                    .ifFailure { failure(error, data) }
        }
    }
}

```

##### Data source

The most common way to interact with your resource is to define a data source:
```swift
import JsonAPI

let client = AlamofireClient()

let dataSourceRouter = DataSource<Article>(client: client, strategy: .router(ScrudRouter()))
let dataSourcePath = DataSource<Article>(client: client, strategy: .path("/<type>/<id>"))
```
A data source need to have a `strategy` specified to know how to interact with your resource. The strategy can either be a router or a path.

For the strategy `path`, `<id>` and `<type>` annotations can be used. If possible, they'll get replaced with adequate values.

##### Router

Routers allow you to define the paths to interacts with the resources.

For example, this is the implementation of the `ScrudRouter` within the library:
```swift
/**
 Router for classical SCRUD paths architecture
 
 - Search: resourceType
 - Create: resourceType
 - Read: resourceType/id
 - Update: resourceType/id
 - Delete: resourceType/id
 */
public class ScrudRouter: Router {
    public init() {}
    
    public func search(type: String) -> String {
        return type
    }
    
    public func create(resource: Resource) -> String {
        return resource.type
    }
    
    public func read(type: String, id: String) -> String {
        return "\(type)/\(id)"
    }

    public func update(resource: Resource) -> String {
        return "\(resource.type)/\(resource.id ?? "")"
    }

    public func delete(type: String, id: String) -> String {
        return "\(type)/\(id)"
    }
    
    public func delete(resource: Resource) -> String {
        return "\(resource.type)/\(resource.id ?? "")"
    }
}
```

##### Requests
###### Search a resource

```swift
import JsonAPI

let client = AlamofireClient()
let dataSource = DataSource<Article>(client: client, strategy: .router(ScrudRouter()))

dataSource
    .search()
    .result({ (articles: [Article], document: Document) in
    }, { (error: Error?, document: Document?) in
    })
```

###### Read a resource

```swift
import JsonAPI

let client = AlamofireClient()
let dataSource = DataSource<Article>(client: client, strategy: .router(ScrudRouter()))

dataSource
    .read(id: "1")
    .result({ (article: Article?, document: Document?) in
    }, { (error: Error?, document: Document?) in
    })
```

###### Create a resource

```swift
import JsonAPI

let client = AlamofireClient()
let dataSource = DataSource<Article>(client: client, strategy: .router(ScrudRouter()))

let article = Article()
    article.id = "1"
    article.title = "Title"

dataSource
    .create(article)
    .result({ (article: Article?, document: Document?) in
    }, { (error: Error?, document: Document?) in
    })
```

###### Update a resource

```swift
import JsonAPI

let client = AlamofireClient()
let dataSource = DataSource<Article>(client: client, strategy: .router(ScrudRouter()))

let article = Article()
    article.id = "1"
    article.title = "Another Title"

dataSource
    .update(article)
    .result({ (article: Article?, document: Document?) in
    }, { (error: Error?, document: Document?) in
    })
```

###### Delete a resource

```swift
import JsonAPI

let client = AlamofireClient()
let dataSource = DataSource<Article>(client: client, strategy: .router(ScrudRouter()))

let article = Article()
    article.id = "1"

dataSource
    .delete(article)
    .result({ (article: Article?, document: Document?) in
    }, { (error: Error?, document: Document?) in
    })
```

Or if you don't have previously fetched the resource:
```swift
import JsonAPI

let client = AlamofireClient()
let dataSource = DataSource<Article>(client: client, strategy: .router(ScrudRouter()))

dataSource
    .delete(id: "1")
    .result({ (article: Article?, document: Document?) in
    }, { (error: Error?, document: Document?) in
    })
```

##### Extensions
###### Implementing pagination and filtering helpers

Since Pagination and Filtering can vary by server implementation, here is an example of how the library can be extended to support them.

```swift
extension ResourceCollectionRequest {
  /**
   Append the given filters to the request's query items

   - Parameter filters: Filters to append
   - Returns: The request with the filters query appended
   */
  public func filters( _ filters: [ String: [ String ] ] ) -> Self {
    var queryItems: [ URLQueryItem ] = []
    for filter in filters {
      queryItems.append( URLQueryItem( name: "filter[\(filter.key)]", value: filter.value.joined( separator: "," ) ) )
    }
    return self.queryItems( queryItems )
  }

  /**
   Append the given filters to the request's query items

   - Parameter key: Key of filter to append
   - Parameter value: Value(s) of filter to append
   - Returns: The request with the filters query appended
   */
  public func filter( _ key: String, _ value: String...) -> Self {
    return self.filters( [ key: value ] )
  }

  /**
   Append the given paging parameters to the request's query items

   - Parameter size: Maximum number of items to return
   - Parameter number: Page number to return
   - Returns: The request with the page query appended
   */
  public func page( _ size: Int, number: Int? = nil ) -> Self {
    var queryItems: [ URLQueryItem ] = [
      URLQueryItem( name: "page[size]", value: String( size ) )
    ]
    if let number = number {
      queryItems.append( URLQueryItem( name: "page[number]", value: String( number ) ) )
    }
    return self.queryItems( queryItems )
  }
}
```

### Advanced

**!! Section in progress !!**

#### API Documentation

A complete API documentation can be found [here](https://aveine.github.io/JsonAPI/).

#### Create a request without a data source

```swift
import JsonAPI

let client = AlamofireClient()
let resourceRequest = ResourceRequest<Article>(path: "/articles/1", method: HttpMethod.get, client: client, resource: nil)
let resourceCollectionRequest = ResourceCollectionRequest<Article>(path: "/articles", method: HttpMethod.get, client: client, resource: nil)

resourceRequest
    .result({ (article: Article?, document: Document?) in
    }, { (error: Error?, document: Document?) in
    })

resourceCollectionRequest
    .result({ (articles: [Article], document: Document) in
    }, { (error: Error?, document: Document?) in
    })
```

#### Raw JSON:API object manipulation

Coming soon
