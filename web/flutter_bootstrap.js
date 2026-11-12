{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();

    const startup = document.getElementById('startup');
    if (startup) {
      startup.classList.add('startup--hide');
      window.setTimeout(() => startup.remove(), 220);
    }
  },
});

