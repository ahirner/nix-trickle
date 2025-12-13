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
    build-system = with python3.pkgs; [ setuptools wheel ];
    doCheck = false;
    dependencies = [ python3.pkgs.sqlalchemy_1_4 ];
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
    build-system = with python3.pkgs; [ setuptools wheel ];
    doCheck = false;
    dependencies = with python3.pkgs; [ six ];
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
    build-system = with python3.pkgs; [ setuptools wheel ];
    doCheck = false;
    dependencies = with python3.pkgs; [ flask ];
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
    build-system = with python3.pkgs; [ setuptools wheel ];
    doCheck = false;
    dependencies = [ flask-login prison sqlalchemy-utils python3.pkgs.sqlalchemy_1_4 ] ++ (with python3.pkgs; [
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

    dependencies = [ flask-appbuilder flask-login sqlalchemy-utils python3.pkgs.sqlalchemy_1_4 ] ++ (with python3.pkgs; [
      backoff
      celery
      click
      colorama
      flask-cors
      croniter
      cryptography
      deprecation
      flask
      flask-caching
      flask-compress
      flask-talisman
      flask-migrate
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
      numpy
      packaging
      pandas
      bottleneck
      parsedatetime
      paramiko
      pillow
      # polyline
      pydantic
      pyparsing
      python-dateutil
      python-dotenv
      # python-geohash
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
      # wtforms-json
      xlsxwriter
    ]);

    meta = {
      description = "Data Visualization and Exploration Platform";
      homepage = "https://superset.apache.org";
      changelog = "https://github.com/apache/superset/blob/master/CHANGELOG/${version}.md"; # not for rc
      license = lib.licenses.asl20;
      mainProgram = "superset";
    };
  };
}
