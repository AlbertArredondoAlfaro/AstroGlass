import Foundation
import Translation
import os

final class CoreMLForecastService: @unchecked Sendable {
    static let shared = CoreMLForecastService()
    private let logger = Logger(subsystem: "AstroGlass", category: "Forecast")

    private init() {}

    func generateWeeklyForecast(
        sunSign: ZodiacSign,
        risingSign: ZodiacSign,
        weekOfYear: Int,
        yearForWeekOfYear: Int,
        profileID: UUID
    ) async -> String {
        let languageIdentifier = currentLanguageIdentifier()
        let languageCode = normalizedLanguageCode(from: languageIdentifier)
        let fallback = fallbackForecastText(for: languageIdentifier)
        let cacheKey = ForecastCacheKey(
            profileID: profileID,
            sunSign: sunSign.rawValue,
            risingSign: risingSign.rawValue,
            weekOfYear: weekOfYear,
            yearForWeekOfYear: yearForWeekOfYear,
            languageCode: languageCode
        )

        if let cached = await WeeklyForecastCache.shared.get(cacheKey), cached != fallback {
            let cleanedCached = finalizeForecastText(cached, maxWords: 200)
            if cleanedCached != cached {
                await WeeklyForecastCache.shared.set(cleanedCached, for: cacheKey)
            }
            return cleanedCached
        }

        let result = await withTimeout(seconds: 180) { [self] in
            let prompt = buildPrompt(
                sunSign: sunSign,
                risingSign: risingSign,
                weekOfYear: weekOfYear,
                languageCode: languageCode
            )

            let generatedEnglish = await LlamaOnDeviceService.shared.generate(
                prompt: prompt,
                maxNewTokens: 280
            ) ?? ""

            var trimmedEnglish = finalizeForecastText(generatedEnglish, maxWords: 200)
            if shouldRetryGeneration(for: trimmedEnglish) {
                let retry = await LlamaOnDeviceService.shared.generate(
                    prompt: prompt,
                    maxNewTokens: 320
                ) ?? ""
                let retryFinal = finalizeForecastText(retry, maxWords: 200)
                if wordCount(retryFinal) >= wordCount(trimmedEnglish) {
                    trimmedEnglish = retryFinal
                }
            }
            guard !trimmedEnglish.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                logger.error("Forecast fallback: generated text is empty")
                return fallback
            }
            guard isReadableForecast(trimmedEnglish) else {
                logger.error("Forecast fallback: generated text rejected by readability filter")
                return fallback
            }
            guard !isEnglishLanguage(languageIdentifier) else { return trimmedEnglish }

            let englishForTranslation = trimmedEnglish
            let translated = await withTimeout(seconds: 20) {
                await ForecastTranslationService.shared.translateFromEnglish(
                    englishForTranslation,
                    to: languageIdentifier
                )
            } ?? englishForTranslation

            return finalizeForecastText(translated, maxWords: 200)
        }

