part of coveralls;

/// Provides access to the coverage settings.
class Configuration extends MapBase<String, String> {

  /// The coverage parameters.
  final Map<String, dynamic> _params;

  /// Creates a new configuration from the specified [map].
  Configuration([Map<String, dynamic> map]): _params = map ?? {};

  /// Creates a new configuration from the variables of the specified [environment].
  /// If [environment] is not provided, it defaults to [Platform.environment].
  Configuration.fromEnvironment([Map<String, String> environment]): _params = {} {
    if (environment == null) environment = Platform.environment;

    // Standard.
    var serviceName = environment['CI_NAME'] ?? '';
    if (serviceName.isNotEmpty) this['service_name'] = serviceName;

    if (environment.containsKey('CI_BRANCH')) this['service_branch'] = environment['CI_BRANCH'];
    if (environment.containsKey('CI_BUILD_NUMBER')) this['service_number'] = environment['CI_BUILD_NUMBER'];
    if (environment.containsKey('CI_BUILD_URL')) this['service_build_url'] = environment['CI_BUILD_URL'];
    if (environment.containsKey('CI_COMMIT')) this['commit_sha'] = environment['CI_COMMIT'];
    if (environment.containsKey('CI_JOB_ID')) this['service_job_id'] = environment['CI_JOB_ID'];

    if (environment.containsKey('CI_PULL_REQUEST')) {
      var matches = new RegExp(r'(\d+)$').allMatches(environment['CI_PULL_REQUEST']);
      if (matches.isNotEmpty && matches.first.groupCount >= 1) this['service_pull_request'] = matches.first[1];
    }

    // Coveralls.
    if (environment.containsKey('COVERALLS_REPO_TOKEN') || environment.containsKey('COVERALLS_TOKEN'))
      this['repo_token'] = environment['COVERALLS_REPO_TOKEN'] ?? environment['COVERALLS_TOKEN'];

    if (environment.containsKey('COVERALLS_COMMIT_SHA')) this['commit_sha'] = environment['COVERALLS_COMMIT_SHA'];
    if (environment.containsKey('COVERALLS_PARALLEL')) this['parallel'] = environment['COVERALLS_PARALLEL'];
    if (environment.containsKey('COVERALLS_RUN_AT')) this['run_at'] = environment['COVERALLS_RUN_AT'];
    if (environment.containsKey('COVERALLS_SERVICE_BRANCH')) this['service_branch'] = environment['COVERALLS_SERVICE_BRANCH'];
    if (environment.containsKey('COVERALLS_SERVICE_JOB_ID')) this['service_job_id'] = environment['COVERALLS_SERVICE_JOB_ID'];
    if (environment.containsKey('COVERALLS_SERVICE_NAME')) this['service_name'] = environment['COVERALLS_SERVICE_NAME'];

    // CI services.
    if (environment.containsKey('TRAVIS')) addAll(travis_ci.configuration);
    else if (environment.containsKey('APPVEYOR')) addAll(appveyor.configuration);
    else if (environment.containsKey('CIRCLECI')) addAll(circleci.configuration);
    else if (serviceName == 'codeship') addAll(codeship.configuration);
    else if (environment.containsKey('GITLAB_CI')) addAll(gitlab_ci.configuration);
    else if (environment.containsKey('JENKINS_URL')) addAll(jenkins.configuration);
    else if (environment.containsKey('SEMAPHORE')) addAll(semaphore.configuration);
    else if (environment.containsKey('SURF_SHA1')) addAll(surf.configuration);
    else if (environment.containsKey('TDDIUM')) addAll(solano_ci.configuration);
    else if (environment.containsKey('WERCKER')) addAll(wercker.configuration);
  }

  /// Creates a new configuration from the specified YAML [document].
  Configuration.fromYaml(String document): this(loadYaml(document));

  /// The keys of this configuration.
  @override
  Iterable<String> get keys => _params.keys;

  /// Returns the value for the given [key] or `null` if [key] is not in the map.
  @override
  String operator [](Object key) => _params[key];

  /// Associates the [key] with the given [value].
  @override
  void operator []=(String key, dynamic value) => _params[key] = value;

  /// Removes all pairs from this configuration.
  @override
  void clear() => _params.clear();

  /// Loads the default configuration.
  /// The default values are read from the `.coveralls.yml` file and the environment variables.
  static Future<Configuration> loadDefaults() async {
    var defaults = new Configuration();

    var file = new File('${Directory.current.path}/.coveralls.yml');
    if (await file.exists()) defaults.addAll(new Configuration.fromYaml(await file.readAsString()));

    defaults.addAll(new Configuration.fromEnvironment());
    return defaults;
  }

  /// Removes the specified [key] and its associated value from this configuration.
  /// Returns the value associated with [key] before it was removed.
  @override
  String remove(Object key) => _params.remove(key);

  /// Converts this object to a map in JSON format.
  Map<String, dynamic> toJson() => _params;

  /// Returns a string representation of this object.
  @override
  String toString() => '$runtimeType ${JSON.encode(this)}';
}
