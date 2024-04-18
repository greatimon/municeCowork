import Foundation

struct TestApiDTO: Codable {
  let userID: Int
  let id: Int
  let title: String
  let completed: Bool
  
  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case id
    case title
    case completed
  }
}
