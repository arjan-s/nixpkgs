{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  poetry-core,
  filterpy,
  importlib-metadata,
  numpy,
  rich,
  scipy,
  motmetrics,
  opencv4,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "norfair";
  version = "2.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "tryolabs";
    repo = "norfair";
    tag = "v${version}";
    hash = "sha256-aKB5TYSLW7FOXIy9u2hK7px6eEmIQdKPrhChKaU1uYs=";
  };

  build-system = [ poetry-core ];

  pythonRelaxDeps = [
    "numpy"
    "rich"
  ];

  dependencies = [
    filterpy
    importlib-metadata
    numpy
    rich
    scipy
  ];

  optional-dependencies = {
    metrics = [ motmetrics ];
    video = [ opencv4 ];
  };

  nativeCheckInputs = [ pytestCheckHook ];

  pythonImportsCheck = [ "norfair" ];

  meta = with lib; {
    description = "Lightweight Python library for adding real-time multi-object tracking to any detector";
    changelog = "https://github.com/tryolabs/norfair/releases/tag/v${version}";
    homepage = "https://github.com/tryolabs/norfair";
    license = licenses.bsd3;
    maintainers = with maintainers; [ fleaz ];
  };
}
