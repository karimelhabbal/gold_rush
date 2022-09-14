import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/cupertino.dart';

class Health extends HudMarginComponent {
  Health({EdgeInsets? margin}) : super(margin: margin);

  int health = 100;
  String healthScore = "Health: ";

  late TextPaint _regularPaint;
  late TextComponent healthTextComponent;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    TextStyle textStyle =
        TextStyle(color: BasicPalette.blue.color, fontSize: 30.0);
    _regularPaint = TextPaint(style: textStyle);
    healthTextComponent = TextComponent(
        text: healthScore + health.toString(), textRenderer: _regularPaint);

    add(healthTextComponent);
  }

  setHealth(int health) {
    this.health = health;
    healthTextComponent.text = healthScore + this.health.toString();
  }
}
