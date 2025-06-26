import Foundation
import HTTPTypes
import HTTPTypesFoundation

extension Client {
  public func meetings() async throws -> ListResponse<Meeting> {
    let url = baseURL.appendingPathComponent("meetings")
    let request = HTTPRequest(
      method: .get,
      url: url
    )
    let (data, _) = try await execute(request)
    let list = try JSONDecoder().decode(ListResponse<Meeting>.self, from: data)
    return list
  }

  public func meeting(for meetingId: Meeting.ID) async throws -> Meeting {
    let url = baseURL.appendingPathComponent("meetings/\(meetingId)")
    let request = HTTPRequest(
      method: .get,
      url: url
    )
    let (data, _) = try await execute(request)
    let response = try JSONDecoder().decode(SingleResponse<Meeting>.self, from: data)
    return response.data
  }
  
  public func createMeeting(_ meeting: CreateMeeting) async throws -> Meeting {
    let url = baseURL.appendingPathComponent("meetings")
    let request = HTTPRequest(
      method: .post,
      url: url,
      headerFields: [
        .contentType: "application/json"
      ]
    )
    let bodyData = try JSONEncoder().encode(meeting)
    let (data, _) = try await execute(request, body: bodyData)
    let response = try JSONDecoder().decode(SingleResponse<Meeting>.self, from: data)
    return response.data
  }
}

