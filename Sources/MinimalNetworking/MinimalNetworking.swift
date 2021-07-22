// I usually like to split code into one file per type, but this library is _minimal_, right?
// So let's keep it all in the same one and keep it short.
import Combine
import Foundation

/// A networking abstraction based on Combine. Use it instead of referencing `URLSession` directly
/// to implement dependency _inversion_ and make testing easier.
public protocol NetworkFetching {

    func load(_ request: URLRequest) -> AnyPublisher<Data, URLError>
}

public struct Endpoint<Resource: Decodable> {

    public let path: String
    public let resourceType: Resource.Type

    public init(path: String, resourceType: Resource.Type) {
        self.path = path
        self.resourceType = resourceType
    }

    public func urlRequest(with baseURL: URL) -> URLRequest {
        URLRequest(url: baseURL.appendingPathComponent(path))
    }
}

// MARK: `NetworkFetching` + `Endpoint` = Networking with little implementation overhead

public extension NetworkFetching {

    func load<Resource>(
        _ endpoint: Endpoint<Resource>,
        from baseURL: URL
    ) -> AnyPublisher<Resource, Error> {
        return load(endpoint.urlRequest(with: baseURL))
            .decode(type: endpoint.resourceType, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

// MARK: `URLSession` `NetworkingFetching` implementation

extension URLSession: NetworkFetching {

    public func load(_ request: URLRequest) -> AnyPublisher<Data, URLError> {
        return dataTaskPublisher(for: request)
            .map { $0.data }
            .eraseToAnyPublisher()
    }
}