        let finalText = result ?? fallback
        if result == nil {
            logger.error("Forecast fallback: generation timed out")
        }
        if finalText != fallback {
            await WeeklyForecastCache.shared.set(finalText, for: cacheKey)
        }
        return finalText
    }

    func currentLanguageCode() -> String {
        normalizedLanguageCode(from: currentLanguageIdentifier())
    }

    private func buildPrompt(
        sunSign: ZodiacSign,
        risingSign: ZodiacSign,
        weekOfYear: Int,
        languageCode: String
    ) -> String {
        let sun = localized(sunSign.nameKey)
        let rising = localized(risingSign.nameKey)

        switch languageCode {
        case "es":
            return """
            Horóscopo semanal para Sol en \(sun) y Ascendente en \(rising), semana \(weekOfYear).
            Escribe entre 150 y 200 palabras en español natural y moderno.
            Incluye orientación práctica sobre trabajo, dinero y amor.
            No uses markdown, títulos, ni asteriscos.
            No asumas el genero de la persona. Trátala siempre en masculino cuando haya concordancia de género.
            Nunca uses formulaciones en femenino para dirigirte al usuario.
            Usa segunda persona y construcciones neutrales cuando sea posible.
            Tono cercano, claro y específico.
            Horóscopo:
            """
        case "ca":
            return """
            Horòscop setmanal per a Sol en \(sun) i Ascendent en \(rising), setmana \(weekOfYear).
            Escriu entre 150 i 200 paraules en català natural i modern.
            Inclou orientació pràctica sobre feina, diners i amor.
            No facis servir markdown, títols ni asteriscs.
            No assumeixis el gènere de la persona. Usa segona persona i llenguatge neutral.
            To proper, clar i específic.
            Horòscop:
            """
        case "fr":
            return """
            Horoscope hebdomadaire pour Soleil en \(sun) et Ascendant en \(rising), semaine \(weekOfYear).
            Écris entre 150 et 200 mots en français naturel et moderne.
            Inclure des conseils pratiques sur travail, argent et amour.
            N'utilise pas de markdown, de titres ni d'astérisques.
            Ne présume pas le genre de la personne. Utilise un style neutre et la deuxième personne.
            Ton proche, clair et concret.
            Horoscope :
            """
        case "de":
            return """
            Woechentlicher Horoskoptext fuer Sonne in \(sun) und Aszendent \(rising), Woche \(weekOfYear).
            Schreibe 150 bis 200 Woerter in natuerlichem, modernem Deutsch.
            Enthalte praktische Hinweise zu Arbeit, Geld und Liebe.
            Verwende kein Markdown, keine Ueberschriften und keine Sternchen.
            Kein Geschlecht annehmen. Nutze neutrale Formulierungen und die zweite Person.
            Ton: nahbar, klar und konkret.
            Horoskop:
            """
        case "pt":
            return """
            Horoscopo semanal para Sol em \(sun) e Ascendente em \(rising), semana \(weekOfYear).
            Escreva entre 150 e 200 palavras em portugues natural e moderno.
            Inclua orientacoes praticas sobre trabalho, dinheiro e amor.
            Nao use markdown, titulos nem asteriscos.
            Nao assuma genero da pessoa. Use segunda pessoa e linguagem neutra.
            Tom proximo, claro e especifico.
            Horoscopo:
            """
        case "fil":
            return """
            Lingguhang horoscope para sa Araw sa \(sun) at Ascendant sa \(rising), linggo \(weekOfYear).
            Sumulat ng 150 hanggang 200 salita sa natural at modernong Filipino.
            Isama ang praktikal na gabay sa trabaho, pera, at pag-ibig.
            Huwag gumamit ng markdown, mga pamagat, o asterisk.
            Huwag mag-assume ng kasarian ng user. Gumamit ng neutral na wika.
            Gawing malinaw, diretso, at may init ang tono.
            Horoscope:
            """
        case "hi":
            return """
            Saptahik rashifal: Surya \(sun) aur Ascendant \(rising), week \(weekOfYear).
            150-200 shabdon mein natural aur modern Hindi mein likho.
            Kaam, paisa aur pyaar par practical guidance do.
            Markdown, headings ya asterisk ka use mat karo.
            User ka gender assume mat karo. Neutral bhasha aur second person use karo.
            Tone friendly, clear aur specific rakho.
            Rashifal:
            """
        case "ja":
            return """
            週間ホロスコープ。太陽星座 \(sun)、アセンダント \(rising)、第\(weekOfYear)週。
            自然で現代的な日本語で150〜200語程度で作成してください。
            仕事・お金・恋愛への実用的なアドバイスを含めてください。
            Markdown、見出し、アスタリスクは使わないでください。
            性別は推測せず、中立的な表現で二人称中心に書いてください。
            トーンは親しみやすく、明確で具体的に。
            ホロスコープ:
            """
        case "ru":
            return """
            Ezhenedelnyy goroskop dlya Solntsa v \(sun) i Aszendenta \(rising), nedelya \(weekOfYear).
            Napishete 150-200 slov na estestvennom sovremennom russkom.
            Vklyuchite praktichnye sovety po rabote, dengam i lyubvi.
            Ne ispolzuyte markdown, zagolovki i zvezdochki.
            Ne predpolagayte pol polzovatelya. Ispolzuyte neytralnye formulirovki i vtoroe litso.
            Ton blizkiy, yasnyy i konkretnyy.
            Goroskop:
            """
        case "zh":
            return """
            每周运势：太阳星座\(sun)，上升星座\(rising)，第\(weekOfYear)周。
            请用自然、现代的中文写150到200词。
            需要包含工作、金钱和感情方面的实用建议。
            不要使用markdown、标题或星号。
            不要假设用户性别，使用中性表达和第二人称。
            语气要亲切、清晰、具体。
            运势：
            """
        case "af":
            return """
            Weeklikse horoskoop vir Son in \(sun) en Ascendant in \(rising), week \(weekOfYear).
            Skryf 150 tot 200 woorde in natuurlike, moderne Afrikaans.
            Sluit praktiese leiding oor werk, geld en liefde in.
            Moenie markdown, opskrifte of sterretjies gebruik nie.
            Moenie geslag aanvaar nie. Gebruik neutrale taal en tweede persoon.
            Toon: vriendelik, duidelik en spesifiek.
            Horoskoop:
            """
        default:
            return """
            Weekly horoscope for \(sun) sun and \(rising) rising, week \(weekOfYear).
            Write 150-200 words in natural modern language.
            Include practical guidance for work, money and love.
            Do not use markdown, headings, or asterisks.
            Do not assume the user's gender. Use neutral phrasing and second person.
            Keep it warm, clear and specific.
            Horoscope:
            """
        }
    }

    private func currentLanguageIdentifier() -> String {
        if let appLanguage = Bundle.main.preferredLocalizations.first, !appLanguage.isEmpty {
            return appLanguage
        }
        return Locale.preferredLanguages.first ?? "en"
    }

    private func normalizedLanguageCode(from identifier: String) -> String {
        identifier
            .lowercased()
            .split(whereSeparator: { $0 == "-" || $0 == "_" })
            .first
            .map(String.init) ?? "en"
    }

    private func isEnglishLanguage(_ identifier: String) -> Bool {
        normalizedLanguageCode(from: identifier) == "en"
    }

    private func localized(_ key: String) -> String {
        Bundle.main.localizedString(forKey: key, value: key, table: nil)
    }

    private func finalizeForecastText(_ text: String, maxWords: Int = 200) -> String {
        let sanitized = sanitizeModelText(text)
        let capped = normalizeLength(sanitized, maxWords: maxWords)
        return trimToCompleteSentence(capped)
    }

    private func sanitizeModelText(_ text: String) -> String {
        var value = text
            .replacingOccurrences(of: "\r", with: " ")
            .replacingOccurrences(of: "\t", with: " ")
            .replacingOccurrences(of: "**", with: "")
            .replacingOccurrences(of: "__", with: "")
            .replacingOccurrences(of: "##", with: "")
            .replacingOccurrences(of: "* ", with: "")
            .replacingOccurrences(of: "- ", with: "")

        let labels = ["Horóscopo:", "Horoscope:", "Horoskop:", "Horòscop:", "运势：", "運勢：", "ホロスコープ:"]
        for label in labels {
            value = value.replacingOccurrences(of: label, with: "")
        }

        value = value
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        while value.contains("  ") {
            value = value.replacingOccurrences(of: "  ", with: " ")
        }
        return value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func normalizeLength(_ text: String, maxWords: Int = 200) -> String {
        let words = text.split(separator: " ")
        if words.count > maxWords {
            return words.prefix(maxWords).joined(separator: " ")
        }
        return text
    }

    private func trimToCompleteSentence(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return trimmed }

        let punctuation = CharacterSet(charactersIn: ".!?。！？")
        if let idx = trimmed.unicodeScalars.lastIndex(where: { punctuation.contains($0) }) {
            let distance = trimmed.unicodeScalars.distance(from: trimmed.unicodeScalars.startIndex, to: idx)
            let total = trimmed.unicodeScalars.count
            if total > 0 && Double(distance) / Double(total) >= 0.55 {
                let scalarEnd = trimmed.unicodeScalars.index(after: idx)
                return String(trimmed.unicodeScalars[..<scalarEnd]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        if let last = trimmed.unicodeScalars.last, CharacterSet.letters.contains(last) {
            return trimmed + "."
        }
        return trimmed
    }

    private func shouldRetryGeneration(for text: String) -> Bool {
        let words = wordCount(text)
        if words < 120 { return true }
        guard let last = text.trimmingCharacters(in: .whitespacesAndNewlines).last else { return true }
        return !".!?。！？".contains(last)
    }

    private func wordCount(_ text: String) -> Int {
        text
            .replacingOccurrences(of: "\n", with: " ")
            .split(separator: " ")
            .count
    }

    private func isReadableForecast(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }

        let words = trimmed.split(separator: " ")
        guard words.count >= 45 else { return false }

        let letters = trimmed.unicodeScalars.filter { CharacterSet.letters.contains($0) }.count
        let digits = trimmed.unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }.count
        let total = max(trimmed.unicodeScalars.count, 1)
        let letterRatio = Double(letters) / Double(total)
        let digitRatio = Double(digits) / Double(total)

        let avgWordLength = Double(words.map { $0.count }.reduce(0, +)) / Double(max(words.count, 1))
        let hasPunctuation = trimmed.contains(".") || trimmed.contains(",")

        return letterRatio >= 0.55
            && digitRatio <= 0.12
            && avgWordLength >= 2.8
            && avgWordLength <= 11.5
            && hasPunctuation
    }

    private func fallbackForecastText(for languageIdentifier: String) -> String {
        let code = normalizedLanguageCode(from: languageIdentifier)
        switch code {
        case "es":
            return "Esta semana te conviene bajar el ruido y ordenar prioridades desde el primer día. En trabajo, céntrate en cerrar un frente importante antes del jueves y deja para después lo accesorio: te irá mejor por profundidad que por velocidad. Si surge una conversación incómoda, llévala con datos, calma y un objetivo claro, porque puede desbloquear más de lo que parece. En dinero, evita decisiones impulsivas; revisa suscripciones, gastos pequeños repetidos y cualquier fuga que ya dabas por normal. Un ajuste sencillo te dará margen real de aquí al fin de semana. En amor, funciona la honestidad sin dramatizar: habla claro, escucha sin interrumpir y no des por hecho lo que no se ha dicho. Si algo te inquieta, pregunta con respeto y concreción. Tu mejor estrategia estos días es disciplina amable: menos promesas, más constancia. Llegas al domingo con sensación de orden, más confianza y una dirección bastante más limpia."
        case "ca":
            return "Aquesta setmana et convé reduir soroll i ordenar prioritats des del primer dia. A la feina, centra't a tancar un front important abans de dijous i deixa l'accessori per després: et funcionarà millor la profunditat que la velocitat. Si apareix una conversa incòmoda, porta-la amb dades, calma i un objectiu clar, perquè pot desbloquejar més del que sembla. En diners, evita decisions impulsives; revisa subscripcions, despeses petites repetides i qualsevol fuita que ja donaves per normal. Un ajust simple et donarà marge real de cara al cap de setmana. En amor, funciona l'honestedat sense dramatitzar: parla clar, escolta sense interrompre i no donis per fet allò que no s'ha dit. Si alguna cosa et remou, pregunta amb respecte i concreció. La millor estratègia aquests dies és disciplina amable: menys promeses, més constància. Arribes a diumenge amb sensació d'ordre, més confiança i una direcció molt més neta."
        case "fr":
            return "Cette semaine, ton meilleur levier est de réduire le bruit et de clarifier tes priorités dès le début. Au travail, vise une fermeture importante avant jeudi et évite de te disperser: la profondeur paiera davantage que la vitesse. Si une discussion délicate arrive, avance avec des faits, du calme et une intention claire; cela peut débloquer une situation qui stagnait. Côté argent, freine les achats impulsifs et passe en revue les abonnements, les petites dépenses répétées et les habitudes qui te grignotent sans que tu le voies. Un réglage simple peut déjà alléger la pression d'ici la fin de semaine. En amour, privilégie la sincérité sans dramatiser: parle net, écoute vraiment et ne suppose pas ce qui n'a pas été dit. Si quelque chose te dérange, pose une question précise avec respect. Ta stratégie gagnante maintenant: moins de promesses, plus de constance. D'ici dimanche, tu te sentiras plus aligné, plus stable et nettement plus en contrôle."
        case "de":
            return "Diese Woche gewinnst du am meisten, wenn du Lärm reduzierst und Prioritäten früh sauber setzt. Im Job lohnt sich Fokus: Schließe bis Donnerstag ein wichtiges Thema ab und lass Nebenschauplätze warten. Tiefe schlägt Tempo. Wenn ein schwieriges Gespräch ansteht, geh mit Fakten, Ruhe und klarer Absicht hinein; genau das kann einen festgefahrenen Punkt lösen. Beim Geld sind spontane Entscheidungen jetzt riskant: prüfe Abos, kleine wiederkehrende Ausgaben und Gewohnheiten, die still Ressourcen ziehen. Schon eine kleine Korrektur bringt spürbar Luft bis zum Wochenende. In der Liebe funktioniert Ehrlichkeit ohne Drama am besten: sag klar, hör wirklich zu und unterstelle nichts, was nicht ausgesprochen wurde. Wenn dich etwas beschäftigt, frag direkt und respektvoll nach. Deine beste Linie in diesen Tagen ist freundliche Disziplin: weniger ankündigen, mehr verlässlich umsetzen. Bis Sonntag fühlst du dich geordneter, sicherer und deutlich klarer in deiner Richtung."
        default:
            return "This week works best when you cut noise early and set clear priorities from day one. In work, focus on closing one meaningful objective before Thursday and avoid scattering your energy across low-impact tasks. Depth beats speed right now. If a difficult conversation shows up, lead with facts, calm tone, and a clear intention; it can unlock more than you expect. Financially, avoid impulsive choices and review subscriptions, small recurring expenses, and habits that quietly drain your margin. One practical adjustment can reduce stress by the weekend. In love, honest communication matters more than perfect wording: be direct, listen fully, and do not assume what has not been said. If something feels off, ask one clear question and stay grounded. Your strongest move this week is disciplined consistency: promise less, follow through more. By Sunday, you should feel more organized, more confident, and much clearer about where your energy needs to go next."
        }
    }

}

