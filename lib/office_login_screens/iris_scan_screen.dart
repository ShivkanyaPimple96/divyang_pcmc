import 'package:flutter/material.dart';

class IrisScanScreen extends StatelessWidget {
  const IrisScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: const Center(
          child: Text(
            'Upload Iris Image',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ), // Light blue-green background
      body: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.yellow, // Yellow border
              width: 2.0, // Border thickness
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fingerprint icon with corner brackets
              Stack(
                alignment: Alignment.center,
                children: [
                  // Corner brackets
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CustomPaint(
                      painter: CornerBracketsPainter(),
                    ),
                  ),
                  // Fingerprint icon
                  Icon(Icons.remove_red_eye_outlined,
                      size: 80, color: Colors.yellow // Teal 0
                      ),
                  Icon(Icons.remove_red_eye_outlined,
                      size: 80, color: Colors.yellow // Teal color
                      ),
                ],
              ),

              const SizedBox(height: 40),

              // Start Scanner button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle start scanner action
                    print('Start Scanner pressed');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Start Scanner',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Scan button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle scan action
                    print('Scan pressed');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Scan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle continue action
                    print('Continue pressed');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF424242),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for corner brackets
class CornerBracketsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final bracketLength = 20.0;
    final cornerRadius = 8.0;

    // Top-left bracket
    Path topLeft = Path();
    topLeft.moveTo(bracketLength, 0);
    topLeft.lineTo(cornerRadius, 0);
    topLeft.arcToPoint(
      const Offset(0, 8),
      radius: Radius.circular(cornerRadius),
    );
    topLeft.lineTo(0, bracketLength);
    canvas.drawPath(topLeft, paint);

    // Top-right bracket
    Path topRight = Path();
    topRight.moveTo(size.width - bracketLength, 0);
    topRight.lineTo(size.width - cornerRadius, 0);
    topRight.arcToPoint(
      Offset(size.width, cornerRadius),
      radius: Radius.circular(cornerRadius),
    );
    topRight.lineTo(size.width, bracketLength);
    canvas.drawPath(topRight, paint);

    // Bottom-left bracket
    Path bottomLeft = Path();
    bottomLeft.moveTo(0, size.height - bracketLength);
    bottomLeft.lineTo(0, size.height - cornerRadius);
    bottomLeft.arcToPoint(
      Offset(cornerRadius, size.height),
      radius: Radius.circular(cornerRadius),
    );
    bottomLeft.lineTo(bracketLength, size.height);
    canvas.drawPath(bottomLeft, paint);

    // Bottom-right bracket
    Path bottomRight = Path();
    bottomRight.moveTo(size.width, size.height - bracketLength);
    bottomRight.lineTo(size.width, size.height - cornerRadius);
    bottomRight.arcToPoint(
      Offset(size.width - cornerRadius, size.height),
      radius: Radius.circular(cornerRadius),
    );
    bottomRight.lineTo(size.width - bracketLength, size.height);
    canvas.drawPath(bottomRight, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Example usage in your main app
