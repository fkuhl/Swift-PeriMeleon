//
//  DataCheckReportView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 1/20/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI

struct DataCheckReportView: View {
    var report: DataCheckReport
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(report.name).font(.body)
            Text("status: \(report.status.rawValue), last trans: \(report.trans.rawValue)")
                .font(Font.caption)
        }
    }
}

struct DataCheckReportView_Previews: PreviewProvider {
    static var previews: some View {
        DataCheckReportView(report: DataCheckReport(name: "Hornswoggle, H.", status: .COMMUNING, trans: .DISMISSED))
    }
}
