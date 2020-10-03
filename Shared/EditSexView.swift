//
//  EditSexView.swift
//  PMClient
//  The name of this file, and its struct, should not be construed as an assertion
//  that a person's sex is "editable."
//  Created by Frederick Kuhl on 5/18/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

struct EditTransactionTypeView: View {
    var captionWidth: CGFloat = defaultCaptionWidth
    var caption: String
    @Binding var transactionType: TransactionType
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(caption)
                .frame(width: captionWidth, alignment: .trailing)
                .font(.caption)
            Picker(selection: $transactionType, label: Text("")) {
                ForEach (TransactionType.allCases, id: \.self) {
                    //Don't forget the tag!
                    Text($0.rawValue).font(.body).tag($0)
                }
            }
        }
    }
}

struct EditServiceTypeView: View {
    var captionWidth: CGFloat = defaultCaptionWidth
    var caption: String
    @Binding var serviceType: ServiceType
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(caption)
                .frame(width: captionWidth, alignment: .trailing)
                .font(.caption)
            Picker(selection: $serviceType, label: Text("")) {
                ForEach (ServiceType.allCases, id: \.self) {
                    //Don't forget the tag!
                    Text($0.rawValue).font(.body).tag($0)
                }
            }
        }
    }
}

struct EditSexView: View {
    var captionWidth: CGFloat = defaultCaptionWidth
    var caption: String
    @Binding var sex: Sex
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(caption)
                .frame(width: captionWidth, alignment: .trailing)
                .font(.caption)
            Picker(selection: $sex, label: Text("")) {
                ForEach (Sex.allCases, id: \.self) {
                    //Don't forget the tag!
                    Text($0.rawValue).font(.body).tag($0)
                }
            }
        }
    }
}

struct EditMemberStatusView: View {
    var captionWidth: CGFloat = defaultCaptionWidth
    var caption: String
    @Binding var memberStatus: MemberStatus
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(caption)
                .frame(width: captionWidth, alignment: .trailing)
                .font(.caption)
            Picker(selection: $memberStatus, label: Text("")) {
                ForEach (MemberStatus.allCases, id: \.self) {
                    //Don't forget the tag!
                    Text($0.rawValue).font(.body).tag($0)
                }
            }
        }
    }
}

struct EditMaritalStatusView: View {
    var captionWidth: CGFloat = defaultCaptionWidth
    var caption: String
    @Binding var maritalStatus: MaritalStatus
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(caption)
                .frame(width: captionWidth, alignment: .trailing)
                .font(.caption)
            Picker(selection: $maritalStatus, label: Text("")) {
                ForEach (MaritalStatus.allCases, id: \.self) {
                    //Don't forget the tag!
                    Text($0.rawValue).font(.body).tag($0)
                }
            }
        }
    }
}

//struct EditSexView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditSexView()
//    }
//}