private struct ForecastCacheKey: Codable, Hashable {
    let profileID: UUID
    let sunSign: String
    let risingSign: String
    let weekOfYear: Int
    let yearForWeekOfYear: Int
    let languageCode: String

    var raw: String {
        "\(profileID.uuidString)|\(sunSign)|\(risingSign)|\(yearForWeekOfYear)-W\(weekOfYear)|\(languageCode)"
    }
}

private actor WeeklyForecastCache {
    static let shared = WeeklyForecastCache()

    private var storage: [String: String]
    private let defaults = UserDefaults.standard

    private init() {
        storage = defaults.dictionary(forKey: DefaultsKeys.weeklyForecastCache) as? [String: String] ?? [:]
    }

    func get(_ key: ForecastCacheKey) -> String? {
        storage[key.raw]
    }

    func set(_ value: String, for key: ForecastCacheKey) {
        storage[key.raw] = value
        while storage.count > 200 {
            if let firstKey = storage.keys.first {
                storage.removeValue(forKey: firstKey)
            } else {
                break
            }
        }
        defaults.set(storage, forKey: DefaultsKeys.weeklyForecastCache)
    }
}

private func withTimeout<T: Sendable>(
    seconds: Double,
    operation: @escaping @Sendable () async -> T
) async -> T? {
    await withTaskGroup(of: T?.self) { group in
        group.addTask {
            await operation()
        }
        group.addTask {
            let ns = UInt64(max(0, seconds) * 1_000_000_000)
            try? await Task.sleep(nanoseconds: ns)
            return nil
        }
        let first = await group.next() ?? nil
        group.cancelAll()
        return first
    }
}

