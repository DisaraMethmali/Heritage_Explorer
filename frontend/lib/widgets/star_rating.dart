import 'package:flutter/material.dart';

class NumberRating extends StatefulWidget {
  final int maxRating;
  final void Function(int rating) onRate;

  const NumberRating({super.key, this.maxRating = 5, required this.onRate});

  @override
  State<NumberRating> createState() => _NumberRatingState();
}

class _NumberRatingState extends State<NumberRating> {
  int? selectedRating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxRating, (index) {
        final rating = widget.maxRating - index; // Reverse order: 5, 4, 3, 2, 1
        final isSelected = selectedRating == rating;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedRating = rating;
              });
              widget.onRate(rating);
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.blue.shade300,
                  width: isSelected ? 2.5 : 2.0,
                ),
                color: isSelected ? Colors.blue.shade50 : Colors.white,
              ),
              child: Center(
                child: Text(
                  '$rating',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.blue.shade700 : Colors.blue.shade400,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// Example usage:
class RatingExample extends StatelessWidget {
  const RatingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rating Example')),
      body: Center(
        child: NumberRating(
          maxRating: 5,
          onRate: (rating) {
            print('User rated: $rating');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('You rated: $rating'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
      ),
    );
  }
}