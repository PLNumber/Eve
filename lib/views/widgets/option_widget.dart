// lib/views/widgets/option_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/gen_l10n/app_localizations.dart';
import '../../provider/audio_provider.dart';
import '../../provider/local_provider.dart';
import '../../provider/quiz_mode_provider.dart';
import '../../provider/theme_provider.dart';
import 'nav_util.dart';
import '../../viewModel/option_view_model.dart';

//옵션 타일
class OptionTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const OptionTile({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(title), onTap: onTap);
  }
}

// 소리 다이얼로그
class SoundDialog {
  static void show(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    final local = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textColor = isDark ? Colors.white : Colors.black87;

    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: EdgeInsets.all(screenWidth * 0.05),
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Consumer<AudioProvider>(
                builder: (context, audio, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _dialogHeader(
                        context,
                        Icons.music_note,
                        local.sound_settings,
                        textColor,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      SwitchListTile(
                        title: Text(
                          local.sound_on,
                          style: TextStyle(color: textColor, fontSize: screenWidth * 0.03,),
                        ),
                        value: audio.isPlaying,
                        onChanged: (_) => audio.togglePlay(),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        local.select_music,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          fontSize: screenWidth * 0.03,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.001),
                      DropdownButton<String>(
                        value: audio.currentMusic,
                        isExpanded: true,
                        dropdownColor: isDark ? Colors.grey[900] : Colors.white,
                        items:
                            audio.musicList.map((music) {
                              return DropdownMenuItem<String>(
                                value: music,
                                child: Text(
                                  music.replaceAll('.mp3', ''),
                                  style: TextStyle(color: textColor, fontSize: screenWidth * 0.02,),
                                ),
                              );
                            }).toList(),
                        onChanged: (newMusic) {
                          if (newMusic != null) {
                            audio.changeMusic(newMusic);
                          }
                        },
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        "${local.volume_level}: ${(audio.volume * 10).round()} / 10",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          fontSize: screenWidth * 0.025
                        ),
                      ),
                      Slider(
                        value: audio.volume,
                        min: 0,
                        max: 1,
                        divisions: 10,
                        onChanged: (value) => audio.setVolume(value),
                        activeColor: Colors.indigo,
                        inactiveColor: Colors.indigo.withOpacity(0.3),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.check, color: Colors.white, size: screenWidth * 0.02,),
                          label: Text(
                            local.close,
                            style: TextStyle(color: Colors.white,fontSize: screenWidth * 0.02,),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.01,
                              horizontal: screenWidth * 0.05,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
    );
  }

  static Widget _dialogHeader(BuildContext context,IconData icon, String title, Color textColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Icon(icon, color: Colors.indigo, size: screenWidth * 0.06,),
        SizedBox(width: screenWidth * 0.01),
        Text(
          title,
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

// 언어 다이얼로그
class LanguageDialog {
  static void show(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double fontSize = screenWidth * 0.03;
    final double headerFontSize = screenWidth * 0.05;
    final double iconSize = screenWidth * 0.06;
    final double spacing = screenHeight * 0.01;
    final double paddingValue = screenWidth * 0.05;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: EdgeInsets.all(paddingValue),
        child: Padding(
          padding: EdgeInsets.all(paddingValue),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dialogHeader(
                Icons.language,
                local.language_selection,
                textColor,
                headerFontSize,
                iconSize,
              ),
              SizedBox(height: spacing),
              _languageOption(
                context,
                icon: Icons.flag,
                label: local.korean,
                onTap: () {
                  localeProvider.setLocale("ko");
                  Navigator.pop(context);
                },
                textColor: textColor,
                fontSize: fontSize,
              ),
              SizedBox(height: spacing),
              _languageOption(
                context,
                icon: Icons.flag_outlined,
                label: local.english,
                onTap: () {
                  localeProvider.setLocale("en");
                  Navigator.pop(context);
                },
                textColor: textColor,
                fontSize: fontSize,
              ),
              SizedBox(height: spacing * 1.5),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.white, size: iconSize * 0.9),
                  label: Text(
                    local.close,
                    style: TextStyle(color: Colors.white, fontSize: fontSize),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: spacing * 0.7,
                      horizontal: screenWidth * 0.05,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _dialogHeader(
      IconData icon,
      String title,
      Color textColor,
      double fontSize,
      double iconSize,
      ) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo, size: iconSize),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _languageOption(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
        required Color textColor,
        required double fontSize,
      }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03,
          vertical: screenWidth * 0.015,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: screenWidth * 0.05),
            SizedBox(width: screenWidth * 0.03),
            Text(label, style: TextStyle(fontSize: fontSize, color: textColor)),
          ],
        ),
      ),
    );
  }
}

