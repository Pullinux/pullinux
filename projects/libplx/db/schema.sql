PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS packages (
  id        INTEGER PRIMARY KEY,
  name      TEXT    NOT NULL,
  version   TEXT    NOT NULL,
  source    TEXT    NULL,
  latest    INTEGER NOT NULL DEFAULT 1,
  UNIQUE (name, version)
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_packages_latest
    ON packages(name)
    WHERE latest = 1;

CREATE TABLE IF NOT EXISTS package_extras (
  package_id INTEGER NOT NULL,
  extra      TEXT    NOT NULL,
  PRIMARY KEY (package_id, extra),
  FOREIGN KEY (package_id) REFERENCES packages(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS package_dependencies (
  id         INTEGER PRIMARY KEY,
  package_id INTEGER NOT NULL,
  dep_package_id INTEGER NOT NULL,
  dep_type   TEXT    NOT NULL CHECK (dep_type IN ('Runtime', 'Build')),
  FOREIGN KEY (package_id) REFERENCES packages(id) ON DELETE CASCADE,
  FOREIGN KEY (dep_package_id) REFERENCES packages(id) ON DELETE CASCADE,
  UNIQUE (package_id, dep_package_id, dep_type)
);

CREATE TABLE IF NOT EXISTS installed_packages (
    package_id INTEGER NOT NULL,
    PRIMARY KEY (package_id)
);

CREATE INDEX IF NOT EXISTS idx_packages_name ON packages(name);
CREATE INDEX IF NOT EXISTS idx_deps_pkg ON package_dependencies(package_id);
CREATE INDEX IF NOT EXISTS idx_extras_pkg ON package_extras(package_id);
