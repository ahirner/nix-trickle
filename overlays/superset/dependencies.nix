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
    postPatch = ''
      sed -i 's/"sqlglot>=[^"]*"/"sqlglot"/g' pyproject.toml
    '';
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

  sqlglot = python.pkgs.sqlglot;

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

  redis = python.pkgs.redis;

  flask-cors = python.pkgs.flask-cors;

  sqlalchemy-utils = python.pkgs.sqlalchemy-utils.override {
    sqlalchemy = python.pkgs.sqlalchemy_1_4;
  };

  prison = python.pkgs.prison;

  flask-limiter = python.pkgs.flask-limiter;

  flask-login = python.pkgs.flask-login;

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

  marshmallow-sqlalchemy = python.pkgs.marshmallow-sqlalchemy.override {
    inherit marshmallow;
    sqlalchemy = python.pkgs.sqlalchemy_1_4;
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

  alembic = python.pkgs.alembic.override {
    sqlalchemy = python.pkgs.sqlalchemy_1_4;
  };

  flask-migrate = python.pkgs.flask-migrate.override {
    inherit alembic flask-sqlalchemy;
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
    postPatch = ''
      substituteInPlace setup.py \
        --replace-fail "Flask-Limiter>3,<4" "Flask-Limiter" \
        --replace-fail "Flask-Login>=0.3, <0.7" "Flask-Login" \
        --replace-fail "prison>=0.2.1, <1.0.0" "prison"
    '';
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
