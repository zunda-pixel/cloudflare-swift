import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct AIConfig: Codable, Sendable {
  public var transcription: TranscriptionConfig = .init()
  public var summarization: SummarizationConfig = .init()
  
  @MemberwiseInit(.public)
  public struct TranscriptionConfig: Codable, Sendable {
    public var keywords: [String] = []
    public var language: Language = .enUS
    public var profanityFilter = false
    
    private enum CodingKeys: String, CodingKey {
      case keywords
      case language
      case profanityFilter = "profanity_filter"
    }
    
    public enum Language: String, Codable, Sendable {
      case enUS = "en-US"
      case enIN = "en-IN"
      case de
      case hi
      case sv
      case ru
      case pl
      case el
      case fr
      case nl
    }
  }
  
  @MemberwiseInit(.public)
  public struct SummarizationConfig: Codable, Sendable {
    public var wordLimit: Int = 500
    public var textFormat: TextFormat = .markdown
    public var summaryType: SummaryType = .general
    
    enum CodingKeys: String, CodingKey {
      case wordLimit = "word_limit"
      case textFormat = "text_format"
      case summaryType = "summary_type"
    }
    
    public enum TextFormat: String, Codable, Sendable {
      case plainText = "plain_text"
      case markdown
    }
    
    public enum SummaryType: String, Codable, Sendable {
      case general
      case teamMeating = "team_meeting"
      case salesCall = "sales_call"
      case clientCheckIn = "client_check_in"
      case interview
      case dailyStandup = "daily_standup"
      case oneOnOneMeeting = "one_on_one_meeting"
      case lecture
      case codeReview = "code_review"
    }
  }
}
