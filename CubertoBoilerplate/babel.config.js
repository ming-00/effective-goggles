const presets = [
    [
        "@babel/env",
        {
            //"corejs": 2,
            //"useBuiltIns": "usage",
            "exclude": ["transform-async-to-generator", "transform-regenerator"]
        }
    ]
];

const plugins = [
    [
        "module:fast-async",
        {
            "spec": true
        }
    ]
];

module.exports = {presets, plugins, "sourceType": "unambiguous"};
