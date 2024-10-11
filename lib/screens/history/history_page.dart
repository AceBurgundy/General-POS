import 'package:general_pos/models/history.dart';
import 'package:general_pos/widgets/app_bar.dart';
import 'package:flutter/material.dart';

import '../../utilities/string_constant.dart';
import 'widgets/list_history_item.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  HistoryPageState createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  List<History> history = [];
  List<History> selectedItems = [];

  @override
  void initState() {
    super.initState();
    setItems();
  }

  void _addItemToSelected(History item) {
    setState(() {
      selectedItems.add(item);
    });
  }

  void _removeItemFromSelected(History item) {
    setState(() {
      selectedItems.remove(item);
    });
  }

  void setItems() async {
    List<History> queriedHistories = await Histories.all();

    setState(() {
      history = queriedHistories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.9),
      appBar: const POSAppBar(),
      body: SafeArea(
          child: SizedBox(
            child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (BuildContext context, int index) =>
                    ListHistoryCardWidget(
                      history: history.elementAt(index),
                      addToSelected: _addItemToSelected,
                      removeFromSelected: _removeItemFromSelected,
                    )
            )
          )
      ),
      floatingActionButton: history.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () async {
                String response = await Histories.exportRecords(selectedItems.isNotEmpty ? selectedItems : history);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response)),
                  );
                }
              },
              label: Text(selectedItems.isEmpty ? Texts.exportAll : Texts.exportRecords),
              icon: const Icon(Icons.download_sharp),
            )
          : null
    );
  }
}
