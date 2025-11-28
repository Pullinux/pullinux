use std::env;
use std::fs;
use std::path::{Path, PathBuf};
use std::io;
use std::process::Command;

pub const PLX_PATH: &str = "usr/share/plx";

pub const PLX_SOURCES_URL: &str = "https://github.com/Pullinux/pullinux/releases/download/1.2-sources/";

pub fn plx_root() -> PathBuf {
    match env::var_os("PLX_ROOT") {
        Some(v) if !v.is_empty() => PathBuf::from(v),
        _ => PathBuf::from("/"),
    }
}

pub fn plx_share_path() -> PathBuf {
    plx_root().join(PLX_PATH)
}

pub fn plx_bin_path() -> PathBuf {
    plx_share_path().join("bin")
}

pub fn plx_tmp_path() -> PathBuf {
    plx_share_path().join("tmp")
}

pub fn plx_db_path() -> PathBuf {
    plx_share_path().join("db")
}

pub fn plx_packages_path() -> PathBuf {
    plx_share_path().join("packages")
}

pub fn plx_package_path(name: &str, version: &str) -> PathBuf {
    let letter = name.chars().next().unwrap_or('_').to_ascii_lowercase().to_string();

    let db_path = Path::new(&plx_packages_path()).join(&letter).join(format!("{}-{}", name, version));

    return db_path;
}

pub fn list_directories<P: AsRef<Path>>(path: P) -> std::io::Result<Vec<PathBuf>> {
    let mut dirs = Vec::new();

    for entry in fs::read_dir(path)? {
        let entry = entry?;
        let path = entry.path();
        if path.is_dir() {
            dirs.push(path);
        }
    }

    Ok(dirs)
}

pub fn copy_dir_recursive(src: &Path, dst: &Path) -> std::io::Result<()> {
    if !src.exists() {
        // nothing to do if source is missing
        return Ok(());
    }

    // Ensure destination root exists
    fs::create_dir_all(dst)?;

    for entry in fs::read_dir(src)? {
        let entry = entry?;
        let file_type = entry.file_type()?;
        let src_path = entry.path();
        let dst_path = dst.join(entry.file_name());

        if file_type.is_dir() {
            copy_dir_recursive(&src_path, &dst_path)?;
        } else if file_type.is_file() {
            fs::copy(&src_path, &dst_path)?;
        } else {
            // Skip symlinks or special files
        }
    }

    Ok(())
}

pub fn copy_file_if_exists(src: &Path, dst: &Path) -> std::io::Result<()> {
    if src.exists() && src.is_file() {
        if let Some(parent) = dst.parent() {
            fs::create_dir_all(parent)?; // make sure destination dir exists
        }
        fs::copy(src, dst)?;
    }
    Ok(())
}

pub fn clear_dir(path: &Path) -> std::io::Result<()> {
    if !path.exists() {
        return Ok(());
    }
    for entry in fs::read_dir(path)? {
        let entry = entry?;
        let p = entry.path();
        if p.is_dir() {
            fs::remove_dir_all(&p)?;
        } else {
            fs::remove_file(&p)?;
        }
    }
    Ok(())
}

pub fn untar_into(archive: &Path, dest: &Path) -> io::Result<()> {
    std::fs::create_dir_all(dest)?; // ensure destination exists

    let status = Command::new("tar")
        // -x = extract, -h = follow symlinks, -f <archive>
        .args(["-x", "-h", "-f"])
        .arg(archive)              // Path works directly; no need to stringify
        .current_dir(dest)         // extract into this directory
        .status()?;

    if status.success() {
        Ok(())
    } else {
        Err(io::Error::new(io::ErrorKind::Other, format!("tar failed: {status}")))
    }
}

pub fn tar_create(archive: &Path) -> io::Result<()> {
    let status = Command::new("tar")
        .args(["-c", "-J", "-p", "-f"])
        .arg(archive)
        .arg(".")
        .status()?;

    if status.success() {
        Ok(())
    } else {
        Err(io::Error::new(io::ErrorKind::Other, format!("tar creation failed: {status}")))
    }
}

pub fn run_script(script: &Path, run_path: &Path) -> io::Result<()> {

    let status = Command::new("bash")
        .arg("-e")
        .arg("-l")
        .arg("-c")
        .arg(format!("bash -e {}", script.display()))
        .current_dir(&run_path)
        .status()?;

    if status.success() {
        Ok(())
    } else {
        Err(io::Error::new(io::ErrorKind::Other, format!("build failed: {status}")))
    }
}

pub fn download_package_source(source : &str, run_path: &Path) -> io::Result<()> {
    let file = format!("{}{}", PLX_SOURCES_URL, source);

    println!("Downloading {} ...", file);

    let status = Command::new("wget")
        .arg("-q")
        .arg(file)
        .current_dir(&run_path)
        .status()?;

    if status.success() {
        Ok(())
    } else {
        Err(io::Error::new(io::ErrorKind::Other, format!("build failed: {status}")))
    }
}
