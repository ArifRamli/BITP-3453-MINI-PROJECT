import 'package:flutter/material.dart';


class PostButton2 extends StatelessWidget {
  final void Function()? onTap;

  const PostButton2({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme
              .of(context)
              .colorScheme
              .secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(left: 10),
        child: Center(
          child: Text(
            'POST',
            style: TextStyle(
              color: Theme
                  .of(context)
                  .colorScheme
                  .inversePrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}