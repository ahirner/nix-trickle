{
  python,
  fetchPypi,
}: rec {
  # Custom overrides
  sqlalchemy-utils = python.pkgs.buildPythonPackage rec {
    pname = "SQLAlchemy-Utils";
    version = "0.38.3";
    src = fetchPypi {
      pname = "SQLAlchemy-Utils";
      inherit version;
      hash = "sha256-n5r7pgekBFXPcDrfqYRlhL8mFooMWmCnAGO3DWUFH00=";
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
    build-system = with python.pkgs; [setuptools wheel flit-core];
    doCheck = false;
    dependencies = with python.pkgs; [
      flask
      sqlalchemy_1_4
    ];
  };

  marshmallow-sqlalchemy = python.pkgs.buildPythonPackage rec {
    pname = "marshmallow-sqlalchemy";
    version = "0.29.0";
    src = fetchPypi {
      pname = "marshmallow-sqlalchemy";
      inherit version;
      hash = "sha256-NSOndDkO8MHA98cIp1GYCcU5bPYIcg8U9Vw290/1u+w=";
    };
    pyproject = true;
    build-system = with python.pkgs; [setuptools wheel];
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
    build-system = with python.pkgs; [setuptools wheel flit-core];
    doCheck = false;
  };

  python-geohash = python.pkgs.buildPythonPackage rec {
    pname = "python-geohash";
    version = "0.8.5";
    src = fetchPypi {
      pname = "python-geohash";
      inherit version;
      hash = "sha256-BaIfz07aGl7dvSkYkK3iP8Xdqmu5jy7iPS04TtFPCG0=";
    };
    pyproject = true;
    build-system = with python.pkgs; [setuptools wheel];
    doCheck = false;
    dependencies = with python.pkgs; [setuptools];
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
      [flask-login prison sqlalchemy-utils python.pkgs.sqlalchemy_1_4 flask-sqlalchemy marshmallow-sqlalchemy]
      ++ (with python.pkgs; [
        apispec
        colorama
        click
        email-validator
        flask
        flask-babel
        flask-limiter
        flask-wtf
        flask-jwt-extended
        jsonschema
        marshmallow
        python-dateutil
        pyjwt
      ]);
  };

  flightsql-dbapi = python.pkgs.buildPythonPackage rec {
    pname = "flightsql-dbapi";
    version = "0.2.2";
    src = fetchPypi {
      pname = "flightsql_dbapi";
      inherit version;
      sha256 = "b6de4d81fa31e7357507c3d493be31c4e68672dd1b4a2a4554463ac4450e5851";
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
