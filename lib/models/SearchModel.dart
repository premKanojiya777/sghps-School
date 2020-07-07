class SearchModel{
  final String attach;
  final String task;

  SearchModel(this.attach,this.task);
}


// class SearchModel {
//   String task;
//   String attach;
//   bool error;
  

//   SearchModel({
//     this.task,
//     this.attach,
//     this.error,
//   });

//   factory SearchModel.fromJson(Map<String, dynamic> parsedJson) {
//     return SearchModel(
//         error: parsedJson['error'] as bool,
//         task: parsedJson['task'] as String,
//         attach: parsedJson['attach'] as String,
//     );
//   }
// }