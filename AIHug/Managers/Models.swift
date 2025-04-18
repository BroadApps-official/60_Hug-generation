import SwiftUI
import Combine

protocol PreviewPlayable {
    var preview: String { get }
    var displayTitle: String { get }
    var idMain: Int { get }
    
}

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

extension Template: PreviewPlayable {
    var displayTitle: String { effect }
    var idMain: Int { id }
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

    var groupedTemplates: [String: [Template]] {
        Dictionary(grouping: templates, by: { $0.categoryTitleEn })
    }
}

struct Filter: Identifiable, Decodable {
    let id: Int
    let title: String
    let preview: String
    let preview_small: String
}

extension Filter: PreviewPlayable {
    var displayTitle: String { title }
    var idMain: Int { id }
}

class FiltersViewModel: ObservableObject {
    @Published var filters: [Filter] = []

    func fetchFilters() {
        print("⏳ fetchFilters вызван")

        NetworkManager.shared.fetchFilters { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let dict = data as? [String: Any],
                       let jsonArray = dict["data"] as? [[String: Any]],
                       let jsonData = try? JSONSerialization.data(withJSONObject: jsonArray),
                       let decoded = try? JSONDecoder().decode([Filter].self, from: jsonData) {
                        
                        self.filters = decoded
                        print("✅ decoded filters: \(decoded.count) шт.")
                    } else {
                        print("❌ Ошибка декодирования фильтров")
                    }
                case .failure(let error):
                    print("❌ Ошибка загрузки фильтров: \(error)")
                }
            }
        }
    }

}



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

enum NetworkError: Error {
    case invalidURL
    case noData
    case serverError(message: String)
    case inProgress
}
