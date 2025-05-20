import SwiftUI
import Combine

protocol PreviewPlayable {
    var previewURL: String { get }
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
    var previewURL: String {
        preview
    }
    
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
    var previewURL: String {
        preview
    }
    
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


struct ScenariosResponse: Decodable {
    let error: Bool
    let message: String?
    let data: ScenarioListData
}

struct ScenarioListData: Decodable {
    let list: [ScenarioGroup]
}

struct ScenarioGroup: Decodable, Identifiable {
    let id: Int
    let title: String
    let preview: String
    let isNew: Bool
    let totalScenarios: Int
    let scenarios: [ScenarioItem]
}

struct ScenarioItem: Decodable, Identifiable {
    let id: Int
    let title: String?
    let preview: String
    let previewProduction: String
    let previewVideo: String
    let gender: String
    let isEnabled: Bool
    let mediaType: String
}

extension ScenarioItem: PreviewPlayable {
    var previewURL: String {
        previewVideo
    }
    var displayTitle: String { title ?? "" }
    var idMain: Int { id }
}


class ScenariosViewModel: ObservableObject {
    @Published var groups: [ScenarioGroup] = []

    func fetchScenarios() {
        print("⏳ fetchScenarios вызван")
        
        NetworkManager.shared.fetchScenarios { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let dict = data as? [String: Any],
                       let dataDict = dict["data"] as? [String: Any],
                       let listArray = dataDict["list"] as? [[String: Any]],
                       let jsonData = try? JSONSerialization.data(withJSONObject: listArray),
                       let decoded = try? JSONDecoder().decode([ScenarioGroup].self, from: jsonData) {

                        self.groups = decoded
                        print("✅ decoded groups: \(decoded.count) штук")
                    } else {
                        print("❌ Ошибка парсинга групп")
                    }
                case .failure(let error):
                    print("❌ Ошибка загрузки сценариев: \(error)")
                }
            }
        }
    }
}



struct EffectsResponse: Decodable {
    let error: Bool
    let message: String?
    let data: EffectsData
}

struct EffectsData: Decodable {
    let list: [EffectGroup]
}

struct EffectGroup: Decodable, Identifiable {
    let id: Int
    let title: String
    let preview: String?
    let isNew: Bool
    let totalEffects: Int
    let totalUsed: Int
    let effects: [EffectItem]
}

struct EffectItem: Decodable, Identifiable {
    let id: Int
    let title: String
    let preview: String
    let previewProduction: String
    let gender: String?
    let prompt: String?
    let isEnabled: Bool
}


extension EffectItem: PreviewPlayable {
    var previewURL: String { previewProduction }
    var displayTitle: String { title }
    var idMain: Int { id }
}

class EffectsViewModel: ObservableObject {
    @Published var groups: [EffectGroup] = []
    
    func fetchEffectsFotobudka() {
        print("⏳ fetchEffectsFotobudka вызван")
        
        NetworkManager.shared.fetchEffectsFotobudka { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let dict = data as? [String: Any],
                       let dataDict = dict["data"] as? [String: Any],
                       let listArray = dataDict["list"] as? [[String: Any]],
                       let jsonData = try? JSONSerialization.data(withJSONObject: listArray),
                       let decoded = try? JSONDecoder().decode([EffectGroup].self, from: jsonData) {
                        
                        self.groups = decoded
                        print("✅ decoded effects groups: \(decoded.count) штук")
                    } else {
                        print("❌ Ошибка парсинга эффектов")
                    }
                case .failure(let error):
                    print("❌ Ошибка загрузки эффектов: \(error)")
                }
            }
        }
    }
}


struct StylesResponse: Decodable {
    let error: Bool
    let message: String?
    let data: [StyleGroup]
}

struct StyleGroup: Decodable, Identifiable {
    let id: Int
    let title: String
    let preview: String?
    let isNew: Bool
    let isCouple: Bool
    let isGirlfriends: Bool
    let groupPreview: [String: [String]]
    let previewByGender: [String: [String: [String]]]
    let totalTemplates: Int
    let totalUsed: Int
    let templates: [StyleTemplate]
    let subCategories: [String]
}

struct StyleTemplate: Decodable, Identifiable {
    let id: Int
    let title: String?
    let preview: String
    let previewProduction: String
    let gender: String?
    let prompt: String?
    let isEnabled: Bool
}

extension StyleTemplate: PreviewPlayable {
    var previewURL: String { previewProduction }
    var displayTitle: String { title ?? "" }
    var idMain: Int { id }
}

class StylesViewModel: ObservableObject {
    @Published var styles: [StyleGroup] = []
    
    func fetchStylesFotobudka() {
        print("⏳ fetchStylesFotobudka вызван")
        
        NetworkManager.shared.fetchStylesFotobudka { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(StylesResponse.self, from: data)
                        self.styles = decoded.data
                        print("✅ decoded style groups: \(decoded.data.count) штук")
                    } catch {
                        print("❌ Ошибка декодирования: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    print("❌ Ошибка загрузки стилей: \(error)")
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

struct GenerationStatusResponseFotobudka: Decodable {
    let error: Bool
    let message: String?
    let data: GenerationDataFotobudka
}

struct GenerationDataFotobudka: Decodable {
    let id: Int
    let generationId: Int
    let jobId: String
    let templateId: Int
    let preview: String?
    let resultUrl: String
    let status: String
    let isGodMode: Bool
    let isCouplePhoto: Bool
    let isPV: Bool
    let isPika: Bool
    let isTxt2Img: Bool
    let isMarked: Bool
    let mark: String?
    let seconds: Int
    let startedAt: String
    let finishedAt: String
}


enum NetworkError: Error {
    case invalidURL
    case noData
    case serverError(message: String)
    case inProgress
}


struct LoginResponse: Decodable {
    let error: Bool
    let message: String?
    let data: LoginUserData
}

struct LoginUserData: Decodable {
    let id: Int
    let userId: String
    let gender: String
    let source: String
    let isNewRegistered: Bool
    let stat: UserStat
    let avatars: [Avatar]
}

struct Avatar: Decodable, Identifiable {
    let id: Int
    let title: String?
    let preview: String?
    let gender: String
    let isActive: Bool
}

struct UserStat: Decodable {
    let id: Int
    let name: String?
    let login: String?
    let gender: String
    let isGodModeEnabled: Bool
    let startAt: String?
    let maxPhotos: Int
    let maxStyles: Int
    let maxModels: Int
    let isActiveTariff: Bool
    let tariffId: Int?
    let maxUploadPhotos: Int
    let minUploadPhotos: Int
    let totalGenerations: Int
    let totalGenerationsTemplate: Int
    let totalGenerationsGod: Int
    let totalModels: Int
    let availableModels: Int
    let availableGenerations: Int
    let totalTrialGenerations: Int
    let createdAt: String
}


@MainActor
class UserSessionViewModel: ObservableObject {
    @Published var userData: LoginUserData?

    private var hasLoadedOnce = false

    func loadUserDataIfNeeded() {
        guard !hasLoadedOnce else { return }

        hasLoadedOnce = true
        print("⏳ Загружаем userData один раз")
        loginUser()
    }

    func refreshUserData() {
        print("🔄 Обновляем userData вручную")
        loginUser()
    }

    private func loginUser() {
        NetworkManager.shared.loginUser { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self?.userData = data
                    print("✅ userData получен: \(data)")
                case .failure(let error):
                    print("❌ Ошибка получения userData: \(error)")
                }
            }
        }
    }
}

