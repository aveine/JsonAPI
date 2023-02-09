import Foundation

/**
 A client using the library
 */
public protocol Client: AnyObject {
    /**
     Execute the request with the given parameters

     - Parameter path: Path on which the client must execute the request
     - Parameter method: HTTP method the client must use to execute the request
     - Parameter queryItems: Potential query items the client must send along with the request
     - Parameter body: Potential body the client must send along with the request
     - Parameter userInfo: Potential meta information that the user can provide to the client
     - Returns The response of the executed request
     */
    func executeRequest(path: String, method: HttpMethod, queryItems: [URLQueryItem]?, body: Document.JsonObject?, userInfo: [String: Any]?) async throws -> ClientSuccessResponse
}

/**
 Represent a client success response
 */
public struct ClientSuccessResponse {
    /**
     HTTP metadata associated with the response
     */
    public let response: HTTPURLResponse?

    /**
     Raw data present in the response from the HTTP request
     */
    public let data: Data?

    /**
     Constructor

     - Parameter response: The HTTP metadata associated with the response
     - Parameter data: The raw data present in the response from the HTTP request
     */
    public init(_ response: HTTPURLResponse?, _ data: Data?) {
        self.response = response
        self.data = data
    }
}

/**
 Different errors that can be returned by a client
 */
public enum ClientError: Error {
    /**
     Allow to correlate an error with raw response data from the HTTP request

     - Parameter error The error generating the failure
     - Parameter data The raw response data from the HTTP request related to the error
     */
    case failure(_ error: Error?, _ data: Data?)
}
