module.exports = {
    include: ["**/*.spec.ts"],
    add: ["**/*.include.ts"],
    flags: {
        "--runtime": ["stub"],
        "--lib": ["node_modules","src"]
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
        reportMax: false,
        reportMin: false,
    },
    wasi: {
      args: [],
      env: process.env,
      preopens: {},
      returnOnExit: false,
    },
    outputBinary: false,
};
