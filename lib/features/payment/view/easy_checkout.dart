// lib/features/payment/view/easy_checkout.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:prostuti/core/configs/app_urls.dart';
import 'package:prostuti/core/services/nav.dart';
import 'package:prostuti/features/payment/view/paymet_successful.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EasyCheckout extends StatefulWidget {
  final String url;

  const EasyCheckout({super.key, required this.url});

  @override
  State<EasyCheckout> createState() => _EasyCheckoutState();
}

class _EasyCheckoutState extends State<EasyCheckout> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    // Validate URL before loading
    if (widget.url.isEmpty) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Invalid payment URL';
      });
      return;
    }

    try {
      Uri.parse(widget.url); // Check if URL is valid

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (url) {
              setState(() {
                _isLoading = true;
              });
            },
            onPageFinished: (url) {
              setState(() {
                _isLoading = false;
              });
            },
            onWebResourceError: (error) {
              setState(() {
                _hasError = true;
                _errorMessage =
                    'Failed to load payment page: ${error.description}';
              });
            },
            onUrlChange: (change) {
              print("URL changed to: ${change.url}");
              if (change.url != null) {
                if (change.url!.contains(AppUrls.paymentSuccess)) {
                  Nav().pushReplacement(const PaymetSuccessful());
                } else if (change.url!.contains(AppUrls.paymentFailed)) {
                  Nav().pop();
                  Fluttertoast.showToast(msg: "Failed to purchase the course.");
                } else if (change.url!.contains(AppUrls.paymentCancelled)) {
                  Nav().pop();
                }
              }
            },
          ),
        );

      // Load the URL
      _controller.loadRequest(Uri.parse(widget.url));
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Invalid payment URL: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Nav().pop(),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _hasError
            ? _buildErrorView()
            : Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Nav().pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
