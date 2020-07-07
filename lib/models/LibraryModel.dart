class LibraryModel {
  final String name;
  final String issue_date;
  final String return_date;
  final String rfid;
  final bool isOverdue;
  final bool isnotDue;

  LibraryModel(this.name, this.issue_date, this.return_date, this.rfid,
      this.isOverdue, this.isnotDue);
}
