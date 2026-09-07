// category_constant.dart
//
// The student categories the backend accepts.
//
// `POST /auth/register-student` validates `categoryType` against exactly this
// enum (`Academic | Admission | Job`) and rejects anything else with a 400.
// There is no endpoint that serves this list — `/category/main` and
// `/category/sub/{main}` do not exist — so this is the source of truth.
//
// The backend has no concept of a sub-category: `subCategory` and `categoryId`
// are not in the register schema and are dropped if sent.

class MainCategory {
  static const String ACADEMIC = "Academic";
  static const String ADMISSION = "Admission";
  static const String JOB = "Job";

  static const List<String> values = [ACADEMIC, ADMISSION, JOB];
}