private actor ForecastTranslationService {
    static let shared = ForecastTranslationService()
    private var storage: [String: String]
    private let defaults = UserDefaults.standard

    init() {
        storage = defaults.dictionary(forKey: DefaultsKeys.forecastTranslationCache) as? [String: String] ?? [:]
    }

    func translateFromEnglish(_ text: String, to targetLanguageIdentifier: String) async -> String {
        guard !text.isEmpty else { return text }

#if targetEnvironment(simulator)
        return text
#endif

        let normalized = targetLanguageIdentifier.replacingOccurrences(of: "_", with: "-")
        if normalized.lowercased().hasPrefix("en") {
            return text
        }

        let cacheKey = "\(normalized)|\(stableHash(text))"
        if let cached = storage[cacheKey] {
            return cached
        }

        let source = Locale.Language(identifier: "en")
        let target = Locale.Language(identifier: normalized)

        do {
            let availability = LanguageAvailability()
            let status = await availability.status(from: source, to: target)
            guard status == .installed || status == .supported else {
                return text
            }

            let session = TranslationSession(installedSource: source, target: target)
            let response = try await session.translate(text)
            storage[cacheKey] = response.targetText
            while storage.count > 400 {
                if let firstKey = storage.keys.first {
                    storage.removeValue(forKey: firstKey)
                } else {
                    break
                }
            }
            defaults.set(storage, forKey: DefaultsKeys.forecastTranslationCache)
            return response.targetText
        } catch {
            return text
        }
    }

    private func stableHash(_ value: String) -> String {
        var hash: UInt64 = 1469598103934665603
        for byte in value.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1099511628211
        }
        return String(hash, radix: 16)
    }
}
