module.exports = {
  branches: ["main"],
  plugins: [
    [
      "@semantic-release/commit-analyzer",
      {
        preset: "conventionalcommits",
      },
    ],
    [
      "@semantic-release/release-notes-generator",
      {
        preset: "conventionalcommits",
      },
    ],
    [
      "@semantic-release/changelog",
      {
        changelogTitle: "# Changelog",
      },
    ],
    [
      "semantic-release-replace-plugin",
      {
        replacements: [
          {
            files: ["build.lua"],
            from: 'version = "([0-9]+\\.[0-9]+\\.[0-9]+)"',
            to: 'version = "${nextRelease.version}"',
            results: [
              {
                file: "build.lua",
                hasChanged: true,
                numMatches: 1,
                numReplacements: 1,
              },
            ],
            countMatches: true,
          },
          {
            files: ["src/cvd.dtx"],
            from: /\\ProvidesPackage\{([^\}]+)\}\[\d{4}-\d{2}-\d{2} v([0-9]+\.[0-9]+\.[0-9]+) ([^\]]+)\]/g,
            to: (_match, pkg, _version, desc, ...args) => {
              const context = args[args.length - 1];
              const { execSync } = require("child_process");
              const date = execSync(
                `git show -s --format=%cs ${context.nextRelease.gitHead}`,
              )
                .toString()
                .trim();
              return `\\ProvidesPackage{${pkg}}[${date} v${context.nextRelease.version} ${desc}]`;
            },
            results: [
              {
                file: "src/cvd.dtx",
                hasChanged: true,
                numMatches: 1,
                numReplacements: 1,
              },
            ],
            countMatches: true,
          },
        ],
      },
    ],
    [
      "@semantic-release/git",
      {
        message:
          "chore(release): release ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}",
        assets: ["src/cvd.dtx", "build.lua", "CHANGELOG.md"],
      },
    ],
    "@semantic-release/github",
  ],
};
