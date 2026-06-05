{
  python,
  fetchPypi,
}: rec {
  # Custom overrides
  "apache-superset-core" = python.pkgs.buildPythonPackage rec {
    pname = "apache-superset-core";
    version = "0.1.0";
    src = fetchPypi {
      pname = "apache_superset_core";
      inherit version;
      hash = "sha256-cs3axVfyEtsw9xjvB0Glm8X1tUVZUl+aEE2cklq6GME=";
    };
    pyproject = true;
    build-system = with python.pkgs; [setuptools wheel];
    doCheck = false;
    dependencies = with python.pkgs; [
      flask-appbuilder
      pydantic
      sqlalchemy_1_4
      sqlalchemy-utils
      sqlglot
      typing-extensions
    ];
  };

  sqlglot = python.pkgs.buildPythonPackage rec {
    pname = "sqlglot";
    version = "28.10.0";
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-89R1kWSthUF2mAs6R+sMfvaZEY36gL7rk+AQiFY3shE=";
    };
    pyproject = true;
    build-system = with python.pkgs; [setuptools setuptools-scm];
    doCheck = false;
  };

  marshmallow = python.pkgs.buildPythonPackage rec {
    pname = "marshmallow";
    version = "3.26.1";
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-5tiv+2y2HTnSZAIJbcCu4S1aJtSQoSHxGNLoHcBxncY=";
    };
    pyproject = true;
    build-system = with python.pkgs; [flit-core];
    doCheck = false;
    dependencies = with python.pkgs; [packaging];
  };

  marshmallow-union = python.pkgs.buildPythonPackage rec {
    pname = "marshmallow-union";
    version = "0.1.15.post1";
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-wI8Kh4ka5z3StdShVLx9rqIMO8D5nKC2omVwySfSDIw=";
    };
    pyproject = true;
    build-system = with python.pkgs; [setuptools wheel];
    doCheck = false;
    dependencies = with python.pkgs; [marshmallow];
  };

  pygeohash = python.pkgs.buildPythonPackage rec {
    pname = "pygeohash";
    version = "3.2.2";
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-qsUHH5qQIyxQ2MahJKFQ/9twBpBTFPcqENaGoH0sUYc=";
    };
    pyproject = true;
    build-system = with python.pkgs; [setuptools wheel];
    doCheck = false;
  };

  redis = python.pkgs.buildPythonPackage rec {
    pname = "redis";
    version = "5.3.1";
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-yklXelMepkA5taNts9bNGgx6YMNBJNRpJKRblW6M8Uw=";
    };
    pyproject = true;
    build-system = with python.pkgs; [setuptools wheel];
    doCheck = false;
    dependencies = with python.pkgs; [pyjwt];
  };

  # nixpkgs has 6.0.1, but its generated dist-info reports 0.0.1.
  flask-cors = python.pkgs.buildPythonPackage rec {
    pname = "flask-cors";
    version = "6.0.1";
    src = fetchPypi {
      pname = "flask_cors";
      inherit version;
      hash = "sha256-2BvLMfB7CYW+f0hAYkfpJDrO0im3dHIZFgoFWe3WeNs=";
    };
    pyproject = true;
    build-system = with python.pkgs; [setuptools wheel];
    doCheck = false;
    dependencies = with python.pkgs; [flask werkzeug];
  };

  sqlalchemy-utils = python.pkgs.buildPythonPackage rec {
    pname = "SQLAlchemy-Utils";
    version = "0.42.1";
    src = fetchPypi {
      pname = "sqlalchemy_utils";
      inherit version;
      hash = "sha256-iB+c2eUETcj4J7zLBCXOLlVJDORPwLuEjFXMjuRMwC4=";
    };
    pyproject = true;
    build-system = with python.pkgs; [setuptools wheel];
    doCheck = false;
    dependencies = [python.pkgs.sqlalchemy_1_4];
  };

  prison = python.pkgs.buildPythonPackage rec {
    pname = "prison";
    version = "0.2.1";
    src = fetchPypi {
      pname = "prison";
      inherit version;
      hash = "sha256-5s1yQESvyxqKaTQMrS8eMVGlg5/TqAJ/0TV1ceeXxZk=";
    };
    pyproject = true;
    build-system = with python.pkgs; [setuptools wheel];
    doCheck = false;
    dependencies = with python.pkgs; [six];
  };

  flask-limiter = python.pkgs.buildPythonPackage rec {
    pname = "Flask-Limiter";
    version = "3.12";
    src = fetchPypi {
      pname = "flask_limiter";
      inherit version;
      hash = "sha256-+ePj0MSs0NH/v6cp4XGY3RBC9NI8EwrhYARPyTDiEwA=";
    };
    pyproject = true;
    build-system = with python.pkgs; [setuptools wheel];
    postPatch = ''
      substituteInPlace requirements/main.txt \
        --replace-fail "rich>=12,<14" "rich>=12"
    '';
    doCheck = false;
    dependencies = with python.pkgs; [
      flask
      limits
      ordered-set
      rich
    ];
  };

  flask-login = python.pkgs.buildPythonPackage rec {
    pname = "Flask-Login";
    version = "0.6.3";
    src = fetchPypi {
      pname = "Flask-Login";
      inherit version;
      hash = "sha256-XiPRSmB+8SgGxplZC4nQ8ODWe67sWZ11lHv5wUczAzM=";
    };
    pyproject = true;
    build-system = with python.pkgs; [setuptools wheel];
    doCheck = false;
    dependencies = with python.pkgs; [flask];
  };

  flask-sqlalchemy = python.pkgs.buildPythonPackage rec {
    pname = "Flask-SQLAlchemy";
    version = "3.0.5";
    src = fetchPypi {
      pname = "flask_sqlalchemy";
      inherit version;
      hash = "sha256-xXZeWMoUVAG1IQbA9GF4VpJDxdolVWviwjHsxghnxbE=";
    };
    pyproject = true;
    build-system = with python.pkgs; [flit-core];
    doCheck = false;
    dependencies = with python.pkgs; [
      flask
      sqlalchemy_1_4
    ];
  };

  marshmallow-sqlalchemy = python.pkgs.buildPythonPackage rec {
    pname = "marshmallow-sqlalchemy";
    version = "1.4.2";
    src = fetchPypi {
      pname = "marshmallow_sqlalchemy";
      inherit version;
      hash = "sha256-ZBAwS/mOwm6jXz+dPO6C5R/Qk8Q0YSrdMqC9zbVmj3w=";
    };
    pyproject = true;
    build-system = with python.pkgs; [flit-core];
    doCheck = false;
    dependencies = with python.pkgs; [
      marshmallow
      sqlalchemy_1_4
    ];
  };

  hashids = python.pkgs.buildPythonPackage rec {
    pname = "hashids";
    version = "1.3.1";
    src = fetchPypi {
      pname = "hashids";
      inherit version;
      hash = "sha256-bD3HdeZe/CziwVemWst3bWNMuBRZj0BkaavvAK4/Y1w=";
    };
    pyproject = true;
    build-system = with python.pkgs; [flit-core];
    doCheck = false;
  };

  shillelagh = python.pkgs.buildPythonPackage rec {
    pname = "shillelagh";
    version = "1.4.3";
    src = fetchPypi {
      pname = "shillelagh";
      inherit version;
      hash = "sha256-14t8gES7EdT7kmOSpJWQfDTOxx1uQ41dEC4b/YQsMfc=";
    };
    pyproject = true;
    build-system = with python.pkgs; [setuptools wheel setuptools-scm];
    doCheck = false;
    dependencies = with python.pkgs; [
      apsw
      requests
      requests-cache
      sqlalchemy_1_4
      python-dateutil
      greenlet
      google-auth
      google-api-python-client
    ];
  };

  wtforms-json = python.pkgs.buildPythonPackage rec {
    pname = "wtforms-json";
    version = "0.3.5";
    src = fetchPypi {
      pname = "WTForms-JSON";
      inherit version;
      hash = "sha256-eCcoUmo5Y+nNhZSIlBhb/1UjPz0GgVUXVGXOzsCdIjQ=";
    };
    pyproject = true;
    build-system = with python.pkgs; [setuptools wheel];
    doCheck = false;
    dependencies = with python.pkgs; [wtforms six];
  };

  alembic = python.pkgs.buildPythonPackage rec {
    pname = "alembic";
    version = "1.17.2";
    src = fetchPypi {
      pname = "alembic";
      inherit version;
      hash = "sha256-u+l1FwXF4PFId/AtRsU9EIheN349kO2oEKAW+bqhno4=";
    };
    pyproject = true;
    build-system = with python.pkgs; [setuptools wheel];
    doCheck = false;
    dependencies = with python.pkgs; [
      mako
      python-dateutil
      sqlalchemy_1_4
      typing-extensions
    ];
  };

  flask-migrate = python.pkgs.buildPythonPackage rec {
    pname = "Flask-Migrate";
    version = "4.1.0";
    src = fetchPypi {
      pname = "flask_migrate";
      inherit version;
      hash = "sha256-GjNrBussOs4AX18t7YZB1TTBh5jWQGH2/xH3nhQ0Em0=";
    };
    pyproject = true;
    build-system = with python.pkgs; [setuptools wheel];
    doCheck = false;
    dependencies = [
      alembic
      flask-sqlalchemy
      python.pkgs.flask
    ];
  };

  flask-appbuilder = python.pkgs.buildPythonPackage rec {
    pname = "flask-appbuilder";
    version = "5.0.2";
    src = fetchPypi {
      pname = "flask_appbuilder";
      inherit version;
      hash = "sha256-9Xe5gqGuQLwhMjjO25PDnGfPIZmqHgBuCH6hs1B9VFA=";
    };
    pyproject = true;
    build-system = with python.pkgs; [setuptools wheel];
    doCheck = false;
    dependencies =
      [flask-limiter flask-login prison sqlalchemy-utils python.pkgs.sqlalchemy_1_4 flask-sqlalchemy marshmallow marshmallow-sqlalchemy]
      ++ (with python.pkgs; [
        apispec
        colorama
        click
        email-validator
        flask
        flask-babel
        flask-wtf
        flask-jwt-extended
        jsonschema
        python-dateutil
        pyjwt
      ]);
  };

  # Not required by Superset core; included for the Flight SQL connector support
  # advertised by this overlay.
  flightsql-dbapi = python.pkgs.buildPythonPackage rec {
    pname = "flightsql-dbapi";
    version = "0.2.2";
    src = fetchPypi {
      pname = "flightsql_dbapi";
      inherit version;
      hash = "sha256-tt5Ngfox5zV1B8PUk74xxOaGct0bSipFVEY6xEUOWFE=";
    };
    pyproject = true;
    build-system = with python.pkgs; [hatchling];
    postPatch = ''
      substituteInPlace pyproject.toml --replace-fail "hatchling<=1.18.0" "hatchling"
      cat >> pyproject.toml <<EOF

      [tool.hatch.build.targets.wheel]
      packages = ["flightsql"]
      EOF
    '';
    #doCheck = false;
    dependencies = with python.pkgs; [
      protobuf
      sqlalchemy_1_4
      pyarrow
    ];
  };
}
