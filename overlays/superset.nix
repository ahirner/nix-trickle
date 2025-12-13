final: prev: let
  inherit (prev) lib;
  python3 = prev.python3;

  pname = "superset";
  version = "6.0.0rc4";
  src = prev.fetchFromGitHub {
    owner = "apache";
    repo = pname;
    rev = "${version}";
    hash = "sha256-lHHbSBSPT8UUAYmlpDHuwdhyy8u4/emydoPa9G8uXZ8=";
  };

  sqlalchemy-utils = python3.pkgs.buildPythonPackage rec {
    pname = "SQLAlchemy-Utils";
    version = "0.38.3";
    src = prev.fetchPypi {
      pname = "SQLAlchemy-Utils";
      inherit version;
      hash = "sha256-n5r7pgekBFXPcDrfqYRlhL8mFooMWmCnAGO3DWUFH00=";
    };
    pyproject = true;
    build-system = with python3.pkgs; [setuptools wheel];
    doCheck = false;
    dependencies = [python3.pkgs.sqlalchemy_1_4];
  };

  prison = python3.pkgs.buildPythonPackage rec {
    pname = "prison";
    version = "0.2.1";
    src = prev.fetchPypi {
      pname = "prison";
      inherit version;
      hash = "sha256-5s1yQESvyxqKaTQMrS8eMVGlg5/TqAJ/0TV1ceeXxZk=";
    };
    pyproject = true;
    build-system = with python3.pkgs; [setuptools wheel];
    doCheck = false;
    dependencies = with python3.pkgs; [six];
  };

  flask-login = python3.pkgs.buildPythonPackage rec {
    pname = "Flask-Login";
    version = "0.6.3";
    src = prev.fetchPypi {
      pname = "Flask-Login";
      inherit version;
      hash = "sha256-XiPRSmB+8SgGxplZC4nQ8ODWe67sWZ11lHv5wUczAzM=";
    };
    pyproject = true;
    build-system = with python3.pkgs; [setuptools wheel];
    doCheck = false;
    dependencies = with python3.pkgs; [flask];
  };

  flask-sqlalchemy = python3.pkgs.buildPythonPackage rec {
    pname = "Flask-SQLAlchemy";
    version = "3.0.5";
    src = prev.fetchPypi {
      pname = "flask_sqlalchemy";
      inherit version;
      hash = "sha256-xXZeWMoUVAG1IQbA9GF4VpJDxdolVWviwjHsxghnxbE=";
    };
    pyproject = true;
    build-system = with python3.pkgs; [setuptools wheel flit-core];
    doCheck = false;
    dependencies = with python3.pkgs; [
      flask
      sqlalchemy_1_4
    ];
  };

  marshmallow-sqlalchemy = python3.pkgs.buildPythonPackage rec {
    pname = "marshmallow-sqlalchemy";
    version = "0.29.0";
    src = prev.fetchPypi {
      pname = "marshmallow-sqlalchemy";
      inherit version;
      hash = "sha256-NSOndDkO8MHA98cIp1GYCcU5bPYIcg8U9Vw290/1u+w=";
    };
    pyproject = true;
    build-system = with python3.pkgs; [setuptools wheel];
    doCheck = false;
    dependencies = with python3.pkgs; [
      marshmallow
      sqlalchemy_1_4
    ];
  };

  hashids = python3.pkgs.buildPythonPackage rec {
    pname = "hashids";
    version = "1.3.1";
    src = prev.fetchPypi {
      pname = "hashids";
      inherit version;
      hash = "sha256-bD3HdeZe/CziwVemWst3bWNMuBRZj0BkaavvAK4/Y1w=";
    };
    pyproject = true;
    build-system = with python3.pkgs; [setuptools wheel flit-core];
    doCheck = false;
  };

  python-geohash = python3.pkgs.buildPythonPackage rec {
    pname = "python-geohash";
    version = "0.8.5";
    src = prev.fetchPypi {
      pname = "python-geohash";
      inherit version;
      hash = "sha256-BaIfz07aGl7dvSkYkK3iP8Xdqmu5jy7iPS04TtFPCG0=";
    };
    pyproject = true;
    build-system = with python3.pkgs; [setuptools wheel];
    doCheck = false;
  };

  shillelagh = python3.pkgs.buildPythonPackage rec {
    pname = "shillelagh";
    version = "1.3.1"; # Using a version that satisfies superset's requirement >=1.4.3 is problematic if not easily available, let's try latest on pypi
    # Superset wants shillelagh[gsheetsapi]>=1.4.3, <2.0
    # Let's target 1.4.3
    src = prev.fetchPypi {
      pname = "shillelagh";
      version = "1.3.0";
      hash = "sha256-4cD+xthzYCJ7XhoRNZOBG6NrkPMAv12aAEDnmTey76c=";
    };
    pyproject = true;
    build-system = with python3.pkgs; [setuptools wheel setuptools-scm];
    doCheck = false;
    dependencies = with python3.pkgs; [
      # minimal deps for now
      apsw
      requests
      requests-cache
      sqlalchemy_1_4
      python-dateutil
      greenlet
    ];
  };

  wtforms-json = python3.pkgs.buildPythonPackage rec {
    pname = "wtforms-json";
    version = "0.3.5";
    src = prev.fetchPypi {
      pname = "WTForms-JSON";
      inherit version;
      hash = "sha256-eCcoUmo5Y+nNhZSIlBhb/1UjPz0GgVUXVGXOzsCdIjQ=";
    };
    pyproject = true;
    build-system = with python3.pkgs; [setuptools wheel];
    doCheck = false;
    dependencies = with python3.pkgs; [wtforms six];
  };

  alembic = python3.pkgs.buildPythonPackage rec {
    pname = "alembic";
    version = "1.13.3";
    src = prev.fetchPypi {
      pname = "alembic";
      inherit version;
      hash = "sha256-IDUDEXQVVh4gOqFFQXQGQ6YR9kFRfwIJ/K5j6foJ8aI=";
    };
    pyproject = true;
    build-system = with python3.pkgs; [setuptools wheel];
    doCheck = false;
    dependencies = with python3.pkgs; [
      mako
      python-dateutil
      sqlalchemy_1_4
      typing-extensions
    ];
  };

  flask-migrate = python3.pkgs.buildPythonPackage rec {
    pname = "Flask-Migrate";
    version = "4.0.7";
    src = prev.fetchPypi {
      pname = "Flask-Migrate";
      inherit version;
      hash = "sha256-3/fdJRE8IQsGmvKA6nE7iD84QMHjRVJ0dF1zVXeMhiI=";
    };
    pyproject = true;
    build-system = with python3.pkgs; [setuptools wheel];
    doCheck = false;
    dependencies = with python3.pkgs; [
      alembic
      flask
      flask-sqlalchemy
    ];
  };

  flask-appbuilder = python3.pkgs.buildPythonPackage rec {
    pname = "flask-appbuilder";
    version = "5.0.2";
    src = prev.fetchPypi {
      pname = "flask_appbuilder";
      inherit version;
      hash = "sha256-9Xe5gqGuQLwhMjjO25PDnGfPIZmqHgBuCH6hs1B9VFA=";
    };
    pyproject = true;
    build-system = with python3.pkgs; [setuptools wheel];
    doCheck = false;
    dependencies =
      [flask-login prison sqlalchemy-utils python3.pkgs.sqlalchemy_1_4]
      ++ (with python3.pkgs; [
        apispec
        colorama
        click
        email-validator
        flask
        flask-babel
        flask-limiter
        flask-sqlalchemy
        flask-wtf
        flask-jwt-extended
        jsonschema
        marshmallow
        marshmallow-sqlalchemy
        python-dateutil
        pyjwt
      ]);
  };
