{{flutter_js}}
{{flutter_build_config}}

// Expose unique build hash and append ?v=<hash> to main entry scripts so browsers
// automatically fetch new deployments even if old bare URLs were cached.
window.__MY_VOCAB_BUILD_VERSION = String({{flutter_service_worker_version}});

(function() {
  var rawVersion = window.__MY_VOCAB_BUILD_VERSION;
  var buildVersion = (rawVersion && rawVersion !== "null" && rawVersion.indexOf('{{') === -1)
    ? rawVersion.replace(/[^a-zA-Z0-9_-]/g, '')
    : "";
  window.__MY_VOCAB_BUILD_VERSION = buildVersion;

  if (buildVersion && window._flutter && window._flutter.buildConfig && window._flutter.buildConfig.builds) {
    window._flutter.buildConfig.builds.forEach(function(build) {
      if (build.mainJsPath && build.mainJsPath.indexOf('?') === -1) {
        build.mainJsPath = build.mainJsPath + '?v=' + buildVersion;
      }
      if (build.mainWasmPath && build.mainWasmPath.indexOf('?') === -1) {
        build.mainWasmPath = build.mainWasmPath + '?v=' + buildVersion;
      }
      if (build.jsSupportRuntimePath && build.jsSupportRuntimePath.indexOf('?') === -1) {
        build.jsSupportRuntimePath = build.jsSupportRuntimePath + '?v=' + buildVersion;
      }
    });
  }
})();

_flutter.loader.load();
