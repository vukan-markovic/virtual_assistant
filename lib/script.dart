//  return InkWell(
//       // When the user taps the button, show a snackbar.
//       onTap: () {
//         Scaffold.of(context).showSnackBar(SnackBar(
//           content: Text('Tap'),
//         ));
//       },
//       child: Container(
//         padding: EdgeInsets.all(12.0),
//         child: Text('Flat Button'),
//       ),
//     );

// ..removeCurrentSnackBar()

// flutter pub upgrade

// flutter build apk --obfuscate --split-debug-info=/<project-name>/<directory>

// Chip(
//   avatar: CircleAvatar(
//     backgroundColor: Colors.grey.shade800,
//     child: Text('AB'),
//   ),
//   label: Text('Aaron Burr'),
// )

// String dropdownValue = 'One';

// @override
// Widget build(BuildContext context) {
//   return DropdownButton<String>(
//     value: dropdownValue,
//     icon: Icon(Icons.arrow_downward),
//     iconSize: 24,
//     elevation: 16,
//     style: TextStyle(
//       color: Colors.deepPurple
//     ),
//     underline: Container(
//       height: 2,
//       color: Colors.deepPurpleAccent,
//     ),
//     onChanged: (String newValue) {
//       setState(() {
//         dropdownValue = newValue;
//       });
//     },
//     items: <String>['One', 'Two', 'Free', 'Four']
//       .map<DropdownMenuItem<String>>((String value) {
//         return DropdownMenuItem<String>(
//           value: value,
//           child: Text(value),
//         );
//       })
//       .toList(),
//   );
// // }

//  body: const WebView(
//         initialUrl: 'https://flutter.io',
//         javascriptMode: JavascriptMode.unrestricted,
//       ),

// class _SectionedMenuDemo extends StatelessWidget {
//   const _SectionedMenuDemo({Key key, this.showInSnackBar}) : super(key: key);

//   final void Function(String value) showInSnackBar;

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text(
//           GalleryLocalizations.of(context).demoMenuAnItemWithASectionedMenu),
//       trailing: PopupMenuButton<String>(
//         padding: EdgeInsets.zero,
//         onSelected: (value) => showInSnackBar(
//             GalleryLocalizations.of(context).demoMenuSelected(value)),
//         itemBuilder: (context) => <PopupMenuEntry<String>>[
//           PopupMenuItem<String>(
//             value: GalleryLocalizations.of(context).demoMenuPreview,
//             child: ListTile(
//               leading: Icon(Icons.visibility),
//               title: Text(
//                 GalleryLocalizations.of(context).demoMenuPreview,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

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

// CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor))
