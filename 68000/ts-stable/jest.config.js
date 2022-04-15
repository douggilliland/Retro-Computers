module.exports = {
    transform: {
        '^.+\\.tsx?$': 'ts-jest',
    },
    'testRegex': '^.*.test.tsx?$',
    testPathIgnorePatterns: ['/lib/', '/node_modules/'],
    moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
    collectCoverage: true,
    'coverageThreshold': {
        'global': {
            'statements': 60,
            'branches': 35,
            'functions': 55,
            'lines': 60
        }
    },
    'collectCoverageFrom': [
        'src/**/*.{ts,tsx}',
        '!**/node_modules/**',
        '!**/coverage/**',
    ],
};
