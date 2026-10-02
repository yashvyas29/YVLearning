//
//  ObservationView.swift
//  YVLearning
//
//  Created by Yash Vyas on 18-05-2026.
//

import SwiftUI

@available(iOS 17.0, *)
struct ObservationView: View {

    @Bindable var observationVM: ObservationViewModel

    var body: some View {
        VStack {
            Text("Observation")
                .font(.title)
            Text(observationVM.fullName)
                .font(.title2)
            VStack {
                ClearableTextField(placeholder: "First name", text: $observationVM.firstName)
                ClearableTextField(placeholder: "Last name", text: $observationVM.lastName)
            }
            .multilineTextAlignment(.center)
            .font(.title3)
        }
        .padding()
    }
}

@available(iOS 17.0, *)
@Observable
class ObservationViewModel {
    var firstName = "Yash"
    var lastName = "Vyas"
    @ObservationIgnored var id = "1"

    var fullName: String {
        firstName + " " + lastName
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @Bindable var observationVM: ObservationViewModel = .init()
    ObservationView(observationVM: observationVM)
}
