//
//  YearString.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 10/22/21.
//

import Foundation

/** Current date in ISO format, e.g., 2021-10-22
 **/

func yearStringISO() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: Date())
}
