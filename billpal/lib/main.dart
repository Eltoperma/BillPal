import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BillPal',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      //alt: 
      //home: const MyHomePage(title: 'BillPal'),
      home: const DashboardPage(),
    );
  }
}


// Die Startseite wie im Mockup.
/// Enthält:
/// - zwei Info-Karten (Verbindlichkeiten / Forderungen)
/// - ein Kreisdiagramm (CustomPaint)
/// - ein Zitat
/// - einen Floating Action Button (Plus)
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Beispiel-Daten für das Pie-Chart (Anteile müssen sich zu 1.0 summieren)
    final pieData = <_PieSlice>[
      _PieSlice(value: 0.35, color: const Color(0xFF26C281)), // grün
      _PieSlice(value: 0.30, color: const Color(0xFF5B8DEF)), // blau
      _PieSlice(value: 0.20, color: const Color(0xFFF6C443)), // gelb
      _PieSlice(value: 0.15, color: const Color(0xFFF06263)), // rot
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8), // helles Grau wie im Screenshot
      // Optional: AppBar ausblenden, weil der Mockup keine hat
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              // OBERER BEREICH: zwei Karten
              Row(
                children: const [
                  Expanded(
                    child: _InfoCard(
                      title: 'Verbindlichkeiten',
                      amount: 120.0,
                      amountColor: Color(0xFFE53935), // rot
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _InfoCard(
                      title: 'Forderungen',
                      amount: 250.0,
                      amountColor: Color(0xFF2E7D32), // grün
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // MITTE: Kreisdiagramm
              // Wir benutzen CustomPaint, damit kein externes Package nötig ist.
              Center(
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: CustomPaint(
                    painter: _PieChartPainter(pieData),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Zitat unten, leicht grau und kursiv
              const Text(
                '„Zu viel Monat am Ende des Geldes.“',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),

      // FAB unten rechts mit Plus
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // später: Navigation zum "Neue Rechnung"-Flow
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Neue Rechnung hinzufügen')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Eine wiederverwendbare Karte für Kennzahlen.
/// - [title]: graue Überschrift
/// - [amount]: Zahl, automatisch als „€“ formatiert
/// - [amountColor]: Farbe der Zahl (z.B. rot/grün)
class _InfoCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color amountColor;

  const _InfoCard({
    required this.title,
    required this.amount,
    required this.amountColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          // sanfter „Card“-Schatten
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Text(
            _formatEuro(amount),
            style: TextStyle(
              color: amountColor,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}

/// Hilfsfunktion um 250 -> "250€" zu formatieren.
/// Für echte Währungen später lieber NumberFormat (intl-Package) verwenden.
String _formatEuro(double value) => '${value.toStringAsFixed(0)}€';

/// Datenmodell für ein Kreisdiagramm-Segment.
class _PieSlice {
  final double value; // Anteil (0..1)
  final Color color;  // Segment-Farbe

  const _PieSlice({required this.value, required this.color});
}

/// CustomPainter, der das Kreisdiagramm zeichnet.
/// Funktionsweise:
/// - Wir laufen die Liste der Segmente durch und malen für jedes Segment
///   einen Bogen (Arc) mit der entsprechenden Länge.
/// - startAngle steigt kumulativ, damit die Segmente sich anschließen.
/// - Zusätzlich malen wir in der Mitte einen weißen Kreis, um den
///   "Donut"-Look aus dem Screenshot zu imitieren.
class _PieChartPainter extends CustomPainter {
  final List<_PieSlice> slices;

  _PieChartPainter(this.slices);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2;

    // Linienbreite für „Donut“. Je größer, desto „dicker“.
    final strokeWidth = radius * 0.6;

    var startAngle = -90.0 * (3.1415926535 / 180.0); // Start bei 12 Uhr

    for (final slice in slices) {
      final sweepAngle = slice.value * 2 * 3.1415926535;

      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      // Wir zeichnen den Bogen als Ring (donut style)
      final arcRect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);
      canvas.drawArc(arcRect, startAngle, sweepAngle, false, paint);

      startAngle += sweepAngle;
    }

    // Optional: kleiner Schattenkreis unter dem Donut für Tiefe
    final shadowPaint = Paint()
      ..color = Colors.black12
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, radius * 0.02, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    // neu zeichnen, wenn sich die Daten ändern
    return oldDelegate.slices != slices;
  }
}



class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
