import Foundation

protocol BitrateLogProvider {
    func getEvents() -> [BitrateLogDto]?
}
