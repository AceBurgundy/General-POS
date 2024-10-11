import 'package:flutter/material.dart';
import 'package:general_pos/app_name.dart';
import 'package:general_pos/theme.dart';
import 'package:general_pos/utilities/export.dart';
import 'package:general_pos/utilities/string_constant.dart';
import 'package:provider/provider.dart';

import '../../utilities/providers/theme.dart';
import '../../widgets/icon_button.dart';

InkWell themeSelector(BuildContext context, AppThemeColor color, Color boxColor) {
  // Get the current theme from the ThemeProvider
  final theme = Provider.of<ThemeProvider>(context).themeData;
  bool isSelected = theme.primaryColor == boxColor;

  return InkWell(
    onTap: () async {
      AppTheme.setThemeColor(color);

      Provider.of<ThemeProvider>(context, listen: false).setTheme(
        await AppTheme.getThemeData(),
      );
    },
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    child: Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: boxColor,
        shape: BoxShape.circle,
          border: !isSelected ? null : Border.all(
            color: Colors.black,
            width: 3.0,
          )
      )
    )
  );
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _appNameController = TextEditingController();
  String? _initialAppName;
  String? saveDirectory;
  bool _isEditingAppName = false;
  bool _isLoading = true; // Loading flag

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    String? appName = await AppName.get();
    _initialAppName = appName;
    _appNameController.text = appName ?? '';
    saveDirectory = await getSavedDirectory();

    setState(() {
      _isLoading = false; // Set loading to false once data is loaded
    });
  }

  void _toggleEditAppName(bool isEditing) {
    setState(() {
      _isEditingAppName = isEditing;

      if (isEditing) {
        FocusScope.of(context).requestFocus(_appNameFocusNode);
      } else {
        FocusScope.of(context).unfocus();
      }
    });
  }

  final FocusNode _appNameFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    AppBar basicAppBar = AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      title: const Text(Texts.settings),
      foregroundColor: Colors.grey[900],
      backgroundColor: Colors.white,
      actions: const [],
    );

    TextField appNameInput = TextField(
      textAlign: TextAlign.center,
      controller: _appNameController,
      focusNode: _appNameFocusNode,
      style: const TextStyle(fontSize: 15),
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
      ),
    );

    ListTile setAppName = ListTile(
      leading: const Icon(Icons.text_fields),
      title: const Text(Texts.appName),
      subtitle: SizedBox(
        height: 40,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: appNameInput,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_isEditingAppName)
            AppIconButton(
              onPressed: () {
                _toggleEditAppName(true);
              },
              icon: Icons.edit,
            ),
          if (_isEditingAppName) ...[
            AppIconButton(
              onPressed: () {
                _appNameController.text = _initialAppName ?? Texts.appName; // Reset to original app name
                _toggleEditAppName(false);
              },
              icon: Icons.cancel,
            ),
            const SizedBox(width: 10),
            AppIconButton(
              onPressed: () async {
                if (_appNameController.text == '') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(Texts.appNameCannotBeEmpty)),
                  );
                  return;
                }

                await AppName.set(_appNameController.text);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(Texts.newAppNameSaved)),
                  );
                }

                _toggleEditAppName(false);
              },
              icon: Icons.save,
            ),
          ]
        ],
      ),
    );

    ListTile setSaveDirectory = ListTile(
      leading: const Icon(Icons.import_export),
      title: const Text(Texts.exportFolder),
      subtitle: Text(saveDirectory ?? Texts.chooseAnExportFolder),
      trailing: ElevatedButton(
        onPressed: () async {
          String? directory = await updateSaveDirectory();

          setState(() {
            saveDirectory = directory;
          });
        },
        child: const Text(Texts.change),
      ),
    );

    ListTile setThemeColor = ListTile(
      leading: const Icon(Icons.palette),
      title: const Text("Theme"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          themeSelector(context, AppThemeColor.orange, AppTheme.orangeTheme.primaryColor),
          const SizedBox(width: 10),
          themeSelector(context, AppThemeColor.red, AppTheme.redTheme.primaryColor),
          const SizedBox(width: 10),
          themeSelector(context, AppThemeColor.green, AppTheme.greenTheme.primaryColor),
          const SizedBox(width: 10),
          themeSelector(context, AppThemeColor.purple, AppTheme.purpleTheme.primaryColor),
        ],
      ),
    );

    return Scaffold(
      appBar: basicAppBar,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : ListView(
        children: [setAppName, setSaveDirectory, setThemeColor],
      ),
    );
  }
}
