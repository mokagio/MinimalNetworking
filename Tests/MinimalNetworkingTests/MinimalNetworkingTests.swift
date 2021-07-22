import Combine
import XCTest
@testable import MinimalNetworking

final class MinimalNetworkingTests: XCTestCase {

    // This is a slimmed down version of the example model used in https://tddinswift.com
    struct MenuItem: Decodable {
        let name: String
    }
    let testBaseURL = URL(string: "https://raw.githubusercontent.com/mokagio/tddinswift_fake_api/trunk")!
    let testEndpoint = Endpoint(path: "dish_of_the_day.json", resourceType: MenuItem.self)

    func testMinimalNetworkingAgainstLiveURL() {
        let expectation = XCTestExpectation(description: "Receives and decodes data from real endpoint")

        var cancellables = Set<AnyCancellable>()

        URLSession.shared.load(testEndpoint, from: testBaseURL)
            .sink(
                receiveCompletion: { completion in
                    XCTFail("Expected to receive a value, got completion: \(completion)")
                },
                receiveValue: { value in
                    XCTAssertEqual(value.name, "Spaghetti Carbonara")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 3)
    }
}
