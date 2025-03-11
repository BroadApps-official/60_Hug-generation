import SwiftUI
import Combine

struct Template: Identifiable, Decodable {
    let id: Int
    let ai: String
    let categoryId: Int
    let categoryTitleEn: String
    let categoryTitleRu: String
    let effect: String
    let preview: String
    let previewSmall: String
}

class TemplatesViewModel: ObservableObject {
    @Published var templates: [Template] = []

    func fetchTemplates() {
        NetworkManager.shared.fetchTemplates { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let json = data as? [String: Any],
                       let jsonData = try? JSONSerialization.data(withJSONObject: json["data"] ?? []),
                       let decoded = try? JSONDecoder().decode([Template].self, from: jsonData) {

                        self.templates = decoded
                    }
                case .failure(let error):
                    print("Ошибка загрузки: \(error)")
                }
            }
        }
    }
}

// Структура для декодирования ответа
struct GenerationStatusResponse: Decodable {
    let error: Bool
    let messages: [String]
    let data: GenerationData
}

struct GenerationData: Decodable {
    let status: String
    let error: String?
    let resultUrl: String
    let progress: String?
    let totalWeekGenerations: Int
    let maxGenerations: Int
}

// Ошибки сети
enum NetworkError: Error {
    case invalidURL
    case noData
    case serverError(message: String)
    case inProgress
}
