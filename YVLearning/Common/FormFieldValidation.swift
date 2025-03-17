//
//  FormFieldValidationRule.swift
//  YVLearning
//
//  Created by Yash Vyas on 17-03-2025.
//

import Foundation

@propertyWrapper
struct FormFieldValidation {
    private var value: String
    private let rule: FormFieldValidationRule

    var errorMessage: String?

    init(wrappedValue initialValue: String, rule: FormFieldValidationRule) {
        self.value = initialValue
        self.rule = rule
        self.errorMessage = validate()
    }

    var wrappedValue: String {
        get {
            value
        }
        set {
            value = newValue
            errorMessage = validate()
        }
    }

    var projectedValue: String? {
        return errorMessage
    }

    func validate() -> String? {
        let value = self.value.trimmingCharacters(in: .whitespacesAndNewlines)
        switch rule {
        case .required(let fieldName, let errorMessage):
            let field = fieldName ?? "This field"
            let error = errorMessage ?? "\(field) is required."
            if value.isEmpty { return error }
        case .name(let fieldName, let errorMessage):
            let field = fieldName ?? "Name"
            let error = errorMessage ?? "\(field) is not valid."
            let regEx = "\\w{7,18}"
            if isNotValid(regEx: regEx) { return error }
        case .email(let errorMessage):
            let error = errorMessage ?? "Email is not valid."
            let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            if isNotValid(regEx: regEx) { return error }
        case .password(let errorMessage):
            let error = errorMessage ?? "Password is not valid."
            let regEx = "(?=.*[A-Z].*[A-Z])(?=.*[!@#$&*])(?=.*[0-9].*[0-9])(?=.*[a-z].*[a-z].*[a-z]).{8}"
            /*
             (?=.*[A-Z].*[A-Z])        Ensure string has two uppercase letters.
             (?=.*[!@#$&*])            Ensure string has one special case letter.
             (?=.*[0-9].*[0-9])        Ensure string has two digits.
             (?=.*[a-z].*[a-z].*[a-z]) Ensure string has three lowercase letters.
             .{8}                      Ensure string is of length 8.
             */
            if isNotValid(regEx: regEx) { return error }
        case .custom(let regEx, let fieldName, let errorMessage):
            let field = fieldName ?? "This field"
            let error = errorMessage ?? "\(field) is not valid."
            if isNotValid(regEx: regEx) { return error }
        }
        return nil
    }

    func isNotValid(regEx: String) -> Bool {
        let predicate = NSPredicate(format:"SELF MATCHES %@", regEx)
        return !predicate.evaluate(with: value)
    }
}

enum FormFieldValidationRule {
    case required(fieldName: String? = nil, errorMessage: String? = nil)
    case name(fieldName: String? = nil, errorMessage: String? = nil)
    case email(errorMessage: String? = nil)
    case password(errorMessage: String? = nil)
    case custom(regex: String, fieldName: String? = nil, errorMessage: String? = nil)
}
