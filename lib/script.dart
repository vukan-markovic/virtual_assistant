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
