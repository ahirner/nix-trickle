{
  lib,
  postgresql,
  fetchPypi,
}: pyFinal: pyPrev: {
  "apache-superset-core" = pyFinal.buildPythonPackage rec {
    pname = "apache-superset-core";
    version = "0.1.0";
    src = fetchPypi {
      pname = "apache_superset_core";
      inherit version;
      hash = "sha256-cs3axVfyEtsw9xjvB0Glm8X1tUVZUl+aEE2cklq6GME=";
    };
    pyproject = true;
    build-system = with pyFinal; [setuptools wheel];
    doCheck = false;
    dependencies = with pyFinal; [
      flask-appbuilder
      pydantic
      sqlalchemy
      sqlalchemy-utils
      sqlglot
      typing-extensions
    ];
    pythonImportsCheck = ["superset_core"];
  };

  sqlalchemy = pyPrev.sqlalchemy_1_4;

  celery = pyPrev.celery.overridePythonAttrs (old: {
    # SQLAlchemy 1.4 wraps dialect-specific types in Variant.
    disabledTests = (old.disabledTests or []) ++ ["test_for_mssql_dialect"];
  });

  numpy = pyPrev.numpy_1;

  cython_0 = pyPrev.cython_0.overridePythonAttrs (old: {
    # Cython's command needs setuptools' distutils shim on Python 3.12.
    dependencies = (old.dependencies or []) ++ [pyFinal.setuptools];
    pythonImportsCheck = ["setuptools" "Cython.Build.Dependencies"];
  });

  # pandas >= 2.2 requires SQLAlchemy >= 2, which Superset does not support.
  pandas = pyPrev.pandas.overridePythonAttrs (_: rec {
    version = "2.1.4";
    src = fetchPypi {
      pname = "pandas";
      inherit version;
      hash = "sha256-/LaCA8gzzHNTIVEuE4YTWAealsF0ph9RFqHeicWMDvc=";
    };
    postPatch = ''
      substituteInPlace pyproject.toml \
        --replace-fail 'meson-python==0.13.1' meson-python \
        --replace-fail 'meson==1.2.1' meson
    '';
    build-system = with pyFinal; [cython_0 meson-python meson numpy versioneer wheel];
  });

  sqlglot = pyPrev.sqlglot.overridePythonAttrs (_: rec {
    version = "28.10.1";
    src = fetchPypi {
      pname = "sqlglot";
      inherit version;
      hash = "sha256-ZuDa5DtLziMxS4DprvQbjIj+oOF62mLeCVtFJiCEqMU=";
    };
  });

  pgsanity = pyPrev.pgsanity.overridePythonAttrs (old: {
    # The sdist omits test/, so unittest otherwise imports Python's own test package.
    doCheck = false;
    postPatch =
      old.postPatch
      + ''
        substituteInPlace pgsanity/ecpg.py \
          --replace-fail '"ecpg"' '"${lib.getDev postgresql}/bin/ecpg"'
      '';
  });

  marshmallow = pyFinal.buildPythonPackage rec {
    pname = "marshmallow";
    version = "3.26.1";
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-5tiv+2y2HTnSZAIJbcCu4S1aJtSQoSHxGNLoHcBxncY=";
    };
    pyproject = true;
    build-system = with pyFinal; [flit-core];
    doCheck = false;
    dependencies = with pyFinal; [packaging];
  };

  marshmallow-union = pyFinal.buildPythonPackage rec {
    pname = "marshmallow-union";
    version = "0.1.15.post1";
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-wI8Kh4ka5z3StdShVLx9rqIMO8D5nKC2omVwySfSDIw=";
    };
    pyproject = true;
    build-system = with pyFinal; [setuptools wheel];
    doCheck = false;
    dependencies = with pyFinal; [marshmallow];
  };

  pygeohash = pyFinal.buildPythonPackage rec {
    pname = "pygeohash";
    version = "3.2.2";
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-qsUHH5qQIyxQ2MahJKFQ/9twBpBTFPcqENaGoH0sUYc=";
    };
    pyproject = true;
    build-system = with pyFinal; [setuptools wheel];
    doCheck = false;
  };

  prison = pyFinal.buildPythonPackage rec {
    pname = "prison";
    version = "0.2.1";
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-5s1yQESvyxqKaTQMrS8eMVGlg5/TqAJ/0TV1ceeXxZk=";
    };
    pyproject = true;
    build-system = [pyFinal.setuptools];
    dependencies = [pyFinal.six];
    pythonImportsCheck = ["prison"];
  };

  flask-limiter = pyFinal.buildPythonPackage rec {
    pname = "flask-limiter";
    version = "3.12";
    src = fetchPypi {
      pname = "flask_limiter";
      inherit version;
      hash = "sha256-+ePj0MSs0NH/v6cp4XGY3RBC9NI8EwrhYARPyTDiEwA=";
    };
    pyproject = true;
    build-system = with pyFinal; [hatchling hatch-vcs];
    pythonRelaxDeps = ["rich"];
    dependencies = with pyFinal; [flask limits ordered-set rich];
    pythonImportsCheck = ["flask_limiter"];
  };

  flask-login = pyFinal.buildPythonPackage rec {
    pname = "flask-login";
    version = "0.6.3";
    src = fetchPypi {
      pname = "Flask-Login";
      inherit version;
      hash = "sha256-XiPRSmB+8SgGxplZC4nQ8ODWe67sWZ11lHv5wUczAzM=";
    };
    pyproject = true;
    build-system = [pyFinal.setuptools];
    dependencies = with pyFinal; [flask werkzeug];
    pythonImportsCheck = ["flask_login"];
  };

  flask-sqlalchemy = pyFinal.buildPythonPackage rec {
    pname = "Flask-SQLAlchemy";
    version = "3.0.5";
    src = fetchPypi {
      pname = "flask_sqlalchemy";
      inherit version;
      hash = "sha256-xXZeWMoUVAG1IQbA9GF4VpJDxdolVWviwjHsxghnxbE=";
    };
    pyproject = true;
    build-system = with pyFinal; [flit-core];
    doCheck = false;
    dependencies = with pyFinal; [
      flask
      sqlalchemy
    ];
  };

  hashids = pyFinal.buildPythonPackage rec {
    pname = "hashids";
    version = "1.3.1";
    src = fetchPypi {
      pname = "hashids";
      inherit version;
      hash = "sha256-bD3HdeZe/CziwVemWst3bWNMuBRZj0BkaavvAK4/Y1w=";
    };
    pyproject = true;
    build-system = with pyFinal; [flit-core];
    doCheck = false;
  };

  shillelagh = pyFinal.buildPythonPackage rec {
    pname = "shillelagh";
    version = "1.4.3";
    src = fetchPypi {
      pname = "shillelagh";
      inherit version;
      hash = "sha256-14t8gES7EdT7kmOSpJWQfDTOxx1uQ41dEC4b/YQsMfc=";
    };
    pyproject = true;
    build-system = with pyFinal; [setuptools wheel setuptools-scm];
    doCheck = false;
    dependencies = with pyFinal; [
      apsw
      requests
      requests-cache
      sqlalchemy
      python-dateutil
      greenlet
      google-auth
      google-api-python-client
    ];
    pythonImportsCheck = ["shillelagh.adapters.api.gsheets.lib"];
  };

  wtforms-json = pyFinal.buildPythonPackage rec {
    pname = "wtforms-json";
    version = "0.3.5";
    src = fetchPypi {
      pname = "WTForms-JSON";
      inherit version;
      hash = "sha256-eCcoUmo5Y+nNhZSIlBhb/1UjPz0GgVUXVGXOzsCdIjQ=";
    };
    pyproject = true;
    build-system = with pyFinal; [setuptools wheel];
    doCheck = false;
    dependencies = with pyFinal; [wtforms six];
  };

  flask-appbuilder = pyFinal.buildPythonPackage rec {
    pname = "flask-appbuilder";
    version = "5.0.2";
    src = fetchPypi {
      pname = "flask_appbuilder";
      inherit version;
      hash = "sha256-9Xe5gqGuQLwhMjjO25PDnGfPIZmqHgBuCH6hs1B9VFA=";
    };
    pyproject = true;
    build-system = with pyFinal; [setuptools wheel];
    doCheck = false;
    dependencies = with pyFinal;
      [
        apispec
        colorama
        click
        email-validator
        flask
        flask-babel
        flask-jwt-extended
        flask-limiter
        flask-login
        flask-sqlalchemy
        flask-wtf
        jsonschema
        marshmallow
        marshmallow-sqlalchemy
        prison
        python-dateutil
        pyjwt
        sqlalchemy
        sqlalchemy-utils
        werkzeug
        wtforms
      ]
      ++ pyFinal.apispec.optional-dependencies.yaml;
  };

  # Not required by Superset core; included for the Flight SQL connector support
  # advertised by this overlay.
  flightsql-dbapi = pyFinal.buildPythonPackage rec {
    pname = "flightsql-dbapi";
    version = "0.2.2";
    src = fetchPypi {
      pname = "flightsql_dbapi";
      inherit version;
      hash = "sha256-tt5Ngfox5zV1B8PUk74xxOaGct0bSipFVEY6xEUOWFE=";
    };
    pyproject = true;
    build-system = with pyFinal; [hatchling];
    postPatch = ''
      substituteInPlace pyproject.toml --replace-fail "hatchling<=1.18.0" "hatchling"
      cat >> pyproject.toml <<EOF

      [tool.hatch.build.targets.wheel]
      packages = ["flightsql"]
      EOF
    '';
    pythonImportsCheck = ["flightsql" "flightsql.sqlalchemy"];
    dependencies = with pyFinal; [
      protobuf
      sqlalchemy
      pyarrow
    ];
  };
}
