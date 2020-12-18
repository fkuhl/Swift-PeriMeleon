#Swift PeriMeleon

PeriMeleon admin app, intended for the clerk and pastors. 
Document-based, like the Java version.
This means that a database is a file that the app opens.
The PeriMeleon document type is encrypted JSON, so it's just data to the OS.
The app remembers in the device's keychain the last key used to open a document.
When the app opens a document it looks in the device's keychain for a key.
If the app finds a key in the keychain, it will attempt to decrypt the document with it.
If there is no key in the keychain, or if the decrypt is unsuccessful, the app
prompts for a new password.
On a successful decrypt the app stores the successful key in the device's keychain.

If the user asks for a "new" document the app will create a blank database with
just the necessary admin entries.

The program PMImporter can be used to take JSON from the previous, Java-based  PeriMeleon
and create a document that this program can open.
(Note that a password has to be specified for the document when you run PMImporter.)

Uses SwiftUI 2, so requires iOS 14 and macOS 11.
