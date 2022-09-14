import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/input.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:goldrush/components/character.dart';
import 'package:goldrush/components/coin.dart';
import 'package:goldrush/components/hud/hud.dart';
import 'package:goldrush/components/water.dart';
import 'package:goldrush/components/zombie.dart';
import 'package:goldrush/components/skeleton.dart';
import 'package:goldrush/utils/map_utils.dart';
import 'package:goldrush/widgets/screen_gameover.dart';
import 'package:goldrush/widgets/screen_menu.dart';
import 'package:goldrush/widgets/screen_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/background.dart';
import 'components/george.dart';
import 'package:flame_audio/flame_audio.dart';
import 'dart:math';

void main() async {
  final goldRush = GoldRush();

  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  // await Flame.device.setLandscape();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Gold Rush',
    initialRoute: '/',
    routes: {
      '/': (context) => const MenuScreen(),
      '/settings': (context) => const SettingsScreen(),
      '/gameover': (context) => const GameOverScreen(),
      '/game': (context) => GameWidget(game: GoldRush()),
    },
  ));
}

class GoldRush extends FlameGame
    with
        HasCollidables,
        HasDraggables,
        HasTappables,
        HasKeyboardHandlerComponents {
  @override
  Future<void> onLoad() async {
    super.onLoad();

    FlameAudio.bgm.initialize();
    await FlameAudio.bgm.load('music/music.mp3');

    var musicVolume;
    await SharedPreferences.getInstance()
        .then((prefs) => prefs.getDouble('musicVolume'))
        .then((value) => musicVolume = value);
    await FlameAudio.bgm.play('music/music.mp3', volume: musicVolume / 100);

    var hud = HudComponent();
    final tiledMap = await TiledComponent.load('tiles.tmx', Vector2.all(32));
    add(tiledMap);
    List<Offset> barrierOffsets = [];
    final water = tiledMap.tileMap.getObjectGroupFromLayer('Water');
    water.objects.forEach((rect) {
      if (rect.width == 32 && rect.height == 32) {
        barrierOffsets.add(worldToGridOffset(Vector2(rect.x, rect.y)));
      }
      add(Water(
          position: Vector2(rect.x, rect.y),
          size: Vector2(rect.width, rect.height),
          id: rect.id));
    });

    var george = George(
        barrierOffsets: barrierOffsets,
        hud: hud,
        position: Vector2(200, 400),
        size: Vector2(32.0, 32.0),
        speed: 40.0);
    add(george);
    children.changePriority(george, 15);

    add(Background(george));

    add(hud);

    final enemies = tiledMap.tileMap.getObjectGroupFromLayer('Enemies');
    enemies.objects.asMap().forEach((index, position) {
      if (index % 2 == 0) {
        var skeltone = Skeleton(
            player: george,
            position: Vector2(position.x, position.y),
            size: Vector2(32.0, 64.0),
            speed: 60.0);
        children.changePriority(skeltone, 15);
        add(skeltone);
      } else {
        var zombie = Zombie(
            player: george,
            position: Vector2(position.x, position.y),
            size: Vector2(32.0, 64.0),
            speed: 20.0);
        children.changePriority(zombie, 15);
        add(zombie);
      }
    });

    Random random = Random(DateTime.now().millisecondsSinceEpoch);
    for (int i = 0; i < 50; i++) {
      int randomX = random.nextInt(48) + 1;
      int randomY = random.nextInt(48) + 1;
      double posCoinX = (randomX * 32) + 5;
      double posCoinY = (randomY * 32) + 5;
      var coin =
          Coin(position: Vector2(posCoinX, posCoinY), size: Vector2(20, 20));
      children.changePriority(coin, 15);
      add(coin);
    }

    camera.speed = 1;
    camera.followComponent(george,
        worldBounds: const Rect.fromLTWH(0, 0, 1600, 1600));
  }

  @override
  void onRemove() {
    FlameAudio.bgm.stop();
    FlameAudio.bgm.clearAll();

    super.onRemove();
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        children.forEach((component) {
          if (component is Character) {
            component.onPaused();
          }
        });
        break;
      case AppLifecycleState.resumed:
        children.forEach((component) {
          if (component is Character) {
            component.onResumed();
          }
        });
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }
}
