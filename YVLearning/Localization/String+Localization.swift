//
//  String+Localization.swift
//  YVLearning
//
//  Created by Yash Vyas on 07/11/22.
//

import Foundation

extension String {
    func localized(comment: String = "") -> Self {
        NSLocalizedString(self, comment: comment)
    }

    func localizedFormat(_ arguments: CVarArg..., comment: String = "") -> Self {
        // String(format: self.localized(comment: comment), arguments: arguments)
        String.localizedStringWithFormat(self.localized(comment: comment), arguments)
    }
}

postfix operator ~
postfix func ~ (string: String) -> String {
    return NSLocalizedString(string, comment: "")
}
