import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<PokemonCard>> fetchPokemonCards({int page = 1}) async {
  final response = await http.get(
    Uri.parse('https://api.pokemontcg.io/v2/cards?page=$page&pageSize=12'),
    headers: {'X-Api-Key': 'YOUR_API_KEY'},
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data['data'] as List).map((json) => PokemonCard.fromJson(json, 'small')).toList();
  } else {
    throw Exception('Failed to load Pokémon cards');
  }
}

Future<PokemonCard> fetchPokemonCardById(String id, String size) async {
  final response = await http.get(
    Uri.parse('https://api.pokemontcg.io/v2/cards/$id'),
    headers: {'X-Api-Key': 'YOUR_API_KEY'},
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return PokemonCard.fromJson(data['data'], size);
  } else {
    throw Exception('Failed to load Pokémon card');
  }
}

class PokemonCard {
  final String id;
  final String name;
  final String imageUrl;

  PokemonCard({required this.id, required this.name, required this.imageUrl});

  factory PokemonCard.fromJson(Map<String, dynamic> json, String size) {
    return PokemonCard(
      id: json['id'],
      name: json['name'],
      imageUrl: json['images'][size],
    );
  }
}
