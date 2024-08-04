import 'package:flutter/material.dart';

class CustomCardWidget extends StatefulWidget {
  final String title;
  final Widget child;
  final bool? link;

  const CustomCardWidget(
      {super.key, required this.title, required this.child, this.link});

  @override
  State<CustomCardWidget> createState() => _CustomCardWidgetState();
}

class _CustomCardWidgetState extends State<CustomCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Row(
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 18.0)),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: widget.child,
      ),
    ]);
  }
}
