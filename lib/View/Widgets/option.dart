import 'package:flutter/material.dart';

// 일반 ListTile의 경우
class OptionTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;

  const OptionTile({
    Key? key,
    required this.title,
    this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      onTap: onTap,
      trailing: trailing,
    );
  }
}

// 스위치를 포함하는 ListTile의 경우
class SwitchOptionTile extends StatefulWidget {
  final String title;
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const SwitchOptionTile({
    Key? key,
    required this.title,
    required this.initialValue,
    this.onChanged,
  }) : super(key: key);

  @override
  _SwitchOptionTileState createState() => _SwitchOptionTileState();
}

class _SwitchOptionTileState extends State<SwitchOptionTile> {
  late bool currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(widget.title),
      value: currentValue,
      onChanged: (bool value) {
        setState(() {
          currentValue = value;
        });
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
      },
    );
  }
}
