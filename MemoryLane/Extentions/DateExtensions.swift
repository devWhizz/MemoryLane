//
//  DateExtensions.swift
//  MemoryLane
//
//  Created by martin on 14.03.24.
//

import Foundation


extension Date {
    
    // Get a formatted month-year string from a date
    func monthYearString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self)
    }
    
}

extension String {
    
    // Compare two month-year strings for sorting
    func compareMonthYearStrings(_ otherString: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        
        if let date1 = formatter.date(from: self), let date2 = formatter.date(from: otherString) {
            return date1 > date2
        }
        return false
    }
    
}
