//
//  Date+Week.swift
//  YVLearning
//
//  Created by Yash Vyas on 24/08/22.
//

import Foundation

extension Date {

    func getWeeksFromCurrentWeekToEndOfTheYear() {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: self)
        guard let lastDayOfTheYear = calendar.date(from: DateComponents(year: currentYear, month: 12, day: 31)) else {
            print("Can not get the weeks of the year.")
            return
        }

        var currentDate = Date()
        while currentDate < lastDayOfTheYear {
            guard let startDay = currentDate.startOfWeek, let endDay = currentDate.endOfWeek else {
                print("Can not get the weeks of the year.")
                return
            }
            print("\(startDay.formatted()) - \(endDay.formatted())")
            guard let nextDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) else {
                print("Can not get the weeks of the year.")
                return
            }
            currentDate = nextDate
        }
    }

    func getWeeksFromCurrentWeekToStartOfTheYear() {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: self)
        guard let startDayOfTheYear = calendar.date(from: DateComponents(year: currentYear, month: 1, day: 1))?.startOfWeek else {
            print("Can not get the weeks of the year.")
            return
        }

        var currentDate = Date()
        while startDayOfTheYear < currentDate {
            guard let startDay = currentDate.startOfWeek, let endDay = currentDate.endOfWeek else {
                print("Can not get the weeks of the year.")
                return
            }
            print("\(startDay.formatted()) - \(endDay.formatted())")
            guard let nextDate = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDate) else {
                print("Can not get the weeks of the year.")
                return
            }
            currentDate = nextDate
        }
    }

    func getWeeksOfYear() {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: self)
        guard let lastDayOfTheYear = calendar.date(from: DateComponents(year: currentYear, month: 12, day: 31)),
        var currentDate = calendar.date(from: DateComponents(year: currentYear, month: 1, day: 1)) else {
            print("Can not get the weeks of the year.")
            return
        }

        while currentDate < lastDayOfTheYear {
            guard let startDay = currentDate.startOfWeek, let endDay = currentDate.endOfWeek else {
                print("Can not get the weeks of the year.")
                return
            }
            print("\(startDay.formatted()) - \(endDay.formatted())")
            guard let nextDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) else {
                print("Can not get the weeks of the year.")
                return
            }
            currentDate = nextDate
        }
    }

    func formatted() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: self)
    }

    var startOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 1, to: sunday)
    }

    var endOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 7, to: sunday)
    }
}
