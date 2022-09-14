import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/layers.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

Particle explodingParticle(Vector2 origin, MaterialColor color) {
  double distanceToMove = 15.0;
  return Particle.generate(
      count: 12,
      lifespan: 0.8,
      generator: (i) {
        double angle = i * 30;
        double xx = origin.x + (distanceToMove * cos(angle));
        double yy = origin.y + (distanceToMove * sin(angle));
        Vector2 destination = Vector2(xx, yy);
        return ComputedParticle(renderer: (Canvas canvas, Particle particle) {
          Paint paint = Paint()
            ..color = color.withOpacity(1.0 - particle.progress);
          canvas.drawCircle(Offset.zero, 1.5, paint);
        }).moving(from: origin, to: destination);
      });
}

class ShadowLayer extends DynamicLayer {
  final Function renderFunction;

  ShadowLayer(this.renderFunction) {
    preProcessors
        .add(ShadowProcessor(color: Colors.black, offset: const Offset(4, 4)));
  }
  @override
  void drawLayer() {
    //Because of this, when we render our sprites in the render function, we will render
//into ShadowLayer and not make a call to the super class there, or we will be
//drawing twice, which is ineffient and not needed
    renderFunction(canvas);
  }
}
