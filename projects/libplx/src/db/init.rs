use anyhow::Result;
use std::path::{Path, PathBuf};
use rusqlite::{params, OptionalExtension, Connection, Transaction};
use std::fs::File;
use std::io::{BufRead, BufReader};
use std::io;

use crate::util::{copy_dir_recursive, copy_file_if_exists, list_directories, plx_bin_path, plx_db_path};

pub fn plx_db_init() -> Result<()> {
    let db_path = Path::new(&plx_db_path()).join("plx.db");
    let mut conn = Connection::open(db_path)?;
    let tx = conn.transaction()?; // batch DB ops safely

    let dirs = list_directories("/home/rpulley/git/pullinux/build/packages")?;
    
    for d in dirs {
        if let Some(name) = d.file_name() {
            let pck_dirs = list_directories(&d)?;
        
            for pck_dir in pck_dirs {
                if let Some(pck_name) = pck_dir.file_name() {
                    println!("{} - {}", name.to_string_lossy(), pck_name.to_string_lossy());

                    db_add_package(&tx, name.to_string_lossy().as_ref(), pck_name.to_string_lossy().as_ref())?;
                }
            }
        }
    }

    tx.commit()?;

    Ok(())
}

fn db_add_package(tx: &Transaction, letter : &str, pck_name : &str) -> Result<()>  {
    let pck_file = Path::new("/home/rpulley/git/pullinux/build/packages").join(letter).join(pck_name).join("pck");
    let extras_file = Path::new("/home/rpulley/git/pullinux/build/packages").join(letter).join(pck_name).join("extras.lst");
    let extras = load_extras(&extras_file)?;
    let (name, version, source) = load_pck_file(&pck_file)?;

    println!("name: {name}, version: {version}, source: {source}");

    tx.execute(
        r#"
        INSERT INTO packages(name, version, source, latest)
        VALUES (?1, ?2, ?3, 0)
        ON CONFLICT(name, version) DO UPDATE
            SET source = excluded.source
        "#,
        params![name, version, source],
    )?;

    let pkg_id: i64 = tx.query_row(
        "SELECT id FROM packages WHERE name = ?1 AND version = ?2",
        params![name, version],
        |row| row.get(0),
    )?;

    tx.execute(
        "DELETE FROM package_extras WHERE package_id = ?1",
        params![pkg_id],
    )?;

    if !extras.is_empty() {
        let mut stmt = tx.prepare(
            "INSERT INTO package_extras(package_id, extra) VALUES (?1, ?2)"
        )?;
        for extra in extras {
            stmt.execute(params![pkg_id, extra])?;
        }
    }

    let build_file = Path::new("/home/rpulley/git/pullinux/build/packages").join(letter).join(pck_name).join("build.sh");
    let files_path = Path::new("/home/rpulley/git/pullinux/build/packages").join(letter).join(pck_name).join("files");
    let install_path = Path::new("/home/rpulley/git/pullinux/build/packages").join(letter).join(pck_name).join("install");

    let dest_path = Path::new("/usr/share/plx/packages").join(letter).join(format!("{}-{}", pck_name, version));

    copy_file_if_exists(&build_file, &dest_path.join("build.sh"))?;
    copy_dir_recursive(&files_path, &dest_path.join("files"))?;
    copy_dir_recursive(&install_path, &dest_path.join("install"))?;

    Ok(())
}

fn load_pck_file(path: &Path) -> std::io::Result<(String, String, String)> {
    let file = File::open(path)?;
    let reader = BufReader::new(file);

    let mut name = String::new();
    let mut version = String::new();
    let mut source = String::new();

    for line in reader.lines() {
        let line = line?; // Result<String, io::Error>
        if let Some((key, value)) = line.split_once('=') {
            match key {
                "name" => name = value.to_string(),
                "version" => version = value.to_string(),
                "source" => source = value.to_string(),
                _ => {}
            }
        }
    }

    Ok((name, version, source))
}

fn load_extras(path: &Path) -> io::Result<Vec<String>> {
    match File::open(path) {
        Ok(file) => {
            let reader = BufReader::new(file);
            let mut extras = Vec::new();
            for line in reader.lines() {
                let line = line?;
                let trimmed = line.trim();
                if !trimmed.is_empty() {
                    extras.push(trimmed.to_string());
                }
            }
            Ok(extras)
        }
        Err(e) if e.kind() == io::ErrorKind::NotFound => Ok(Vec::new()), // missing file → empty vec
        Err(e) => Err(e), // real error bubbles up
    }
}

fn parse_deps(dep_str: &str) -> Vec<(String, Option<String>)> {
    dep_str
        .split(',')                       // split on commas
        .filter(|s| !s.trim().is_empty()) // skip empties
        .map(|s| {
            let mut parts = s.splitn(2, ':'); // split at first colon, at most 2 parts
            let name = parts.next().unwrap().trim().to_string();
            let version = parts.next().map(|v| v.trim().to_string());
            (name, version)
        })
        .collect()
}

pub fn plx_add_deps(package : &str, dep_str : &str) -> Result<()> {

    let db_path = Path::new(&plx_db_path()).join("plx.db");
    let mut conn = Connection::open(db_path)?;
    let tx = conn.transaction()?;

    let pkg_id: i64 = tx.query_row(
        "SELECT id FROM packages WHERE name = ?1",
        params![package],
        |row| row.get(0),
    )?;

    println!("Package: {}", pkg_id);

    let deps = parse_deps(dep_str);

    for (name, dep_type) in deps {
        let find_query = "select id from packages where name = ?1".to_string();
        let mut dt = "Runtime".to_string();
        
        match dep_type {
            Some(v) => {
                if v == "b" {
                    dt = "Build".to_string();
                }
            },
            _ => {
                
            },
        }

        let dep_id: i64 = tx.query_row(
            &find_query,
            params![name],
            |row| row.get(0),
        )?;

        let circular_id: Option<i64> = tx.query_row(
            "SELECT id FROM package_dependencies WHERE package_id = ?1 and dep_package_id = ?2",
            params![dep_id, pkg_id],
            |row| row.get(0),
        ).optional()?;

        if let Some(id) = circular_id {
            panic!("Cannot add circular dependency: {} - {} ({})", name, package, id);
        }

        let mut stmt = tx.prepare(
            "INSERT INTO package_dependencies(package_id, dep_package_id, dep_type) VALUES (?1, ?2, ?3)"
        )?;

        stmt.execute(params![pkg_id, dep_id, dt])?;

        println!("Dep added to {}", dep_id);
        
    }

    tx.commit()?;

    Ok(())
}