// 배경 다이얼로그
class BackgroundDialog {
  static void show(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final local = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double fontSize = screenWidth * 0.03;
    final double headerFontSize = screenWidth * 0.05;
    final double iconSize = screenWidth * 0.06;
    final double spacing = screenHeight * 0.01;
    final double paddingValue = screenWidth * 0.05;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: EdgeInsets.all(paddingValue),
        child: Padding(
          padding: EdgeInsets.all(paddingValue),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dialogHeader(
                Icons.palette,
                local.change_background,
                textColor,
                headerFontSize,
                iconSize,
              ),
              SizedBox(height: spacing),
              _themeOption(
                context,
                icon: Icons.wb_sunny_outlined,
                label: local.default_background,
                onTap: () {
                  themeProvider.setTheme(ThemeMode.light);
                  Navigator.pop(context);
                },
                textColor: textColor,
                fontSize: fontSize,
              ),
              SizedBox(height: spacing * 0.01),
              _themeOption(
                context,
                icon: Icons.nightlight_round,
                label: local.dark_background,
                onTap: () {
                  themeProvider.setTheme(ThemeMode.dark);
                  Navigator.pop(context);
                },
                textColor: textColor,
                fontSize: fontSize,
              ),
              SizedBox(height: spacing * 1.5),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.white, size: iconSize * 0.9),
                  label: Text(
                    local.close,
                    style: TextStyle(color: Colors.white, fontSize: fontSize),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: spacing * 0.7,
                      horizontal: screenWidth * 0.05,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _dialogHeader(
      IconData icon,
      String title,
      Color textColor,
      double fontSize,
      double iconSize,
      ) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo, size: iconSize),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _themeOption(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
        required Color textColor,
        required double fontSize,
      }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03,
          vertical: screenWidth * 0.015,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: screenWidth * 0.05),
            SizedBox(width: screenWidth * 0.03),
            Text(label, style: TextStyle(fontSize: fontSize, color: textColor)),
          ],
        ),
      ),
    );
  }
}

// 닉네임 다이얼로그
class NicknameDialog {
  static void show(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    final viewModel = Provider.of<OptionViewModel>(context, listen: false);
    final local = AppLocalizations.of(context)!;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double fontSize = screenWidth * 0.045;
    final double headerFontSize = screenWidth * 0.05;
    final double iconSize = screenWidth * 0.06;
    final double spacing = screenHeight * 0.01;
    final double paddingValue = screenWidth * 0.05;

    String message = '';
    bool? isAvailable;

    void checkNickname(BuildContext dialogContext) async {
      final nickname = _controller.text.trim();
      final result = await viewModel.checkNicknameAvailable(nickname);
      isAvailable = result == null;
      message = result ?? local.nickname_available;
      (dialogContext as Element).markNeedsBuild();
    }

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: EdgeInsets.all(paddingValue),
        child: Padding(
          padding: EdgeInsets.all(paddingValue),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dialogHeader(
                    Icons.person,
                    local.change_nickname,
                    textColor,
                    headerFontSize,
                    iconSize,
                  ),
                  SizedBox(height: spacing),
                  TextField(
                    controller: _controller,
                    style: TextStyle(color: textColor, fontSize: fontSize * 0.5),
                    decoration: InputDecoration(
                      hintText: local.nickname_placeholder,
                      hintStyle: TextStyle(color: textColor.withOpacity(0.5), fontSize: fontSize * 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.edit, size: iconSize * 0.5),
                    ),
                  ),
                  SizedBox(height: spacing),
                  ElevatedButton.icon(
                    onPressed: () => checkNickname(dialogContext),
                    icon: Icon(Icons.search, color: Colors.white, size: iconSize * 0.8),
                    label: Text(
                      local.check_duplicate,
                      style: TextStyle(color: Colors.white, fontSize: fontSize* 0.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: spacing * 0.6),
                  if (message.isNotEmpty)
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: fontSize * 0.95,
                        color: isAvailable == true ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  SizedBox(height: spacing * 1.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.cancel, color: textColor, size: iconSize * 0.5),
                        label: Text(
                          local.cancel,
                          style: TextStyle(color: textColor, fontSize: fontSize * 0.5),
                        ),
                      ),
                      SizedBox(width: spacing),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final nickname = _controller.text.trim();
                          if (isAvailable != true) {
                            showSavedSnackBar(context, message: local.nickname_check_prompt);
                            return;
                          }
                          await viewModel.updateNickname(nickname);
                          Navigator.pop(context);
                          showSavedSnackBar(context, message: local.nickname_success);
                        },
                        icon: Icon(Icons.check, color: Colors.white, size: iconSize * 0.5),
                        label: Text(
                          local.confirm,
                          style: TextStyle(color: Colors.white, fontSize: fontSize * 0.5),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static Widget _dialogHeader(
      IconData icon,
      String title,
      Color textColor,
      double fontSize,
      double iconSize,
      ) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo, size: iconSize),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
