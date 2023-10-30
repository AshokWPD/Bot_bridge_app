// import 'package:flutter/material.dart';

// class WeatherIconWidget extends StatefulWidget {
//   final IconData icon;
//   final double size;
//   final Color color;

//   WeatherIconWidget({
//     required this.icon,
//     required this.size,
//     required this.color,
//   });

//   @override
//   _WeatherIconWidgetState createState() => _WeatherIconWidgetState();
// }

// class _WeatherIconWidgetState extends State<WeatherIconWidget>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 1), // You can adjust the animation duration
//     )..repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedIcon(
//       icon: AnimatedIcons.play_pause,
//       size: widget.size,
//       color: widget.color,
//       progress: _animationController.view,
//     );
//   }
// }