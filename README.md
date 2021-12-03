#Swift PeriMeleon
PeriMeleon admin app, intended for the clerk and pastors. 

##Document-Based
Document-based, like the Java version.
This means that a database is a file that the app opens.
The app conforms to the SwiftUI document-based app paradigm,
specifically the ReferenceFileDocument approach.
See [*Building a Document-Based App with SwiftUI*](https://developer.apple.com/documentation/swiftui/building_a_document-based_app_with_swiftui)
The document type is `PeriMeleonDocument`, which implements the `ReferenceFileDocument` protocol.

##PeriMeleon documents are encrypted at rest.
The PeriMeleon document type is encrypted JSON, so it's just data to the OS.
The app remembers in the device's keychain the last key used to open a document.
When the app opens a document it looks in the device's keychain for a key.
If the app finds a key in the keychain, it will attempt to decrypt the document with it.
If there is no key in the keychain, or if the decrypt is unsuccessful, the app
prompts for a new password.
On a successful decrypt the app stores the successful key in the device's keychain.

If the user asks for a "new" document, the app will create a blank database with
just the necessary admin entries.

##Software and configfuration requirements
Uses SwiftUI 2, so requires iOS 14 and macOS 11.
It doesn't use async/await (Swift 5.5) so remains compatible with iOS 14 and macOS 11.

To enable Mac Calayst framework, so the app can run on the Mac,
I had to enable Mac support on the *iOS target*.

On the iOS target, under Info tab, note additions to Document Types, Esported Type Identifiers, and Imported Type Identifiers.

Also: under "App Sandbox", enable read/write access on File Access,
User Selected File.

In PeriMeleon.entitlements, add keychain access.

##Importing from previous PeriMeleon
The program PMImporter can be used to take JSON from the previous, Java-based PeriMeleon
and create a document that this program can open.
(Note that a password has to be specified for the document when you run PMImporter.)