in {
  superset = python3.pkgs.buildPythonApplication {
    inherit src pname version;

    pyproject = true;
    build-system = with python3.pkgs; [setuptools wheel];

    dependencies =
      [flask-appbuilder flask-migrate flask-login hashids python-geohash shillelagh sqlalchemy-utils python3.pkgs.sqlalchemy_1_4 wtforms-json]
      ++ (with python3.pkgs; [
        backoff
        celery
        click
        click-option-group
        colorama
        flask-cors
        croniter
        cron-descriptor
        cryptography
        deprecation
        flask
        flask-caching
        flask-compress
        flask-talisman
        flask-session
        flask-wtf
        geopy
        greenlet
        gunicorn
        holidays
        humanize
        isodate
        jsonpath-ng
        mako
        markdown
        marshmallow
        msgpack
        nh3
        numpy
        pandas
        bottleneck
        parsedatetime
        paramiko
        pgsanity
        pillow
        polyline
        pydantic
        pyparsing
        python-dateutil
        python-dotenv
        pyarrow
        pyyaml
        pyjwt
        redis
        selenium
        sshtunnel
        simplejson
        slack-sdk
        sqlglot
        tabulate
        typing-extensions
        watchdog
        wtforms
        xlsxwriter
      ]);

    meta = {
      description = "Data Visualization and Exploration Platform";
      homepage = "https://superset.apache.org";
      changelog = "https://github.com/apache/superset/blob/master/CHANGELOG/${version}.md"; # not for rc
      license = lib.licenses.asl20;
      mainProgram = "superset";
    };

    dontCheckRuntimeDeps = true;
  };
}
