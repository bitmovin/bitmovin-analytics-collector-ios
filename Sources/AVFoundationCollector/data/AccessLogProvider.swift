import Foundation

protocol AccessLogProvider {
    func getEvents() -> [AccessLogDto]?
}
