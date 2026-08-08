part of '../../weather_screen.dart';

class _Widget extends StatelessWidget {
  final Weather weather;

  const _Widget({required this.weather});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textShadow = [
      Shadow(
        color: Colors.black.withValues(alpha: 0.15),
        blurRadius: 5,
        offset: Offset(2, 2),
      ),
    ];

    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 8,
          children: [
            CustomCircleAvatar(url: weather.user.avatarUrl),
            Text(weather.user.name, style: textTheme.labelSmall),
          ],
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: _buildGradient(),
            borderRadius: BorderRadius.circular(28),
          ),
          padding: EdgeInsets.all(20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  Text(
                    weather.name,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      shadows: textShadow,
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Text(
                        '${weather.tempC}',
                        style: textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          shadows: textShadow,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: -25,
                        child: Text(
                          '°',
                          style: textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            shadows: textShadow,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    DateFormatter.format(
                      date: weather.localtime,
                      pattern: 'HH:mm',
                    ),
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      shadows: textShadow,
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                child: CachedNetworkImage(
                  imageUrl: weather.conditionIcon,
                  width: 50,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  LinearGradient _buildGradient() {
    if (!weather.isDay) {
      return const LinearGradient(
        colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    final temp = weather.tempC;

    if (temp <= -5) {
      return const LinearGradient(
        colors: [Color(0xFFBEE9FF), Color(0xFF7CC6FE)],
      );
    }

    if (temp <= 0) {
      return const LinearGradient(
        colors: [Color(0xFF89F7FE), Color(0xFF66A6FF)],
      );
    }

    if (temp <= 5) {
      return const LinearGradient(
        colors: [Color(0xFF6DD5FA), Color(0xFF2980B9)],
      );
    }

    if (temp <= 10) {
      return const LinearGradient(
        colors: [Color(0xFF74EBD5), Color(0xFFACB6E5)],
      );
    }

    if (temp <= 15) {
      return const LinearGradient(
        colors: [Color(0xFF9BE15D), Color(0xFF00E3AE)],
      );
    }

    if (temp <= 20) {
      return const LinearGradient(
        colors: [Color(0xFFFFE259), Color(0xFFFFA751)],
      );
    }

    if (temp <= 25) {
      return const LinearGradient(
        colors: [Color(0xFFFFD200), Color(0xFFFFA14A)],
      );
    }

    if (temp <= 30) {
      return const LinearGradient(
        colors: [Color(0xFFFF9966), Color(0xFFFF5E62)],
      );
    }

    if (temp <= 35) {
      return const LinearGradient(
        colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
      );
    }

    return const LinearGradient(colors: [Color(0xFF8E0E00), Color(0xFF1F1C18)]);
  }
}
