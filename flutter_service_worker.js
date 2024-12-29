'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "c71a09214cb6f5f8996a531350400a9a",
"main.dart.js": "9f0d556f9ce5afd8d8e9d287d4f9cf8e",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin": "35f7bb5f83c57a3ec2feed2096ac1a81",
"assets/fonts/MaterialIcons-Regular.otf": "05dd197b9f4f400fcd14a992808f711a",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/assets/changelog.md": "37b3a93954edcadfe11feeed9c82757f",
"assets/assets/items/pokedex.png": "57d29ff98723319efa6f03093fafec3f",
"assets/assets/items/potion.png": "e8288718c48ee3087e857fbaaf103e4a",
"assets/assets/items/super-potion.png": "5952c706cf05bc08c4c33c0544537ff6",
"assets/assets/items/town-map.webp": "063f86752c1151824bad1e1edda74721",
"assets/assets/otherLogo.png": "df6fe2ace1d5241028f5a8be2b60044d",
"assets/assets/video/background.mp4": "6ef499e00ff81eef019b3ea19838d43c",
"assets/assets/type_icons/ground.png": "b3a10048dd75b4d8d2371c4b5048a447",
"assets/assets/type_icons/poison.png": "37b74c4b3d3b7cf34b5709fd271fba22",
"assets/assets/type_icons/rock.png": "706e0b592c03a13908373dfdb554055c",
"assets/assets/type_icons/grass.png": "767f0c2b8113906fade044ef7afb0a90",
"assets/assets/type_icons/fairy.png": "95cd9cabf9772c2491a4c3eb33349d0f",
"assets/assets/type_icons/normal.png": "c08982c6ba1b4f182e4dac9d5c847a9d",
"assets/assets/type_icons/fighting.png": "338290d07ad48ef152f6c2174bacaa9c",
"assets/assets/type_icons/steel.png": "e35f75472d7e926a7410736879e56756",
"assets/assets/type_icons/dragon.png": "cfe1a2a5b2a28903a43c0812f46b1efe",
"assets/assets/type_icons/electric.png": "17cc65fc25e43a5e6fc6cc74c23b8c80",
"assets/assets/type_icons/bug.png": "be48844be5d91636cbfef9af57da445b",
"assets/assets/type_icons/fire.png": "4fef1834dc21133e84c30ff1d4064700",
"assets/assets/type_icons/flying.png": "c214e2f5e717de5dad4d39a871c85745",
"assets/assets/type_icons/ice.png": "857431e75308fb6b68c162913547319b",
"assets/assets/type_icons/ghost.png": "5e7b5554ecf89488e497fbda9f605286",
"assets/assets/type_icons/water.png": "668cdba9b6ff4258277a620a5fdf9ab9",
"assets/assets/type_icons/dark.png": "0c80c485ede0e7e57d34342f863be4c1",
"assets/assets/type_icons/psychic.png": "0b5a2e888f37ce3155acf196b3c7c740",
"assets/assets/no-pokemon.png": "258aadd45ed70f104d0f0ad1afad106d",
"assets/assets/logo.png": "0f073d823e074a7f97239cfe98da2389",
"assets/NOTICES": "1313da3c73a629fb63d9e5289eb55e2f",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.json": "9f136330d88b7e9c78905c5e29ae3e4e",
"assets/AssetManifest.bin.json": "2ddedd344a731d416b91e3263859cd4d",
"index.html": "941a759ac1e44a672be06c15823accec",
"/": "941a759ac1e44a672be06c15823accec",
"manifest.json": "97b7071797a273634ff4e1155a5a7f46",
"canvaskit/canvaskit.js": "c86fbd9e7b17accae76e5ad116583dc4",
"canvaskit/canvaskit.js.symbols": "38cba9233b92472a36ff011dc21c2c9f",
"canvaskit/chromium/canvaskit.js": "43787ac5098c648979c27c13c6f804c3",
"canvaskit/chromium/canvaskit.js.symbols": "4525682ef039faeb11f24f37436dca06",
"canvaskit/chromium/canvaskit.wasm": "f5934e694f12929ed56a671617acd254",
"canvaskit/skwasm.js": "445e9e400085faead4493be2224d95aa",
"canvaskit/skwasm.js.symbols": "741d50ffba71f89345996b0aa8426af8",
"canvaskit/canvaskit.wasm": "3d2a2d663e8c5111ac61a46367f751ac",
"canvaskit/skwasm.wasm": "e42815763c5d05bba43f9d0337fa7d84",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"icons/Icon-maskable-192.png": "66e2c14bc394dd886a81496e96088321",
"icons/Icon-192.png": "66e2c14bc394dd886a81496e96088321",
"icons/Icon-512.png": "0f073d823e074a7f97239cfe98da2389",
"icons/Icon-maskable-512.png": "0f073d823e074a7f97239cfe98da2389",
"favicon.png": "f4f4b81542df56ad0521e7909547fca0",
"version.json": "2b66675020b7a5b9bfd896fd039612b9"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
