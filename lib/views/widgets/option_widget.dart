// lib/views/widgets/option_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/gen_l10n/app_localizations.dart';
import '../../provider/audio_provider.dart';
import '../../provider/local_provider.dart';
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
    final textColor = isDark ? Colors.white : Colors.black87;

    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Consumer<AudioProvider>(
                builder: (context, audio, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _dialogHeader(
                        Icons.music_note,
                        local.sound_settings,
                        textColor,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: Text(
                          local.sound_on,
                          style: TextStyle(color: textColor),
                        ),
                        value: audio.isPlaying,
                        onChanged: (_) => audio.togglePlay(),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        local.select_music,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
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
                                  style: TextStyle(color: textColor),
                                ),
                              );
                            }).toList(),
                        onChanged: (newMusic) {
                          if (newMusic != null) {
                            audio.changeMusic(newMusic);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "${local.volume_level}: ${(audio.volume * 10).round()} / 10",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textColor,
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
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: Text(
                            local.close,
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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

  static Widget _dialogHeader(IconData icon, String title, Color textColor) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
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

    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dialogHeader(
                    Icons.language,
                    local.language_selection,
                    textColor,
                  ),
                  const SizedBox(height: 16),
                  _languageOption(
                    context,
                    icon: Icons.flag,
                    label: local.korean,
                    onTap: () {
                      localeProvider.setLocale("ko");
                      Navigator.pop(context);
                    },
                    textColor: textColor,
                  ),
                  const SizedBox(height: 12),
                  _languageOption(
                    context,
                    icon: Icons.flag_outlined,
                    label: local.english,
                    onTap: () {
                      localeProvider.setLocale("en");
                      Navigator.pop(context);
                    },
                    textColor: textColor,
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: Text(
                        local.close,
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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

  static Widget _dialogHeader(IconData icon, String title, Color textColor) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
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
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 16, color: textColor)),
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

    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dialogHeader(
                    Icons.palette,
                    local.change_background,
                    textColor,
                  ),
                  const SizedBox(height: 16),
                  _themeOption(
                    context,
                    icon: Icons.wb_sunny_outlined,
                    label: local.default_background,
                    onTap: () {
                      themeProvider.setTheme(ThemeMode.light);
                      Navigator.pop(context);
                    },
                    textColor: textColor,
                  ),
                  const SizedBox(height: 12),
                  _themeOption(
                    context,
                    icon: Icons.nightlight_round,
                    label: local.dark_background,
                    onTap: () {
                      themeProvider.setTheme(ThemeMode.dark);
                      Navigator.pop(context);
                    },
                    textColor: textColor,
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: Text(
                        local.close,
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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

  static Widget _dialogHeader(IconData icon, String title, Color textColor) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
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
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 16, color: textColor)),
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
      builder:
          (dialogContext) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
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
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _controller,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: local.nickname_placeholder,
                          hintStyle: TextStyle(
                            color: textColor.withOpacity(0.5),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.edit),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => checkNickname(dialogContext),
                        icon: const Icon(Icons.search, color: Colors.white),
                        label: Text(
                          local.check_duplicate,
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (message.isNotEmpty)
                        Text(
                          message,
                          style: TextStyle(
                            color:
                                isAvailable == true ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.cancel, color: textColor),
                            label: Text(
                              local.cancel,
                              style: TextStyle(color: textColor),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final nickname = _controller.text.trim();
                              if (isAvailable != true) {
                                showSavedSnackBar(
                                  context,
                                  message: local.nickname_check_prompt,
                                );
                                return;
                              }

                              await viewModel.updateNickname(nickname);
                              Navigator.pop(context);
                              showSavedSnackBar(
                                context,
                                message: local.nickname_success,
                              );
                            },
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: Text(
                              local.confirm,
                              style: const TextStyle(color: Colors.white),
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

  static Widget _dialogHeader(IconData icon, String title, Color textColor) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
