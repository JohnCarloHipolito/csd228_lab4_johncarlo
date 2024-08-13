import 'package:flutter/material.dart';

import 'pokemon_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<PokemonCard>> futurePokemonCards;
  List<PokemonCard> _pokemonCards = [];
  List<PokemonCard> _filteredPokemonCards = [];
  int _currentPage = 1;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchPokemonCards();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _fetchPokemonCards() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    final newCards = await fetchPokemonCards(page: _currentPage);
    setState(() {
      _pokemonCards.addAll(newCards);
      _filteredPokemonCards = _pokemonCards;
      _currentPage++;
      _isLoading = false;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _fetchPokemonCards();
    }
  }

  void _onSearchChanged() {
    setState(() {
      _filteredPokemonCards = _pokemonCards
          .where((card) => card.name.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  void _showLargeImage(BuildContext context, String id) async {
    try {
      final card = await fetchPokemonCardById(id);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Image.network(card.imageUrl, fit: BoxFit.contain),
            ),
          );
        },
      );
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: const InputDecoration(
            hintText: 'Search Pokémon',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white54),
            prefixIcon: Icon(Icons.search, color: Colors.white54),
            contentPadding: EdgeInsets.symmetric(vertical: 15.0),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.png'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: _pokemonCards.isEmpty && _isLoading
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                        ),
                        itemCount: _filteredPokemonCards.length,
                        itemBuilder: (context, index) {
                          final card = _filteredPokemonCards[index];
                          return GestureDetector(
                            onTap: () => _showLargeImage(context, card.id),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(6.0),
                                      topRight: Radius.circular(6.0),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(6.0),
                                          topRight: Radius.circular(6.0),
                                        ),
                                        child: AspectRatio(
                                          aspectRatio: 1.0,
                                          child: Image.network(card.imageUrl, fit: BoxFit.fitHeight),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          color: Colors.black54,
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            card.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      if (_isLoading) const CircularProgressIndicator(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
