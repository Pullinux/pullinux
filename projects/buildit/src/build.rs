use libplx::{package::{package_binary_path, Package}, util::{clear_dir, copy_dir_recursive, download_package_source, plx_bin_path, plx_package_path, plx_tmp_path, tar_create, untar_into}};
use anyhow::{Error, Result, bail};
use std::fs;
use std::env;

use crate::utils::{first_subdir, plx_package_source_path, plx_sources_path, run_build};

pub fn build_package(pck : &Package) -> Result<()> {
    println!("Building Package: {} {}", pck.name, pck.version);

    let path = plx_package_path(&pck.name, &pck.version);

    //first make tmp path
    let build_path = plx_tmp_path().join(format!("{}-{}", pck.name, pck.version));
    fs::create_dir_all(&build_path)?;
    clear_dir(&build_path)?;

    env::set_current_dir(&build_path)?;

    let build_file = build_path.join("build.sh");

    let mut run_path = build_path.clone();

    //extract sources..
    if pck.source != "" {
        //TODO: download if not exist...

        let archive = plx_package_source_path(&pck.source);

        if !archive.exists() {
            println!("Downloading source...");
            download_package_source(&pck.source, &plx_sources_path())?;
        }

        println!("Extracting {}", archive.display());
        untar_into(&archive, &build_path)?;

        let subdir = first_subdir(&build_path)?;

        if let Some(sd) = subdir {
            env::set_current_dir(&sd)?;
            run_path = sd;
        }
        
    } else {
        println!("NO SOURCE");
    }

    //copy files
    copy_dir_recursive(&path, &build_path)?;

    let files_path = build_path.join("files");

    if !files_path.exists() {
        fs::create_dir_all(&files_path)?;
    }

    for extra in &pck.extras {
        let file = plx_package_source_path(&extra);

        if !file.exists() {
            println!("Downloading extra {}...", extra);
            download_package_source(&extra, &plx_sources_path())?;
        }

        fs::copy(&file, &files_path.join(extra))?;
    }

    let pckdir = plx_tmp_path().join("inst");
    fs::create_dir_all(&pckdir)?;
    clear_dir(&pckdir)?;

    //then copy install
    if build_path.join("install").exists() {
        copy_dir_recursive(&build_path.join("install"), &pckdir.join(".install"))?;
    }

    //then run build
    if build_file.exists() {
        run_build(&build_file, &run_path)?;
    } else {
        println!("No build file");
    }

    std::fs::remove_dir_all(&build_path)?;

    if pck.name == "base-system" || pck.name == "base-dev" || pck.name == "base-ui" {
        fs::create_dir_all(&pckdir.join("tmp"))?;
        fs::write(pckdir.join("tmp").join(&pck.name), "installed")?;
    }

    //TODO: create package
    if fs::read_dir(&pckdir)?.next().is_none() {
        bail!("No files to package");
    }

    env::set_current_dir(&pckdir)?;

    let pck_bin_path = package_binary_path(&pck);

    println!("Creating install package: {}", pck_bin_path.display());
    tar_create(&pck_bin_path)?;

    std::fs::remove_dir_all(&pckdir)?;

    Ok(())
}

