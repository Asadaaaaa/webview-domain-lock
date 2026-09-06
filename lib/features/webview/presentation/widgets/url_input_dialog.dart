import 'package:flutter/material.dart';
import 'package:webview_domain_lock/core/utils/domain_utils.dart';
import 'package:webview_domain_lock/core/utils/url_utils.dart';
import 'package:webview_domain_lock/features/webview/models/webview_config.dart';

class UrlInputDialog extends StatefulWidget {
  final String? initialUrl;
  final String title;
  final String submitButtonText;
  final bool canDismiss;

  const UrlInputDialog({
    super.key,
    this.initialUrl,
    this.title = 'Open Website',
    this.submitButtonText = 'Open',
    this.canDismiss = true,
  });

  @override
  State<UrlInputDialog> createState() => _UrlInputDialogState();
}

class _UrlInputDialogState extends State<UrlInputDialog> {
  late final TextEditingController _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final rawInput = _controller.text.trim();
    if (rawInput.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a valid URL.';
      });
      return;
    }

    final normalizedUrl = UrlUtils.normalizeUrl(rawInput);
    if (!UrlUtils.isValidUrl(normalizedUrl)) {
      setState(() {
        _errorMessage = 'Please enter a valid URL.';
      });
      return;
    }

    final host = DomainUtils.extractHost(normalizedUrl);
    if (host == null || host.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a valid URL.';
      });
      return;
    }

    final config = WebViewConfig(
      mainUrl: normalizedUrl,
      allowedHost: host,
    );

    Navigator.of(context).pop(config);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.canDismiss,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter website URL',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.go,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: 'https://example.com',
                errorText: _errorMessage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                prefixIcon: const Icon(Icons.language),
              ),
            ),
          ],
        ),
        actions: [
          if (widget.canDismiss)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(widget.submitButtonText),
          ),
        ],
      ),
    );
  }
}
