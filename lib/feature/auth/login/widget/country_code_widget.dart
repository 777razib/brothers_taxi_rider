import 'package:flutter/material.dart';

class Country {
  final String name;
  final String code;
  final String flag;

  Country({required this.name, required this.code, required this.flag});
}

class CountryDropdown extends StatefulWidget {
  const CountryDropdown({super.key});

  @override
  State<CountryDropdown> createState() => _CountryDropdownState();
}

class _CountryDropdownState extends State<CountryDropdown> {
  final List<Country> countries = [
    Country(name: "Bangladesh", code: "+880", flag: "🇧🇩"),
    Country(name: "United States", code: "+1", flag: "🇺🇸"),
    Country(name: "United Kingdom", code: "+44", flag: "🇬🇧"),
    Country(name: "India", code: "+91", flag: "🇮🇳"),
    Country(name: "Canada", code: "+1", flag: "🇨🇦"),
  ];

  Country? selectedCountry;

  @override
  void initState() {
    super.initState();
    selectedCountry = countries.first; // default
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Country>(
      value: selectedCountry,
      isExpanded: true,
      underline: const SizedBox(),
      items: countries.map((country) {
        return DropdownMenuItem(
          value: country,
          child: Row(
            children: [
              Text(
                country.flag,
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(width: 8),
              Text("${country.code} "),
              const SizedBox(width: 6),
              Text(country.name),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedCountry = value;
        });
      },
    );
  }
}
