// flutter build apk --obfuscate --split-debug-info=/<project-name>/<directory>
// CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor))

//   int indexSelected = -1;

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Wrap(
//         children: [
//           ChoiceChip(
//             label: Text(GalleryLocalizations.of(context).chipSmall),
//             selected: indexSelected == 0,
//             onSelected: (value) {
//               setState(() {
//                 indexSelected = value ? 0 : -1;
//               });
//             },
//           ),
//           SizedBox(width: 8),
//           ChoiceChip(
//             label: Text(GalleryLocalizations.of(context).chipMedium),
//             selected: indexSelected == 1,
//             onSelected: (value) {
//               setState(() {
//                 indexSelected = value ? 1 : -1;
//               });
//             },
//           ),
//           SizedBox(width: 8),
//           ChoiceChip(
//             label: Text(GalleryLocalizations.of(context).chipLarge),
//             selected: indexSelected == 2,
//             onSelected: (value) {
//               setState(() {
//                 indexSelected = value ? 2 : -1;
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// void _openGoogleMapsStreetView() {
//     final AndroidIntent intent = AndroidIntent(
//         action: 'action_view',
//         data: Uri.encodeFull('google.streetview:cbll=46.414382,10.013988'),
//         package: 'com.google.android.apps.maps');
//     intent.launch();
//   }

//   void _displayMapInGoogleMaps({int zoomLevel = 12}) {
//     final AndroidIntent intent = AndroidIntent(
//         action: 'action_view',
//         data: Uri.encodeFull('geo:37.7749,-122.4194?z=$zoomLevel'),
//         package: 'com.google.android.apps.maps');
//     intent.launch();
//   }

//   void _launchTurnByTurnNavigationInGoogleMaps() {
//     final AndroidIntent intent = AndroidIntent(
//         action: 'action_view',
//         data: Uri.encodeFull(
//             'google.navigation:q=Taronga+Zoo,+Sydney+Australia&avoid=tf'),
//         package: 'com.google.android.apps.maps');
//     intent.launch();
//   }

//   void _openLinkInGoogleChrome() {
//     final AndroidIntent intent = AndroidIntent(
//         action: 'action_view',
//         data: Uri.encodeFull('https://flutter.io'),
//         package: 'com.android.chrome');
//     intent.launch();
//   }

//   void _startActivityInNewTask() {
//     final AndroidIntent intent = AndroidIntent(
//       action: 'action_view',
//       data: Uri.encodeFull('https://flutter.io'),
//       flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
//     );
//     intent.launch();
//   }

//   void _testExplicitIntentFallback() {
//     final AndroidIntent intent = AndroidIntent(
//         action: 'action_view',
//         data: Uri.encodeFull('https://flutter.io'),
//         package: 'com.android.chrome.implicit.fallback');
//     intent.launch();
//   }

//   void _openLocationSettingsConfiguration() {
//     final AndroidIntent intent = const AndroidIntent(
//       action: 'action_location_source_settings',
//     );
//     intent.launch();
//   }

//   void _openApplicationDetails() {
//     final AndroidIntent intent = const AndroidIntent(
//       action: 'action_application_details_settings',
//       data: 'package:io.flutter.plugins.androidintentexample',
//     );
//     intent.launch();
//   }