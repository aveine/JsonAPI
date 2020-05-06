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
