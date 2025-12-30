{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchFromGitHub,
  python,
  curl,
}: let
  customDeps = import ./dependencies.nix {
    inherit fetchPypi python;
  };
  pname = "superset";
  versionBase = "6.0.0";
  rc = "";
  version = "${versionBase}${rc}";
  src = fetchPypi {
    inherit version;
    pname = "apache_superset";
    hash = "sha256-K+2pzFYdyildS6CZVK32lFuYKwM9nHwup3lj+7bDNdo=";
  };

  # Fetch tests from GitHub since they are missing in PyPI package
  srcTests = fetchFromGitHub {
    owner = "apache";
    repo = pname;
    rev = version;
    hash = "sha256-lHHbSBSPT8UUAYmlpDHuwdhyy8u4/emydoPa9G8uXZ8=";
  };
in
  buildPythonPackage {
    inherit pname version src;

    postPatch = ''
      # Relax dependencies
      sed -i 's/"flask-cors>=[^"]*"/"flask-cors"/g' pyproject.toml
      sed -i 's/"cryptography>=[^"]*"/"cryptography"/g' pyproject.toml
      sed -i 's/"flask>=[^"]*"/"flask"/g' pyproject.toml
      sed -i 's/"flask-migrate>=[^"]*"/"flask-migrate"/g' pyproject.toml
      sed -i 's/"greenlet>=[^"]*"/"greenlet"/g' pyproject.toml
      sed -i 's/"msgpack>=[^"]*"/"msgpack"/g' pyproject.toml
      sed -i 's/"numpy>[^"]*"/"numpy"/g' pyproject.toml
      sed -i 's/"pandas\[excel\]>=[^"]*"/"pandas[excel]"/g' pyproject.toml
      sed -i 's/"Pillow>=[^"]*"/"Pillow"/g' pyproject.toml
      sed -i 's/"pyarrow>=[^"]*"/"pyarrow"/g' pyproject.toml
      sed -i 's/"redis>=[^"]*"/"redis"/g' pyproject.toml
      sed -i 's/"sqlalchemy-utils>=[^"]*"/"sqlalchemy-utils"/g' pyproject.toml
      sed -i 's/"xlsxwriter>=[^"]*"/"xlsxwriter"/g' pyproject.toml

      # Fix for numpy 2.0 (AttributeError: module 'numpy' has no attribute 'product')
      substituteInPlace superset/utils/pandas_postprocessing/utils.py \
        --replace-fail "np.product" "np.prod"
    '';

    pyproject = true;
    build-system = with python.pkgs; [setuptools wheel];

    nativeCheckInputs = with python.pkgs; [
      pytest
      pytest-mock
      freezegun
      curl
    ];

    doCheck = true;
    checkPhase = ''
      export HOME=$(mktemp -d)
      export SUPERSET_HOME=$HOME

      cp -r ${srcTests}/tests .

      # Run specific unit tests that don't require external services
      pytest tests/unit_tests/utils/date_parser_tests.py
      pytest tests/unit_tests/utils/json_tests.py
    '';

    # Using postInstall to run the initialization check after the package is installed
    # This ensures the binary is available and works correctly
    postInstall = ''
      set -e
      export SUPERSET_SECRET_KEY="testing_secret_key_12345"
      export SUPERSET_HOME=$(mktemp -d)
      export PATH=$out/bin:$PATH

      echo "Running superset version..."
      superset version

      echo "Running db upgrade..."
      superset db upgrade

      echo "Creating admin user..."
      superset fab create-admin \
          --username admin \
          --firstname Superset \
          --lastname Admin \
          --email admin@superset.com \
          --password admin

      echo "Initializing roles..."
      superset init

      echo "Starting server for integration check..."
      superset run -p 8088 --with-threads > superset.log 2>&1 &
      SERVER_PID=$!

      echo "Waiting for server to start..."
      for i in {1..30}; do
        if curl -s -o /dev/null http://localhost:8088/health; then
          echo "Server is up!"
          break
        fi
        if ! kill -0 $SERVER_PID 2>/dev/null; then
          echo "Server died unexpectedly!"
          cat superset.log
          exit 1
        fi
        sleep 2
      done

      if ! curl -s -o /dev/null http://localhost:8088/health; then
        echo "Server failed to start in time"
        cat superset.log
        kill $SERVER_PID || true
        exit 1
      fi

      echo "Integration check passed: /health endpoint reachable"
      kill $SERVER_PID || true
    '';

    dependencies =
      (builtins.attrValues customDeps)
      ++ (with python.pkgs; [
        python.pkgs.sqlalchemy_1_4

        backoff
        bottleneck
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
        flask-cors
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
        marshmallow
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
        redis
        selenium
        simplejson
        slack-sdk
        sqlglot
        sshtunnel
        tabulate
        typing-extensions
        watchdog
        wtforms
        xlsxwriter
        # Database Drivers
        psycopg2
      ]);

    # saves ca. 10min build time:
    dontStrip = true;

    passthru.deps = customDeps;
    meta = {
      description = "Data Visualization and Exploration Platform";
      homepage = "https://superset.apache.org";
      changelog = "https://github.com/apache/superset/blob/master/CHANGELOG/${versionBase}.md";
      license = lib.licenses.asl20;
      mainProgram = "superset";
    };
  }
