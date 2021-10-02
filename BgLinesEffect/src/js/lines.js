import * as THREE from 'three';

const vertexShader = `
    uniform sampler2D data;
    uniform float time;
    uniform float scroll;
    uniform float speed;
    uniform float segments;
    uniform float intensity;
    varying float vPos;
    void main() {
        vec4 pos = modelMatrix * vec4(position, 1.);
        vPos = pos.x;
        float func1 = sin((pos.y - scroll / (947. / 2000.)) * (segments * 0.001)) * (1. + intensity * sin(time * speed));
        float func2 = cos((pos.y - scroll / (947. / 2000.)) * (segments * 0.001)) * (1. + intensity * cos(time * speed));
        pos.x += mix(func1, func2, (pos.x + 10.) / 20. * sin(time * speed));
        float coordY = scroll / 2896. + (1000. - pos.y) / 2000. * 947. / 2896.;
        vec4 rgba = texture2D(data, vec2(.5, coordY));
        float k2 = 2. - smoothstep(0., 10., abs(pos.x));
        float offset = rgba.r * 1000. * k2;
        pos.x += offset;
        gl_Position = projectionMatrix * viewMatrix * pos;
    }      
`;

const fragmentShader = `
    uniform vec4 color;
    void main() {
        gl_FragColor = color;
    }
`;

export default class Lines {
    constructor(canvas, options) {
        const width = window.innerWidth;
        const height = window.innerHeight;

        this.options = Object.assign({}, {
            color: [0.82, 0.86, 0.88, 1],
            speed: 0.7,
            density: 0.6,
            lines: 20,
            scale: 15,
            position: 0,
            segments: 2,
            intensity: 10
        }, options);

        this.renderer = new THREE.WebGLRenderer({canvas: canvas, antialias: true, alpha: true});
        this.renderer.setPixelRatio(window.devicePixelRatio);
        this.renderer.setSize(width, height);
        this.camera = new THREE.OrthographicCamera(-width / this.options.scale - (width * this.options.position / 10), width / this.options.scale - (width * this.options.position / 10), 1000, -1000, 1, 100);
        this.scene = new THREE.Scene();
        this.clock = new THREE.Clock();
        this.time = this.clock.getElapsedTime();

        this.texture = new THREE.WebGLRenderTarget(16, height, {type: THREE.FloatType});
        this.material = new THREE.ShaderMaterial({
            uniforms: {
                data: {value: this.texture.texture},
                time: {value: this.time},
                scroll: {value: 0},
                color: {value: new THREE.Vector4(...this.options.color)},
                speed: {value: this.options.speed},
                segments: {value: this.options.segments},
                intensity: {value: this.options.intensity},
            },
            vertexShader: vertexShader,
            fragmentShader: fragmentShader
        });

        for (let x = -(this.options.lines / 2); x < (this.options.lines / 2); x += this.options.density) {
            const vertices = [];
            const indices = [0];
            let index = 0;
            for (let y = 1000; y > -1000; y--) {
                vertices.push(x, y, -30);
                indices.push(++index);
                indices.push(index);
            }
            for (let i = 0; i < 3; i++) indices.pop();
            const geometry = new THREE.BufferGeometry();
            geometry.setAttribute('position', new THREE.BufferAttribute(new Float32Array(vertices), 3));
            geometry.setIndex(new THREE.BufferAttribute(new Uint16Array(indices), 1));
            const mesh = new THREE.LineSegments(geometry, this.material);
            this.scene.add(mesh);
        }

        window.addEventListener('resize', () => this.setSizes(), false);

        this.render();
    }

    setSizes() {
        const width = window.innerWidth;
        const height = window.innerHeight;

        this.camera.left = -width / this.options.scale - (width * this.options.position / 10);
        this.camera.right = width / this.options.scale - (width * this.options.position / 10);
        this.renderer.setSize(width, height);
        this.camera.updateProjectionMatrix();
    }

    render() {
        this.material.uniforms.time.value = this.time;
        this.renderer.render(this.scene, this.camera);
        this.time += this.clock.getDelta();
        window.requestAnimationFrame(this.render.bind(this));
    }
}
