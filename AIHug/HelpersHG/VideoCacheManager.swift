import AVKit

class VideoCacheManager {
    static let shared = VideoCacheManager()

    private let cache = URLCache.shared

    /// Получает закешированное видео по URL, если оно уже есть в кеше
    func cachedURL(for url: URL) -> URL? {
        let request = URLRequest(url: url)

        // Проверяем, есть ли кешированные данные
        if let cachedResponse = cache.cachedResponse(for: request) {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
            try? cachedResponse.data.write(to: tempURL)
            return tempURL
        }
        return nil
    }

    /// Загружает видео и кеширует его, если в кеше его еще нет
    func cacheVideo(url: URL, completion: @escaping (URL?) -> Void) {
        let request = URLRequest(url: url)

        // Если видео уже в кеше, сразу возвращаем его путь
        if let cachedURL = cachedURL(for: url) {
            completion(cachedURL)
            return
        }

        // Если видео нет в кеше — скачиваем и сохраняем его
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response else {
                completion(nil)
                return
            }

            // Сохраняем ответ в URLCache
            let cachedResponse = CachedURLResponse(response: response, data: data)
            self.cache.storeCachedResponse(cachedResponse, for: request)

            // Записываем видео в локальную директорию
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
            try? data.write(to: tempURL)

            DispatchQueue.main.async {
                completion(tempURL)
            }
        }.resume()
    }
    
    /// Возвращает текущий размер кэша в байтах
    func cacheSize() -> Int {
        return cache.currentDiskUsage
    }

    /// Возвращает размер кэша как строку, например: "4.3 MB"
    func formattedCacheSize() -> String {
        let size = Double(cache.currentDiskUsage)
        if size < 1_000 {
            return String(format: "%.0f B", size)
        } else if size < 1_000_000 {
            return String(format: "%.1f KB", size / 1_000)
        } else {
            return String(format: "%.1f MB", size / 1_000_000)
        }
    }
    
    func clearCache() {
        cache.removeAllCachedResponses()
        NotificationCenter.default.post(name: .cacheDidClear, object: nil)
    }
}

extension Notification.Name {
    static let cacheDidClear = Notification.Name("cacheDidClear")
}
