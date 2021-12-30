/*
  Copyright (C) 2013 John McCutchan

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/

part of spectre;

class FpsFlyCameraController extends CameraController {
  bool up = false;
  bool down = false;
  bool strafeLeft = false;
  bool strafeRight = false;
  bool forward = false;
  bool backward = false;

  double floatVelocity = 25.0;
  double strafeVelocity = 25.0;
  double forwardVelocity = 25.0;
  double mouseSensitivity = 360.0;

  int accumDX = 0;
  int accumDY = 0;

  FpsFlyCameraController();

  void updateCamera(double seconds, Camera cam) {
    _MoveFloat(seconds, up, down, cam);
    _MoveStrafe(seconds, strafeRight, strafeLeft, cam);
    _MoveForward(seconds, forward, backward, cam);
    _RotateView(seconds, cam);
  }

  void _MoveFloat(double dt, bool positive, bool negative, Camera cam) {
    double scale = 0.0;
    if (positive) {
      scale += 1.0;
    }
    if (negative) {
      scale -= 1.0;
    }
    if (scale == 0.0) {
      return;
    }
    scale = scale * dt * floatVelocity;
    Vector3 upDirection = new Vector3(0.0, 1.0, 0.0);
    upDirection.scale(scale);
    cam.focusPosition.add(upDirection);
    cam.position.add(upDirection);
  }

  void _MoveStrafe(double dt, bool positive, bool negative, Camera cam) {
    double scale = 0.0;
    if (positive) {
      scale += 1.0;
    }
    if (negative) {
      scale -= 1.0;
    }
    if (scale == 0.0) {
      return;
    }
    scale = scale * dt * strafeVelocity;
    Vector3 frontDirection = cam.frontDirection;
    frontDirection.normalize();
    Vector3 upDirection = new Vector3(0.0, 1.0, 0.0);
    Vector3 strafeDirection = frontDirection.cross(upDirection);
    strafeDirection.scale(scale);
    cam.focusPosition.add(strafeDirection);
    cam.position.add(strafeDirection);
  }

  void _MoveForward(double dt, bool positive, bool negative, Camera cam) {
    double scale = 0.0;
    if (positive) {
      scale += 1.0;
    }
    if (negative) {
      scale -= 1.0;
    }
    if (scale == 0.0) {
      return;
    }
    scale = scale * dt * forwardVelocity;

    Vector3 frontDirection = cam.frontDirection;
    frontDirection.normalize();
    frontDirection.scale(scale);
    cam.focusPosition.add(frontDirection);
    cam.position.add(frontDirection);
  }

  void _RotateView(double dt, Camera cam) {
    Vector3 frontDirection = cam.frontDirection;
    frontDirection.normalize();
    Vector3 upDirection = new Vector3(0.0, 1.0, 0.0);
    Vector3 strafeDirection = frontDirection.cross(upDirection);
    strafeDirection.normalize();

    double mouseYawDelta = accumDX/mouseSensitivity;
    double mousePitchDelta = accumDY/mouseSensitivity;
    accumDX = 0;
    accumDY = 0;

    final double f_dot_up = frontDirection.dot(upDirection);
    final double pitchAngle = Math.acos(f_dot_up);
    final double minPitchAngle = 0.785398163;
    final double maxPitchAngle = 2.35619449;
    final double pitchDegrees = degrees(pitchAngle);
    final double minPitchDegrees = degrees(minPitchAngle);
    final double maxPitchDegrees = degrees(maxPitchAngle);
    if (pitchAngle+mousePitchDelta <= maxPitchAngle &&
        pitchAngle+mousePitchDelta >= minPitchAngle) {
      _RotateEyeAndLook(mousePitchDelta, strafeDirection, cam);
    }
    _RotateEyeAndLook(mouseYawDelta, upDirection, cam);
  }

  void _RotateEyeAndLook(double delta_angle, Vector3 axis, Camera cam) {
    Quaternion q = new Quaternion.axisAngle(axis, delta_angle);
    Vector3 frontDirection = cam.frontDirection;
    frontDirection.normalize();
    q.rotate(frontDirection);
    frontDirection.normalize();
    cam.focusPosition = cam.position + frontDirection;
  }
}
