{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchFromGitHub,
  python,
}: let
  pname = "superset";
  versionBase = "6.1.0";
  rc = "";
  version = "${versionBase}${rc}";
  src = fetchPypi {
    inherit version;
    pname = "apache_superset";
    hash = "sha256-VpduV3OGT5BuMKaJ3sJkHlVChui+hg7MHj1P9f9rLjI=";
  };

  # Fetch tests from GitHub since they are missing in PyPI package
  srcTests = fetchFromGitHub {
    owner = "apache";
    repo = pname;
    rev = version;
    hash = "sha256-BT6tOIHR/OYFaWRG6pJbbtLbo+3qyMTSNkF+1fvGwvM=";
  };
in
  buildPythonPackage {
    inherit pname version src;

    pythonRelaxDeps = [
      "cryptography"
      "flask-cors"
      "flask-migrate"
      "greenlet"
      "msgpack"
      "nh3"
      "redis"
      "pyarrow"
      "xlsxwriter"
    ];

    pyproject = true;
    build-system = with python.pkgs; [setuptools wheel];

    nativeCheckInputs = with python.pkgs; [
      pytest
      pytest-mock
      freezegun
    ];

    doCheck = true;
    checkPhase = ''
      runHook preCheck
      export SUPERSET_HOME=$(mktemp -d)
      export SUPERSET_SECRET_KEY="nix-build-only-secret-key-never-use-in-production"

      cp -r ${srcTests}/tests .

      pytest --confcutdir=tests/unit_tests \
        tests/unit_tests/utils/date_parser_tests.py \
        tests/unit_tests/utils/json_tests.py
      runHook postCheck
    '';

    dependencies = with python.pkgs;
      [
        apache-superset-core
        flask-appbuilder
        flask-cors
        flask-limiter
        flask-login
        flask-migrate
        flask-sqlalchemy
        flightsql-dbapi
        hashids
        marshmallow
        marshmallow-sqlalchemy
        marshmallow-union
        packaging
        pygeohash
        redis
        shillelagh
        sqlalchemy
        sqlalchemy-utils
        sqlglot
        wtforms-json

        backoff
        bottleneck
        cachetools
        celery
        click
        click-option-group
        colorama
        cron-descriptor
        croniter
        cryptography
        deprecation
        flask
        flask-caching
        flask-compress
        flask-session
        flask-talisman
        flask-wtf
        geopy
        google-api-python-client
        google-auth
        greenlet
        gunicorn
        holidays
        humanize
        isodate
        jsonpath-ng
        mako
        markdown
        msgpack
        nh3
        numpy
        pandas
        paramiko
        parsedatetime
        pgsanity
        pillow
        polyline
        pyarrow
        pydantic
        pyjwt
        pyparsing
        python-dateutil
        python-dotenv
        pyyaml
        rich
        selenium
        simplejson
        slack-sdk
        sshtunnel
        tabulate
        typing-extensions
        watchdog
        wtforms
        xlsxwriter
        # Database Drivers
        psycopg2
      ]
      ++ python.pkgs.pandas.optional-dependencies.excel;

    # saves ca. 10min build time:
    dontStrip = true;

    passthru = {inherit python;};
    meta = {
      description = "Data Visualization and Exploration Platform";
      homepage = "https://superset.apache.org";
      changelog = "https://github.com/apache/superset/blob/master/CHANGELOG/${versionBase}.md";
      license = lib.licenses.asl20;
      mainProgram = "superset";
    };
  }
