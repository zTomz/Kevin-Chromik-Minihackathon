import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:minimalist_weather/apis/geocoding_api.dart';
import 'package:minimalist_weather/config/constants.dart';
import 'package:minimalist_weather/pages/cities_page/provider/cities_provider.dart';
import 'package:minimalist_weather/widgets/custom_button.dart';

class NewCityDialog extends HookConsumerWidget {
  const NewCityDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = useState<String?>(null);
    final geoLocation = useState<GeoLocation?>(null);

    return SimpleDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(defaultBorderRadius),
        ),
      ),
      backgroundColor: Colors.white,
      title: const Text("Add a new city"),
      contentPadding: const EdgeInsets.all(
        Spacing.medium,
      ),
      children: [
        Autocomplete<GeoLocation>(
          optionsBuilder: (value) async {
            List<GeoLocation> results = [];
            error.value = null;

            try {
              results = await GeocodingApi.getSuggestions(
                value.text,
              );
            } catch (e) {
              error.value = e.toString();
            }

            return results;
          },
          onSelected: (value) {
            geoLocation.value = value;
          },
          displayStringForOption: (option) {
            return "${option.name}, ${option.countryCode}";
          },
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              onSubmitted: (_) => onFieldSubmitted,
              enableSuggestions: true,
              decoration: InputDecoration(
                error:
                    error.value != null ? Text("Error: ${error.value}") : null,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(defaultBorderRadius),
                  ),
                ),
                hintText: "City name",
              ),
            );
          },
        ),
        const SizedBox(height: Spacing.medium),
        Row(
          children: [
            Expanded(
              child: CustomButton.outlined(
                text: "Close",
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(width: Spacing.medium),
            Expanded(
              flex: 2,
              child: CustomButton(
                text: "Add",
                onPressed: () async {
                  // Check the controller
                  if (geoLocation.value == null) {
                    // TODO: Show a snackbar, that no city is selected
                    return;
                  }

                  // Add the city
                  await ref
                      .read<CitiesNotifier>(citiesProvider.notifier)
                      .addCity(
                        geoLocation.value!,
                      );

                  // Close the dialog
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}