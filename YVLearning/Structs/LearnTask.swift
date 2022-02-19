//
//  LearnTask.swift
//  YVLearning
//
//  Created by Yash Vyas on 12/02/22.
//

import Foundation

struct LearnTask {
    init() {
        Task {
            DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
                debugPrint("In dispatch after.")
            }
            try await Task.sleep(nanoseconds: 2_000_000_000)
            debugPrint("In task.")
        }
        debugPrint("Outside of task.")
    }
}
