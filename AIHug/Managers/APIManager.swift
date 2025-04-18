import Alamofire
import SwiftUI

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    private let baseURL = "https://vewapnew.online/api/user"
    private let baseURLTemplates = "https://vewapnew.online/api/templates"
    private let generationStatusURL = "https://vewapnew.online/api/generationStatus"
    private let bearerToken = "rE176kzVVqjtWeGToppo4lRcbz3HRLoBrZREEvgQ8fKdWuxySCw6tv52BdLKBkZTOHWda5ISwLUVTyRoZEF0A33Xpk63lF9wTCtDxOs8XK3YArAiqIXVb7ZS4IK61TYPQMu5WqzFWwXtZc1jo8w"
    private let bearerTokenHailuo = "0e9560af-ab3c-4480-8930-5b6c76b03eea"
    private let appIdHailuo = "com.test.test"
    private let bundleID = "com.elv.hugg3n3r4t10n"
    private let userID = /*"F452345B-BEEC-43EA-AF96-000000000"*/ UIDevice.current.identifierForVendor?.uuidString ?? "unknown_id"
    private let isNew: Bool = true
    private var appName: String = "com.elv.hugg3n3r4t10n"
    private var ai: [String] = ["pika", "pv"]
    
    func fetchUserData(completion: @escaping (Result<Any, Error>) -> Void) {
        let parameters: [String: String] = [
            "userId": userID,
            "bundleId": bundleID
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(bearerToken)"
        ]
        
        print("🔹 Headers: \(headers)")
        print("🔹 Params: \(parameters)")
        
        AF.request(baseURL, method: .get, parameters: parameters, headers: headers)
            .validate()
            .responseJSON { response in
                print("🔹 Full Response: \(response)")
                
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    
    func fetchTemplates(completion: @escaping (Result<Any, Error>) -> Void) {
        var parameters: [String: Any] = [:]
        
        parameters["isNew"] = isNew
        parameters["appName"] = appName
        for (index, value) in ai.enumerated() {
            parameters["ai[\(index)]"] = value
        }
        
        let token = bearerToken
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        AF.request(baseURLTemplates, method: .get, parameters: parameters, headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                    print("✅ success2")

                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func fetchFilters(completion: @escaping (Result<Any, Error>) -> Void) {
        
        let baseURLFilters = "https://futuretechapps.shop/filters"
        
        let parameters: [String: Any] = [
            "appId": "com.test.test",
            "userId": "F452345B-BEEC-43EA-AF96-000000000"
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(bearerTokenHailuo)"
        ]

        AF.request(baseURLFilters, method: .get, parameters: parameters, headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let data):
                    print("✅ Filters response: \(data)")
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }


    
    func generateImage(templateId: Int?, imageURL: URL?, completion: @escaping (Result<String, Error>) -> Void) {
        let generateURL = "https://vewapnew.online/api/generate"
        
        let parameters: [String: Any] = [
            "userId": userID,
            "appId": bundleID,
            "templateId": templateId as Any
        ].compactMapValues { $0 } // Убираем nil
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(bearerToken)"
        ]
        
        AF.upload(
            multipartFormData: { multipartFormData in
                for (key, value) in parameters {
                    if let stringValue = value as? String {
                        multipartFormData.append(Data(stringValue.utf8), withName: key)
                    } else if let intValue = value as? Int {
                        multipartFormData.append(Data("\(intValue)".utf8), withName: key)
                    }
                }
                
                if let imageURL = imageURL, let imageData = try? Data(contentsOf: imageURL) {
                    multipartFormData.append(imageData, withName: "image", fileName: imageURL.lastPathComponent, mimeType: "image/jpeg")
                }
            },
            to: generateURL,
            headers: headers
        )
        .validate()
        .responseJSON { response in
            switch response.result {
            case .success(let data):
                print("✅ Ответ от сервера: \(data)")
                
                if let json = data as? [String: Any],
                   let responseData = json["data"] as? [String: Any],
                   let generationId = responseData["generationId"] as? String {
                    completion(.success(generationId))
                } else {
                    completion(.failure(NSError(domain: "Invalid response format", code: -1, userInfo: nil)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func generateVideo(promptText: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = "https://vewapnew.online/api/generate/txt2video"
        
        let parameters: [String: String] = [
            "promptText": promptText,
            "userId": userID,
            "appId": bundleID
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(bearerToken)"
        ]
        
        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in parameters {
                if let data = value.data(using: .utf8) {
                    multipartFormData.append(data, withName: key)
                }
            }
        }, to: url, method: .post, headers: headers)
        .validate()
        .responseJSON { response in
            switch response.result {
            case .success(let data):
                if let json = data as? [String: Any],
                   let dataDict = json["data"] as? [String: Any],
                   let generationId = dataDict["generationId"] as? String {
                    completion(.success(generationId))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func generateVideoWithPhotoRef(promptText: String, image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        let url = "https://vewapnew.online/api/generate/img2video"
        
        let parameters: [String: String] = [
            "promptText": promptText,
            "userId": userID,
            "appId": bundleID
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(bearerToken)"
        ]
        
        var imageData: Data?
        var mimeType: String?
        
        if let pngData = image.pngData() {
            imageData = pngData
            mimeType = "image/png"
        } else if let jpegData = image.jpegData(compressionQuality: 1.0) {
            imageData = jpegData
            mimeType = "image/jpeg"
        }
        
        guard let finalImageData = imageData, let finalMimeType = mimeType else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in parameters {
                if let data = value.data(using: .utf8) {
                    multipartFormData.append(data, withName: key)
                }
            }

            multipartFormData.append(finalImageData, withName: "image", fileName: "image.\(mimeType == "image/png" ? "png" : "jpg")", mimeType: finalMimeType)
        }, to: url, method: .post, headers: headers)
        .validate()
        .responseJSON { response in
            switch response.result {
            case .success(let data):
                if let json = data as? [String: Any],
                   let dataDict = json["data"] as? [String: Any],
                   let generationId = dataDict["generationId"] as? String {
                    completion(.success(generationId))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getGenerationStatus(generationId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let parameters: [String: String] = [
            "generationId": generationId
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(bearerToken)"
        ]
        
        AF.request(generationStatusURL, method: .get, parameters: parameters, headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let data):
                    do {
                        let responseObject = try JSONDecoder().decode(GenerationStatusResponse.self, from: response.data!)
                        
                        if responseObject.error {
                            completion(.failure(NetworkError.serverError(message: responseObject.messages.joined(separator: ", "))))
                        } else if responseObject.data.status == "finished", !responseObject.data.resultUrl.isEmpty {
                            completion(.success(responseObject.data.resultUrl))
                        } else {
                            completion(.failure(NetworkError.inProgress))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
