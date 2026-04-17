---
# Security Practices

**Project**: YVLearning
**Auth Method**: None (local app, no backend auth)
**Input Validation**: Form field validation via property wrapper

---

## Input Validation

### Validation Layer

**Library**: Custom property wrapper `@FormFieldValidation`
**Applied At**: Form fields in views

```swift
// Source: YVLearning/Common/FormFieldValidation.swift:10-36
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
        get { value }
        set {
            value = newValue
            errorMessage = validate()
        }
    }

    var projectedValue: String? {
        return errorMessage
    }

    func validate() -> String? { /* ... */ }
}
```

### Validation Rules

```swift
// Source: YVLearning/Common/FormFieldValidation.swift:78-84
enum FormFieldValidationRule {
    case required(fieldName: String? = nil, errorMessage: String? = nil)
    case name(fieldName: String? = nil, errorMessage: String? = nil)
    case email(errorMessage: String? = nil)
    case password(errorMessage: String? = nil)
    case custom(regex: String, fieldName: String? = nil, errorMessage: String? = nil)
}
```

### Password Requirements

```
Regex: (?=.*[A-Z].*[A-Z])(?=.*[!@#$&*])(?=.*[0-9].*[0-9])(?=.*[a-z].*[a-z].*[a-z]).{8}

Requirements:
- Two uppercase letters
- One special character (!@#$&*)
- Two digits
- Three lowercase letters
- Minimum 8 characters total
```

### Email Validation

```
Regex: [A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}

Validates: basic email format with domain
```

### Rules

- ✅ Validate at form field level using `@FormFieldValidation`
- ✅ Use predefined rules (required, email, password, name) when possible
- ✅ Create custom rules via regex for domain-specific validation
- ❌ Never trust: user input from text fields, pickers, or external sources without validation
- ❌ Don't validate in network layer; validate at input boundary

---

## Regex Usage

```swift
// Source: YVLearning/Common/FormFieldValidation.swift:72-75
func isNotValid(regEx: String) -> Bool {
    let predicate = NSPredicate(format:"SELF MATCHES %@", regEx)
    return !predicate.evaluate(with: value)
}
```

**Pattern**: Use `NSPredicate` with regex for pattern matching. Always validate before processing user input.

---

## Form Field Error Display

```swift
// Usage in SwiftUI view:
@FormFieldValidation(wrappedValue: "", rule: .email())
var email: String

// Access error message via projected value:
if let error = $email {
    Text(error)
        .foregroundStyle(.red)
        .font(.caption)
}
```

---

## Data Security

**Local Storage**: SwiftData encrypts data at rest automatically on iOS 17+

**User Defaults**: Avoid for sensitive data; use SwiftData or Keychain instead

**Passwords**: Never store plaintext; use Keychain services (not implemented in this playground)

---

## Anti-Patterns

| ❌ NEVER | ✅ INSTEAD | Risk |
|----------|-----------|------|
| Trust user input directly | Validate with `@FormFieldValidation` | Data corruption, injection |
| Skip validation in forms | Always validate before saving | Invalid data in database |
| Hardcode regex patterns | Define in `FormFieldValidationRule` | Maintenance burden |
| Mix validation logic in views | Use property wrapper | Code duplication |

---

## Common Validation Patterns

| Field Type | Validation | Example |
|-----------|-----------|---------|
| Email | `.email()` | user@example.com |
| Password | `.password()` | Must meet strength requirements |
| Name | `.name()` | 7-18 alphanumeric characters |
| Required | `.required(fieldName: "Name")` | Non-empty string |
| Custom | `.custom(regex: "pattern")` | Custom regex pattern |

---

## Quick Reference

| Security Need | Location | Pattern |
|---------------|----------|---------|
| Input validation | `YVLearning/Common/FormFieldValidation.swift` | `@FormFieldValidation(rule: .email())` |
| Validation rules | `YVLearning/Common/FormFieldValidation.swift:78-84` | `FormFieldValidationRule` enum |
| Error display | SwiftUI views | `$fieldName` projected value |
| Data storage | `YVLearning/App/YVSwiftDataSchema.swift` | Encrypted via SwiftData |
| Custom regex | `.custom(regex:)` | Define pattern in rule |

---
