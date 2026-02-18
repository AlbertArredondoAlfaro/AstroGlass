import Foundation
import FoundationModels
import os

actor LlamaOnDeviceService {
    static let shared = LlamaOnDeviceService()

    private let logger = Logger(subsystem: "AstroGlass", category: "FoundationModels")
    private let model = SystemLanguageModel.default

    private init() {}

    func generate(prompt: String, maxNewTokens: Int) async -> String? {
        guard model.isAvailable else {
            logger.error("Foundation model unavailable: \(String(describing: self.model.availability))")
            return nil
        }

        do {
            let session = LanguageModelSession(model: model)
            var options = GenerationOptions()
            options.temperature = 0.7
            options.maximumResponseTokens = max(64, min(maxNewTokens, 320))

            let response = try await session.respond(to: prompt, options: options)
            let text = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
            return text.isEmpty ? nil : text
        } catch {
            logger.error("Foundation model generation failed: \(error.localizedDescription)")
            return nil
        }
    }
}
