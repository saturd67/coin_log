import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

Future<int?> themedShowYearPicker(BuildContext context, DateTime selectedDateTime) async {
  return await showYearPicker(
    context: context,
    monthPickerDialogSettings: MonthPickerDialogSettings(
        dialogSettings: PickerDialogSettings(
            dialogBackgroundColor: Theme.of(context).colorScheme.secondary
        ),
        headerSettings: PickerHeaderSettings(
            headerBackgroundColor: Theme.of(context).colorScheme.primary,
            headerCurrentPageTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: Theme.of(context).textTheme.headlineLarge!.fontSize
            )
        ),
        dateButtonsSettings: PickerDateButtonsSettings(
            currentYearTextColor: Theme.of(context).colorScheme.onSecondary,
            currentMonthTextColor: Theme.of(context).colorScheme.onSecondary,
            unselectedYearsTextColor: Theme.of(context).textTheme.bodyMedium!.color,
            unselectedMonthsTextColor: Theme.of(context).textTheme.bodyMedium!.color,
            selectedYearTextColor: Theme.of(context).colorScheme.primary,
            selectedMonthTextColor: Theme.of(context).colorScheme.primary
        )
    ),
    initialDate: selectedDateTime,
    firstDate: DateTime(2001),
    lastDate: DateTime(2100),
  );
}