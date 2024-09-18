import XCTest
@testable import CryptoCore

final class ListEndpointTests: XCTestCase {
    
    func testGetMarketsEndpoint() {
        let endpoint = ListEndpoint.getMarkets(currency: "usd")
        let request = endpoint.build()
        
        XCTAssertNotNil(request, "Request should not be nil")
        XCTAssertEqual(request?.httpMethod, "GET")
        
        // Parse URL components to check query parameters
        guard let url = request?.url, let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            XCTFail("Invalid URL or URL Components")
            return
        }
        
        XCTAssertEqual(urlComponents.scheme, "https")
        XCTAssertEqual(urlComponents.host, "api.coingecko.com")
        XCTAssertEqual(urlComponents.path, "/api/v3/coins/markets")
        
        // Create a dictionary from the query items for easier comparison
        let queryItems = urlComponents.queryItems?.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        }
        
        XCTAssertEqual(queryItems?["vs_currency"], "usd")
        XCTAssertEqual(queryItems?["order"], "market_cap_desc")
        XCTAssertEqual(queryItems?["sparkline"], "false")
    }
    
    func testGetDetailsEndpoint() {
        let endpoint = ListEndpoint.getDetails(market: "bitcoin", currency: "usd")
        let request = endpoint.build()
        
        XCTAssertNotNil(request, "Request should not be nil")
        XCTAssertEqual(request?.httpMethod, "GET")
        
        // Parse URL components to check query parameters
        guard let url = request?.url, let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            XCTFail("Invalid URL or URL Components")
            return
        }
        
        XCTAssertEqual(urlComponents.scheme, "https")
        XCTAssertEqual(urlComponents.host, "api.coingecko.com")
        XCTAssertEqual(urlComponents.path, "/api/v3/coins/markets")
        
        // Create a dictionary from the query items for easier comparison
        let queryItems = urlComponents.queryItems?.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        }
        
        XCTAssertEqual(queryItems?["vs_currency"], "usd")
        XCTAssertEqual(queryItems?["ids"], "bitcoin")
        XCTAssertEqual(queryItems?["sparkline"], "true")
    }
}

final class CoreDecoderTests: XCTestCase {
    
    struct MockModel: Decodable, Equatable {
        let name: String
        let price: Double
    }
    
    func testDecodeValidModel() {
        let jsonData = """
        {
            "name": "Bitcoin",
            "price": 40000.0
        }
        """.data(using: .utf8)!
        
        let decoder = CoreDecoder()
        do {
            let result = try decoder.decode(MockModel.self, from: jsonData)
            XCTAssertEqual(result, MockModel(name: "Bitcoin", price: 40000.0))
        } catch {
            XCTFail("Decoding should succeed: \(error)")
        }
    }
    
    func testDecodeVoidResult() {
        let emptyData = Data()
        let decoder = CoreDecoder()
        
        XCTAssertNoThrow(try decoder.decode(VoidResult.self, from: emptyData))
    }
}

class MockURLProtocol: URLProtocol {
    // Static property to hold the mock response that will be returned
    static var mockResponse: (data: Data?, response: URLResponse?, error: Error?)?
    
    // This method determines whether the protocol can handle the request.
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    // This method is required but not used for this mock.
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    // Start loading the request and return the mock response
    override func startLoading() {
        if let mockResponse = MockURLProtocol.mockResponse {
            if let data = mockResponse.data {
                self.client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = mockResponse.response {
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = mockResponse.error {
                self.client?.urlProtocol(self, didFailWithError: error)
            } else {
                self.client?.urlProtocolDidFinishLoading(self)
            }
        }
    }

    // Stop loading the request. This method is required but not used for this mock.
    override func stopLoading() {}
}

func createMockSession() -> URLSession {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: configuration)
}
