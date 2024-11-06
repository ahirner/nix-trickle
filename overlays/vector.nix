final: prev: {
  vector = prev.vector.overrideAttrs (_: {
    buildNoDefaultFeatures = true;
    buildFeatures = [
      "api"
      "api-client"
      "enrichment-tables"
      "sinks"
      "sources"
      "sources-dnstap"
      "transforms"
      "component-validation-runner"
    ];
  });
}
