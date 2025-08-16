abstract class BaseModel<FormModel> {
  Map<String, dynamic> toMap();

  FormModel toFormModel();
}