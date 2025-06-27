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
  
  public func createMeeting(_ meeting: NewMeeting) async throws -> Meeting {
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
  
  @discardableResult
  public func replaceMeeting(for meetingId: Meeting.ID, meeting: NewMeeting) async throws -> Meeting {
    let url = baseURL.appendingPathComponent("meetings/\(meetingId)")
    let request = HTTPRequest(
      method: .put,
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
  
  public func participants(
    for meetingId: Meeting.ID,
    pageNo: Int? = nil,
    perPage: Int? = nil
  )  async throws -> ListResponse<User> {
    let url = baseURL
      .appendingPathComponent("meetings/\(meetingId)/participants")
      .appending(queryItems: [
        .init(name: "page_no", value: pageNo.map { String($0) }),
        .init(name: "per_page", value: perPage.map { String($0) })
      ].compactMap({ $0.value != nil ? $0 : nil }))
    let request = HTTPRequest(
      method: .get,
      url: url,
      headerFields: [
        .contentType: "application/json"
      ]
    )
    let (data, _) = try await execute(request)
    let response = try JSONDecoder().decode(ListResponse<User>.self, from: data)
    return response
  }
  
  @discardableResult
  public func addParticipant(
    for meetingId: Meeting.ID,
    participant: NewUser
  )  async throws -> User {
    let url = baseURL.appendingPathComponent("meetings/\(meetingId)/participants")

    let request = HTTPRequest(
      method: .post,
      url: url,
      headerFields: [
        .contentType: "application/json"
      ]
    )
    let bodyData = try JSONEncoder().encode(participant)
    let (data, _) = try await execute(request, body: bodyData)
    let response = try JSONDecoder().decode(SingleResponse<User>.self, from: data)
    return response.data
  }
  
  public func participant(
    for meetingId: Meeting.ID,
    participantId: User.ID
  )  async throws -> User {
    let url = baseURL.appendingPathComponent("meetings/\(meetingId)/participants/\(participantId)")

    let request = HTTPRequest(
      method: .get,
      url: url,
      headerFields: [
        .contentType: "application/json"
      ]
    )
    let (data, _) = try await execute(request)
    let response = try JSONDecoder().decode(SingleResponse<User>.self, from: data)
    return response.data
  }
  
  @discardableResult
  public func updateParticipant(
    for meetingId: Meeting.ID,
    participantId: User.ID,
    user: UpdateUser
  )  async throws -> User {
    let url = baseURL.appendingPathComponent("meetings/\(meetingId)/participants/\(participantId)")

    let request = HTTPRequest(
      method: .patch,
      url: url,
      headerFields: [
        .contentType: "application/json"
      ]
    )
    let bodyData = try JSONEncoder().encode(user)
    let (data, _) = try await execute(request, body: bodyData)
    let response = try JSONDecoder().decode(SingleResponse<User>.self, from: data)
    return response.data
  }
  
  @discardableResult
  public func deleteParticipant(
    for meetingId: Meeting.ID,
    participantId: User.ID
  )  async throws -> User {
    let url = baseURL.appendingPathComponent("meetings/\(meetingId)/participants/\(participantId)")

    let request = HTTPRequest(
      method: .delete,
      url: url,
      headerFields: [
        .contentType: "application/json"
      ]
    )
    let (data, _) = try await execute(request)
    let response = try JSONDecoder().decode(SingleResponse<User>.self, from: data)
    return response.data
  }
}
