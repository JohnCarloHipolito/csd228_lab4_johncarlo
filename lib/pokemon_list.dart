import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<PokemonCard>> fetchPokemonCards({int page = 1}) async {
  final response = await http.get(
    Uri.parse('https://api.pokemontcg.io/v2/cards?page=$page&pageSize=32'),
    headers: {'X-Api-Key': 'YOUR_API_KEY'},
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data['data'] as List).map((json) => PokemonCard.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load Pokémon cards');
  }
}

class PokemonCard {
  final String name;
  final String imageUrl;

  PokemonCard({required this.name, required this.imageUrl});

  factory PokemonCard.fromJson(Map<String, dynamic> json) {
    return PokemonCard(
      name: json['name'],
      imageUrl: json['images']['large'],
    );
  }
}