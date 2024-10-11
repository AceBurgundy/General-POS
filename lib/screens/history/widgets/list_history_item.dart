import 'package:general_pos/constants.dart';
import 'package:general_pos/models/history.dart';
import 'package:general_pos/utilities/dates.dart';
import 'package:flutter/material.dart';

class ListHistoryCardWidget extends StatefulWidget {
  final History history;
  final void Function(History) addToSelected;
  final void Function(History) removeFromSelected;

  const ListHistoryCardWidget({
    super.key,
    required this.history,
    required this.addToSelected,
    required this.removeFromSelected
  });

  @override
  ListItemWidgetState createState() => ListItemWidgetState();
}

class ListItemWidgetState extends State<ListHistoryCardWidget> {
  bool selected = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(formattedDateTime(widget.history.paidOn.toString())),
      subtitle: Text(asCurrency(widget.history.total!)),
      trailing: Icon(
        selected ? Icons.check_circle : Icons.check_circle_outline,
        color: selected ? Theme.of(context).primaryColor : Colors.grey
      ),
      onTap: () {
        setState(() {
          selected = !selected;

          if (selected) {
            widget.addToSelected(widget.history);
            return;
          }

          widget.removeFromSelected(widget.history);
        });
      }
    );
  }
}
