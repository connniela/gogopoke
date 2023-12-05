//
//  SystemLocaleUtil.swift
//  GogoPoke
//
//  Created by Connie Chang on 2023/12/4.
//

import Foundation

class SystemLocaleUtil {
    
    static func deviceLocaleName() -> String {
        if let systemLocale = Locale.preferredLanguages.first {
            if systemLocale.hasPrefix("zh-Hant") || systemLocale.hasPrefix("zh-TW") {
                return "zh-Hant"
            }
            if systemLocale.hasPrefix("zh-Hans") || systemLocale.hasPrefix("zh-CN") {
                return "zh-Hans"
            }
            if let prefix = systemLocale.components(separatedBy: "-").first {
                return prefix
            }
        }
        return "en"
    }
}
