import 'package:flutter/material.dart';

class FediAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final void Function()? backAction;
  final void Function()? closeAction;

  const FediAppBar({
    Key? key,
    required this.title,
    this.backAction,
    this.closeAction,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          backAction != null
              ? SimpleIconButton(
                  action: backAction,
                  icon: Icons.arrow_back,
                  semanticLabel: "Back",
                )
              : const SizedBox(
                  width: 24,
                ),
          Text(title, style: Theme.of(context).textTheme.headline3),
          SimpleIconButton(
            action: closeAction,
            icon: Icons.close,
            semanticLabel: "Close",
          ),
        ],
      ),
    );
  }
}

class SimpleIconButton extends StatelessWidget {
  const SimpleIconButton({
    Key? key,
    required this.action,
    required this.icon,
    required this.semanticLabel,
  }) : super(key: key);

  final void Function()? action;
  final IconData icon;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      onTap: action,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 24.0,
          semanticLabel: semanticLabel,
        ),
      ),
    );
  }
}
