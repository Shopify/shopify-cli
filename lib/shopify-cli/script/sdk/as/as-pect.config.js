module.exports = {
    include: ["**/*.spec.ts"],
    add: ["**/*.include.ts"],
    flags: {
        "--runtime": ["stub"],
        "--lib": ["node_modules"]
    },
    disclude: [/node_modules/],
    imports: {},
    performance: {
        enabled: false,
        maxSamples: 10000,
        maxTestRunTime: 5000,
        reportMedian: true,
        reportAverage: true,
        reportStandardDeviation: false,
        reportMax: true,
        reportMin: true,
    },
    outputBinary: false,
};
