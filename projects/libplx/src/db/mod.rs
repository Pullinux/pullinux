pub mod init;

use anyhow::{bail, Result};
use rusqlite::{params, Connection};
use std::path::{Path, PathBuf};
use std::collections::HashSet;

use crate::{package::{DepType, DependencyInfo, Package}, util::plx_db_path};

/// Load an exact (name, version).
pub fn plx_find_package_version(name: &str, version: &str) -> Result<Package> {
    let db_path = Path::new(&plx_db_path()).join("plx.db");
    let conn = Connection::open(db_path)?;

    // 1) fetch package row → (id, source)
    let (pkg_id, source_opt): (i64, Option<String>) = conn.query_row(
        "SELECT id, source FROM packages WHERE name = ?1 AND version = ?2",
        rusqlite::params![name, version],
        |row| Ok((row.get(0)?, row.get::<_, Option<String>>(1)?)),
    )?;

    let source = source_opt.unwrap_or_default(); 

    // 2) extras
    let extras: Vec<String> = {
        let mut st = conn.prepare(
            "SELECT extra FROM package_extras WHERE package_id = ?1 ORDER BY extra",
        )?;
        let rows = st.query_map(params![pkg_id], |r| r.get::<_, String>(0))?;
        rows.collect::<rusqlite::Result<Vec<_>>>()?
    };

    // 3) dependencies
    let dependencies: Vec<DependencyInfo> = {
        let mut st = conn.prepare(
            "SELECT pck.name, pck.version, dep.dep_type FROM package_dependencies dep inner join packages pck on pck.id = dep.dep_package_id
             WHERE package_id = ?1
             ORDER BY name, version",
        )?;
        let rows = st.query_map(params![pkg_id], |r| {
            Ok((
                r.get::<_, String>(0)?, // name
                r.get::<_, String>(1)?, // version
                r.get::<_, String>(2)?, // dep_type text
            ))
        })?;

        let mut deps = Vec::new();
        for row in rows {
            let (n, v, t) = row?;
            let dep_type = match t.as_str() {
                "Runtime" | "runtime" => DepType::Runtime,
                "Build"   | "build"   => DepType::Build,
                other => bail!("unknown dep_type: {other}"),
            };
            deps.push(DependencyInfo { name: n, version: v, dep_type });
        }
        deps
    };

    Ok(Package {
        name: name.to_string(),
        version: version.to_string(),
        source,
        extras,
        dependencies,
        id: pkg_id
    })
}

/// Convenience: load the “latest” version by package name (uses `latest` flag if present).
pub fn plx_find_package(name: &str) -> Result<Package> {
    let db_path = Path::new(&plx_db_path()).join("plx.db");
    let conn = Connection::open(db_path)?;

    let version: String = conn.query_row(
        "SELECT version FROM packages
        WHERE name = ?1
        ORDER BY latest DESC, id DESC
        LIMIT 1",
        rusqlite::params![name],
        |row| row.get(0),
    )?;

    plx_find_package_version(name, &version)
}

// visits deps of `pkg_name`, pushes each package once AFTER its own deps
fn dfs_dep_order(
    pkg_name: &str,
    out: &mut Vec<String>,
    visiting: &mut HashSet<String>,
    visited: &mut HashSet<String>,
) -> Result<(), Box<dyn std::error::Error>> {

    let pck = plx_find_package(pkg_name)?; // your function returning Package

    if plx_package_installed(&pck.name)? {
        return Ok(());
    }
    
    if visited.contains(pkg_name) { return Ok(()); }
    if !visiting.insert(pkg_name.to_string()) {
        return Err(format!("dependency cycle detected at {pkg_name}").into());
    }

    for dep in pck.dependencies {
        // If you only want required/runtime deps:
        // if dep.dep_type != DepType::Runtime { continue; }
        dfs_dep_order(&dep.name, out, visiting, visited)?;
    }

    visiting.remove(pkg_name);
    visited.insert(pkg_name.to_string());
    out.push(pkg_name.to_string()); // parent after children
    Ok(())
}

// public helper: collect ALL deps of `name`, but not `name` itself
pub fn plx_find_all_dependencies(name: &str) -> Result<Vec<String>, Box<dyn std::error::Error>> {
    let mut out = Vec::new();
    let mut visiting = HashSet::new();
    let mut visited  = HashSet::new();

    // call DFS on each direct dependency, so `name` itself isn't added
    let root = plx_find_package(name)?;
    for dep in root.dependencies {
        // if dep.dep_type != DepType::Runtime { continue; }
        dfs_dep_order(&dep.name, &mut out, &mut visiting, &mut visited)?;
    }

    Ok(out)
}

pub fn plx_package_installed(name: &str) -> Result<bool> {
    let db_path = Path::new(&plx_db_path()).join("plx.db");
    let conn = Connection::open(db_path)?;

    let pck = plx_find_package(name)?;

    let exists: bool = conn.query_row(
        "SELECT EXISTS(SELECT 1 FROM installed_packages WHERE package_id = ?1)",
        params![pck.id],
        |row| row.get(0),
    )?;

    Ok(exists)
}

pub fn plx_package_mark_installed(name: &str) -> Result<()> {
    let db_path = Path::new(&plx_db_path()).join("plx.db");
    let mut conn = Connection::open(db_path)?;
    let tx = conn.transaction()?;

    {
        let pkg_id: i64 = tx.query_row(
            "SELECT id FROM packages WHERE name = ?1",
            params![name],
            |row| row.get(0),
        )?;

        let mut stmt = tx.prepare(
            "INSERT INTO installed_packages(package_id) VALUES (?1)"
        )?;

        stmt.execute(params![pkg_id])?;
    }

    tx.commit()?;
    
    Ok(())
}