import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../payment/controller/create_new_card.dart';
import '../../payment/controller/get_saved_card.dart';
import '../model/payment_method_model.dart';

class WidgetAddNewCard extends StatefulWidget {
  const WidgetAddNewCard({super.key});

  @override
  State<WidgetAddNewCard> createState() => _WidgetAddNewCardState();
}

class _WidgetAddNewCardState extends State<WidgetAddNewCard> {
  final CreateNewCardApiController createNewCardController = Get.put(CreateNewCardApiController());
  final GetSavedCardApiController savedCardController = Get.put(GetSavedCardApiController());

  String? _selectedCardType;
  bool _isDefault = false;

  // Updated to realistic card types (adjust if needed for your simulation)
  final List<String> _cardTypes = ['Visa Card', 'MasterCard'];

  @override
  void initState() {
    super.initState();
    savedCardController.getSavedCardApiMethod();
    createNewCardController.clearError();
  }

  Future<void> _saveCard() async {
    if (_selectedCardType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select card type.")),
      );
      return;
    }

    final success = await createNewCardController.createNewCardApiMethod(
      _selectedCardType!,
      _isDefault,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Card saved successfully! Default: $_isDefault")),
      );
      await savedCardController.getSavedCardApiMethod();
      Get.back(
        result: PaymentMethod(
          id: '', // Placeholder ID; in real app, use generated ID from API
          payment_method: _selectedCardType!,
          isDefault: _isDefault,
        ),
      );
    }
  }

  Widget _buildExistingMethodsSection() {
    return Obx(() {
      if (savedCardController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (savedCardController.errorMessage.value.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible( // Wrap Text in Flexible to prevent overflow
                child: Text(
                  savedCardController.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                  overflow: TextOverflow.ellipsis, // Ellipsis for very long errors
                ),
              ),
              TextButton(
                onPressed: () => savedCardController.getSavedCardApiMethod(),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      if (savedCardController.savedCards.isEmpty) { // Simplified null-safe check (RxList is never null)
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Text('No saved payment methods found.'),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Text(
              'Your Existing Payment Methods',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ...savedCardController.savedCards.map((method) => ListTile(
            leading: const Icon(Icons.payment, color: Colors.blue),
            title: Text(method.payment_method ?? 'Unknown Type'), // Null-safe with fallback
            subtitle: Text(
              method.id ?? 'No ID',
              overflow: TextOverflow.ellipsis, // Prevent subtitle overflow
              maxLines: 1,
            ),
            trailing: method.isDefault == true
                ? const Chip(
              label: Text('Default'),
              backgroundColor: Colors.greenAccent,
            )
                : null,
            onTap: () {
              Get.back(result: method);
            },
          )),
          const Divider(height: 20),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Card'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                _buildExistingMethodsSection(),
                const Text('Card Type',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  value: _selectedCardType,
                  hint: const Text('Select Card Type'),
                  items: _cardTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCardType = newValue;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible( // Wrap Text in Flexible to prevent overflow
                      child: Text(
                        'Set as Default Payment Method',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        overflow: TextOverflow.ellipsis, // Ellipsis for long text
                        maxLines: 2, // Allow wrapping to 2 lines if needed
                      ),
                    ),
                    Switch(
                      value: _isDefault,
                      onChanged: (bool newValue) {
                        setState(() {
                          _isDefault = newValue;
                        });
                      },
                      activeColor: Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Obx(() {
                  if (createNewCardController.errorMessage.value.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        createNewCardController.errorMessage.value,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                ElevatedButton(
                  onPressed: createNewCardController.isLoading.value
                      ? null
                      : _saveCard,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Save Card',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            if (createNewCardController.isLoading.value)
              const Center(child: CircularProgressIndicator()),
          ],
        );
      }),
    );
  }
}