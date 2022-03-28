//
//  FileView.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 3/28/22.
//

import SwiftUI

enum FileLink {
    case information
    case changePassword
    case memberHouseholdChecker
    case dataChecker
}

struct FileView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @State private var linkSelection: FileLink? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink(destination: InformationView().environmentObject(document),
                           tag: .information,
                           selection: $linkSelection) {
                LinkButton(linkSelection: $linkSelection,
                           link: .information,
                           label: "Information")
            }
            Caption(text: "Statistics on the data; app build information.")
        }
#if targetEnvironment(macCatalyst)
        .padding(.bottom, 10)
#endif
        VStack(alignment: .leading) {
            NavigationLink(destination: MemberHouseholdCheckerView().environmentObject(document),
                           tag: .memberHouseholdChecker,
                           selection: $linkSelection) {
                LinkButton(linkSelection: $linkSelection, link: .memberHouseholdChecker, label: "Member-household consistency")
            }
            Caption(text: "For each active member, check that they are a member of that household and that household only.")
        }
#if targetEnvironment(macCatalyst)
        .padding(.bottom, 10)
#endif
        VStack(alignment: .leading) {
            NavigationLink(destination: dataCheckerView,
                           tag: .dataChecker,
                           selection: $linkSelection) {
                LinkButton(linkSelection: $linkSelection, link: .dataChecker, label: "Status-transaction consistency")
            }
            Caption(text: "For each active member, check that member's status "
                    + "and last transaction are consistent.")
        }
#if targetEnvironment(macCatalyst)
        .padding(.bottom, 10)
#endif
        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    linkSelection = .changePassword
                    document.state = .newPassword
                }) {
                    Text("Change password \(Image(systemName: "chevron.forward"))")
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(10)
                }
                Spacer()
            }
            Caption(text: "Change passwoprd of current file")
        }
#if targetEnvironment(macCatalyst)
        .padding(.bottom, 10)
#endif
    }
    
    fileprivate struct LinkButton: View {
        @Binding var linkSelection: FileLink?
        var link: FileLink
        var label: String
        
        var body: some View {
            HStack {
                Button(action: { linkSelection = link }) {
                    Text("\(label) \(Image(systemName: "chevron.forward"))")
                        .font(.body)
                    ///https://stackoverflow.com/questions/56593120/how-do-you-create-a-multi-line-text-inside-a-scrollview-in-swiftui/56604599#56604599
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(10)
                }
                Spacer()
            }
        }
    }
    
    fileprivate struct Caption: View {
        var text: String
        
        var body: some View {
            Text(text)
                .font(.caption)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(10)
        }
    }
    
    private var dataCheckerView: some View {
        return DataCheckerView(dataChecker: DataChecker(document: document))
    }
}

struct FileView_Previews: PreviewProvider {
    static var previews: some View {
        FileView()
            .previewLayout(PreviewLayout.fixed(width: 1024, height: 768))
            .environmentObject(mockDocument)
    }
}
