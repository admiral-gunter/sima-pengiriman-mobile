import 'package:flutter/material.dart';

/// A button that shows a loading spinner while [onPressed] is running.
class LoadingButton extends StatefulWidget {
  /// The button label.
  final String label;

  /// The asynchronous callback to execute; the button shows a spinner while this is in progress.
  final Future<void> Function() onPressed;

  /// Optional styling for the button.
  final ButtonStyle? style;

  const LoadingButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.style,
  }) : super(key: key);

  @override
  _LoadingButtonState createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    setState(() => _isLoading = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: widget.style,
      onPressed: _isLoading ? null : _handlePress,
      child: _isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(widget.label),
    );
  }
}
