import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(count: 10),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.count});

  final int count;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final List<String> _imageUrls;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _imageUrls =
        List.generate(widget.count, (index) => 'https://picsum.photos/id/${index + 20}/300/560');
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const rotationAngle = 0.5 * math.pi;
    return Scaffold(
      body: Transform.rotate(
        angle: -rotationAngle,
        child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: 1 - _controller.value,
                child: ListWheelScrollView(
                  perspective: 0.01,
                  itemExtent: 120.0,
                  children: _imageUrls.map((url) {
                    return Transform.rotate(
                      angle: rotationAngle,
                      child: GestureDetector(
                        onTap: () async {
                          final navigator = Navigator.of(context);
                          await _controller.forward();
                          final route = MaterialPageRoute<void>(builder: (_) {
                            return FullScreenImage(imageUrl: url);
                          });
                          await navigator.push(route);
                          await _controller.reverse();
                        },
                        child: Container(
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.0)),
                          width: 120.0,
                          child: Hero(
                            tag: url,
                            child: Image.network(url, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
      ),
    );
  }
}

class FullScreenImage extends StatefulWidget {
  const FullScreenImage({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;
  final _descriptionContainerHeight = 180.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: -_descriptionContainerHeight, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.bounceOut),
      ),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1, curve: Curves.linear),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Scaffold(
            floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
            floatingActionButton: Opacity(
              opacity: _fadeAnimation.value,
              child: IconButton.filledTonal(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await _controller.reverse();
                  navigator.pop();
                },
                icon: const Icon(Icons.keyboard_backspace_rounded),
              ),
            ),
            body: Hero(
              tag: widget.imageUrl,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: NetworkImage(widget.imageUrl),
                      fit: BoxFit.fitHeight,
                    )),
                  ),
                  Positioned(
                    left: 0.0,
                    right: 0.0,
                    bottom: _slideAnimation.value,
                    child: Container(
                      height: _descriptionContainerHeight,
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Image Description',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
