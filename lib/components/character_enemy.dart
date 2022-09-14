// ignore_for_file: constant_identifier_names

import 'package:goldrush/components/character.dart';
import 'package:goldrush/components/water.dart';
import 'package:flame/components.dart';
import 'dart:math';

import 'package:goldrush/utils/math_utils.dart';

enum EnemyMovementType { WALKING, CHASING }

class EnemyCharacter extends Character {
  EnemyCharacter(
      {required Character player,
      required Vector2 position,
      required Vector2 size,
      required double speed})
      : playerToTrack = player,
        walkingSpeed = speed,
        chasingSpeed = speed * 2,
        super(
          position: position,
          size: size,
          speed: speed,
        );

  Character playerToTrack;
  EnemyMovementType enemyMovementType = EnemyMovementType.WALKING;
  static const DISTANCE_TO_TRACK = 150.0;
  double walkingSpeed, chasingSpeed;
  void changeDirection() {
    Random random = Random();
    int newDirection = random.nextInt(4);

    switch (newDirection) {
      case Character.down:
        animation = downAnimation;
        break;
      case Character.left:
        animation = leftAnimation;
        break;
      case Character.up:
        animation = upAnimation;
        break;
      case Character.right:
        animation = rightAnimation;
        break;
    }

    currentDirection = newDirection;
  }

  @override
  void update(double dt) {
    super.update(dt);

    elapsedTime += dt;

    speed = isPlayerNearAndVisible() ? chasingSpeed : walkingSpeed;
    enemyMovementType = isPlayerNearAndVisible()
        ? EnemyMovementType.CHASING
        : EnemyMovementType.WALKING;

    switch (enemyMovementType) {
      case EnemyMovementType.WALKING:
        if (elapsedTime > 3.0) {
          changeDirection();
          elapsedTime = 0.0;
        }

        switch (currentDirection) {
          case Character.down:
            position.y += speed * dt;
            break;
          case Character.left:
            position.x -= speed * dt;
            break;
          case Character.up:
            position.y -= speed * dt;
            break;
          case Character.right:
            position.x += speed * dt;
            break;
        }
        break;
      case EnemyMovementType.CHASING:
        Vector2 direction = (playerToTrack.position - position).normalized();
        position += direction * dt * speed;
        break;
    }
  }

  @override
  void onCollision(Set<Vector2> points, Collidable other) {
    if (other is Water) {
      switch (currentDirection) {
        case Character.down:
          currentDirection = Character.up;
          animation = upAnimation;
          break;
        case Character.left:
          currentDirection = Character.right;
          animation = rightAnimation;
          break;
        case Character.up:
          currentDirection = Character.down;
          animation = downAnimation;
          break;
        case Character.right:
          currentDirection = Character.left;
          animation = leftAnimation;
          break;
      }

      elapsedTime = 0.0;
    }
  }

  bool isPlayerNearAndVisible() {
    bool isPlayerNear =
        position.distanceTo(playerToTrack.position) < DISTANCE_TO_TRACK;

    bool isEnemyFacingPlayer = false;
    var angle = getAngle(position, playerToTrack.position);

    if ((angle > 315 && angle < 360) || (angle > 0 && angle < 45)) {
      // Facing right
      isEnemyFacingPlayer = currentDirection == Character.right;
    } else if (angle > 45 && angle < 135) {
      // Facing down
      isEnemyFacingPlayer = currentDirection == Character.down;
    } else if (angle > 135 && angle < 225) {
      // Facing left
      isEnemyFacingPlayer = currentDirection == Character.left;
    } else if (angle > 225 && angle < 315) {
      // Facing up
      isEnemyFacingPlayer = currentDirection == Character.up;
    }
    return isPlayerNear && isEnemyFacingPlayer;
  }
}
