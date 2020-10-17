//
//  DataCheckReport.swift
//  PMClient
//
//  Created by Frederick Kuhl on 1/20/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import Foundation
import PMDataTypes

struct DataCheckReport {
    let name: String
    let status: MemberStatus
    let trans: TransactionType
}
