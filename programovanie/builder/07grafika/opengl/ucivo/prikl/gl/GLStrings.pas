unit GLStrings;

interface

resourcestring

  // SceneViewer
  glsNoRenderingContext = 'Could not create a rendering context';
  glsWrongVersion       = 'Need at least OpenGL version 1.1';
  glsTooManyLights      = 'Too many lights in the scene';
  glsDisplayList        = 'Failed to create a new display list for object ''%s''';
  glsWrongBitmapCanvas  = 'Couldn''t create a rendering context for the given bitmap';
  glsWrongPrinter       = 'Couldn''t render to printer';

  // GLTree
  glsSceneRoot  = 'Scene root';
  glsObjectRoot = 'Scene objects';
  glsCameraRoot = 'Cameras';
  glsCamera     = 'Camera';

  // GLTexture
  glsImageInvalid = 'Could not load texture, image is invalid';
  glsNoNewTexture = 'Could not get new texture name';

  // GLObjects
  glsSphereTopBottom = 'The top angle must be higher than the bottom angle';
  glsSphereStartStop = 'The start angle must be smaller than then stop angle';
  glsMaterialNotFound = 'Loading failed: could not find material %s';

  // common messages
  glsOutOfMemory = 'Fatal: Out of memory';
  glsFailedOpenFile = 'Could not open file: %s';

implementation

end.

