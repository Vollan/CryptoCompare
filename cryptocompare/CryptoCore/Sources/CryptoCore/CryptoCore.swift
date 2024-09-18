
import Foundation

public protocol Endpoint {
    var baseURL: String { get }
    var queryParams: [String: String] { get }
    var path: String { get }
    var method: RequestMethod { get }
    var hasQueryParameters: Bool { get }
}

public enum RequestMethod: String, CaseIterable {
    case delete = "DELETE"
    case get = "GET"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
}

extension Endpoint {
    
    public var baseURL: String {
        "https://api.coingecko.com/api/v3"
    }
    
    func build() -> URLRequest? {
        // Construct the base URL with the path
        guard var urlComponents = URLComponents(string: baseURL) else {
            return nil
        }
        urlComponents.path = urlComponents.path + path
        
        // Add query parameters if there are any
        if hasQueryParameters {
            urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        // Ensure we have a valid URL
        guard let url = urlComponents.url else {
            return nil
        }
        
        // Create URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        return request
    }
}

class CoreDecoder: JSONDecoder {
    override public init() {
        super.init()
        self.dateDecodingStrategy = .formatted(.networkFormatter)
        self.keyDecodingStrategy = .useDefaultKeys
    }

    override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        if let noData = VoidResult() as? T {
            return noData
        }

        return try super.decode(type, from: data)
    }
}

struct VoidResult: Decodable {
    public init() {}
}

@available(macOS 12.0, iOS 15.0, *)
open class HTTPClient {
    
    public init() {}
    
    public func sendRequest<T: Decodable>(endpoint: Endpoint, responseModel: T.Type, session: URLSession) async throws -> Result<T, CryptoCore.RequestError> {
        guard let request = endpoint.build() else {
            return .failure(.invalidURL)
        }
        
        let (data, _) = try await session.data(for: request)
        let decoder = CoreDecoder()
        do {
            let decodedResponse = try decoder.decode(responseModel, from: data)// else {
            return .success(decodedResponse)
        } catch {
            return .failure(.decode)
        }
    }
}

public enum ListEndpoint: Endpoint {
    
    case getMarkets
    case getDetails(market: String)
    
    public var path: String {
        switch self {
        case .getMarkets, .getDetails:
            return "/coins/markets"
        }
    }
    
    public var method: RequestMethod {
        .get
    }
    
    public var queryParams: [String: String] {
        switch self {
        case .getMarkets:
            return [
                "vs_currency": "USD",
                "order": "market_cap_desc",
                "sparkline": "false"
            ]
        case .getDetails(let id):
            return [
                "vs_currency": "USD",
                "ids": id,
                "sparkline": "true"
            ]
        }
    }
    
    public var hasQueryParameters: Bool {
        !queryParams.isEmpty
    }
}

public enum RequestError: Error, Equatable {
    public static func == (lhs: RequestError, rhs: RequestError) -> Bool {
        switch (lhs, rhs) {
        case (.decode, .decode), (.invalidURL, .invalidURL), (.noResponse, .noResponse),
            (.unauthorized, .unauthorized), (.unexpectedStatusCode, .unexpectedStatusCode),
            (.unknown, .unknown), (.invalidRequestModel, .invalidRequestModel):
            return true
        default:
            return false
        }
    }
    
    case decode
    case invalidURL
    case noResponse
    case unauthorized
    case upgradeRequired
    case unexpectedStatusCode
    case unknown
    case invalidRequestModel
    
    var customMessage: String {
        switch self {
        case .decode:
            return "Decode error"
        case .unauthorized:
            return "Session expired"
        default:
            return "Unknown error"
        }
    }
}

extension DateFormatter {
    static let networkFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
    }()
}
