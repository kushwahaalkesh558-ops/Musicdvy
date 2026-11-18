import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const MusicDvy());

class Song {
  final String title, artist;
  final int secs;
  final List<Color> colors;
  final List<String> lyrics;
  const Song(this.title, this.artist, this.secs, this.colors, this.lyrics);
}

const songs = [
  Song('Raat ka Safar', 'Dev & The Echoes', 184,
      [Color(0xFF7C3AED), Color(0xFFEC4899)], [
    'Raat ki khamoshi mein', 'Ek dhun si bajti hai', 'Door kahin shehar ki',
    'Roshni si jalti hai', 'Chalte rahe hum yunhi', 'Bina manzil ke bhi',
    'Har mod pe milti thi', 'Koi nayi kahani si'
  ]),
  Song('Monsoon Tape', 'Aarav Mehta', 152,
      [Color(0xFF0EA5E9), Color(0xFF22D3EE)], [
    'Baarish ki pehli boond', 'Khidki pe likhti naam', 'Chai ki bhaap mein',
    'Ghul gayi thi shaam', 'Purane cassette ki', 'Dheemi si awaaz thi',
    'Yaadon ke pannon mein', 'Bheegi si saugaat thi'
  ]),
  Song('Neon Lane', 'Kiara Vox', 201,
      [Color(0xFFF97316), Color(0xFFFACC15)], [
    'Neon ki gali mein', 'Hum raat bhar ghoomein', 'Bass dil pe dastak de',
    'Aasmaan ko choomein', 'Lights low, volume up', 'Sab kuch bhula do',
    'Is pal ki laya mein', 'Bas ab jhoom jaa do'
  ]),
];

LinearGradient grad(List<Color> c) => LinearGradient(
    colors: c, begin: Alignment.topLeft, end: Alignment.bottomRight);

class MusicDvy extends StatelessWidget {
  const MusicDvy({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'musicdvy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: const Color(0xFF7C3AED)),
        home: const LoginPage(),
      );
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _go(BuildContext c, String user) => Navigator.pushReplacement(
      c, MaterialPageRoute(builder: (_) => HomePage(user: user)));

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('musicdvy',
                  style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('Gaane, lyrics aur playlists, sab ek jagah.'),
              const SizedBox(height: 28),
              // TODO: replace with Firebase Google Sign-In
              FilledButton(
                  onPressed: () => _go(context, 'Google user'),
                  child: const Text('Continue with Google')),
              const SizedBox(height: 12),
              // TODO: replace with FirebaseAuth.signInAnonymously()
              OutlinedButton(
                  onPressed: () => _go(context, 'Guest'),
                  child: const Text('Continue as guest')),
            ],
          ),
        ),
      );
}

class HomePage extends StatelessWidget {
  final String user;
  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Home'), actions: [
          Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: Text(user)))
        ]),
        body: ListView.builder(
          itemCount: songs.length,
          itemBuilder: (c, i) {
            final s = songs[i];
            return ListTile(
              leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      gradient: grad(s.colors),
                      borderRadius: BorderRadius.circular(10))),
              title: Text(s.title),
              subtitle: Text(s.artist),
              onTap: () => Navigator.push(c,
                  MaterialPageRoute(builder: (_) => PlayerPage(index: i))),
            );
          },
        ),
      );
}

class PlayerPage extends StatefulWidget {
  final int index;
  const PlayerPage({super.key, required this.index});
  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late int i = widget.index;
  double pos = 0;
  bool playing = true;
  Timer? timer;
  final scroll = ScrollController();
  static const lineH = 64.0;

  Song get s => songs[i];
  int get line =>
      (pos / (s.secs / s.lyrics.length)).floor().clamp(0, s.lyrics.length - 1);

  @override
  void initState() {
    super.initState();
    // TODO: connect just_audio here for real playback
    timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!playing) return;
      setState(() => pos += 0.25);
      if (pos >= s.secs) _change(1);
      if (scroll.hasClients) {
        scroll.animateTo(line * lineH,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _change(int d) => setState(() {
        i = (i + d + songs.length) % songs.length;
        pos = 0;
        if (scroll.hasClients) scroll.jumpTo(0);
      });

  String _fmt(double v) {
    final t = v.floor();
    return '${t ~/ 60}:${(t % 60).toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    timer?.cancel();
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('High · 320 kbps')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(children: [
          Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                  gradient: grad(s.colors),
                  borderRadius: BorderRadius.circular(16))),
          const SizedBox(height: 12),
          Text(s.title,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          Text(s.artist),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              controller: scroll,
              itemExtent: lineH,
              itemCount: s.lyrics.length,
              itemBuilder: (c, k) => Align(
                alignment: Alignment.centerLeft,
                child: Text(s.lyrics[k],
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: k == line
                            ? Colors.amber
                            : cs.onSurface.withOpacity(0.4))),
              ),
            ),
          ),
          Slider(
              value: pos.clamp(0, s.secs.toDouble()),
              max: s.secs.toDouble(),
              onChanged: (v) => setState(() => pos = v)),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(_fmt(pos)),
            Text(_fmt(s.secs.toDouble()))
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
                iconSize: 32,
                onPressed: () => _change(-1),
                icon: const Icon(Icons.skip_previous)),
            const SizedBox(width: 12),
            IconButton.filled(
                iconSize: 40,
                onPressed: () => setState(() => playing = !playing),
                icon: Icon(playing ? Icons.pause : Icons.play_arrow)),
            const SizedBox(width: 12),
            IconButton(
                iconSize: 32,
                onPressed: () => _change(1),
                icon: const Icon(Icons.skip_next)),
          ]),
        ]),
      ),
    );
  }
}
