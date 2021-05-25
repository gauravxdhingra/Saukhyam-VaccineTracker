import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class FloatingModal extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;

  const FloatingModal({Key? key, required this.child, this.backgroundColor})
      : super(key: key);

  @override
  _FloatingModalState createState() => _FloatingModalState();
}

class _FloatingModalState extends State<FloatingModal> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Material(
          color: widget.backgroundColor,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(12),
          child: widget.child,
        ),
      ),
    );
  }
}

Future<T> showFloatingModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
}) async {
  final result = await showCustomModalBottomSheet(
      context: context,
      builder: builder,
      enableDrag: true,
      containerWidget: (_, animation, child) => FloatingModal(child: child),
      useRootNavigator: true,
      expand: false);

  return result;
}
