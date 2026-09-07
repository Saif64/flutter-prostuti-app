import 'package:flutter/material.dart';

import '../../../../../common/widgets/time_converter.dart';

class TrailingIcon extends StatefulWidget {
  final String classDate;
  final bool isCompleted;

  const TrailingIcon(
      {super.key, required this.classDate, required this.isCompleted});

  @override
  State<TrailingIcon> createState() => _TrailingIconState();
}

class _TrailingIconState extends State<TrailingIcon> {
  @override
  Widget build(BuildContext context) {
    DateTime parsedDate = TimeConverter.toDhakaTime(DateTime.parse(widget.classDate));
    DateTime now = TimeConverter.nowInDhaka();

    if (parsedDate.day == now.day &&
        parsedDate.month == now.month &&
        parsedDate.year == now.year &&
        !widget.isCompleted) {
      // Today's class
      return Icon(
        Icons.circle_outlined,
        color: Colors.grey.shade700,
        size: 20,
      );
    } else if (parsedDate.isBefore(now) && !widget.isCompleted) {
      return Icon(
        Icons.circle_outlined,
        color: Colors.grey.shade700,
        size: 20,
      );
    } else if (parsedDate.day == now.day &&
        parsedDate.month == now.month &&
        parsedDate.year == now.year &&
        widget.isCompleted) {
      return const Icon(
        Icons.check_circle,
        color: Colors.blue,
        size: 20,
      );
    } else if (parsedDate.isBefore(now) && widget.isCompleted) {
      return const Icon(
        Icons.check_circle,
        color: Colors.blue,
        size: 20,
      );
    } else {
      return Icon(
        Icons.lock_outline_rounded,
        color: Colors.grey.shade700,
        size: 20,
      );
    }
  }
}
