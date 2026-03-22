//
//  BohrModel3DView.swift
//  Periodic Table
//
//  Displays the 3D Bohr model (GLB) from Bowserinator bohr_model_3d URL using WebKit + Three.js.
//

import SwiftUI
import WebKit

struct BohrModel3DView: View {
    let modelURL: URL
    var height: CGFloat = 216

    var body: some View {
        BohrModel3DWebView(url: modelURL)
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
    }
}

private struct BohrModel3DWebView: UIViewRepresentable {
    let url: URL

    final class Coordinator {
        var lastHTML: String?
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let html = makeHTML(glbURL: url.absoluteString)
        // Avoid reloading the entire Three.js scene on every SwiftUI update
        // when the content hasn't changed. This reduces repeated allocations
        // and helps WebKit reclaim GPU/JS memory more predictably.
        if context.coordinator.lastHTML != html {
            context.coordinator.lastHTML = html
            webView.loadHTMLString(html, baseURL: nil)
        }
    }

    private func makeHTML(glbURL: String) -> String {
        let escaped = glbURL
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\n", with: "\\n")
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
            <style> body { margin: 0; background: transparent; overflow: hidden; -webkit-user-select: none; user-select: none; } #c { width: 100%; height: 100%; display: block; touch-action: none; -webkit-touch-callout: none; } </style>
        </head>
        <body>
            <canvas id="c"></canvas>
            <script type="importmap">
            { "imports": { "three": "https://unpkg.com/three@0.160.0/build/three.module.js", "three/addons/": "https://unpkg.com/three@0.160.0/examples/jsm/" } }
            </script>
            <script type="module">
            import * as THREE from 'three';
            import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
            import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';

            const canvas = document.getElementById('c');
            const renderer = new THREE.WebGLRenderer({ canvas, alpha: true, antialias: true });
            renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
            renderer.setSize(canvas.clientWidth, canvas.clientHeight);

            const scene = new THREE.Scene();
            const camera = new THREE.PerspectiveCamera(40, canvas.clientWidth / canvas.clientHeight, 0.1, 100);
            camera.position.set(0, 0, 2.2);

            const controls = new OrbitControls(camera, canvas);
            controls.enableDamping = true;
            controls.dampingFactor = 0.05;
            controls.autoRotate = true;
            controls.autoRotateSpeed = 0.8;
            controls.enableRotate = true;
            controls.enablePan = false;
            controls.enableZoom = true;
            controls.minPolarAngle = 0;
            controls.maxPolarAngle = Math.PI;
            controls.minAzimuthAngle = -Infinity;
            controls.maxAzimuthAngle = Infinity;

            const light = new THREE.DirectionalLight(0xffffff, 1.2);
            light.position.set(2, 2, 2);
            scene.add(light);
            scene.add(new THREE.AmbientLight(0xffffff, 0.6));

            // Initial view: orbital tilted back (top farther), slightly rotated left (matches card design).
            const INITIAL_TILT_BACK_RAD = 0.90;
            const INITIAL_ROTATE_LEFT_RAD = 0.90;

            const loader = new GLTFLoader();
            loader.load('\(escaped)', (gltf) => {
                const root = gltf.scene;
                const box = new THREE.Box3().setFromObject(root);
                const center = box.getCenter(new THREE.Vector3());
                const size = box.getSize(new THREE.Vector3());
                const maxDim = Math.max(size.x, size.y, size.z);
                const scale = (1.2 * 1.2) / maxDim;
                root.scale.setScalar(scale);
                root.position.sub(center.multiplyScalar(scale));
                root.rotation.x = INITIAL_TILT_BACK_RAD;
                root.rotation.y = INITIAL_ROTATE_LEFT_RAD;
                scene.add(root);
            }, undefined, (e) => console.warn(e));

            function resize() {
                const w = canvas.clientWidth;
                const h = canvas.clientHeight;
                if (canvas.width !== w || canvas.height !== h) {
                    renderer.setSize(w, h);
                    camera.aspect = w / h;
                    camera.updateProjectionMatrix();
                }
            }

            function animate() {
                requestAnimationFrame(animate);
                resize();
                controls.update();
                renderer.render(scene, camera);
            }
            animate();
            </script>
        </body>
        </html>
        """
    }
}

#if DEBUG
#Preview {
    BohrModel3DView(
        modelURL: URL(string: "https://storage.googleapis.com/search-ar-edu/periodic-table/element_001_hydrogen/element_001_hydrogen.glb")!,
        height: 240
    )
    .padding()
    .background(Color.black.opacity(0.3))
}
#endif
