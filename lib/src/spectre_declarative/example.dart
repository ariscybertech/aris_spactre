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

part of spectre_declarative;

class DeclarativeExample extends Example {
  String spectreId;
  DeclarativeExample(CanvasElement element, this.spectreId)
      : super('DeclarativeExample', element);

  CameraController cameraController;

  Future initialize() {
    return super.initialize().then((_) {
      cameraController = new FpsFlyCameraController();
      declarativeInstance.debugDrawManager = debugDrawManager;
      declarativeInstance.graphicsContext = graphicsContext;
      declarativeInstance.graphicsDevice = graphicsDevice;
      declarativeInstance.assetManager = assetManager;
      SpectreSpectreElement root = querySelector(spectreId);
      declarativeInstance.root = root;
      declarativeInstance.example = this;
      declarativeInstance._init();
    });
  }

  Future load() {
    return super.load().then((_) {
    });
  }

  onUpdate() {
    updateCameraController(cameraController);
    var spectre = declarativeInstance;
    spectre.time = gameLoop.time;
    spectre.root.update();
  }

  void onResize(width, height) {
    if (camera != null) {
      // Change the aspect ratio of the camera
      camera.aspectRatio = viewport.aspectRatio;
    }
  }

  toggleFullscreen() {
    bool fs = gameLoop.isFullscreen;
    gameLoop.enableFullscreen(!fs);
  }

  onRender() {
    // Set the viewport (2D area of render target to render on to).
    graphicsContext.setViewport(viewport);
    // Clear it.
    graphicsContext.clearColorBuffer(0.97, 0.97, 0.97, 1.0);
    graphicsContext.clearDepthBuffer(1.0);

    var spectre = declarativeInstance.root;

    spectre.pushCamera(camera);
    spectre.render();
    spectre.popCamera();

    debugDrawManager.prepareForRender();
    debugDrawManager.render(camera);
  }
}